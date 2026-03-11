terraform { 
  source = "git@github.com:terraformmodules.git//linuxVirtualMachines?ref=${local.latest_tag}"
  #source = "../../../../../terraform-modules/linuxVirtualMachines"
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

dependency "rg" {
  config_path = "../resourceGroups"
  mock_outputs = {
    resource_group_name = "temporary-dummy-rg"
    location = "westus"
  }
  # skip_outputs = true
  mock_outputs_allowed_terraform_commands = ["init", "plan"]
}

dependencies {
  paths = ["../resourceGroups"]
}

inputs = {
  location                        = local.location
  resource_group_name             = dependency.rg.outputs.resource_group_name
  key_vault_id                    = ""
  administrator_user_name         = ""   
  
  source_image_id = ""
  
  linux_vms = {
    vm_1= { 
      name                             = "${local.prefix}-${local.envName}-${local.alias}-vm-test-1"
      vm_size                          = "Standard_D2ds_v5"
      disk_size_gb                     = 128
      source_image_reference_offer     = "0001-com-ubuntu-server-jammy"
      source_image_reference_sku       = "20_04-lts-gen2"
      source_image_reference_version   = "20.04.202312080"
    }
  }
}