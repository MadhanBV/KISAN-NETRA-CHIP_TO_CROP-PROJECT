import logging
from typing import Optional

from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status

from app.services.community_service import CommunityService

logger = logging.getLogger("chiptocrop.community_routes")

router = APIRouter(prefix="/community", tags=["Community"])


@router.get("/posts")
def get_community_posts(crop_type: Optional[str] = None):
    """Retrieves all community posts, optionally filtered by crop type."""
    try:
        posts = CommunityService.get_posts(crop_type=crop_type)
        return {
            "success": True,
            "count": len(posts),
            "posts": posts,
        }
    except Exception as e:
        logger.error(f"Error fetching community posts: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch community posts: {str(e)}",
        )


@router.post("/posts")
async def create_community_post(
    title: str = Form(...),
    description: str = Form(...),
    crop_type: str = Form("General"),
    farmer_name: str = Form("Farmer"),
    farmer_phone: str = Form(""),
    farmer_id: Optional[str] = Form(None),
    image: Optional[UploadFile] = File(None),
):
    """
    Creates a new farmer community post.
    Saves image to Supabase Storage ('community-media' bucket)
    and saves post record in Supabase / SQLite.
    """
    try:
        image_bytes = None
        image_filename = None
        if image:
            image_bytes = await image.read()
            image_filename = image.filename

        post = CommunityService.create_post(
            farmer_name=farmer_name,
            farmer_phone=farmer_phone,
            title=title,
            description=description,
            crop_type=crop_type,
            image_bytes=image_bytes,
            image_filename=image_filename,
            farmer_id=farmer_id,
        )

        return {
            "success": True,
            "message": "Community post created successfully.",
            "post": post,
        }
    except Exception as e:
        logger.error(f"Error creating community post: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create community post: {str(e)}",
        )


@router.post("/posts/{post_id}/like")
def like_community_post(post_id: str):
    """Increments like count for a community post."""
    try:
        likes = CommunityService.like_post(post_id)
        return {
            "success": True,
            "post_id": post_id,
            "likes_count": likes,
        }
    except Exception as e:
        logger.error(f"Error liking post {post_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to like post: {str(e)}",
        )

