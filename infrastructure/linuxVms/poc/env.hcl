locals {
  module_version          = "0.4.63"
  common_vars             = read_terragrunt_config(find_in_parent_folders("common.hcl")) 
  currentsubID            = local.common_vars.locals.sanbox
  prefix                  = "app"
  location                = "westus"
  alias                   = "wus"
  envName                 = "sanbox"
}