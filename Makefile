.PHONY: all install build cluster-up clean check-docker-image help

# Default target when just running 'make'
all: check-docker-image

# Check if Docker image exists
check-docker-image:
	@echo "Checking for Docker image go-k3-app:v1.0.0..."
	@if ! docker image inspect go-k3-app:v1.0.0 >/dev/null 2>&1; then \
		echo "Docker image not found. Running build..."; \
		$(MAKE) build; \
	else \
		echo "Docker image found. Skipping build."; \
	fi

# Install dependencies and setup k3d cluster
install:
	@echo "Running installation script..."
	@chmod +x ./hack/install.sh
	@./hack/install.sh

# Build the Docker image
build:
	@echo "Building Docker image..."
	@chmod +x ./hack/build.sh
	@./hack/build.sh

# Run the application in the k3d cluster
cluster-up:
	@echo "Setting up application in k3d cluster..."
	@chmod +x ./hack/run.sh
	@./hack/run.sh

# Clean up resources
clean:
	@echo "Cleaning up resources..."
	@kubectl delete ns go-k3-app-ns --ignore-not-found=true
	@echo "Resources cleaned up."

# Show help
help:
	@echo "Available targets:"
	@echo "  make            - Check for Docker image, build if needed, and deploy to cluster"
	@echo "  make install    - Install dependencies and set up k3d cluster"
	@echo "  make build      - Build the Docker image"
	@echo "  make cluster-up - Deploy application to k3d cluster"
	@echo "  make clean      - Remove application from cluster"
	@echo "  make help       - Show this help message"