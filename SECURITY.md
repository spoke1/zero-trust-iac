# Security policy

## Reporting a vulnerability

Please do not open a public issue for security problems. Use GitHub's private vulnerability reporting instead: **Security → Report a vulnerability** in this repository. You will get a response within a few working days.

## Scope

In scope are the templates, parameter files and workflows in this repository, for example:

- a template that weakens a security setting it claims to enforce
- a workflow that could expose credentials or deploy without the documented safeguards
- secrets or tenant-specific identifiers committed to the repository

## Handling of secrets

This repository contains no secrets, subscription IDs or tenant IDs, and it must stay that way:

- Pipelines authenticate with OIDC federated credentials. There is no client secret.
- Client, tenant and subscription IDs are stored as GitHub environment secrets, so they are masked in public logs.
- Every push and pull request is scanned with [gitleaks](https://github.com/gitleaks/gitleaks).
