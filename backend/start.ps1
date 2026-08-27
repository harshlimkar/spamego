# ScameGo AI Backend Startup Script
# Run this in PowerShell as Administrator

Write-Host "=== ScameGo AI Backend Setup ===" -ForegroundColor Cyan

# Check Python
$pythonVersion = python --version 2>&1
Write-Host "Python: $pythonVersion" -ForegroundColor Green

# Install dependencies
Write-Host "`nInstalling Python dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt

# Install Playwright browsers
Write-Host "`nInstalling Playwright Chromium..." -ForegroundColor Yellow
playwright install chromium

# Create .env if not exists
if (-not (Test-Path ".env")) {
    Write-Host "`nCreating .env from example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "Please edit .env with your secrets!" -ForegroundColor Red
}

# Run the server
Write-Host "`nStarting ScameGo AI Backend on http://localhost:8000" -ForegroundColor Cyan
Write-Host "API docs available at http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray

python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000