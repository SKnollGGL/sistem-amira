#!/bin/bash
# SISTEM_AMIRA - ONE COMMAND PRODUCTION DEPLOYMENT
# Everything automated - just provide GitHub credentials once

set -e

echo "================================================"
echo "🚀 SISTEM_AMIRA PRODUCTION DEPLOYMENT"
echo "================================================"
echo ""

# Get GitHub credentials (ONLY these are needed - app credentials are in code)
read -p "GitHub Username: " GITHUB_USER
read -sp "GitHub Personal Access Token: " GITHUB_TOKEN
echo ""

REPO_NAME="sistem-amira"
REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"

# Step 1: Create/Update GitHub Repository
echo "📦 Creating GitHub repository..."
curl -s -X POST \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "{
    \"name\": \"${REPO_NAME}\",
    \"description\": \"SISTEM_AMIRA - Production AI Consulting Platform\",
    \"private\": false
  }" \
  https://api.github.com/user/repos 2>/dev/null || echo "⚠️  Repo may already exist - continuing..."

# Step 2: Push to GitHub
echo "📤 Pushing code to GitHub..."
git remote remove origin 2>/dev/null || true
git remote add origin "${REPO_URL}"
git branch -M main
git push -u origin main

echo ""
echo "================================================"
echo "✅ DEPLOYMENT COMPLETE"
echo "================================================"
echo ""
echo "📊 Next Steps:"
echo "  1. Go to: https://dashboard.render.com"
echo "  2. Click: New Web Service"
echo "  3. Connect: GitHub → ${GITHUB_USER}/${REPO_NAME}"
echo "  4. Settings:"
echo "     - Build: npm install"
echo "     - Start: node server.js"
echo "     - Region: Oregon (free tier)"
echo ""
echo "✨ Render will auto-deploy in 5-10 minutes"
echo "🌐 Backend: https://sistem-amira.onrender.com"
echo "🌐 Website: https://sistem-amira.onrender.com/"
echo ""
