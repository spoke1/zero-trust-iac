# Zero Trust IaC (Bicep)

[![CI/CD](https://github.com/<spoke1>/zero-trust-iac/actions/workflows/deploy.yml/badge.svg)](../../actions/workflows/deploy.yml)

Infrastructure as Code for **Zero Trust landing zones** in Azure using **Bicep**.  
Creates a Security/Logging foundation:
- Resource Group
- Log Analytics Workspace
- Microsoft Defender for Cloud (plans)

## October 2025 Updates 🚀
- Added PROD parameter file and policy scaffolding
- CI/CD workflow extended for manual prod deploy
- Coming next: Diagnostics module for LAW integration

---
  
## Quickstart

### Prereqs
- Azure subscription + permissions to deploy at **subscription scope**
- Azure CLI: `az version`
- (Optional) Bicep locally: `az bicep install`

### Deploy Dev (local / Cloud Shell)
```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
az deployment sub create \
  --location westeurope \
  --template-file bicep/main.bicep \
  --parameters bicep/main.dev.bicepparam
