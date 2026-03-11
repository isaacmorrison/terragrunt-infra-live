terraform {
  source = "git@github.com:sample-repo/terraform-modules.git//topicSubscription?ref=0.2.24"
  # source = "./../../../../../../terraform-modules/topicSubscription"
}

locals {
  env            = get_env("TF_VAR_environment")
  base_dir       = "${basename(dirname(get_terragrunt_dir()))}"
  common_vars    = read_terragrunt_config(find_in_parent_folders("common.hcl")) 
  config         = read_terragrunt_config(find_in_parent_folders("env.hcl")) 
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
  topic_functionApp_subscription = {
    egt_1 = {
      eventGridSubscriptionName        = "HandleFacilityContractDataChangedEvent"
      topicId                          = "/subscriptions/${local.currentsubID}/resourceGroups/faccon-${local.env}-${local.alias}-rg-1/providers/Microsoft.EventGrid/topics/sample-${local.env}-faccon-sqlevent-${local.alias}-egt-1"
      funcId                           = "/subscriptions/${local.currentsubID}/resourceGroups/faccon-${local.env}-${local.alias}-rg-1/providers/Microsoft.Web/sites/faccon-${local.env}-${local.alias}-func-1/functions/${local.config.locals.func1}"  
      subscriptionType                 = "azurefunction"
      preferredbatchsize               = 64
      maxeventperbatch                 = 1
      # includedeventtypes               = "sample.FacilityContracts.Functions.FacilityEventGridTrigger sample.FacilityContracts.Functions"
    }
  }
}