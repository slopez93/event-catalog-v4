#!/usr/bin/env bash

set -euo pipefail

export AWS_PAGER=""

infra_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd -- "$infra_dir/.." && pwd)"

for command_name in aws npm terraform; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Error: required command not found: %s\n' "$command_name" >&2
    exit 1
  fi
done

if ! bucket_name="$(terraform -chdir="$infra_dir" output -raw bucket_name)"; then
  printf 'Error: Terraform output "bucket_name" is unavailable. Initialize and apply the infrastructure first.\n' >&2
  exit 1
fi

if ! distribution_id="$(terraform -chdir="$infra_dir" output -raw cloudfront_distribution_id)"; then
  printf 'Error: Terraform output "cloudfront_distribution_id" is unavailable. Initialize and apply the infrastructure first.\n' >&2
  exit 1
fi

printf 'Building EventCatalog...\n'
npm --prefix "$project_root" run build

printf 'Syncing dist/ to s3://%s ...\n' "$bucket_name"
aws s3 sync "$project_root/dist/" "s3://$bucket_name" --delete

printf 'Invalidating CloudFront distribution %s ...\n' "$distribution_id"
aws cloudfront create-invalidation \
  --distribution-id "$distribution_id" \
  --paths '/*'

printf 'Deployment uploaded. CloudFront invalidation has been requested.\n'
