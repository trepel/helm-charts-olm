#!/bin/bash
# Quick script to run Helm for installing tools

set -e; set -o pipefail;

cd "$(dirname "$0")"

echo "--Installing tools operators"
helm install --wait tools-operators tools/operators

echo "--Installing tools instances"
helm install --wait --timeout 10m tools-instances tools/instances
