# Deployment Guide

This guide uses placeholders deliberately. Do not commit the files or real identifiers created while following it.

## Local deployment

1. Enable billing and the APIs listed in the README.
2. Create a private, versioned GCS bucket for state.
3. Copy and edit the ignored configuration files:

   ```bash
   cp backend.hcl.example backend.hcl
   cp terraform.tfvars.example terraform.tfvars
   ```

4. Authenticate, initialize, review, and deploy:

   ```bash
   gcloud auth application-default login
   terraform init -backend-config=backend.hcl
   terraform fmt -check -recursive
   terraform validate
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

Plan files can contain sensitive values. Keep them local and review them before applying.

## WIF bootstrap outline

Run these placeholder-based commands with an identity authorized to manage IAM:

```bash
export GCP_PROJECT_ID="YOUR_GCP_PROJECT_ID"
export GITHUB_OWNER="YOUR_GITHUB_OWNER"
export GITHUB_REPOSITORY="YOUR_GITHUB_REPOSITORY"
export PROJECT_NUMBER="$(gcloud projects describe "$GCP_PROJECT_ID" --format='value(projectNumber)')"
export WIF_POOL_ID="github-actions"
export WIF_PROVIDER_ID="github"
export DEPLOYER_SA_ID="github-terraform"

gcloud iam service-accounts create "$DEPLOYER_SA_ID" --project="$GCP_PROJECT_ID"
gcloud iam workload-identity-pools create "$WIF_POOL_ID" \
  --project="$GCP_PROJECT_ID" --location=global --display-name="GitHub Actions"
gcloud iam workload-identity-pools providers create-oidc "$WIF_PROVIDER_ID" \
  --project="$GCP_PROJECT_ID" --location=global \
  --workload-identity-pool="$WIF_POOL_ID" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
  --attribute-condition="assertion.repository=='$GITHUB_OWNER/$GITHUB_REPOSITORY'"
gcloud iam service-accounts add-iam-policy-binding \
  "$DEPLOYER_SA_ID@$GCP_PROJECT_ID.iam.gserviceaccount.com" \
  --project="$GCP_PROJECT_ID" --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$WIF_POOL_ID/attribute.repository/$GITHUB_OWNER/$GITHUB_REPOSITORY"
```

Grant the deployment/backend roles documented in the README, preferably via a custom role. Configure a protected GitHub environment and its documented variables. Do not create a service-account key.

## Verification and removal

Use the README verification commands. To remove resources, create and review a destroy plan, apply only that saved plan, then manage the separately created state bucket under your retention policy.
