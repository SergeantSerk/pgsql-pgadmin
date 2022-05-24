#!/bin/bash
NC='\033[0m'
RED='\033[1;31m'
HOST_PORT=54321

echo -e "${RED}Port-forwarding pgAdmin...${NC}"
kubectl port-forward --namespace pgsql-pgadmin service/pgadmin $HOST_PORT:80