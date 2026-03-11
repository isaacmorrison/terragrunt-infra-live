inputs = {
  #######################################
  # Global & Dynamic diagnostic Settings
  #######################################
  product_line            = "sample"
  pipeline                = "sample-${local.envName}-${local.config.locals.prefix}"
  automation              = "terraform"
  owner                   = "Devops"
} 

locals {
  config            = read_terragrunt_config(find_in_parent_folders("env.hcl")) 
  common_vars       = read_terragrunt_config(find_in_parent_folders("common.hcl")) 
  rscfg             = yamldecode(file(find_in_parent_folders("remote_state.yml")))
  currentsubID      = local.config.locals.currentsubID
  envName           = "${basename(dirname(get_terragrunt_dir()))}"
  parentdir         = "${get_terragrunt_dir()}/../../"
  path              = basename(dirname(local.parentdir))
  alias             = local.config.locals.alias
  common_remote_state_rgname   = local.rscfg.remote_state.common.resource_group_name
  common_remote_state_name     = local.rscfg.remote_state.common.storage_account_name
  dr_remote_state_rgname       = local.rscfg.remote_state.dr.resource_group_name
  dr_remote_state_name         = local.rscfg.remote_state.dr.storage_account_name
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
        container_name       = "sample${local.envName}"
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
        container_name       =  "sample${local.envName}"
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
      storage_use_azuread = true
  }
EOF
}
