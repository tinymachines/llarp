#!/usr/bin/env python3

import json
import os
import sys
import requests
import hashlib
from typing import List, Dict, Optional, Tuple

# Add paths for our components
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../repos/vectl/build"))
import vector_cluster_store_py

class KnowledgeBridge:
    """Bridge between workflow engine and vectl vector store"""

    def __init__(self,
                 store_path="./workflow_knowledge.bin",
                 ollama_url="http://127.0.0.1:11434",
                 embedding_model="nomic-embed-text"):

        self.store_path = store_path
        self.ollama_url = ollama_url
        self.embedding_model = embedding_model
        self.vector_dim = 768  # nomic-embed-text dimension

        # Initialize vector store
        self._init_vector_store()

        # Load metadata
        self.metadata_file = store_path.replace('.bin', '_metadata.json')
        self.metadata = self._load_metadata()

    def _init_vector_store(self):
        """Initialize the vector store"""
        try:
            # Create logger
            logger = vector_cluster_store_py.Logger(self.store_path.replace('.bin', '.log'))

            # Create and initialize vector store
            self.store = vector_cluster_store_py.VectorClusterStore(logger)

            # Initialize with kmeans clustering
            if not self.store.initialize(self.store_path, "kmeans", self.vector_dim, 10):
                raise Exception(f"Failed to initialize vector store at {self.store_path}")

            print(f"Vector store initialized: {self.store_path}")

        except Exception as e:
            print(f"Vector store initialization failed: {e}")
            self.store = None

    def _load_metadata(self) -> Dict:
        """Load metadata about stored knowledge"""
        if os.path.exists(self.metadata_file):
            try:
                with open(self.metadata_file, 'r') as f:
                    return json.load(f)
            except Exception as e:
                print(f"Error loading metadata: {e}")

        return {
            "next_id": 0,
            "entries": {},
            "vector_dim": self.vector_dim,
            "model": self.embedding_model
        }

    def _save_metadata(self):
        """Save metadata"""
        try:
            with open(self.metadata_file, 'w') as f:
                json.dump(self.metadata, f, indent=2)
        except Exception as e:
            print(f"Error saving metadata: {e}")

    def _get_embedding(self, text: str) -> Optional[List[float]]:
        """Get embedding from ollama"""
        try:
            payload = {
                "model": self.embedding_model,
                "input": text
            }

            response = requests.post(f"{self.ollama_url}/api/embed", json=payload)
            response.raise_for_status()

            data = response.json()
            embedding = data["embeddings"][0]

            # Validate dimension
            if len(embedding) != self.vector_dim:
                print(f"Warning: Embedding dimension mismatch. Got {len(embedding)}, expected {self.vector_dim}")
                if len(embedding) > self.vector_dim:
                    return embedding[:self.vector_dim]
                else:
                    return embedding + [0.0] * (self.vector_dim - len(embedding))

            return embedding

        except Exception as e:
            print(f"Error getting embedding: {e}")
            return None

    def store_knowledge(self, text: str, knowledge_type: str, metadata: Dict = None) -> bool:
        """Store a piece of knowledge in the vector store"""
        if not self.store:
            return False

        embedding = self._get_embedding(text)
        if not embedding:
            return False

        # Prepare metadata
        knowledge_metadata = {
            "text": text,
            "type": knowledge_type,
            "timestamp": __import__('datetime').datetime.now().isoformat(),
            "text_hash": hashlib.md5(text.encode()).hexdigest(),
            **(metadata or {})
        }

        # Store in vector store
        try:
            vector_id = self.metadata["next_id"]
            metadata_json = json.dumps(knowledge_metadata)

            success = self.store.store_vector(vector_id, embedding, metadata_json)

            if success:
                # Update local metadata
                self.metadata["entries"][str(vector_id)] = knowledge_metadata
                self.metadata["next_id"] = vector_id + 1
                self._save_metadata()

                print(f"Stored knowledge: {knowledge_type} - ID {vector_id}")
                return True

        except Exception as e:
            print(f"Error storing knowledge: {e}")

        return False

    def search_knowledge(self, query: str, k: int = 5, knowledge_type: str = None) -> List[Dict]:
        """Search for similar knowledge"""
        if not self.store:
            return []

        embedding = self._get_embedding(query)
        if not embedding:
            return []

        try:
            # Search for similar vectors
            results = self.store.find_similar_vectors(embedding, k * 2)  # Get more results to filter

            if not results:
                return []

            # Process and filter results
            knowledge_results = []

            for vector_id, similarity in results:
                try:
                    # Get metadata from vector store
                    metadata_json = self.store.get_vector_metadata(vector_id)

                    if metadata_json:
                        knowledge_metadata = json.loads(metadata_json)

                        # Filter by knowledge type if specified
                        if knowledge_type and knowledge_metadata.get("type") != knowledge_type:
                            continue

                        result = {
                            "id": vector_id,
                            "similarity": similarity,
                            "text": knowledge_metadata.get("text", ""),
                            "type": knowledge_metadata.get("type", "unknown"),
                            "metadata": knowledge_metadata
                        }

                        knowledge_results.append(result)

                        # Stop if we have enough results
                        if len(knowledge_results) >= k:
                            break

                except Exception as e:
                    print(f"Error processing search result {vector_id}: {e}")
                    continue

            # Sort by similarity (highest first)
            knowledge_results.sort(key=lambda x: x["similarity"], reverse=True)

            return knowledge_results[:k]

        except Exception as e:
            print(f"Error searching knowledge: {e}")
            return []

    def index_lego_scripts(self, lego_path: str = "../llarp-scripts") -> int:
        """Index all lego scripts into the knowledge base"""
        indexed_count = 0

        if not os.path.exists(lego_path):
            print(f"Lego path not found: {lego_path}")
            return 0

        for filename in os.listdir(lego_path):
            if filename.endswith('.sh'):
                filepath = os.path.join(lego_path, filename)

                try:
                    with open(filepath, 'r') as f:
                        content = f.read()

                    # Extract description and functionality
                    description = self._extract_script_description(content)
                    functionality = self._extract_script_functionality(content)

                    # Create knowledge text
                    knowledge_text = f"""Script: {filename}
Description: {description}
Functionality: {functionality}
Content preview: {content[:500]}"""

                    # Store in knowledge base
                    metadata = {
                        "filename": filename,
                        "filepath": filepath,
                        "description": description,
                        "functionality": functionality,
                        "size": len(content)
                    }

                    if self.store_knowledge(knowledge_text, "lego_script", metadata):
                        indexed_count += 1

                except Exception as e:
                    print(f"Error indexing {filename}: {e}")

        print(f"Indexed {indexed_count} lego scripts")
        return indexed_count

    def _extract_script_description(self, content: str) -> str:
        """Extract description from script comments"""
        lines = content.split('\n')

        # Look for description in first 10 lines
        for line in lines[:10]:
            line = line.strip()
            if line.startswith('#') and len(line) > 3:
                desc = line[1:].strip()
                if len(desc) > 10 and not desc.startswith('!'):
                    return desc

        return "No description available"

    def _extract_script_functionality(self, content: str) -> str:
        """Extract functionality keywords from script content"""
        keywords = []

        # Look for UCI commands
        uci_commands = ['uci set', 'uci add', 'uci delete', 'uci commit']
        for cmd in uci_commands:
            if cmd in content:
                keywords.append('uci_config')
                break

        # Look for specific functions
        functions = {
            'wifi': ['wifi', 'wireless', 'ssid'],
            'firewall': ['firewall', 'iptables', 'fw3'],
            'network': ['network', 'interface', 'br-lan'],
            'dhcp': ['dhcp', 'dnsmasq'],
            'ssh': ['ssh', 'dropbear'],
            'system': ['hostname', 'system', 'timezone']
        }

        for func, patterns in functions.items():
            if any(pattern in content.lower() for pattern in patterns):
                keywords.append(func)

        return ', '.join(keywords) if keywords else 'general'

    def get_stats(self) -> Dict:
        """Get statistics about the knowledge base"""
        stats = {
            "total_entries": self.metadata["next_id"],
            "stored_entries": len(self.metadata["entries"]),
            "vector_dimension": self.metadata["vector_dim"],
            "embedding_model": self.metadata["model"]
        }

        # Count by knowledge type
        type_counts = {}
        for entry in self.metadata["entries"].values():
            entry_type = entry.get("type", "unknown")
            type_counts[entry_type] = type_counts.get(entry_type, 0) + 1

        stats["type_distribution"] = type_counts

        return stats

