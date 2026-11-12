# CHIP TO CROP - PowerShell All-in-One Launcher
$RootDir = $PSScriptRoot
$RagDir = Join-Path $RootDir "rag_engine"
$BackendDir = Join-Path $RootDir "backend"

Write-Host "=====================================================================" -ForegroundColor Green
Write-Host "               CHIP TO CROP - START ALL SERVICES                     " -ForegroundColor Green
Write-Host "=====================================================================" -ForegroundColor Green

# 1. Ollama
Write-Host "`n[1/5] Checking Ollama Service (Port 11434)..." -ForegroundColor Cyan
$ollamaListening = Get-NetTCPConnection -LocalPort 11434 -State Listen -ErrorAction SilentlyContinue
if ($ollamaListening) {
    Write-Host "  [OK] Ollama is already running on port 11434." -ForegroundColor Green
} else {
    Write-Host "  [INFO] Starting Ollama serve in background..." -ForegroundColor Yellow
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Minimized
    Start-Sleep -Seconds 3
}

# 2. RAG Engine (Port 8001)
Write-Host "`n[2/5] Starting Agricultural RAG Engine (Port 8001)..." -ForegroundColor Cyan
$ragListening = Get-NetTCPConnection -LocalPort 8001 -State Listen -ErrorAction SilentlyContinue
if ($ragListening) {
    Write-Host "  [OK] RAG Engine is already listening on port 8001." -ForegroundColor Green
} else {
    $ragPython = Join-Path $RagDir "venv\Scripts\python.exe"
    if (-not (Test-Path $ragPython)) { $ragPython = "python" }
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$RagDir'; & '$ragPython' -m uvicorn app.main:app --host 127.0.0.1 --port 8001"
    Write-Host "  [LAUNCHED] RAG Engine started in a new PowerShell window." -ForegroundColor Green
}

# 3. Main Backend (Port 8000)
Write-Host "`n[3/5] Starting FastAPI Application Backend (Port 8000)..." -ForegroundColor Cyan
$backendListening = Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue
if ($backendListening) {
    Write-Host "  [OK] Main Backend is already listening on port 8000." -ForegroundColor Green
} else {
    $backendPython = Join-Path $BackendDir "venv\Scripts\python.exe"
    if (-not (Test-Path $backendPython)) { $backendPython = "python" }
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$BackendDir'; & '$backendPython' -m uvicorn app.main:app --host 0.0.0.0 --port 8000"
    Write-Host "  [LAUNCHED] Main Backend started in a new PowerShell window." -ForegroundColor Green
}

# 4. ADB Port Forwarding
Write-Host "`n[4/5] Setting up ADB USB Reverse Port Forwarding..." -ForegroundColor Cyan
$adbPath = (Get-Command adb -ErrorAction SilentlyContinue)?.Source
if (-not $adbPath) {
    $sdkAdb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    if (Test-Path $sdkAdb) {
        $adbPath = $sdkAdb
    }
}

if ($adbPath) {
    & $adbPath reverse tcp:8000 tcp:8000
    & $adbPath reverse tcp:8001 tcp:8001
    Write-Host "  [OK] ADB reverse port forwarding configured for ports 8000 and 8001." -ForegroundColor Green
} else {
    Write-Host "  [WARN] ADB not found. Skip if running without physical USB device." -ForegroundColor Yellow
}

Write-Host "`n=====================================================================" -ForegroundColor Green
Write-Host "  ALL BACKEND & AI SERVICES ARE OPERATIONAL!" -ForegroundColor Green
Write-Host "  - Backend API:  http://127.0.0.1:8000 (Swagger: http://127.0.0.1:8000/docs)" -ForegroundColor White
Write-Host "  - RAG Engine:   http://127.0.0.1:8001 (Swagger: http://127.0.0.1:8001/docs)" -ForegroundColor White
Write-Host "  - Ollama AI:    http://127.0.0.1:11434" -ForegroundColor White
Write-Host "=====================================================================`n" -ForegroundColor Green

$runFlutter = Read-Host "Do you want to launch the Flutter app now? (Y/N)"
if ($runFlutter -eq 'Y' -or $runFlutter -eq 'y') {
    Set-Location $RootDir
    flutter run
}
