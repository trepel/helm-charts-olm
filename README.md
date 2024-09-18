# Helm chart for deploying Kuadrant and testing environment

This chart requires that your cluster has loadbalancing service.

# What is installed

- Kuadrant-operator
- Red Hat cert-manager
- Sail operator (Istio)
- Gateway API

Testsuite requirements (tools)
- RH Keycloak
- Jaeger
- Mockserver

# How to run

1. Set up values.yaml
2. Create additionalManifests.yaml with list of DNS provider credentials and Letsencrypt issuer. More info about required objects see [testsuite wiki](https://github.com/Kuadrant/testsuite/wiki/Guide-to-prepare-Openshift-cluster-to-run-testsuite)
3. Login to your cluster.
4. Finally run:
```sh
./install.sh
```
5. Enjoy

## Manual helm

1. Install Operators
```sh
helm install --values values.yaml --values additionalManifests.yaml --wait -g operators/
```
4. Install instances (operands)
```
helm install --values values.yaml --values additionalManifests.yaml --wait -g instances/

