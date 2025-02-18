#!/bin/bash

export ZINC_FIRST_ADMIN_USER=admin
export ZINC_FIRST_ADMIN_PASSWORD=Complexpass@123
export ZINC_DATA_PATH=~/.zincsearch/data
export ZINC_SERVER_ADDRESS=127.0.0.1
export ZINC_SERVER_PORT=4080

zincsearch --config ~/.zincsearch/config.yaml

# Create directories
mkdir -p ~/.zincsearch/data

# # Set permissions
# chmod +x ~/.zincsearch/start-zinc.sh

# # Start ZincSearch
# ~/.zincsearch/start-zinc.sh

# # Create an index
# curl -X POST -H "Content-Type: application/json" -u admin:Complexpass@123 \
#   "http://localhost:4080/api/index" \
#   -d '{"name": "logs", "storage_type": "disk"}'

# # Index a document
# curl -X POST -H "Content-Type: application/json" -u admin:Complexpass@123 \
#   "http://localhost:4080/api/logs/_doc" \
#   -d '{"message": "test log entry", "timestamp": "2024-03-19T10:00:00Z"}'

# # Search
# curl -X POST -H "Content-Type: application/json" -u admin:Complexpass@123 \
#   "http://localhost:4080/api/logs/_search" \
#   -d '{"search_type": "match", "query": {"term": "test"}}'