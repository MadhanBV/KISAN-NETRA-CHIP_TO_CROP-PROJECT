# CHIP TO CROP — Authentication Backend Service

A high-performance Python FastAPI service providing Phone + 1:1 Face Biometric Authentication with Supabase and Face++ for the **CHIP TO CROP** mobile application.

---

## Architecture Overview

- **Framework**: FastAPI (Asynchronous, High-Performance)
- **Database**: Supabase PostgreSQL (`public.farmers` table with Row Level Security)
- **Object Storage**: Supabase Private Storage (`farmer-faces` bucket)
- **Biometric Comparison Engine**: Face++ Compare API (1:1 Verification)
- **Token Format**: Expiring JSON Web Tokens (JWT) signed with HMAC-SHA256
- **Biometric Privacy**: Strict explicit farmer consent and instant deletion lifecycle

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Service health status, Supabase & Face++ configuration checks |
| `GET` | `/api/auth/check-phone?phone_number=+91...` | Verifies whether a phone number is registered in PostgreSQL |
| `POST` | `/api/auth/register` | Registers farmer with phone, explicit consent & uploads photo to private storage |
| `POST` | `/api/auth/login` | Compares freshly captured login face against reference photo via Face++ |
| `DELETE` | `/api/auth/account` | Deletes farmer account and biometric image permanently from Supabase |

---

## How to Run

1. Activate virtual environment:
   ```powershell
   cd backend
   .\venv\Scripts\Activate.ps1
   ```
2. Start the development server:
   ```powershell
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```
3. Interactive API documentation:
   - Swagger UI: `http://localhost:8000/docs`
   - Redoc: `http://localhost:8000/redoc`

---

## Configuration

Copy `.env.example` to `.env` and provide your credentials:

- `SUPABASE_URL`: Your Supabase Project URL (`https://<project-ref>.supabase.co`)
- `SUPABASE_SECRET_KEY`: Your Supabase service-role secret key (Backend only - never expose in Flutter)
- `FACEPP_API_KEY` & `FACEPP_API_SECRET`: Supplied by Face++ Console
- `FACEPP_COMPARE_URL`: Your regional Face++ compare endpoint (e.g., `https://api-us.faceplusplus.com/facepp/v3/compare`)
- `FACEPP_CONFIDENCE_THRESHOLD`: Minimum similarity score (default `80.0`)
