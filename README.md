# go-k3

k3d cluster create mycluster --agents 0 --servers 1 --no-lb

kubectl get nodes

kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

kubectl port-forward svc/nginx 8080:80

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
