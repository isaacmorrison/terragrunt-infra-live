locals {
  env               = get_env("TF_VAR_environment")
  config            = read_terragrunt_config(find_in_parent_folders("${local.env}/${local.env}.hcl")) 
  common_vars       = read_terragrunt_config(find_in_parent_folders("common.hcl")) 
  parentdir         = "${get_terragrunt_dir()}/../../"
  path              = basename(dirname(local.parentdir))
  currentsubID      = local.config.locals.currentsubID
  base_dir          = "${basename(dirname(get_terragrunt_dir()))}"
}

inputs = {
  #######################################
  # Global & Dynamic Settings
  #######################################
  product_line            = "demo"
  pipeline                = "demo-${local.env}-${local.config.locals.prefix}"
  automation              = "terraform"
  owner                   = "Devops"
} 

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  %{ if local.config.locals.location == "westus" }
    terraform {
      backend "azurerm" {
        key = "${local.path}/${basename((get_terragrunt_dir()))}/${basename((get_terragrunt_dir()))}.tfstate"
        resource_group_name  = "${local.common_remote_state_rgname}" 
        storage_account_name = "${local.common_remote_state_name}"
        container_name       = "demo${local.envName}"
        use_azuread_auth     = true
      }
    }
  %{ endif }
  %{ if local.config.locals.location == "eastus" }
    terraform {
      backend "azurerm" {
        key = "${local.path}/${basename((get_terragrunt_dir()))}/${basename((get_terragrunt_dir()))}.tfstate"
        resource_group_name  = "${local.dr_remote_state_rgname}" 
        storage_account_name = "${local.dr_remote_state_name}"
        container_name       =  "demo${local.envName}"
        use_azuread_auth     =  true
      }
    }
  %{ endif }
EOF
}

generate "versions" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "azurerm" {
      features {}
      subscription_id = "${local.currentsubID}"
    }
    provider "azurerm" {
      # to access diag storage account
      features {}
      alias           = "sharedsvcsub"
      subscription_id = "${local.common_vars.locals.sharedsub}"
    }
EOF
}
