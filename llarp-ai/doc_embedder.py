#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OpenWRT Documentation Embedder
Processes markdown files and creates vector embeddings using Ollama
"""

import os
import sys
import json
import requests
import time
from pathlib import Path
from datetime import datetime
import hashlib

# Add vectl to path
vectl_build_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../repos/vectl/build")
sys.path.append(vectl_build_path)

try:
    import vector_cluster_store_py
    VECTOR_STORE_AVAILABLE = True
except ImportError as e:
    print(f"⚠️  Could not import vector_cluster_store_py from {vectl_build_path}")
    print(f"   Error: {e}")
    print(f"   Running in fallback mode without vector storage.")
    print(f"   To enable vector storage: cd repos/vectl && source ~/.pyenv/versions/tinymachines/bin/activate && ./build.sh")
    VECTOR_STORE_AVAILABLE = False
    vector_cluster_store_py = None

# Configuration
OLLAMA_API_URL = "http://127.0.0.1:11434/api/embed"
EMBEDDING_MODEL = "nomic-embed-text:v1.5"  # or "embedding-gemma:300m"
VECTOR_DIM = 768
DOCS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../openwrt/openwrt.org.md")
VECTOR_STORE_PATH = "./openwrt_docs.bin"
LOG_FILE = "./openwrt_embedder.log"
METADATA_FILE = "./openwrt_docs_metadata.json"

class OpenWRTDocEmbedder:
    def __init__(self):
        self.vector_store = None
        self.metadata = {"next_id": 0, "entries": {}, "vector_dim": VECTOR_DIM, "files_processed": {}}
        self.logger = None
        
    def init_vector_store(self):
        """Initialize the vector store"""
        if not VECTOR_STORE_AVAILABLE:
            print("⚠️  Vector store not available - running in fallback mode")
            print("   Documents will be processed but not stored in vector database")
            return True
            
        try:
            self.logger = vector_cluster_store_py.Logger(LOG_FILE)
            self.vector_store = vector_cluster_store_py.VectorClusterStore(self.logger)
            
            if not self.vector_store.initialize(VECTOR_STORE_PATH, "kmeans", VECTOR_DIM, 20):
                print(f"Error initializing vector store. Check log: {LOG_FILE}")
                return False
                
            print("✅ Vector store initialized successfully")
            return True
            
        except Exception as e:
            print(f"❌ Error initializing vector store: {e}")
            return False
    
    def load_metadata(self):
        """Load existing metadata"""
        if os.path.exists(METADATA_FILE):
            try:
                with open(METADATA_FILE, 'r') as f:
                    self.metadata = json.load(f)
                print(f"📁 Loaded metadata: {len(self.metadata['entries'])} entries")
                return True
            except Exception as e:
                print(f"⚠️ Error loading metadata: {e}")
        return False
    
    def save_metadata(self):
        """Save metadata to file"""
        try:
            with open(METADATA_FILE, 'w') as f:
                json.dump(self.metadata, f, indent=2)
            return True
        except Exception as e:
            print(f"❌ Error saving metadata: {e}")
            return False
    
    def get_embedding(self, text):
        """Get embedding from Ollama"""
        try:
            payload = {
                "model": EMBEDDING_MODEL,
                "input": text
            }
            
            response = requests.post(OLLAMA_API_URL, json=payload, timeout=30)
            response.raise_for_status()
            data = response.json()
            
            embedding = data["embeddings"][0]
            
            if len(embedding) != VECTOR_DIM:
                print(f"⚠️ Embedding dimension mismatch: got {len(embedding)}, expected {VECTOR_DIM}")
                if len(embedding) > VECTOR_DIM:
                    return embedding[:VECTOR_DIM]
                else:
                    return embedding + [0.0] * (VECTOR_DIM - len(embedding))
            
            return embedding
            
        except Exception as e:
            print(f"❌ Error getting embedding: {e}")
            return None
    
    def process_markdown_file(self, file_path):
        """Process a single markdown file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Calculate file hash for change detection
            file_hash = hashlib.md5(content.encode('utf-8')).hexdigest()
            
            # Get relative path - resolve both paths to absolute first
            docs_path_resolved = Path(DOCS_PATH).resolve()
            file_path_resolved = Path(file_path).resolve()
            
            try:
                relative_path = str(file_path_resolved.relative_to(docs_path_resolved))
            except ValueError:
                # If relative_to fails, use a fallback approach
                relative_path = str(file_path_resolved).replace(str(docs_path_resolved), "").lstrip("/")
            
            # Check if file has changed
            if relative_path in self.metadata["files_processed"]:
                stored_hash = self.metadata["files_processed"][relative_path].get("hash")
                if stored_hash == file_hash:
                    print(f"⏭️ Skipping {relative_path} (unchanged)")
                    return True
            
            print(f"📝 Processing: {relative_path}")
            
            # Split content into chunks (for large files)
            chunks = self.split_content(content, relative_path)
            
            chunk_ids = []
            for i, chunk in enumerate(chunks):
                if len(chunk.strip()) < 50:  # Skip very short chunks
                    continue
                    
                embedding = self.get_embedding(chunk)
                if embedding is None:
                    continue
                
                # Prepare metadata
                metadata_entry = {
                    "file_path": relative_path,
                    "chunk_index": i,
                    "total_chunks": len(chunks),
                    "text": chunk,
                    "text_preview": chunk[:200] + "..." if len(chunk) > 200 else chunk,
                    "timestamp": datetime.now().isoformat(),
                    "embedding_model": EMBEDDING_MODEL,
                    "file_hash": file_hash
                }
                
                # Store in vector database (if available)
                vector_id = self.metadata["next_id"]
                metadata_json = json.dumps(metadata_entry)
                
                if VECTOR_STORE_AVAILABLE and self.vector_store:
                    if self.vector_store.store_vector(vector_id, embedding, metadata_json):
                        self.metadata["entries"][str(vector_id)] = metadata_entry
                        chunk_ids.append(vector_id)
                        self.metadata["next_id"] += 1
                        print(f"  ✅ Stored chunk {i+1}/{len(chunks)} as ID {vector_id}")
                    else:
                        print(f"  ❌ Failed to store chunk {i+1}")
                else:
                    # Fallback mode - just store metadata
                    self.metadata["entries"][str(vector_id)] = metadata_entry
                    chunk_ids.append(vector_id)
                    self.metadata["next_id"] += 1
                    print(f"  📝 Processed chunk {i+1}/{len(chunks)} as ID {vector_id} (fallback mode)")
            
            # Update file processing record
            self.metadata["files_processed"][relative_path] = {
                "hash": file_hash,
                "chunk_ids": chunk_ids,
                "processed_at": datetime.now().isoformat(),
                "chunk_count": len(chunk_ids)
            }
            
            return True
            
        except Exception as e:
            print(f"❌ Error processing {file_path}: {e}")
            return False
    
    def split_content(self, content, file_path):
        """Split content into manageable chunks"""
        # For markdown files, split by headers and paragraphs
        chunks = []
        
        # Split by double newlines (paragraphs)
        paragraphs = content.split('\n\n')
        
        current_chunk = ""
        current_size = 0
        max_chunk_size = 1500  # Characters per chunk
        
        for paragraph in paragraphs:
            paragraph = paragraph.strip()
            if not paragraph:
                continue
                
            # If adding this paragraph would exceed max size, save current chunk
            if current_size + len(paragraph) > max_chunk_size and current_chunk:
                chunks.append(current_chunk.strip())
                current_chunk = ""
                current_size = 0
            
            # Add file path context to first chunk
            if not current_chunk and chunks == []:
                current_chunk = f"File: {file_path}\n\n"
                current_size = len(current_chunk)
            
            current_chunk += paragraph + "\n\n"
            current_size += len(paragraph) + 2
        
        # Add remaining content
        if current_chunk.strip():
            chunks.append(current_chunk.strip())
        
        return chunks if chunks else [content]  # Fallback to full content
    
    def process_all_docs(self):
        """Process all markdown files in the docs directory"""
        docs_path = Path(DOCS_PATH).resolve()
        if not docs_path.exists():
            print(f"❌ Documentation path not found: {docs_path}")
            return False
        
        print(f"🔍 Scanning for markdown files in: {docs_path}")
        print(f"📁 Resolved docs path: {docs_path}")
        
        # Find all .md files
        md_files = list(docs_path.rglob("*.md"))
        print(f"📚 Found {len(md_files)} markdown files")
        
        if not md_files:
            print("⚠️ No markdown files found!")
            return False
        
        processed = 0
        failed = 0
        
        for md_file in md_files:
            try:
                if self.process_markdown_file(md_file):
                    processed += 1
                else:
                    failed += 1
                    
                # Save metadata periodically
                if processed % 10 == 0:
                    self.save_metadata()
                    
            except KeyboardInterrupt:
                print("\n⚠️ Processing interrupted by user")
                break
            except Exception as e:
                print(f"❌ Unexpected error processing {md_file}: {e}")
                failed += 1
        
        # Final save
        self.save_metadata()
        
        print(f"\n📊 Processing complete:")
        print(f"  ✅ Processed: {processed} files")
        print(f"  ❌ Failed: {failed} files")
        print(f"  📦 Total vectors: {self.metadata['next_id']}")
        
        return True
    
    def search_docs(self, query, k=5):
        """Search the embedded documentation"""
        if not self.vector_store:
            print("❌ Vector store not initialized")
            return []
        
        print(f"🔍 Searching for: '{query}'")
        
        embedding = self.get_embedding(query)
        if embedding is None:
            return []
        
        try:
            results = self.vector_store.find_similar_vectors(embedding, k)
            
            if results:
                print(f"\n📋 Top {len(results)} matches:")
                print("-" * 80)
                
                matches = []
                for vector_id, similarity in sorted(results, key=lambda x: x[1], reverse=True):
                    # Get metadata from vector store
                    metadata_json = self.vector_store.get_vector_metadata(vector_id)
                    if metadata_json:
                        metadata_entry = json.loads(metadata_json)
                        file_path = metadata_entry.get("file_path", "Unknown")
                        text_preview = metadata_entry.get("text_preview", "Unknown")
                        chunk_info = f"chunk {metadata_entry.get('chunk_index', 0)+1}/{metadata_entry.get('total_chunks', 1)}"
                        
                        print(f"ID: {vector_id:4} | Score: {similarity:.4f}")
                        print(f"File: {file_path} ({chunk_info})")
                        print(f"Text: {text_preview}")
                        print("-" * 80)
                        
                        matches.append({
                            "id": vector_id,
                            "similarity": similarity,
                            "file_path": file_path,
                            "text": metadata_entry.get("text", ""),
                            "metadata": metadata_entry
                        })
                
                return matches
            else:
                print("❌ No results found")
                return []
                
        except Exception as e:
            print(f"❌ Search error: {e}")
            return []

