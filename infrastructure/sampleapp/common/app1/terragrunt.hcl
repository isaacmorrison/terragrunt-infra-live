terraform {
  source = "git@github.com:sample-repo/terraform-modules.git//topicSubscription?ref=0.2.24"
  # source = "./../../../../../../terraform-modules/topicSubscription"
}

locals {
  env            = get_env("TF_VAR_environment")
  base_dir       = "${basename(dirname(get_terragrunt_dir()))}"
  common_vars    = read_terragrunt_config(find_in_parent_folders("common.hcl")) 
  config         = read_terragrunt_config(find_in_parent_folders("${local.env}/${local.env}.hcl")) 
  location       = local.config.locals.location
  alias          = local.config.locals.alias
  currentsubID   = local.config.locals.currentsubID
  prefix         = local.config.locals.prefix
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  merge_strategy = "deep"
  expose = true
}


inputs = {
  #Create Event Grid Topics
}