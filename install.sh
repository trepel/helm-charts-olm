#!/bin/sh
# Quick script to run helm

echo "Installing operators" && \
helm install --values values.yaml --values additionalManifests.yaml --wait kuadrant-operators operators/ && \
echo "\nInstalling instances" && \
helm install --values values.yaml --values additionalManifests.yaml --wait kuadrant-instances instances/ && \
echo "Success!"

