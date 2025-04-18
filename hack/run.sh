#!/bin/bash
set -e

# Define the namespace and image
NAMESPACE="go-k3-app-ns"
IMAGE="go-k3-app:v1.0.0"
CLUSTER="codespaces-cluster"

# Apply the namespace
echo "Applying namespace..."
kubectl apply -f ./config/namespace.yaml

# Import the Docker image into the k3d cluster
echo "Importing image into k3d cluster..."
k3d image import "$IMAGE" -c "$CLUSTER"

# Apply deployment and service
echo "Applying deployment and service..."
kubectl apply -f ./config/deployment.yaml -f ./config/service.yaml

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=go-k3-app -n "$NAMESPACE" --timeout=60s

# Get the pod status
echo "Getting pod status..."
kubectl get pods -n "$NAMESPACE"
