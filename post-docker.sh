#!/bin/bash
NC='\033[0m'
RED='\033[1;31m'
PGSQL_RELEASE_NAME=postgresql-release
PGSQL_PGADMIN_NAMESPACE=pgsql-pgadmin

echo -e "${RED}Installing kubectl...${NC}"
sudo snap install kubectl --classic
echo -e "${RED}Installing helm...${NC}"
sudo snap install helm --classic

echo -e "${RED}Installing minikube...${NC}"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo apt install --yes ./minikube_latest_amd64.deb

echo -e "${RED}Starting minikube...${NC}"
echo -e "${RED}Remember, you may need to start minikube every reboot with minikube start${NC}"
minikube start

echo -e "${RED}Adding bitnami repo to helm...${NC}"
helm repo add bitnami https://charts.bitnami.com/bitnami

# namespace=pgsql-pgadmin
echo -e "${RED}Creating and using $PGSQL_PGADMIN_NAMESPACE namespace...${NC}"
kubectl create namespace $PGSQL_PGADMIN_NAMESPACE
kubectl config set-context --current --namespace=$PGSQL_PGADMIN_NAMESPACE

echo -e "${RED}Creating persistent volume and claims...${NC}"
kubectl apply -f ./configs/pgsql/postgres-pv.yaml
kubectl apply -f ./configs/pgsql/postgres-pvc.yaml

echo -e "${RED}Installing PostgreSQL with newly made persistent volume claim and permissions...${NC}"
helm install $PGSQL_RELEASE_NAME bitnami/postgresql \
        --set persistence.existingClaim=postgresql-pv-claim \
        --set volumePermissions.enabled=true

echo -e "${RED}PostgreSQL credentials: postgres:$(kubectl get secret --namespace pgsql-pgadmin my-release-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)${NC}"

echo -e "${RED}Deploying pgAdmin using predefined configs...${NC}"
kubectl apply -f ./configs/pgadmin/pgadmin-pvc.yaml
kubectl apply -f ./configs/pgadmin/pgadmin-configmap.yaml
kubectl apply -f ./configs/pgadmin/pgadmin-secret.yaml
kubectl apply -f ./configs/pgadmin/pgadmin-deployment.yaml
kubectl apply -f ./configs/pgadmin/pgadmin-svc.yaml

echo -e "${RED}Done!${NC}"
echo -e "${RED}Don't forget to port-forward pgAdmin using kubectl port-forward.${NC}"