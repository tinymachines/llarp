const express = require('express');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');

const app = express();
const PORT = 8222;
const ROOT_DIR = '../openwrt/openwrt.org.md';

// Middleware for JSON parsing
app.use(express.json());

// API Routes
app.post('/api/chat', async (req, res) => {
  try {
    const { message } = req.body;
    
    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }
    
    // Call the Python chat system
    const chatProcess = spawn('python', ['../llarp-ai/web_chat_handler.py'], {
      cwd: __dirname,
      stdio: ['pipe', 'pipe', 'pipe']
    });
    
    let output = '';
    let errorOutput = '';
    
    chatProcess.stdout.on('data', (data) => {
      output += data.toString();
    });
    
    chatProcess.stderr.on('data', (data) => {
      errorOutput += data.toString();
    });
    
    chatProcess.on('close', (code) => {
      if (code === 0 && output.trim()) {
        try {
          const result = JSON.parse(output);
          res.json(result);
        } catch (parseError) {
          res.status(500).json({
            error: 'Failed to parse chat response',
            details: parseError.message
          });
        }
      } else {
        res.status(500).json({
          error: 'Chat system error',
          details: errorOutput || 'No output received'
        });
      }
    });
    
    // Send the message to the chat system
    chatProcess.stdin.write(message + '\n');
    chatProcess.stdin.end();
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/router-status', async (req, res) => {
  try {
    // Call router status check
    const statusProcess = spawn('python', ['../llarp-ai/router_manager.py', 'status'], {
      cwd: __dirname,
      stdio: ['pipe', 'pipe', 'pipe']
    });
    
    let output = '';
    let errorOutput = '';
    
    statusProcess.stdout.on('data', (data) => {
      output += data.toString();
    });
    
    statusProcess.stderr.on('data', (data) => {
      errorOutput += data.toString();
    });
    
    statusProcess.on('close', (code) => {
      if (code === 0 && output.trim()) {
        try {
          const statusData = JSON.parse(output);
          res.json(statusData);
        } catch (parseError) {
          res.json({
            status: 'no_router',
            message: 'No target router configured'
          });
        }
      } else {
        res.json({
          status: 'no_router',
          message: 'No target router configured'
        });
      }
    });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Serve chat interface
app.get('/chat', (req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.sendFile(path.resolve(__dirname, 'chat.html'));
});

// Middleware to handle UTF-8 encoding for docs
app.use('/docs', (req, res, next) => {
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  next();
});

// Redirect middleware - add .md to URLs without extensions
app.use((req, res, next) => {
  let requestedPath = req.path;
  
  // Handle root path specially
  if (requestedPath === '/') {
    requestedPath = '/index';
  }
  
  // If no extension, check if .md file exists and redirect
  if (!path.extname(requestedPath)) {
    let testPath = requestedPath;
    if (testPath.startsWith('/')) {
      testPath = testPath.slice(1);
    }
    
    const mdFilePath = path.resolve(ROOT_DIR, testPath + '.md');
    
    console.log(`Request: ${req.path} -> Checking for: ${mdFilePath}`);
    
    if (fs.existsSync(mdFilePath)) {
      // Redirect to URL with .md extension
      const redirectUrl = requestedPath + '.md';
      console.log(`Redirecting: ${req.path} -> ${redirectUrl}`);
      return res.redirect(301, redirectUrl);
    }
  }
  
  next();
});

// Static file serving middleware
app.use((req, res, next) => {
  let requestedPath = req.path;
  
  // Remove leading slash for path.join
  if (requestedPath.startsWith('/')) {
    requestedPath = requestedPath.slice(1);
  }
  
  const fullPath = path.resolve(ROOT_DIR, requestedPath);
  
  console.log(`Serving: ${req.path} -> ${fullPath}`);
  
  // Check if file exists
  if (fs.existsSync(fullPath)) {
    // Read file with UTF-8 encoding
    fs.readFile(fullPath, 'utf8', (err, data) => {
      if (err) {
        console.error(`Error reading file: ${err.message}`);
        res.status(500).send('Error reading file');
        return;
      }
      
      // Set appropriate content type based on file extension
      const ext = path.extname(fullPath).toLowerCase();
      if (ext === '.md') {
        res.setHeader('Content-Type', 'text/markdown; charset=utf-8');
      } else if (ext === '.txt') {
        res.setHeader('Content-Type', 'text/plain; charset=utf-8');
      } else if (ext === '.html') {
        res.setHeader('Content-Type', 'text/html; charset=utf-8');
      }
      
      res.send(data);
    });
  } else {
    // File not found, continue to next middleware
    next();
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).send(`File not found: ${req.path}\nTried looking for: ${req.path}.md`);
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).send('Internal server error');
});

app.listen(PORT, () => {
  console.log(`🌍 Server running on http://localhost:${PORT}`);
  console.log(`📁 Serving files from: ${path.resolve(ROOT_DIR)}`);
  console.log(`🔄 Auto-adding .md extension to paths without extensions`);
  console.log(`✨ UTF-8 encoding enabled`);
});