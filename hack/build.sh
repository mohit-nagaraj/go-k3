#!/bin/bash

# Step 1: Navigate to the app directory
cd ./app || exit

# Step 2: Build the Docker image
echo "Building Docker image 'go-k3-app'..."
docker build -t go-k3-app:v1.0.0 .

# Step 3: Return to the root directory
cd ..

# Done
echo "✅ Docker image 'go-k3-app' built successfully."
