#!/bin/sh
# Quick script to uninstall helm

echo "Uninstalling instances" && \
helm uninstall --wait kuadrant-instances
echo "Uninstalling operators" && \
helm uninstall --wait kuadrant-operators && \
kubectl delete ns cert-manager && \
echo "Success!"

