# Zero Trust IaC

Bicep templates for the security foundation of an Azure subscription: central security logging, Microsoft Defender for Cloud, alert routing and policy guardrails. One deployment at subscription scope, parameterised per environment, deployable from the CLI or from GitHub Actions with OIDC and without any stored secret.

[![CI](https://github.com/spoke1/zero-trust-iac/actions/workflows/ci.yml/badge.svg)](https://github.com/spoke1/zero-trust-iac/actions/workflows/ci.yml)
![Bicep](https://img.shields.io/badge/IaC-Bicep-0078D4?logo=microsoftazure&logoColor=white)
![Scope](https://img.shields.io/badge/scope-subscription-5C2D91)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## What gets deployed

| Resource | Purpose | Zero Trust principle |
|---|---|---|
| Resource group `rg-<prefix>-security-<env>` with `CanNotDelete` lock | Home of the security workspace | Assume breach |
| Log Analytics workspace, local auth disabled | Central store for security logs, Entra ID authentication only | Verify explicitly |
| Workspace audit diagnostic setting | Records who queries the security logs | Assume breach |
| Activity log diagnostic setting | Streams all control plane events of the subscription into the workspace | Assume breach |
| Microsoft Defender for Cloud plans | Threat protection per resource type, with sub-plans | Assume breach |
| Security contacts (optional) | Alert emails to a team mailbox and subscription owners | Assume breach |
| Policy assignments | *Allowed locations* for resources and resource groups | Least privilege |

Details and design decisions: [docs/architecture.md](docs/architecture.md).

## Quick start

Prerequisites: a current Azure CLI with Bicep (`az bicep install`) and the [required roles](docs/deployment.md#required-permissions) on the target subscription.

```bash
git clone https://github.com/spoke1/zero-trust-iac.git
cd zero-trust-iac

az login
az account set --subscription "<subscription-id>"

# Preview the changes
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

## Environments

| Setting | `main.dev.bicepparam` | `main.prod.bicepparam` |
|---|---|---|
| Log retention | 30 days, 5 GB daily cap | 180 days, no cap |
| Defender plans | Resource Manager, Key Vault | CSPM, Servers P2, Storage, Key Vault, Resource Manager, Containers, App Service, SQL |
| Alert emails | none | team mailbox (set at deployment time) |
| Allowed locations | West Europe, Germany West Central | West Europe, Germany West Central |
| Policy enforcement | `DoNotEnforce` (audit only) | `Default` (deny) |
| Delete lock | off | on |

Defender for Cloud plans are billed per protected resource. Review the plans and their pricing before you deploy the production parameters.

## Key parameters

| Parameter | Default | Description |
|---|---|---|
| `environmentName` | required | `dev`, `test` or `prod` |
| `prefix` | `zt` | Short code in resource names |
| `logRetentionInDays` | `90` | 30-730 days |
| `dailyQuotaGb` | `-1` | Daily ingestion cap, `-1` disables it |
| `workspacePublicNetworkAccess` | `Enabled` | Set to `Disabled` with Azure Monitor Private Link |
| `defenderPlans` | Resource Manager, Key Vault | List of `{ name, subPlan? }` |
| `securityContactEmails` | empty | Semicolon-separated recipients; empty skips the configuration |
| `allowedLocations` | deployment location | Empty list skips the policy assignments |
| `policyEnforcementMode` | `Default` | `DoNotEnforce` reports without denying |
| `enableDeleteLock` | `true` | Lock on the security resource group |

All parameters are documented with `@description` in [`bicep/main.bicep`](bicep/main.bicep).

## CI/CD

| Workflow | Trigger | What it does |
|---|---|---|
| [`ci.yml`](.github/workflows/ci.yml) | Push, pull request | Bicep lint with the rules in [`bicepconfig.json`](bicepconfig.json), build of the template and all parameter files, gitleaks secret scan of the full history. Needs no Azure access. |
| [`deploy.yml`](.github/workflows/deploy.yml) | Manual | What-if, then optional deployment to the chosen GitHub environment. Authenticates with OIDC federated credentials, no client secret. |

Setting up the federated credential, roles and GitHub environments: [docs/deployment.md](docs/deployment.md).

## Repository structure

```text
bicep/
  main.bicep                  Entry point (targetScope = subscription)
  main.dev.bicepparam         Development parameters
  main.prod.bicepparam        Production parameters
  types.bicep                 Shared user-defined types
  modules/
    logAnalytics.bicep        Workspace and workspace audit
    activityLog.bicep         Subscription activity log export
    defender.bicep            Defender for Cloud plans
    securityContacts.bicep    Alert notifications
    policy.bicep              Allowed-locations guardrails
    lock.bicep                CanNotDelete lock
docs/
  architecture.md             Components, Zero Trust mapping, design decisions
  deployment.md               Permissions, CLI and OIDC pipeline setup, removal
bicepconfig.json              Linter rules
```

## Roadmap

- [ ] Microsoft Sentinel onboarding on the security workspace
- [ ] Azure Monitor Private Link Scope for private ingestion and query
- [ ] DeployIfNotExists policies for diagnostic settings on common resource types
- [ ] Management group variant for multi-subscription landing zones

See the [changelog](CHANGELOG.md) for what changed in version 2.

## Related repositories

- [id-hub](https://github.com/spoke1/id-hub): staged Conditional Access, identity security and governance baselines for Microsoft Entra ID
- [hybrid-workplace-automation](https://github.com/spoke1/hybrid-workplace-automation): read-only PowerShell tooling for AD, Entra ID and Intune operations

## Maintainer

Built and maintained by **Ramón Lotz**, IAM & Security Architect (Cloud Security).

[ramonlotz.de](https://ramonlotz.de) · Blog: [Access Insights](https://ramonlotz.de/blog) · [LinkedIn](https://www.linkedin.com/in/ramonlotz)

## Disclaimer

Templates are provided as-is. Run the what-if and review it before deploying to a subscription that matters.

## License

[MIT](LICENSE)
