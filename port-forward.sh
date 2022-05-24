#!/bin/bash
HOST_PORT=54321

echo "Port-forwarding pgAdmin..."
kubectl port-forward --namespace pgsql-pgadmin service/pgadmin $HOST_PORT:80