#!/bin/bash
set -e

NAMESPACE="go-k3-app-ns"
IMAGE="go-k3-app:v1.0.0"
CLUSTER="codespaces-cluster"

echo "Applying namespace..."
kubectl apply -f ./config/namespace.yaml

echo "Applying Prometheus RBAC rules"              # ← new
kubectl apply -f ./config/rbac.yaml 

echo "Importing image into k3d cluster..."
k3d image import "$IMAGE" -c "$CLUSTER"

echo "Applying deployment and service..."
kubectl apply -f ./config/deployment.yaml -f ./config/service.yaml

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=go-k3-app -n "go-k3-app-ns" --timeout=60s

echo "Getting pod status..."
kubectl get pods -n "$NAMESPACE"

# Start port forwarding in the background
echo "Starting port forwarding in background..."
kubectl port-forward svc/go-k3-app-service 8080:80 -n "$NAMESPACE" > /dev/null 2>&1 &

PF_PID=$!
echo "Port forwarding started with PID: $PF_PID"
echo "Application is now accessible at http://localhost:8080"
echo "To stop port forwarding: kill $PF_PID"