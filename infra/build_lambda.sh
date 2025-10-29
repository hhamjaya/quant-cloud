#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
rm -f lambda.zip
# create zip at repo root to make path simple in Terraform
(cd backend && zip -r ../lambda.zip handler.py requirements.txt >/dev/null)
echo "Built lambda.zip"