# EventCatalog hosting infrastructure

This Terraform configuration creates a public S3 website bucket and a
CloudFront distribution in front of it. The bucket's objects are publicly
readable, so do not store secrets or private files in the bucket.
The AWS account-level S3 Block Public Access settings must also allow public
bucket policies; account-level settings can override this bucket configuration.

## Configure

The S3 bucket name and CloudFront distribution comment are configured in
`locals.tf`. S3 bucket names are globally unique; if `service-catalog-v4` is
already taken, choose another name there. Set `aws_region` through a `.tfvars`
file or the CLI if you need a region other than `eu-west-1`.

AWS credentials should be configured using your usual AWS CLI or environment
credential provider. No credentials belong in Terraform files.

## Deploy

After initializing and applying the infrastructure, configure AWS CLI
credentials with permission to list and update the bucket, delete stale
objects, and create CloudFront invalidations. From the project root, run:

```sh
npm run deploy
```

The script builds EventCatalog, syncs `dist/` to S3, and requests a CloudFront
invalidation. `aws s3 sync --delete` removes objects from the bucket that are
no longer present in the build output, so use this bucket only for the site.
AWS credentials and region/profile selection are taken from the AWS CLI
configuration and environment.

The S3 website endpoint uses `index.html` as its index document for the root
and subdirectories. Requests for subdirectories without a trailing slash are
redirected by S3 to the slash-terminated URL. The invalidation makes updated
files available immediately when reusing object keys.
