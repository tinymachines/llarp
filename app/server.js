const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 8222;
const ROOT_DIR = '../openwrt/openwrt.org.md';

// Middleware to handle UTF-8 encoding
app.use((req, res, next) => {
  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
  next();
});

// Redirect middleware - add .md to URLs without extensions
app.use((req, res, next) => {
  let requestedPath = req.path;
  
  // If no extension, check if .md file exists and redirect
  if (!path.extname(requestedPath)) {
    let testPath = requestedPath;
    if (testPath.startsWith('/')) {
      testPath = testPath.slice(1);
    }
    
    const mdFilePath = path.resolve(ROOT_DIR, testPath + '.md');
    
    console.log(`Request: ${requestedPath} -> Checking for: ${mdFilePath}`);
    
    if (fs.existsSync(mdFilePath)) {
      // Redirect to URL with .md extension
      const redirectUrl = requestedPath + '.md';
      console.log(`Redirecting: ${requestedPath} -> ${redirectUrl}`);
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