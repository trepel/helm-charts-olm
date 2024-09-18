#!/bin/bash

PASS=$(kubectl get -n tools secret keycloak-initial-admin --template={{.data.password}} | base64 --decode)
kubectl create -n tools secret generic credential-sso --from-literal=ADMIN_USERNAME=admin --from-literal=ADMIN_PASSWORD=$PASS