def main():
    """CLI interface for knowledge bridge"""
    import argparse

    parser = argparse.ArgumentParser(description="LLARP Knowledge Bridge")
    parser.add_argument("--index-legos", action="store_true", help="Index lego scripts")
    parser.add_argument("--search", type=str, help="Search knowledge base")
    parser.add_argument("--stats", action="store_true", help="Show statistics")
    parser.add_argument("--store", type=str, help="Store knowledge text")
    parser.add_argument("--type", type=str, default="manual", help="Knowledge type for storing")

    args = parser.parse_args()

    bridge = KnowledgeBridge()

    if args.index_legos:
        count = bridge.index_lego_scripts()
        print(f"Indexed {count} lego scripts")

    elif args.search:
        results = bridge.search_knowledge(args.search)
        print(f"\nSearch results for: '{args.search}'")
        print("-" * 50)

        for result in results:
            print(f"ID: {result['id']} | Score: {result['similarity']:.3f} | Type: {result['type']}")
            print(f"Text: {result['text'][:200]}...")
            print("-" * 50)

    elif args.store:
        success = bridge.store_knowledge(args.store, args.type)
        print(f"Storage {'successful' if success else 'failed'}")

    elif args.stats:
        stats = bridge.get_stats()
        print("Knowledge Base Statistics:")
        print(json.dumps(stats, indent=2))

    else:
        print("Use --help for usage options")

if __name__ == "__main__":
    main()