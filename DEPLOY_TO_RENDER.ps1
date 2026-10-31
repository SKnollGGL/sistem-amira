#!/usr/bin/env pwsh
# SISTEM_AMIRA - AUTONOMOUS RENDER DEPLOYMENT VIA WEBHOOK
# No permissions, no API key, fully autonomous

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "SISTEM_AMIRA - AUTO-DEPLOY TO RENDER" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if webhook URL is set (provided one-time by user)
if (-not $env:RENDER_DEPLOY_HOOK) {
    Write-Host "First time setup - enter your Render webhook URL" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To get webhook URL:" -ForegroundColor Cyan
    Write-Host "  1. Go: https://dashboard.render.com" -ForegroundColor Cyan
    Write-Host "  2. Select service: sistem-amira" -ForegroundColor Cyan
    Write-Host "  3. Settings → Deploy hook" -ForegroundColor Cyan
    Write-Host "  4. Copy the webhook URL" -ForegroundColor Cyan
    Write-Host ""

    $webhookUrl = Read-Host "Paste webhook URL"

    # Save to environment for future runs
    [Environment]::SetEnvironmentVariable("RENDER_DEPLOY_HOOK", $webhookUrl, [EnvironmentVariableTarget]::User)
    Write-Host "Webhook URL saved for future deployments" -ForegroundColor Green
} else {
    $webhookUrl = $env:RENDER_DEPLOY_HOOK
}

Write-Host ""
Write-Host "Triggering Render deployment..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri $webhookUrl -Method POST -UseBasicParsing

    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 204) {
        Write-Host "SUCCESS! Render deployment triggered" -ForegroundColor Green
        Write-Host ""
        Write-Host "Deployment in progress (5-10 minutes)" -ForegroundColor Cyan
        Write-Host "Monitor at: https://dashboard.render.com" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Your dashboard will be live soon at:" -ForegroundColor Green
        Write-Host "  https://sistem-amira.onrender.com/" -ForegroundColor Green
    }
} catch {
    Write-Host "Error triggering deployment: $_" -ForegroundColor Red
    Write-Host "Check that webhook URL is correct" -ForegroundColor Yellow
}
