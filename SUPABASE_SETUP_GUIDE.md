# CHIP TO CROP — Supabase Integration Setup Guide

This guide details how to configure Supabase for the **CHIP TO CROP** authentication module, connecting the PostgreSQL database (`public.farmers`) and private Storage (`farmer-faces`) with the Python FastAPI backend.

---

## 1. Supabase Project Credentials

1. Open your [Supabase Dashboard](https://supabase.com/dashboard).
2. Select your **CHIP TO CROP** project.
3. In the left navigation, click **Project Settings** (gear icon) → **API**.
4. Locate your **Project URL**:
   ```
   https://<your-project-ref>.supabase.co
   ```
5. Under **Project API keys**, locate the **`service_role` (Secret)** key:
   > [!WARNING]
   > The `service_role` secret key has full administrative access and bypasses Row Level Security.
   > **NEVER expose this key in the Flutter application, public repositories, or client code.**
   > It must only be configured in `backend/.env`.

---

## 2. PostgreSQL Database Table (`public.farmers`)

The `public.farmers` table holds farmer account records. Verify or create the table structure in the **SQL Editor**:

```sql
CREATE TABLE IF NOT EXISTS public.farmers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    face_image_path TEXT NOT NULL,
    biometric_consent BOOLEAN NOT NULL DEFAULT true,
    consent_timestamp TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    account_status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.farmers ENABLE ROW LEVEL SECURITY;

-- Index phone_number for rapid lookups
CREATE INDEX IF NOT EXISTS idx_farmers_phone ON public.farmers(phone_number);
```

---

## 3. Private Storage Bucket (`farmer-faces`)

The biometric face reference images are stored securely in a private storage bucket:

1. In Supabase Dashboard, navigate to **Storage** in the left sidebar.
2. Ensure the bucket is named:
   ```
   farmer-faces
   ```
3. Set the bucket privacy:
   - **Public bucket**: **DISABLED (Private)**
   - Only backend server-side service-role requests can read and upload images.
4. Allowed MIME types: `image/jpeg`, `image/png`.
5. Max file size: `5 MB`.

Storage structure used by the backend:
```
farmer-faces/
└── {farmer_id}/
    └── reference.jpg
```

---

## 4. Backend Environment Configuration

Open `backend/.env` and supply your Supabase parameters:

```ini
# Supabase Configuration (Backend server-side only)
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_SECRET_KEY=<your-supabase-service-role-secret-key>

# Storage & Table identifiers (Defaults)
SUPABASE_STORAGE_BUCKET=farmer-faces
SUPABASE_TABLE_NAME=farmers
```

---

## 5. Starting and Verifying the Backend

1. Navigate to the backend directory and activate the virtual environment:
   ```powershell
   cd "C:\KISAN NETRA ANDRIOD APP\backend"
   .\venv\Scripts\Activate.ps1
   ```
2. Start the FastAPI server:
   ```powershell
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```
3. Verify readiness via the `/health` endpoint:
   - Open `http://localhost:8000/health`
   - Expected response when configured:
     ```json
     {
       "status": "healthy",
       "app_name": "CHIP TO CROP Auth Service",
       "version": "1.0.0",
       "supabase_configured": true,
       "facepp_configured": true,
       "timestamp": "2026-11-01T..."
     }
     ```

