#!/bin/sh
# Quick script to uninstall helm and kuadrant CRD

cd "$(dirname "$0")" || exit 1
echo "Removing leftover Kuadrant objects"
for crd in $(kubectl get crd -o name | grep "kuadrant" | sed 's/.*\/\(.*\)/\1/'); do
    kubectl get --chunk-size=0 -o name -n "kuadrant" "$crd" |\
    xargs --no-run-if-empty -P 20 -n 1 kubectl delete --ignore-not-found -n "kuadrant"
done

echo "Uninstalling instances"
helm uninstall --ignore-not-found --wait kuadrant-instances
echo "Uninstalling operators"
helm uninstall --ignore-not-found --wait kuadrant-operators && \
kubectl delete --ignore-not-found ns cert-manager && \
kubectl get crd -o name | grep "kuadrant" | xargs --no-run-if-empty kubectl delete && \
echo "Success!"

