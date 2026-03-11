# Terragrunt-live

A starter repository of Terragrunt/Terraform configurations targeting Azure. It
implements a "live" infrastructure pattern that lets you organize your
projects, environments, and state files with Terragrunt. This repo is designed
for DevOps engineers who need a reusable, multi-application layout with CI/CD
pipelines.

## Table of Contents

1. [Features](#features)
2. [Quick Start](#quick-start)
3. [Layout Overview](#layout-overview)
4. [State File Configuration](#state-file-configuration)
5. [Pipelines](#pipelines)
6. [Deployment Best Practices](#deployment-best-practices)
7. [Cleaning Terragrunt Cache](#cleaning-terragrunt-cache)
8. [Use Cases](#use-cases)
9. [Security & Sensitive Data](#security--sensitive-data)
10. [Contribution](#contribution)
11. [License](#license)

## Features

- **Environment parameterization** via `env.hcl`
- **Common configuration** captured in `common.hcl`
- **Hierarchical layout** for applications and environments
- **Blob-backed remote state** with environment-specific naming
- **CI/CD pipeline templates** for Azure DevOps (YAML)
- **Cache cleaning helper** for `.terragrunt-cache`
- **Examples of dependencies and plan strategies**

> 🔒 All business-specific names and sensitive values are replaced with
generic placeholders for reuse in public/private repos.

## Quick Start

1. Clone this repository.
2. Copy `.template/env.hcl` into your deployment directory and update values.
3. Create an application folder:

   ```bash
   mkdir -p infrastructure/myapp/{dev,prod}/
   cp -r infrastructure/.template/* infrastructure/myapp/
   ```

4. Update `terragrunt.hcl` files with your prefixes, subscription IDs, etc.
5. Run Terragrunt from an environment folder:

   ```bash
   cd infrastructure/myapp/dev
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

## Local Development and Testing

For local testing and development without pipelines, navigate to the common folder and set the `TF_VAR_environment` variable to target a specific environment:

```bash
cd infrastructure/myapp/  # Go to the application folder
export TF_VAR_environment="sand"  # Set to desired environment (e.g., sand, dev, prod)
terragrunt run-all plan  # Plan all modules for the 'sand' environment
terragrunt run-all apply  # Apply changes (use with caution)
```

This approach allows developers to test configurations locally by switching the environment variable, ensuring the same DRY templates work across all environments.

## Layout Overview

```
.
├── common.hcl
├── .pipelines/
│   ├── build2.yaml
│   └── deploy2.yaml
├── terraformmodules/
│   ├── network/
│   └── vm/
└── infrastructure/
    ├── .template/            # generic starter configs
    ├── app1/
    │   ├── dev/
    │   ├── prod/
    │   ├── terragrunt.hcl
    │   └── infra-pipelines.yaml
    └── global.hcl
```

- **common.hcl**: Contains globals such as subscription locals, naming
defaults, etc.
- **env.hcl**: Placed at each environment level to supply `currentSubID`,
  `prefix`, `location`, `alias`, and any global resources.
- **terragrunt.hcl**: Main configuration that reads the above files and sets
  locals like `envName`, `parentDir`, `path`, and most importantly
  `env` (via `get_env("TF_VAR_environment")`).  This value drives the
  environment-specific logic and allows you to use the same folder structure
  for `dev`, `prod`, `sand`, etc., without copying configurations.  By
  passing `TF_VAR_environment` (or setting a shell variable) you simply run
  Terragrunt from the desired environment directory and the code references
  everything through that single variable, keeping the repository DRY.


### Application directory template

Each new application follows this structure. Example application names: `webapp`, `api-gateway`, `data-pipeline`, `microservice-auth`.

```
applicationName/
├── devsand/                    # environment folder (name is arbitrary)
│   ├── env.hcl
│   ├── keyvault/terragrunt.hcl
│   ├── rbac/terragrunt.hcl
│   ├── resourcegroup/terragrunt.hcl
│   ├── servicebus/terragrunt.hcl
│   ├── storage/terragrunt.hcl
│   ├── winFunctions/terragrunt.hcl
│   └── winWebApps/terragrunt.hcl
├── infra-pipelines.yaml        # CI/CD template
└── root.hcl
```

Locals provided for naming:

- `local.prefix` – user-defined prefix, e.g. `app`
- `local.envName` – environment name, e.g. `dev`
- `local.location` – Azure region
- `local.alias` – short alias for region, e.g. `wus`

Example resource name:

```hcl
"${local.prefix}-${local.envName}-${local.alias}-01" # -> app-dev-wus-01
```

## State File Configuration

State is stored in an Azure Storage Account blob container named after the
environment. The path includes the application folder:

```
<storage-account>/
  <env>/
    <module>/
      terraform.tfstate
```

## Pipelines

YAML templates are provided under `.pipelines/`. Copy them to your application
and update the `directorypath` parameter:

```yaml
parameters:
  - name: directorypath
    type: string
    default: infrastructure/myapp
```

Refer to Azure DevOps pipeline documentation for running Terragrunt steps.

## Deployment Best Practices

- **Dependencies**: Terragrunt cannot `run-all plan` modules that depend on
  outputs from modules not yet applied. Deploy independent modules first, then
  use `dependencies` blocks or external data providers for lookups.
- **Data lookups**: Avoid using `data.azureRM_*` providers for resources in the
  same deployment; plan apply in stages or use mock outputs.
- Use `terragrunt run-all apply --terragrunt-parallelism 1` when order matters.
- Consult the [Terragrunt run-all reference](https://terragrunt.gruntwork.io/docs/features/execute-terraform-commands-on-multiple-modules-at-once/#unapplied-dependency-and-mock-outputs).

## Cleaning Terragrunt Cache

Remove all cached folders with:

```bash
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
```

## Use Cases

1. **Multi-tenant platform**: deploy shared infrastructure per tenant with
   common configuration.
2. **Microservice onboarding**: spin up applications with their own resource
   groups and pipelines.
3. **Disaster recovery**: maintain separate `prod` and `dr` environments with
   identical structure.
4. **Learning/Proof of Concept**: quickly stand up sandbox environments.

## Security & Sensitive Data

- No credentials or proprietary identifiers are stored in this repo.
- Replace real subscription IDs, storage account names, and resource prefixes
  before sharing publicly.
- Use `.gitignore` to exclude any environment-specific secrets.

## Contribution

Contributions are welcome! Please:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit your changes.
4. Open a pull request.

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file
for details.
