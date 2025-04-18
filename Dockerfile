FROM mcr.microsoft.com/devcontainers/go:1.23

RUN curl -sfL https://get.k3s.io | sh -s - --disable traefik --disable servicelb

ENV KUBECONFIG=/etc/rancher/k3s/k3s.yaml
