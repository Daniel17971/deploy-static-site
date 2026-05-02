# Deploy — Static Site on AWS

Hosts the Next.js static export on **S3 + CloudFront** with an **ACM TLS certificate** and **Route53** DNS.

```
Internet → Route53 (A alias) → CloudFront → S3 (private bucket)
```

---

## Prerequisites

| What | Why |
|------|-----|
| AWS CLI configured (`aws configure`) | Terraform uses your local credentials |
| Terraform ≥ 1.5 | `brew install terraform` |
| A Route53 **hosted zone** for your domain | Terraform looks it up by name — it must exist before you run `apply` |
| Domain registered and nameservers pointing to Route53 | Required for DNS validation of the ACM cert |

### One manual step — create the Route53 hosted zone

Terraform reads the hosted zone but does not create it (creating it in Terraform would tie domain registration to infra state, which is risky to destroy).

1. Go to **Route53 → Hosted zones → Create hosted zone**
2. Enter your apex domain (e.g. `example.com`), type **Public**
3. Note the four NS records that are generated
4. In your domain registrar, set the nameservers to those four values

That's the only AWS console step required.

---

## First deploy

```bash
cd deploy/

# 1. Initialise Terraform
terraform init

# 2. Preview changes
terraform plan -var="domain_name=example.com"

# 3. Apply (takes ~5 min — ACM validation waits for DNS propagation)
terraform apply -var="domain_name=example.com"
```

To avoid typing the variable every time, create a local var file (already gitignored):

```bash
echo 'domain_name = "example.com"' > terraform.tfvars
```

Then just run `terraform plan` / `terraform apply`.

---

## Deploying site content

After `terraform apply` succeeds, upload the Next.js static export to S3 and invalidate the CloudFront cache:

```bash
# 1. Build the static export
cd ../frontend/app
next build        # produces the `out/` directory

# 2. Sync to S3 (replace BUCKET with the value from `terraform output s3_bucket_name`)
aws s3 sync out/ s3://BUCKET --delete

# 3. Invalidate CloudFront cache (replace DIST_ID with `terraform output cloudfront_distribution_id`)
aws cloudfront create-invalidation --distribution-id DIST_ID --paths "/*"
```

> Next.js must be configured for static export. Add `output: 'export'` to `next.config.ts` if it isn't already.

---

## Architecture notes

| Resource | Detail |
|----------|--------|
| S3 bucket | Private — no public access. Only CloudFront can read it via OAC. |
| CloudFront OAC | SigV4-signed requests from CloudFront to S3 (replaces legacy OAI). |
| ACM certificate | Provisioned in `us-east-1` (required by CloudFront). Validated via DNS records written to Route53 automatically by Terraform. |
| Price class | `PriceClass_100` — US, Canada, Europe only. Change to `PriceClass_All` for global edge coverage. |
| 404 handling | CloudFront rewrites 403/404 → `index.html` / `404.html` for client-side routing. |
| Aliases | Both `example.com` and `www.example.com` are served by the same distribution. |

---

## Tear down

```bash
# Empty the bucket first (S3 won't delete a non-empty bucket)
aws s3 rm s3://BUCKET --recursive

terraform destroy -var="domain_name=example.com"
```
