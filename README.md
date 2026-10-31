# 🤖 AMIRA LOCAL BOT - DEVELOPMENT ENVIRONMENT

**Status:** ✅ Ready to use  
**Purpose:** Individual bot testing with new Claude API key  
**Environment:** Local development  
**Port:** 3001  
**New Key:** Yes (Individual account)

---

## ⚡ QUICK START (2 minutes)

### 1. Copy `.env` File
```bash
copy .env.example .env
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Start Bot
```bash
npm start
```

**Output:**
```
✅ Server started on http://localhost:3001
```

### 4. Test Bot
In another terminal:
```bash
curl http://localhost:3001/api/test
```

---

## 📋 COMMANDS

### Start Development
```bash
npm start          # Run server
npm run dev        # Run with auto-restart (nodemon)
npm run test       # Test bot response
npm run logs       # View conversations
npm run clear-logs # Clear log file
```

---

## 🧪 TEST BOT

### Test 1: Health Check
```bash
curl http://localhost:3001/health
```

### Test 2: Send Message (Romanian)
```bash
curl -X POST http://localhost:3001/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Ce servicii oferiti?",
    "language": "ro"
  }'
```

### Test 3: Send Message (English)
```bash
curl -X POST http://localhost:3001/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "text": "What services do you offer?",
    "language": "en"
  }'
```

### Test 4: View Conversation Logs
```bash
curl http://localhost:3001/api/logs
```

---

## 📂 FILE STRUCTURE

```
amira-local-bot/
├── .env                    ← Credentials (created from .env.example)
├── .env.example            ← Template
├── .vscode-workspace.json  ← VS Code config
├── server.js               ← Main bot server
├── package.json            ← Dependencies
├── package-lock.json       ← Dependency lock (auto)
├── conversations.log       ← Bot conversation history
├── node_modules/           ← Installed packages (auto)
└── README.md              ← This file
```

---

## 🎯 FEATURES

✅ **Individual Claude Key** - New account, separate from production  
✅ **Local Testing** - Develop & test before deploying to N8N  
✅ **Conversation Logging** - Every message logged to `conversations.log`  
✅ **Multi-Language** - Works in any language  
✅ **Quick API** - Easy to test and integrate  
✅ **Error Handling** - Graceful error responses  
✅ **Console Output** - See detailed logs in terminal  

---

## 🔧 DEVELOPMENT WORKFLOW

### 1. Edit `server.js`
- Change bot behavior
- Add new routes
- Modify prompts

### 2. Server Auto-Restarts
- When using `npm run dev`
- Changes apply immediately

### 3. Test Changes
```bash
curl -X POST http://localhost:3001/api/chat \
  -H "Content-Type: application/json" \
  -d '{"text":"Your test message"}'
```

### 4. View Logs
```bash
curl http://localhost:3001/api/logs
```

### 5. Deploy to N8N
- Copy working code to N8N Code node
- Test in N8N workflow
- Deploy to production

---

## 🛠️ MODIFY BOT BEHAVIOR

### Change System Prompt
Edit `server.js`, find `SYSTEM_PROMPT`:
```javascript
const SYSTEM_PROMPT = `You are Amira Consulting's AI Assistant...`
```

Modify the prompt text and save. Server auto-restarts (if using `npm run dev`).

### Add New Route
```javascript
app.post('/api/custom-endpoint', (req, res) => {
  // Your custom logic here
  res.json({ success: true, data: 'something' });
});
```

### Change Model
Edit `.env`:
```
CLAUDE_MODEL=claude-opus-4-1-20250805  # Change model name
```

---

## 📊 MONITORING

### Terminal Output
```
📨 Message received
   Language: ro
   Text: "Ce servicii oferiti?"
   
🔄 Calling Claude API...

✅ Bot response generated
   Length: 250 chars
   Preview: "Bine ati venit..."
   
✅ Response sent
```

### Log File
```bash
cat conversations.log
```

Each line is a JSON object:
```json
{
  "timestamp": "2026-10-30T10:15:30Z",
  "language": "ro",
  "customerId": "test-001",
  "userMessage": "Ce servicii oferiti?",
  "botReply": "Bine ati venit..."
}
```

---

## 🚀 DEPLOY OPTIONS

### Option A: Keep Local Only
- Use for development/testing
- Never deploy to internet
- Good for learning

### Option B: Deploy to Render
```bash
git init
git add .
git commit -m "Initial local bot"
# Connect to GitHub, push to Render
```

### Option C: Deploy to Vercel
```bash
npm install -g vercel
vercel
```

---

## 🐛 TROUBLESHOOTING

| Problem | Solution |
|---------|----------|
| `Port 3001 in use` | `npm start -- --port 3002` |
| `Claude key invalid` | Check `.env` file |
| `Module not found` | Run `npm install` |
| `Server won't start` | Check Node.js: `node --version` |
| `CORS error` | Check frontend is using correct URL |

---

## 💡 TIPS

- Use `nodemon` for auto-restart: `npm run dev`
- View all logs: `curl http://localhost:3001/api/logs`
- Clear logs: `curl -X DELETE http://localhost:3001/api/logs`
- Use Postman for easier testing
- Check console output for detailed error messages

---

## 🎓 NEXT STEPS

1. **✅ Start bot** - `npm start`
2. **✅ Test responses** - Use curl commands
3. **✅ View logs** - See what the bot is doing
4. **✅ Modify behavior** - Edit `server.js` and test
5. **✅ Deploy to N8N** - Copy code to N8N when ready

---

## 📞 SUPPORT

**All logs are in terminal and `conversations.log`**

Check for:
- Claude API errors → Check key validity
- Syntax errors → Check server.js
- Runtime errors → Check terminal output

---

**READY TO START?**

```bash
npm install
npm start
```

Then test: `http://localhost:3001/api/test`

Enjoy developing! 🚀
