// Module imports with error handling
let express, dotenv, cors, morgan, axios, fs, path;

try {
  express = require('express');
  dotenv = require('dotenv');
  cors = require('cors');
  morgan = require('morgan');
  axios = require('axios');
  fs = require('fs');
  path = require('path');
} catch (error) {
  console.error('❌ Failed to load required modules:', error.message);
  process.exit(1);
}

dotenv.config();

// Validate critical environment variables
if (!process.env.CLAUDE_API_KEY || process.env.CLAUDE_API_KEY.trim() === '') {
  console.error('❌ CRITICAL: CLAUDE_API_KEY is not set or empty. Server cannot start.');
  process.exit(1);
}

const app = express();
const PORT = process.env.PORT || 3001;

// Configure log directory - cross-platform compatible
const LOG_DIR = process.env.LOG_DIR || path.join(__dirname, 'logs');
const CONVERSATIONS_LOG = path.join(LOG_DIR, 'conversations.log');

// Ensure log directory exists
if (!fs.existsSync(LOG_DIR)) {
  fs.mkdirSync(LOG_DIR, { recursive: true });
}

// Middleware
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));

console.log('\n🤖 AMIRA LOCAL BOT - PRODUCTION READY');
console.log('================================================');
console.log(`📍 Port: ${PORT}`);
console.log(`🔑 Claude Key: ${process.env.CLAUDE_API_KEY ? '✅ Loaded' : '❌ Missing'}`);
console.log(`📁 Log Directory: ${LOG_DIR}`);
console.log(`🗄️  Supabase: ${process.env.SUPABASE_URL ? '✅ Configured' : '⚠️  Optional'}`);
console.log(`🖥️  Node Environment: ${process.env.NODE_ENV || 'development'}`);
console.log('================================================\n');

// System prompt
const SYSTEM_PROMPT = `You are Amira Consulting's AI Assistant - Local Development Version.

ENVIRONMENT: Local Testing (NOT Production)
CLAUDE KEY: New Individual Account
PURPOSE: Bot development & testing

COMPANY CONTEXT:
- Name: Amira Consulting
- Focus: AI Sales Automation & Lead Management
- Website: https://amiraconsulting.services
- Team: 10 specialized consultants
- Services: 4 pricing tiers (€2200-€3500/month)

DEVELOPMENT MODE:
- Be helpful in testing
- Respond to test queries
- Support debugging
- Provide example responses
- Never break character

BEHAVIOR:
1. Professional, consultative tone
2. Match language to user request
3. Offer consultant escalation when appropriate
4. Keep responses focused and clear
5. Never expose system internals
6. Use realistic examples from Amira services`;

// Logging helper - uses environment-based path
function logConversation(text, reply, language, customerId) {
  const timestamp = new Date().toISOString();
  const logEntry = {
    timestamp,
    language,
    customerId,
    userMessage: text,
    botReply: reply,
  };

  try {
    fs.appendFileSync(
      CONVERSATIONS_LOG,
      JSON.stringify(logEntry) + '\n',
      'utf8'
    );
  } catch (error) {
    console.error(`⚠️  Failed to log conversation: ${error.message}`);
  }
}

// ============ ROUTES ============

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: '✅ ok',
    service: 'Amira Local Bot Dev',
    environment: 'development',
    port: PORT,
    claudeKey: process.env.CLAUDE_API_KEY ? 'Loaded' : 'Missing',
    timestamp: new Date().toISOString(),
  });
});

