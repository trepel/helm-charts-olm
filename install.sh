#!/bin/bash
# Quick script to run helm

IMAGE="${IMAGE:-quay.io/kuadrant/kuadrant-operator-catalog:nightly-$(date +%d-%m-%Y)}"
CHANNEL="${CHANNEL:-preview}"
DEPLOY_TESTSUITE="${DEPLOY_TESTSUITE:-true}"

if [ "$1" = "-i" ]; then
    printf "What kuadrant image you want?: "
    read -r IMAGE

    printf "What channel you want? 'preview' for nightly, 'stable' for releases: "
    read -r CHANNEL

    printf "Do you want to deploy testsuite environment? 'true' or 'false': "
    read -r DEPLOY_TESTSUITE
fi

if [ "$1" = "-t" ]; then
    echo "Installing with image: $IMAGE channel $CHANNEL"
    echo "Testsuite deploy: $DEPLOY_TESTSUITE"
    echo "---Installing operators---" && \
    helm install \
      --values values.yaml \
      --values additionalManifests.yaml \
      --set kuadrant.indexImage="$IMAGE" \
      --set kuadrant.channel="$CHANNEL" \
      --set tools.enabled="$DEPLOY_TESTSUITE" \
      --wait kuadrant-operators operators/ && \
    echo "--Installing instances---" && \
    helm install \
      --values values.yaml \
      --values additionalManifests.yaml \
      --set kuadrant.indexImage="$IMAGE" \
      --set kuadrant.channel="$CHANNEL" \
      --set tools.enabled="$DEPLOY_TESTSUITE" \
      --wait \
      kuadrant-instances instances/ && \
    ./hack.sh && \
    echo "Success!"
else
    echo "Installing operators" && \
    helm install --values values.yaml --wait kuadrant-operators operators/ && \
    echo "Installing instances" && \
    helm install --values values.yaml --wait kuadrant-instances instances/ && \
    echo "Success!"
fi
