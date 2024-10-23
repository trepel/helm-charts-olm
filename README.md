# Helm chart for deploying Kuadrant and testing environment

This chart requires that your cluster has loadbalancing service.

# What is installed

- Kuadrant-operator
- Red Hat cert-manager
- Istio provider (one of)
  - Sail operator
  - Openshift service mesh v2
  - Openshift service mesh v3
- Gateway API

If you choose to deploy testsuite environment by setting `tools.enabled` to true:

- RH Keycloak
- Jaeger
- Mockserver
- `kuadrant` and `kuadrant2` namespaces with additionalManifests.yaml

# How to run

1. Set up values.yaml
2. Login to your cluster.
3. Run:
```sh
./install.sh
```
4. Enjoy

## Testsuite deploy and Environment variables

If you want testsuite environment create additionalManifests.yaml with list of DNS provider credentials and Letsencrypt issuer. More info about required objects see [testsuite wiki](https://github.com/Kuadrant/testsuite/wiki/Guide-to-prepare-Openshift-cluster-to-run-testsuite)
Look at example-additionalManifests.yaml

Set env variables and run `./testsuite.sh -t`

Env vars:
- IMAGE sets `kuadrant.indexImage` and defines image of Kuadrant operator, by default it sets today nightly
- CHANNEL sets `kuadrant.channel` and defines channel of deployed Kuadrant, by default it sets 'preview'
- DEPLOY_TESTSUITE sets `tools.enabled` and defines if to deploy testsuite environment, by default it sets true

## Manual helm

If you do not want to use provided `./install.sh`

1. Install Operators
```sh
helm install --values values.yaml --values additionalManifests.yaml --wait -g operators/
```
2. Install instances (operands)
```sh
helm install --values values.yaml --values additionalManifests.yaml --wait -g instances/
```

# Troubleshooting

## Cannot re-use name

```
$ ./install.sh 
Installing operators
Error: INSTALLATION FAILED: cannot re-use a name that is still in use
```
To fix this execute `helm uninstall kuadrant-operators`

## Unable to continue with install

```
$ ./install.sh 
Installing operators
Error: INSTALLATION FAILED: Unable to continue with install: CustomResourceDefinition "gatewayclasses.gateway.networking.k8s.io" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "kuadrant-operators"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "default"
```
This happens if there are some leftovers there on a cluster. Typically the Kuadrant had been installed on the cluster previously not using Helm. To overcome such issues everything that Helm creates needs to be removed prior to installing via Helm. For this particular error the Gateway API CRDs needed to be removed.
