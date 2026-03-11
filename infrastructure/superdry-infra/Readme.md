# Super-DRY Infrastructure Approach

This folder demonstrates an **even more extreme DRY (Don't Repeat Yourself) approach** to Terragrunt configuration. Instead of maintaining separate `env.hcl` files for each environment (dev, prod, sand, etc.), we use a single `env.hcl` file and rely on parameterized pipelines to handle environment-specific values.

## Key Concept

Based on the environment parameter passed to the pipeline job, the agent sets the `TF_VAR_environment` variable. Terragrunt picks this up via `get_env("TF_VAR_environment")` and dynamically resolves all environment-specific logic.

## Benefits

- **Ultra-minimal configuration**: One `env.hcl` file serves all environments
- **Pipeline-driven**: Environment values are injected at runtime via pipeline parameters
- **Zero duplication**: No copying `env.hcl` between environment folders
- **Centralized control**: All environment settings managed in one place

## Trade-offs

- **Pipeline dependency**: Requires parameterized pipelines to set `TF_VAR_environment`
- **Less flexibility**: Environment-specific overrides must be handled in pipeline logic
- **Debugging complexity**: Harder to test locally without pipeline context

## Usage

1. Set up your pipeline with an environment parameter (e.g., `env: dev`, `env: prod`)
2. In the pipeline job, export `TF_VAR_environment` before running Terragrunt:

   ```yaml
   - script: |
       export TF_VAR_environment=$(env)
       terragrunt run-all plan
   ```

3. The single `env.hcl` file contains base values, and Terragrunt resolves environment-specific behavior through the `TF_VAR_environment` variable.

This approach is ideal for teams with mature CI/CD pipelines who want to minimize configuration files while maintaining full environment isolation. 