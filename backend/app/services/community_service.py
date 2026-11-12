import json
import logging
import os
import sqlite3
import uuid
from datetime import datetime
from typing import Any, Dict, List, Optional

from app.config import settings
from app.services.supabase_service import SupabaseService

logger = logging.getLogger("chiptocrop.community_service")

# Server-side local mirror SQLite database for fast response & seamless fallback
DB_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "community.db")


class CommunityService:
    @classmethod
    def _get_local_db(cls) -> sqlite3.Connection:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        with conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS community_posts (
                    id TEXT PRIMARY KEY,
                    farmer_id TEXT,
                    farmer_name TEXT NOT NULL,
                    farmer_phone TEXT NOT NULL,
                    crop_type TEXT,
                    title TEXT NOT NULL,
                    description TEXT NOT NULL,
                    image_url TEXT,
                    likes_count INTEGER DEFAULT 0,
                    created_at TEXT NOT NULL
                )
            """)
            # Ensure fake seed posts are completely wiped
            conn.execute("DELETE FROM community_posts WHERE id LIKE 'post-seed%'")
        return conn

    @classmethod
    def upload_post_image(cls, image_bytes: bytes, filename: str) -> Optional[str]:
        """
        Uploads community crop photo to Supabase Storage bucket 'community-media'.
        Returns the public accessible URL.
        """
        try:
            client = SupabaseService.get_client()
            ext = os.path.splitext(filename)[1] or ".jpg"
            unique_filename = f"post_{uuid.uuid4().hex[:12]}{ext}"
            storage_path = f"images/{unique_filename}"

            client.storage.from_("community-media").upload(
                path=storage_path,
                file=image_bytes,
                file_options={"content-type": "image/jpeg", "upsert": "true"},
            )

            # Generate public URL
            clean_url = (
                settings.supabase_url.split("/rest/v1")[0]
                .split("/storage/v1")[0]
                .rstrip("/")
            )
            public_url = f"{clean_url}/storage/v1/object/public/community-media/{storage_path}"
            logger.info(f"Uploaded community image to Supabase Storage: {public_url}")
            return public_url
        except Exception as e:
            logger.error(f"Failed to upload image to Supabase Storage: {e}")
            return None

    @classmethod
    def create_post(
        cls,
        farmer_name: str,
        farmer_phone: str,
        title: str,
        description: str,
        crop_type: Optional[str] = None,
        image_bytes: Optional[bytes] = None,
        image_filename: Optional[str] = None,
        farmer_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Creates a new community post, uploads image to Supabase Storage,
        and saves the record in Supabase & local mirror.
        """
        post_id = str(uuid.uuid4())
        created_at = datetime.utcnow().isoformat()
        image_url = None

        if image_bytes:
            image_url = cls.upload_post_image(
                image_bytes, image_filename or f"{post_id}.jpg"
            )

        post_data = {
            "id": post_id,
            "farmer_id": farmer_id or "",
            "farmer_name": farmer_name,
            "farmer_phone": farmer_phone,
            "crop_type": crop_type or "General",
            "title": title,
            "description": description,
            "image_url": image_url or "",
            "likes_count": 0,
            "created_at": created_at,
        }

        # 1. Save to Supabase Storage post backup
        try:
            client = SupabaseService.get_client()
            post_json = json.dumps(post_data).encode("utf-8")
            client.storage.from_("community-media").upload(
                path=f"posts/{post_id}.json",
                file=post_json,
                file_options={"content-type": "application/json", "upsert": "true"},
            )
            logger.info(f"Saved post {post_id} to Supabase Storage posts/{post_id}.json")
        except Exception as e:
            logger.warning(f"Could not backup post JSON to Supabase storage: {e}")

        # 2. Try inserting into Supabase community_posts table (if exists)
        try:
            client = SupabaseService.get_client()
            client.table("community_posts").insert(post_data).execute()
            logger.info(f"Saved post {post_id} to Supabase community_posts table")
        except Exception as e:
            logger.info(
                f"Supabase community_posts table note: {e}, post saved in Supabase storage & local mirror."
            )

        # 3. Always mirror to local SQLite DB for instant fast retrieval
        conn = cls._get_local_db()
        with conn:
            conn.execute(
                """
                INSERT INTO community_posts 
                (id, farmer_id, farmer_name, farmer_phone, crop_type, title, description, image_url, likes_count, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
                (
                    post_id,
                    post_data["farmer_id"],
                    post_data["farmer_name"],
                    post_data["farmer_phone"],
                    post_data["crop_type"],
                    post_data["title"],
                    post_data["description"],
                    post_data["image_url"],
                    post_data["likes_count"],
                    post_data["created_at"],
                ),
            )

        return post_data

    @classmethod
    def get_posts(cls, crop_type: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Retrieves all authentic community posts (latest first).
        First queries Supabase community_posts table; then syncs from Supabase Storage;
        mirrors to local SQLite database. Absolutely no fake/mock posts.
        """
        # Try Supabase DB table first
        try:
            client = SupabaseService.get_client()
            query = client.table("community_posts").select("*").order("created_at", desc=True)
            if crop_type and crop_type.lower() != "all":
                query = query.ilike("crop_type", f"%{crop_type}%")
            res = query.execute()
            if res.data:
                # Filter out any lingering seed records if any
                return [p for p in res.data if not str(p.get("id", "")).startswith("post-seed")]
        except Exception as e:
            logger.debug(f"Querying Supabase community_posts fallback: {e}")

        # Sync from Supabase Cloud Storage (where posts are permanently stored as JSON)
        try:
            client = SupabaseService.get_client()
            storage_files = client.storage.from_("community-media").list("posts")
            if storage_files:
                conn = cls._get_local_db()
                with conn:
                    for sf in storage_files:
                        fname = sf.get("name", "")
                        if fname.endswith(".json") and not fname.startswith("post-seed"):
                            post_id = fname[:-5]
                            cur = conn.cursor()
                            cur.execute("SELECT id FROM community_posts WHERE id = ?", (post_id,))
                            if not cur.fetchone():
                                try:
                                    content = client.storage.from_("community-media").download(f"posts/{fname}")
                                    p_data = json.loads(content.decode("utf-8"))
                                    conn.execute("""
                                        INSERT OR REPLACE INTO community_posts
                                        (id, farmer_id, farmer_name, farmer_phone, crop_type, title, description, image_url, likes_count, created_at)
                                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                                    """, (
                                        p_data.get("id", post_id),
                                        p_data.get("farmer_id", ""),
                                        p_data.get("farmer_name", "Farmer"),
                                        p_data.get("farmer_phone", ""),
                                        p_data.get("crop_type", "General"),
                                        p_data.get("title", ""),
                                        p_data.get("description", ""),
                                        p_data.get("image_url", ""),
                                        p_data.get("likes_count", 0),
                                        p_data.get("created_at", datetime.utcnow().isoformat())
                                    ))
                                except Exception as dl_err:
                                    logger.warning(f"Error downloading post {fname} from Supabase: {dl_err}")
        except Exception as st_err:
            logger.warning(f"Error syncing Supabase storage posts: {st_err}")

        # Query local SQLite mirror
        conn = cls._get_local_db()
        cursor = conn.cursor()
        if crop_type and crop_type.lower() != "all":
            cursor.execute(
                "SELECT * FROM community_posts WHERE crop_type LIKE ? AND id NOT LIKE 'post-seed%' ORDER BY created_at DESC",
                (f"%{crop_type}%",),
            )
        else:
            cursor.execute("SELECT * FROM community_posts WHERE id NOT LIKE 'post-seed%' ORDER BY created_at DESC")

        rows = cursor.fetchall()
        return [dict(row) for row in rows]

    @classmethod
    def like_post(cls, post_id: str) -> int:
        """Increments like count for a post."""
        conn = cls._get_local_db()
        with conn:
            conn.execute(
                "UPDATE community_posts SET likes_count = likes_count + 1 WHERE id = ?",
                (post_id,),
            )
            cursor = conn.cursor()
            cursor.execute(
                "SELECT likes_count FROM community_posts WHERE id = ?", (post_id,)
            )
            row = cursor.fetchone()
            count = row[0] if row else 1

        # Also attempt update in Supabase Table
        try:
            client = SupabaseService.get_client()
            client.table("community_posts").update({"likes_count": count}).eq(
                "id", post_id
            ).execute()
        except Exception:
            pass

        # Also attempt update in Supabase Storage JSON backup
        try:
            client = SupabaseService.get_client()
            content = client.storage.from_("community-media").download(f"posts/{post_id}.json")
            if content:
                p_data = json.loads(content.decode("utf-8"))
                p_data["likes_count"] = count
                updated_json = json.dumps(p_data).encode("utf-8")
                client.storage.from_("community-media").update(
                    path=f"posts/{post_id}.json",
                    file=updated_json,
                    file_options={"content-type": "application/json", "upsert": "true"},
                )
        except Exception:
            pass

        return count
