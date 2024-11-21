#!/bin/bash

USER=$(kubectl get -n tools secret keycloak-initial-admin --template="{{.data.username}}" | base64 -d)
PASS=$(kubectl get -n tools secret keycloak-initial-admin --template="{{.data.password}}" | base64 -d)
kubectl create -n tools secret generic credential-sso --from-literal="ADMIN_USERNAME=$USER" --from-literal="ADMIN_PASSWORD=$PASS"

