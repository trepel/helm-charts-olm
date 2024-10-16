#!/bin/sh
# Quick script to uninstall helm and kuadrant CRD

echo "Uninstalling instances" && \
helm uninstall --wait kuadrant-instances
echo "Uninstalling operators" && \
helm uninstall --wait kuadrant-operators && \
kubectl delete ns cert-manager && \
kubectl get crd -o name | grep "kuadrant" | xargs kubectl delete && \
echo "Success!"

