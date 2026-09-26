# Deployment

There are two ways to deploy: from your machine with the Azure CLI, or with the manual GitHub Actions workflow. Both run a what-if first.

## Required permissions

The template works at subscription scope and touches authorization resources (policy assignments, locks). The deploying identity needs:

| Operation | Role |
|---|---|
| Resource group, workspace, diagnostic settings | Contributor |
| Policy assignments | Resource Policy Contributor |
| Defender for Cloud plans, security contacts | Security Admin |
| Resource lock (`Microsoft.Authorization/locks/*`) | Owner, User Access Administrator or a custom role |

`Owner` on the subscription covers everything and is the simplest option for a first deployment. For a pipeline identity, prefer the combination above with a small custom role for locks.

## Local deployment

```bash
az login
az account set --subscription "<subscription-id>"

# Preview
az deployment sub what-if \
  --location westeurope \
  --template-file bicep/main.bicep \
  --parameters bicep/main.dev.bicepparam

# Deploy
az deployment sub create \
  --name zero-trust-foundation-dev \
  --location westeurope \
  --template-file bicep/main.bicep \
  --parameters bicep/main.dev.bicepparam
```

Override single values without editing the parameter file:

```bash
az deployment sub create ... \
  --parameters bicep/main.prod.bicepparam \
  --parameters securityContactEmails='secops@contoso.example'
```

## GitHub Actions with OIDC (no secrets)

The workflow `.github/workflows/deploy.yml` runs only when started manually. It authenticates with a federated credential: GitHub issues a short-lived token per run, and Entra ID exchanges it for an access token. There is no client secret to store, rotate or leak.

### 1. App registration and federated credential per environment

```bash
# One identity per environment
az ad app create --display-name "gh-zero-trust-iac-dev"
APP_ID=$(az ad app list --display-name "gh-zero-trust-iac-dev" --query "[0].appId" -o tsv)
az ad sp create --id "$APP_ID"

# Trust only runs of this repository that target the GitHub environment "dev"
az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-environment-dev",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:<github-owner>/zero-trust-iac:environment:dev",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

The subject `repo:<owner>/<repo>:environment:<name>` restricts the credential to jobs that run in that GitHub environment. A pull request or a different branch cannot obtain the token.

### 2. Role assignments

```bash
SUB="/subscriptions/<subscription-id>"
for ROLE in "Contributor" "Resource Policy Contributor" "Security Admin"; do
  az role assignment create --assignee "$APP_ID" --role "$ROLE" --scope "$SUB"
done
# Plus a custom role (or User Access Administrator) for Microsoft.Authorization/locks/*
```

### 3. GitHub environments

Create the environments `dev` and `prod` under **Settings → Environments** and add these environment secrets:

| Secret | Value |
|---|---|
| `AZURE_CLIENT_ID` | Application (client) ID of the app registration |
| `AZURE_TENANT_ID` | Directory (tenant) ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription ID |

These values are identifiers, not credentials. They are stored as secrets anyway, so they are masked in the public workflow logs.

For `prod`, add **required reviewers** so that every production run needs an approval.

### 4. Run

**Actions → Deploy → Run workflow**, choose the environment and `what-if` or `deploy`. `deploy` always runs the what-if first and applies the template in the same job.

## Removing the foundation

1. Delete the lock `do-not-delete` on the security resource group.
2. Delete the policy assignments `<prefix>-<env>-allowed-locations` and `<prefix>-<env>-allowed-locations-rg`.
3. Delete the diagnostic setting `activity-log-to-security-workspace` on the subscription.
4. Set the Defender plans back to `Free` if they are no longer needed.
5. Delete the resource group.
