#!/bin/bash
set -e

echo "Setting up Prometheus..."
kubectl apply -f ./config/prom-config.yaml
kubectl apply -f ./config/prom-service.yaml -f ./config/prom-deployment.yaml

echo "Setting up Grafana..."
kubectl apply -f ./config/grafana-service.yaml -f ./config/grafana-deployment.yaml

echo "Waiting for monitoring deployments to be ready..."
kubectl wait --for=condition=available deployment/prometheus -n go-k3-app-ns --timeout=60s
kubectl wait --for=condition=available deployment/grafana -n go-k3-app-ns --timeout=60s

echo "Setting up port forwarding for monitoring tools..."
kubectl port-forward svc/prometheus-service 9090:9090 -n go-k3-app-ns > /dev/null 2>&1 &
PROMETHEUS_PID=$!

kubectl port-forward svc/grafana-service 3000:3000 -n go-k3-app-ns > /dev/null 2>&1 &
GRAFANA_PID=$!

echo "Monitoring setup complete!"
echo "Prometheus is now accessible at http://localhost:9090"
echo "Grafana is now accessible at http://localhost:3000"
echo ""
echo "To stop port forwarding:"
echo "  kill $PROMETHEUS_PID  # Stop Prometheus port forwarding"
echo "  kill $GRAFANA_PID     # Stop Grafana port forwarding"