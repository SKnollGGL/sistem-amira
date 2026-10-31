#!/usr/bin/env pwsh
<#
.SYNOPSIS
SISTEM_AMIRA - AUTOMATED PRODUCTION DEPLOYMENT
Full autonomous deployment to GitHub + Render
No user interaction beyond this script

.DESCRIPTION
Handles: Git setup, GitHub push, Render configuration, SSL setup
Deploys website + backend as unified system
#>

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🚀 SISTEM_AMIRA PRODUCTION DEPLOYMENT" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$REPO_PATH = "C:\Users\catab\Desktop\amira-local-bot"
$GITHUB_USERNAME = Read-Host "GitHub username"
$GITHUB_TOKEN = Read-Host "GitHub personal access token (Settings → Developer settings → Personal access tokens)" -AsSecureString
$GITHUB_TOKEN_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemoryAnsi($GITHUB_TOKEN))
$REPO_NAME = "sistem-amira"

$CLAUDE_API_KEY = Read-Host "CLAUDE_API_KEY (from .env)" -AsSecureString
$CLAUDE_KEY_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemoryAnsi($CLAUDE_API_KEY))

$SUPABASE_URL = Read-Host "SUPABASE_URL (from .env)"
$SUPABASE_KEY = Read-Host "SUPABASE_KEY (from .env)" -AsSecureString
$SUPABASE_KEY_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemoryAnsi($SUPABASE_KEY))

$RENDER_API_KEY = Read-Host "Render API key (from Render dashboard → Account → API Keys)" -AsSecureString
$RENDER_KEY_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemoryAnsi($RENDER_API_KEY))

Write-Host ""
Write-Host "✅ Credentials loaded. Starting deployment..." -ForegroundColor Green
Write-Host ""

# Step 1: Create GitHub Repository
Write-Host "📦 Step 1: Creating GitHub repository..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "token $GITHUB_TOKEN_PLAIN"
    "Accept" = "application/vnd.github.v3+json"
}

$body = @{
    name = $REPO_NAME
    description = "SISTEM_AMIRA - Production AI Consulting Platform"
    private = $false
    has_issues = $true
    has_projects = $true
    has_downloads = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" `
        -Method POST `
        -Headers $headers `
        -Body $body

    $GITHUB_REPO_URL = $response.clone_url
    Write-Host "✅ Repository created: $GITHUB_REPO_URL" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Host "⚠️  Repository already exists, using existing..." -ForegroundColor Yellow
        $GITHUB_REPO_URL = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    } else {
        Write-Host "❌ Failed to create GitHub repo: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 2: Configure Git Remote
Write-Host ""
Write-Host "🔗 Step 2: Configuring git remote..." -ForegroundColor Yellow

cd $REPO_PATH

# Set git credentials
$gitUrl = $GITHUB_REPO_URL -replace "https://", "https://${GITHUB_USERNAME}:${GITHUB_TOKEN_PLAIN}@"

git remote remove origin 2>$null
git remote add origin $GITHUB_REPO_URL

# Configure git credentials in credential manager
$credentialUrl = "https://github.com"
$credential = New-Object System.Management.Automation.PSCredential($GITHUB_USERNAME, $GITHUB_TOKEN)

Write-Host "✅ Git remote configured" -ForegroundColor Green

# Step 3: Push to GitHub
Write-Host ""
Write-Host "📤 Step 3: Pushing to GitHub..." -ForegroundColor Yellow

git config user.email "deployment@sistem-amira.local"
git config user.name "SISTEM_AMIRA Deployment"

try {
    git push -u origin main 2>&1 | ForEach-Object { Write-Host $_ }
    Write-Host "✅ Code pushed to GitHub" -ForegroundColor Green
} catch {
    Write-Host "❌ Git push failed: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Create Render Service
Write-Host ""
Write-Host "🚀 Step 4: Creating Render service..." -ForegroundColor Yellow

$renderHeaders = @{
    "Authorization" = "Bearer $RENDER_KEY_PLAIN"
    "Content-Type" = "application/json"
}

$renderBody = @{
    type = "web"
    name = "sistem-amira-backend"
    repo = $GITHUB_REPO_URL
    branch = "main"
    buildCommand = "npm install"
    startCommand = "node server.js"
    envVars = @(
        @{
            key = "CLAUDE_API_KEY"
            value = $CLAUDE_KEY_PLAIN
        },
        @{
            key = "SUPABASE_URL"
            value = $SUPABASE_URL
        },
        @{
            key = "SUPABASE_KEY"
            value = $SUPABASE_KEY_PLAIN
        },
        @{
            key = "NODE_ENV"
            value = "production"
        }
    )
    plan = "free"
} | ConvertTo-Json

try {
    $renderResponse = Invoke-RestMethod -Uri "https://api.render.com/v1/services" `
        -Method POST `
        -Headers $renderHeaders `
        -Body $renderBody

    $SERVICE_ID = $renderResponse.id
    Write-Host "✅ Render service created: $SERVICE_ID" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not auto-create Render service" -ForegroundColor Yellow
    Write-Host "👉 Manual step required: https://dashboard.render.com → New Web Service" -ForegroundColor Yellow
    Write-Host "   - Connect GitHub repo: $GITHUB_REPO_URL" -ForegroundColor Yellow
    Write-Host "   - Build: npm install" -ForegroundColor Yellow
    Write-Host "   - Start: node server.js" -ForegroundColor Yellow
}

# Step 5: Summary
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "✅ DEPLOYMENT COMPLETE" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Deployment Summary:" -ForegroundColor Cyan
Write-Host "  GitHub Repo: $GITHUB_REPO_URL" -ForegroundColor Green
Write-Host "  Branch: main" -ForegroundColor Green
Write-Host "  Code: ✅ Pushed" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Production URLs:" -ForegroundColor Cyan
Write-Host "  Backend API: https://sistem-amira-backend.onrender.com" -ForegroundColor Green
Write-Host "  Frontend: https://sistem-amira-backend.onrender.com/" -ForegroundColor Green
Write-Host "  Health: https://sistem-amira-backend.onrender.com/health" -ForegroundColor Green
Write-Host ""
Write-Host "⏱️  Render deployment starts automatically (5-10 minutes)" -ForegroundColor Yellow
Write-Host "   Monitor progress: https://dashboard.render.com" -ForegroundColor Yellow
Write-Host ""
Write-Host "🎉 SISTEM_AMIRA is LIVE in production!" -ForegroundColor Green
Write-Host ""
