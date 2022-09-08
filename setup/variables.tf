variable "ado_org_service_url" {
  type        = string
  description = "Org service url for Azure DevOps"
}

variable "ado_github_repo" {
  type        = string
  description = "Name of the repository in the format <GitHub Org>/<RepoName>"
  default     = "jenka13all/azdevops-project-basic"
}

variable "ado_pipeline_yaml_path_1" {
  type        = string
  description = "Path to the yaml for the first pipeline"
  default     = "tenant/azure-pipelines.yaml"
}

variable "ado_github_pat" {
  type        = string
  description = "Personal authentication token for GitHub repo"
  sensitive   = true
}

variable "ado_terraform_version" {
  type        = string
  description = "Version of Terraform to use in the pipeline"
  default     = "1.2.5"
}

variable "prefix" {
  type        = string
  description = "Naming prefix for resources"
  default     = "itzb"
}

variable "env" {
  type = string
  description = "Environment"
  default = "platform" #or dev
}

variable "az_location" {
  type    = string
  default = "germanywestcentral"
}

variable "az_container_name" {
  type        = string
  description = "Name of container on storage account for Terraform state"
  default     = "terraform-state"
}

variable "az_state_key" {
  type        = string
  description = "Name of key in storage account for Terraform state"
  default     = "terraform.tfstate"
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

locals {
  ado_project_name        = "${var.prefix}-${var.env}-project"
  ado_project_description = "Project for ${var.prefix}"
  ado_project_visibility  = "private"
  ado_pipeline_name_1     = "Main"

  az_resource_group_name  = "rg-${var.prefix}-${var.env}"
  az_storage_account_name = "${lower(var.prefix)}${var.env}"
  az_key_vault_name = "valut-${var.prefix}-${var.env}"

  az_root_mg_id = "<your root management group id>"

  pipeline_variables = {
    storageaccount = azurerm_storage_account.sa.name
    container-name = var.az_container_name
    key = var.az_state_key
    sas-token = data.azurerm_storage_account_sas.state.sas
    az-client-id = azuread_application.resource_creation.application_id
    az-client-secret = azuread_service_principal_password.resource_creation.value
    az-subscription = data.azurerm_client_config.current.subscription_id
    az-tenant = data.azurerm_client_config.current.tenant_id
  }

  azad_service_connection_sp_name = "${var.prefix}-${var.env}-service-connection"
  azad_resource_creation_sp_name = "${var.prefix}-${var.env}-resource-creation"
}