def main():
    if len(sys.argv) > 1:
        command = sys.argv[1]
    else:
        command = "process"
    
    embedder = OpenWRTDocEmbedder()
    
    if not embedder.init_vector_store():
        return 1
    
    embedder.load_metadata()
    
    if command == "process":
        print("🚀 Starting OpenWRT documentation embedding...")
        if embedder.process_all_docs():
            print("✅ Embedding complete!")
        else:
            print("❌ Embedding failed!")
            return 1
            
    elif command == "search":
        if len(sys.argv) < 3:
            print("Usage: python doc_embedder.py search <query>")
            return 1
        
        query = " ".join(sys.argv[2:])
        embedder.search_docs(query)
        
    elif command == "info":
        print(f"📊 Vector Store Info:")
        print(f"  📁 Store file: {VECTOR_STORE_PATH}")
        print(f"  📦 Total vectors: {embedder.metadata['next_id']}")
        print(f"  📚 Files processed: {len(embedder.metadata['files_processed'])}")
        print(f"  🤖 Embedding model: {EMBEDDING_MODEL}")
        print(f"  📏 Vector dimension: {VECTOR_DIM}")
        
        if embedder.vector_store:
            embedder.vector_store.print_store_info()
    
    else:
        print("Usage: python doc_embedder.py [process|search|info]")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())