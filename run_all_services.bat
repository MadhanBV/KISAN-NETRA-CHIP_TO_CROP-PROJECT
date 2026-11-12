@echo off
TITLE CHIP TO CROP - All Services Launcher
COLOR 0A
set "ROOT_DIR=%~dp0"
if "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR:~0,-1%"

echo =====================================================================
echo                CHIP TO CROP - START ALL SERVICES
echo =====================================================================
echo.

:: 1. Check Ollama
echo [1/5] Checking Ollama Service (Port 11434)...
netstat -ano | findstr 11434 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   [OK] Ollama is already running on port 11434.
) else (
    echo   [INFO] Starting Ollama server in background...
    start "Ollama Service" /min ollama serve
    timeout /t 3 /nobreak >nul
)

:: 2. Start RAG Engine (Port 8001)
echo.
echo [2/5] Starting Agricultural RAG Engine (Port 8001)...
netstat -ano | findstr 8001 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   [OK] RAG Engine is already listening on port 8001.
) else (
    if exist "%ROOT_DIR%\rag_engine\venv\Scripts\python.exe" (
        start "CHIP TO CROP - RAG Engine (8001)" cmd /k "cd /d "%ROOT_DIR%\rag_engine" && .\venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8001"
    ) else (
        start "CHIP TO CROP - RAG Engine (8001)" cmd /k "cd /d "%ROOT_DIR%\rag_engine" && python -m uvicorn app.main:app --host 127.0.0.1 --port 8001"
    )
    echo   [LAUNCHED] RAG Engine started in a separate console window.
)

:: 3. Start Main FastAPI Backend (Port 8000)
echo.
echo [3/5] Starting FastAPI Application Backend (Port 8000)...
netstat -ano | findstr 8000 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   [OK] Main Backend is already listening on port 8000.
) else (
    if exist "%ROOT_DIR%\backend\venv\Scripts\python.exe" (
        start "CHIP TO CROP - Backend API (8000)" cmd /k "cd /d "%ROOT_DIR%\backend" && .\venv\Scripts\python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8000"
    ) else (
        start "CHIP TO CROP - Backend API (8000)" cmd /k "cd /d "%ROOT_DIR%\backend" && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000"
    )
    echo   [LAUNCHED] Backend API started in a separate console window.
)

:: 4. Setup ADB Port Forwarding
echo.
echo [4/5] Setting up ADB USB Reverse Port Forwarding...
where adb >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    adb reverse tcp:8000 tcp:8000
    adb reverse tcp:8001 tcp:8001
    echo   [OK] ADB reverse port forwarding configured for port 8000 and 8001.
) else (
    if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
        "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000
        "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" reverse tcp:8001 tcp:8001
        echo   [OK] Android SDK adb reverse port forwarding configured.
    ) else (
        echo   [WARN] ADB not detected in PATH. Connect your phone via USB if testing on hardware.
    )
)

:: 5. Launch Flutter App
echo.
echo [5/5] Ready to launch Flutter mobile app!
echo.
echo =====================================================================
echo   ALL SERVICES ARE ACTIVE:
echo   - Backend API:  http://127.0.0.1:8000 (Docs: http://127.0.0.1:8000/docs)
echo   - RAG Engine:   http://127.0.0.1:8001 (Docs: http://127.0.0.1:8001/docs)
echo   - Ollama AI:    http://127.0.0.1:11434
echo =====================================================================
echo.

set /p RUN_FLUTTER="Do you want to run the Flutter app now? (Y/N): "
if /i "%RUN_FLUTTER%"=="Y" (
    echo.
    echo Launching Flutter app...
    cd /d "%ROOT_DIR%"
    flutter run
) else (
    echo.
    echo You can start Flutter anytime with:
    echo   cd /d "%ROOT_DIR%" ^&^& flutter run
    pause
)
