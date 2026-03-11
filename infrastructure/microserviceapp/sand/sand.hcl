locals {
  env                     = get_env("TF_VAR_environment")
  common_vars             = read_terragrunt_config(find_in_parent_folders("common.hcl"))  #load common hcl config
  base_dir                = "${basename(dirname(get_original_terragrunt_dir()))}"         # gets current env name
  currentsubID            = local.common_vars.locals.sanbox                           
  prefix                  = "coreapi"
  location                = "westus"
  alias                   = "wus"
  vmname                  = "mytestvm"
}