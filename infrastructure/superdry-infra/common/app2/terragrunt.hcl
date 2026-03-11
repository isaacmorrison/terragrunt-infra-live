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
  # topic_servicebusqueue_subscription = {
  #   sb_1 = {
  #     eventGridSubscriptionName        = "Notificationsample2"
  #     topicId                          = "/subscriptions/${local.currentsubID}/resourceGroups/faccon-${local.env}-wus-rg-1/providers/Microsoft.EventGrid/topics/sample-${local.env}-faccon-sqlevent-wus-egt-1"
  #     serviceBusQueueId                = "/subscriptions/${local.currentsubID}/resourceGroups/sample-${local.env}-service-bus-wus-01_rg/providers/Microsoft.ServiceBus/namespaces/sample-${local.env}-common-svs-wus-sb-01/queues/posteddocument"
  #   }
  # }
}