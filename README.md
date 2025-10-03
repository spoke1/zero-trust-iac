# Zero Trust IaC (Bicep)

Infrastructure as Code for Zero Trust landing zones in Azure using **Bicep**.  
This repository provides a lightweight baseline setup for security & compliance:

- Resource Group creation  
- Log Analytics Workspace  
- Microsoft Defender for Cloud (Standard plans)  
- Modular structure with Bicep modules  

---

## Quickstart

### Deploy (Dev)
```bash
az login
az account set --subscription "<SUB-ID>"
az deployment sub create \
  --location westeurope \
  --template-file bicep/main.bicep \
  --parameters bicep/main.dev.bicepparam
