#!/bin/sh
# Quick script to uninstall helm and kuadrant CRD

cd "$(dirname "$0")" || exit 1

echo "Uninstalling instances"
helm uninstall --ignore-not-found --wait kuadrant-instances
echo "Uninstalling operators"
helm uninstall --ignore-not-found --wait kuadrant-operators && \
kubectl delete --ignore-not-found ns cert-manager && \
kubectl get crd -o name | grep "kuadrant" | xargs --no-run-if-empty kubectl delete && \
echo "Success!"

