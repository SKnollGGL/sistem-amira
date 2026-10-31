# SISTEM_AMIRA - RENDER DEPLOYMENT (Autonomous After Setup)

## Status
✅ Code on GitHub: https://github.com/SKnollGGL/sistem-amira  
✅ render.yaml configured with build/start commands  
✅ Environment variables specified  

## ONE-TIME SETUP (Manual, then fully automatic forever)

**Go to Render Dashboard and do this ONCE:**

```
1. https://dashboard.render.com
2. Click: "New +" → "Web Service"
3. Select: "Connect GitHub"
4. Authorize Render to access your GitHub
5. Find and select: SKnollGGL/sistem-amira
6. Render auto-detects from render.yaml:
   - Build: npm install
   - Start: node server.js
7. Click: "Create Web Service"
```

## What Happens Next (100% Automatic)

**After initial connection:**
- ✅ Render builds and deploys initial code
- ✅ Every future push to main auto-deploys
- ✅ GitHub webhook triggers Render automatically
- ✅ Zero manual steps needed

## Environment Variables (In Render Dashboard)

After service created, go to Settings → Environment and add:
```
CLAUDE_API_KEY = [from your .env file]
SUPABASE_URL = [from your .env file]
SUPABASE_KEY = [from your .env file]
NODE_ENV = production
```

(Check your local .env file for the actual credential values)

## Your Live Dashboard

After Render deploys (~5-10 minutes):

**Frontend:** https://sistem-amira.onrender.com/  
**Metrics:** Shows REAL data with animation  
**API:** https://sistem-amira.onrender.com/api/stats  
**Health:** https://sistem-amira.onrender.com/health  

## Fully Autonomous Future Deployments

Every time you push code to GitHub → Render automatically:
- Pulls latest code
- Runs: npm install
- Runs: node server.js
- Deploys live
- Zero human intervention

**One setup step. Infinite automatic deployments.**
