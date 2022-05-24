#!/bin/bash
PGSQL_PGADMIN_NAMESPACE=pgsql-pgadmin

echo "Installing kubectl..."
sudo snap install kubectl --classic
echo "Installing helm..."
sudo snap install helm --classic

echo "Installing minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo apt install ./minikube_latest_amd64.deb

echo "Starting minikube..."
echo "Remember, you may need to start minikube every reboot with minikube start"
minikube start

echo "Adding bitnami repo to helm..."
helm repo add bitnami https://charts.bitnami.com/bitnami

# namespace=pgsql-pgadmin
echo "Creating and using $PGSQL_PGADMIN_NAMESPACE namespace..."
kubectl create namespace $PGSQL_PGADMIN_NAMESPACE
kubectl config set-context --current --namespace=$PGSQL_PGADMIN_NAMESPACE

echo "Creating persistent volume and claims..."
kubectl apply -f ./configs/pgsql/postgres-pv.yaml
kubectl apply -f ./configs/pgsql/postgres-pvc.yaml

echo "Installing PostgreSQL with newly made persistent volume claim and permissions..."
helm install my-release bitnami/postgresql \
        --set persistence.existingClaim=postgresql-pv-claim \
        --set volumePermissions.enabled=true

echo "PostgreSQL credentials: postgres:$(kubectl get secret --namespace pgsql-pgadmin my-release-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)"

echo "Deploying pgAdmin using predefined configs..."
kubectl apply -f ./configs/pgadmin/pgadmin-pvc.yaml
kubectl apply -f ./configs/pgadmin/pgadmin-configmap.yaml
kubectl apply -f ./configs/pgadmin/pgadmin-secret.yaml
kubectl apply -f ./configs/pgadmin/pgadmin-deployment.yaml
kubectl apply -f ./configs/pgadmin/pgadmin-svc.yaml

echo "Done!"
echo "Don't forget to port-forward pgAdmin using kubectl port-forward."