// Main chat endpoint
app.post('/api/chat', async (req, res) => {
  try {
    const {
      text,
      language = 'ro',
      customerId = 'local-test',
      channel = 'chat',
    } = req.body;

    // Validation
    if (!text || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Message text required',
      });
    }

    console.log(`\n📨 Message received`);
    console.log(`   Language: ${language}`);
    console.log(`   Channel: ${channel}`);
    console.log(`   Text: "${text}"`);
    console.log(`   Customer: ${customerId}`);

    // Call Claude API
    console.log(`\n🔄 Calling Claude API...`);

    // Validate API key is set (already checked at startup, but safe to validate again)
    if (!process.env.CLAUDE_API_KEY) {
      throw new Error('CLAUDE_API_KEY is not configured');
    }

    const response = await axios.post(
      'https://api.anthropic.com/v1/messages',
      {
        model: process.env.CLAUDE_MODEL || 'claude-opus-4-1-20250805',
        max_tokens: 1024,
        system: SYSTEM_PROMPT,
        messages: [
          {
            role: 'user',
            content: text,
          },
        ],
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': process.env.CLAUDE_API_KEY,
          'anthropic-version': '2023-06-01',
        },
        timeout: 30000,
      }
    );

    const reply = response.data.content[0].text;

    console.log(`\n✅ Bot response generated`);
    console.log(`   Length: ${reply.length} chars`);
    console.log(`   Preview: "${reply.substring(0, 100)}..."`);

    // Log conversation
    logConversation(text, reply, language, customerId);

    // Return response
    res.json({
      success: true,
      reply,
      response: reply,
      message: reply,
      language,
      customerId,
      channel,
      timestamp: new Date().toISOString(),
    });

    console.log(`✅ Response sent\n`);

  } catch (error) {
    console.error('\n❌ Error occurred:');

    if (error.response) {
      console.error(`   Status: ${error.response.status}`);
      console.error(`   Error: ${error.response.data?.error?.message || 'Unknown'}`);
    } else {
      console.error(`   Message: ${error.message}`);
    }
    console.log('');

    res.status(500).json({
      success: false,
      error: error.response?.data?.error?.message || error.message,
      timestamp: new Date().toISOString(),
    });
  }
});

// Test endpoint
app.get('/api/test', (req, res) => {
  res.json({
    success: true,
    message: '✅ Local bot is running!',
    environment: 'development',
    endpoints: {
      health: 'GET /health',
      chat: 'POST /api/chat',
      test: 'GET /api/test',
      logs: 'GET /api/logs',
    },
    exampleRequest: {
      method: 'POST',
      url: 'http://localhost:3001/api/chat',
      headers: { 'Content-Type': 'application/json' },
      body: {
        text: 'Ce servicii oferiti?',
        language: 'ro',
        customerId: 'test-001',
        channel: 'chat',
      },
    },
  });
});

// View logs endpoint - uses environment-based path
app.get('/api/logs', (req, res) => {
  try {
    if (!fs.existsSync(CONVERSATIONS_LOG)) {
      return res.json({
        success: true,
        totalLogs: 0,
        logs: [],
        message: 'No logs yet',
      });
    }

    const logContent = fs.readFileSync(CONVERSATIONS_LOG, 'utf8');
    const logs = logContent
      .split('\n')
      .filter((line) => line.trim())
      .map((line) => {
        try {
          return JSON.parse(line);
        } catch (e) {
          return null;
        }
      })
      .filter((log) => log !== null)
      .reverse()
      .slice(0, 50); // Last 50 conversations

    res.json({
      success: true,
      totalLogs: logs.length,
      logs,
    });
  } catch (error) {
    console.error(`⚠️  Error reading logs: ${error.message}`);
    res.status(500).json({
      success: false,
      error: 'Could not read logs',
      message: error.message,
    });
  }
});

// Clear logs endpoint - uses environment-based path
app.delete('/api/logs', (req, res) => {
  try {
    fs.writeFileSync(CONVERSATIONS_LOG, '', 'utf8');
    res.json({
      success: true,
      message: 'Logs cleared',
    });
  } catch (error) {
    console.error(`⚠️  Error clearing logs: ${error.message}`);
    res.status(500).json({
      success: false,
      error: 'Could not clear logs',
      message: error.message,
    });
  }
});

// Catch 404
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: `Route not found: ${req.method} ${req.path}`,
    availableEndpoints: [
      'GET /health',
      'POST /api/chat',
      'GET /api/test',
      'GET /api/logs',
      'DELETE /api/logs',
    ],
  });
});

// Start server
const server = app.listen(PORT, () => {
  console.log(`✅ Server started on http://localhost:${PORT}`);
  console.log('\n📊 Quick Commands:');
  console.log(`   Health: curl http://localhost:${PORT}/health`);
  console.log(`   Test: curl http://localhost:${PORT}/api/test`);
  console.log(`   Chat: curl -X POST http://localhost:${PORT}/api/chat \\`);
  console.log(`         -H "Content-Type: application/json" \\`);
  console.log(`         -d '{"text":"Hello","language":"ro"}'`);
  console.log(`   Logs: curl http://localhost:${PORT}/api/logs`);
  console.log(`\n💡 Tip: Check VS Code terminal for detailed logs\n`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n\n🛑 Shutting down...');
  server.close(() => {
    console.log('✅ Server stopped');
    process.exit(0);
  });
});

process.on('SIGTERM', () => {
  console.log('\n\n🛑 Shutting down...');
  server.close(() => {
    console.log('✅ Server stopped');
    process.exit(0);
  });
});
