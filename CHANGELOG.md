# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.0.0] - 2026-09-26

### Added

- Subscription activity log export to the security workspace (`modules/activityLog.bicep`).
- Workspace audit log (`LAQueryLogs`) sent to the workspace itself.
- Defender for Cloud security contacts (`modules/securityContacts.bicep`), optional.
- Allowed-locations guardrails for resources and resource groups (`modules/policy.bicep`).
- `CanNotDelete` lock on the security resource group (`modules/lock.bicep`).
- Production parameter file `main.prod.bicepparam`.
- User-defined type `defenderPlan` with optional sub-plan (`types.bicep`).
- Linter configuration `bicepconfig.json`.
- CI workflow: Bicep lint and build, gitleaks secret scan. Runs without Azure credentials.
- Documentation: architecture with Zero Trust mapping, deployment guide with OIDC setup.

### Changed

- Breaking: parameters renamed and extended. `rgName` and `lawName` are now `resourceGroupName` and `workspaceName` with a naming convention based on `prefix` and `environmentName`.
- Log Analytics workspace: local authentication disabled, resource-context access only, configurable retention (30-730 days), daily cap and public network access. API version 2025-02-01.
- Defender for Cloud: plans are a parameter with sub-plans, deployed one at a time. Removed the deprecated plans `Dns`, `KubernetesService` and `ContainerRegistry`.
- Deploy workflow is manual only (`workflow_dispatch`), runs a what-if first, targets GitHub environments with their own OIDC identity and fails early with a clear message if the environment is not configured.

### Fixed

- The workspace module was deployed into the resource group without a dependency on it and could fail on the first deployment.
- `diagnostics.bicep` used `scope: resource(...)`, which is not valid Bicep, and was never referenced.
- The workspace SKU was set outside of `properties`.
- The CI badge pointed to a placeholder owner.
- The workflow tried to deploy on every push to `main` and failed when no Azure credentials were configured.

## [1.0.0] - 2025-10-09

- Initial release: resource group, Log Analytics workspace, Defender for Cloud plans, deploy workflow.
