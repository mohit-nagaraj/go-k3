#!/bin/bash
set -e

echo "📦 Starting K3s + Docker + Go install..."

install_go() {
    # Universal Go installation using official tarball
    local GO_VERSION="1.22.2"
    
    echo "🔧 Installing Go ${GO_VERSION}..."
    if ! command -v go &> /dev/null; then
        wget -q https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
        rm go${GO_VERSION}.linux-amd64.tar.gz
        echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
        source ~/.bashrc
        echo "✅ Go ${GO_VERSION} installed."
    else
        echo "✅ Go is already installed: $(go version)"
    fi
}

install_kubectl() {
    # Universal kubectl installation
    if ! command -v kubectl &> /dev/null; then
        echo "📥 Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
        echo "✅ kubectl installed: $(kubectl version --client --short 2>/dev/null)"
    else
        echo "✅ kubectl is already installed: $(kubectl version --client --short 2>/dev/null)"
    fi
}

if [ "$CODESPACES" = "true" ] || grep -qa "CODESPACES" /proc/1/environ 2>/dev/null; then
    echo "💻 Detected GitHub Codespaces environment."

    echo "📥 Installing K3s with k3d..."
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
    k3d cluster create codespaces-cluster
    
    install_kubectl
    install_go
else
    echo "🖥️  Detected Local Linux environment: $(uname -a)"
    
    # Package manager detection
    if command -v apt-get &> /dev/null; then
        PKG_MGR="apt"
    elif command -v dnf &> /dev/null; then
        PKG_MGR="dnf"
    elif command -v yum &> /dev/null; then
        PKG_MGR="yum"
    else
        echo "❌ Unsupported package manager. Only apt/dnf/yum supported."
        exit 1
    fi

    # Install Docker
    if ! command -v docker &> /dev/null; then
        echo "🐳 Installing Docker..."
        case $PKG_MGR in
            "apt")
                sudo apt-get update
                sudo apt-get install -y docker.io
                ;;
            "dnf"|"yum")
                sudo $PKG_MGR install -y docker
                ;;
        esac
        sudo systemctl enable --now docker
        echo "✅ Docker installed: $(docker --version)"
    else
        echo "✅ Docker is already installed: $(docker --version)"
    fi

    # Install K3s
    if ! command -v k3s &> /dev/null; then
        echo "☁️  Installing K3s (no traefik/servicelb)..."
        curl -sfL https://get.k3s.io | sh -s - --disable traefik --disable servicelb --write-kubeconfig-mode 644
        # Add kubectl symlink
        sudo ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl
    else
        echo "✅ K3s is already installed."
    fi

    install_kubectl
    install_go
fi

echo "🔍 Final checks:"
kubectl cluster-info
echo "Nodes:"
kubectl get nodes

echo "🎉 Done! Environment ready for development."