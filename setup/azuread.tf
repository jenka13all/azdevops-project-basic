# The pipeline needs a service principal to use for an AzureRM service connection
# It will need access to the Azure Key Vault

# You also need a service principal to use for creating resources in an AzureRM sub

# I don't think those should be the same SP. The KV might be in a different sub than the place
# you want to create resources. So we'll create two SPs.

# Create SP for service connection in pipeline. Will be used to access KV.


provider "azuread" {
  tenant_id = "<your tenant id>"
}

resource "azuread_application" "service_connection" {
  display_name = local.azad_service_connection_sp_name
}

resource "azuread_service_principal" "service_connection" {
  application_id = azuread_application.service_connection.application_id
}

resource "azuread_service_principal_password" "service_connection" {
  service_principal_id = azuread_service_principal.service_connection.object_id
}

# Create service principal (SP) for Azure resource creation AT ROOT LEVEL
# These credentials will be written to the Key Vault and retrieved during pipeline run

resource "azuread_application" "resource_creation" {
  display_name = local.azad_resource_creation_sp_name
}

resource "azuread_service_principal" "resource_creation" {
  application_id = azuread_application.resource_creation.application_id
}

resource "azuread_service_principal_password" "resource_creation" {
  service_principal_id = azuread_service_principal.resource_creation.object_id
}

# Create a custom role and assign it at the top management group level to our resource_creation SP

resource "azurerm_role_definition" "contributor_with_writing" {
  name        = "ContributorWithWriting"
  scope       = local.az_root_mg_id
  description = "Contributor role that also allows SP to write and delete on resources of type RoleAssignment" 

  permissions {
    actions     = ["*"]
    not_actions = [
      "Microsoft.Authorization/elevateAccess/Action",
      "Microsoft.Blueprint/blueprintAssignments/write",
      "Microsoft.Blueprint/blueprintAssignments/delete",
      "Microsoft.Compute/galleries/share/action"
    ]
  }
}

resource "azurerm_role_assignment" "resource_creation" {
  scope              = local.az_root_mg_id
  role_definition_id = azurerm_role_definition.contributor_with_writing.role_definition_resource_id
  principal_id       = azuread_service_principal.resource_creation.object_id
}
  
resource "azurerm_role_assignment" "resource_creation" {
  scope = local.az_root_mg_id
  role_definition_name = "Contributor"
  principal_id = azuread_service_principal.resource_creation.object_id
}
