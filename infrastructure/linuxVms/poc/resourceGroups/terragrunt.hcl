terraform { 
  source = "git@github.com:/resourceGroups?ref=${local.latest_tag}"
  #source = "../../../../../terraformmodules/resourceGroups"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  merge_strategy = "deep"
  expose = true
}
locals {
  envName        = "${basename(dirname(get_terragrunt_dir()))}"
  common_vars    = read_terragrunt_config(find_in_parent_folders("common.hcl")) 
  config         = read_terragrunt_config(find_in_parent_folders("env.hcl"))   
  prefix         = local.config.locals.prefix
  location       = local.config.locals.location
  alias          = local.config.locals.alias
  latest_tag     = local.config.locals.module_version
}

inputs = {
  location            = local.location               
  resource_group_name = "${local.prefix}-${local.envName}-${local.alias}-test-rg-1"
}