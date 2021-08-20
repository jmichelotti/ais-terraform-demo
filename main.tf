# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

locals {
  api_doc_path     = "${path.module}/apiDocs"
  policy_file_path = "${path.module}/policyFiles"

}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}

#Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

#Api Management Resource
resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = "Justin"
  publisher_email     = "justin.michelotti@ais.com"

  sku_name = "Developer_1"

  depends_on = [
    azurerm_resource_group.rg
  ]
}

#Key Vault Data Block
data "azurerm_key_vault" "questVault" {
  resource_group_name = var.resource_group_name
  name                = var.key_vault_name
}

#Getting secrets from var.secret_names out of Key Vault
data "azurerm_key_vault_secret" "secretMultipleTest" {
  for_each     = toset(var.secret_names)
  name         = each.key
  key_vault_id = data.azurerm_key_vault.questVault.id
}

#Version Set Resources
resource "azurerm_api_management_api_version_set" "gbfVersionSet" {
  name                = "gbf-version-set"
  resource_group_name = var.resource_group_name
  api_management_name = var.apim_name
  display_name        = "GBF Version Set"
  versioning_scheme   = "Segment"
}
resource "azurerm_api_management_api_version_set" "buVersionSet" {
  name                = "bu-version-set"
  resource_group_name = var.resource_group_name
  api_management_name = var.apim_name
  display_name        = "BU Version Set"
  versioning_scheme   = "Segment"
}
resource "azurerm_api_management_api_version_set" "uiVersionSet" {
  name                = "ui-version-set"
  resource_group_name = var.resource_group_name
  api_management_name = var.apim_name
  display_name        = "UI Version Set"
  versioning_scheme   = "Segment"
}

#Api Resources
resource "azurerm_api_management_api" "ghkoat" {
  for_each            = { for api in var.api_array: api.name => api }
  resource_group_name = var.resource_group_name
  api_management_name = var.apim_name
  revision            = "1"
  protocols           = ["http", "https"]
  name                = each.value.name
  display_name        = each.value.display_name
  #If there parent_api is equal to "none" then use the name for the path, otherwise use parent_api for path
  #This is done so that future versions can have the same path as the original API, just with /v2 or /v3 on the end of the path
  path        = "${each.value.parent_api}" == "none" ? "${each.value.name}" : "${each.value.parent_api}"
  service_url = each.value.backend_url

  #Assigning the version identifier which is "" for the original APIs
  version = each.value.version
  #Assigning each API to the version set created earlier in the script
  version_set_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.apim_name}/apiVersionSets/${each.value.version_set_name}"

  #importing each as a file, in actual Quest code this will be done from a link
  import {
    content_format = "openapi+json"
    content_value  = file("${local.api_doc_path}/${each.value.import_file_name}")
  }

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_api_management.apim,
    #Making sure version-sets are created before APIs are assigned to them
    azurerm_api_management_api_version_set.gbfVersionSet,
    azurerm_api_management_api_version_set.uiVersionSet,
    azurerm_api_management_api_version_set.buVersionSet
  ]
}

# Setting policies for each api
resource "azurerm_api_management_api_policy" "ghkoatPolicy" {
  for_each            = var.policy_map
  api_management_name = var.apim_name
  resource_group_name = var.resource_group_name
  api_name            = each.key

  #Getting value of policy file from folder in file system
  xml_content = file("${local.policy_file_path}/${each.value}")

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_api_management.apim,
    #Making sure APIs are created before policies are assigned to them
    azurerm_api_management_api.ghkoat
  ]
}

# Creating products in Azure
resource "azurerm_api_management_product" "gbfProduct" {
  product_id            = "gbf"
  api_management_name   = var.apim_name
  resource_group_name   = var.resource_group_name
  display_name          = "GBF"
  subscription_required = true
  approval_required     = false
  published             = true

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_api_management.apim
  ]
}
resource "azurerm_api_management_product" "wellnessEngineProduct" {
  product_id            = "wellness-engine"
  api_management_name   = var.apim_name
  resource_group_name   = var.resource_group_name
  display_name          = "Wellness Engine"
  subscription_required = true
  approval_required     = false
  published             = true

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_api_management.apim
  ]
}
resource "azurerm_api_management_product" "uiProduct" {
  product_id            = "ui"
  api_management_name   = var.apim_name
  resource_group_name   = var.resource_group_name
  display_name          = "UI"
  subscription_required = true
  approval_required     = false
  published             = true

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_api_management.apim
  ]
}

#Assigning all apis to their intended product
resource "azurerm_api_management_product_api" "ghkoatAssign" {
  for_each            = { for api in var.api_array: api.name => api }
  api_name            = each.value.name
  api_management_name = var.apim_name
  resource_group_name = var.resource_group_name
  product_id          = each.value.product_name

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_api_management.apim,
    azurerm_api_management_api.ghkoat,
    azurerm_api_management_product.uiProduct
  ]
}

#Creating subscriptions in Azure
resource "azurerm_api_management_subscription" "gbfSub" {
  api_management_name = var.apim_name
  display_name        = "GBF Subscription"
  resource_group_name = var.resource_group_name
  product_id          = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.apim_name}/products/gbf"
  state               = "active"
  allow_tracing       = false
  #Getting value about secrets by indexing object
  primary_key   = data.azurerm_key_vault_secret.secretMultipleTest["GBFsubPrimaryKey"].value
  secondary_key = data.azurerm_key_vault_secret.secretMultipleTest["GBFsubSecondaryKey"].value

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_api_management.apim,
    azurerm_api_management_product.gbfProduct
  ]
}
resource "azurerm_api_management_subscription" "wellnessSub" {
  api_management_name = var.apim_name
  display_name        = "Wellness Engine Subscription"
  resource_group_name = var.resource_group_name
  product_id          = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.apim_name}/products/wellness-engine"
  state               = "active"
  allow_tracing       = false
  primary_key         = data.azurerm_key_vault_secret.secretMultipleTest["wellnessSubPrimaryKey"].value
  secondary_key       = data.azurerm_key_vault_secret.secretMultipleTest["wellnessSubsecondaryKey"].value

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_api_management.apim,
    azurerm_api_management_product.wellnessEngineProduct
  ]
}
resource "azurerm_api_management_subscription" "uiSub" {
  api_management_name = var.apim_name
  display_name        = "UI Subscription"
  resource_group_name = var.resource_group_name
  product_id          = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.apim_name}/products/ui"
  state               = "active"
  allow_tracing       = false
  primary_key         = data.azurerm_key_vault_secret.secretMultipleTest["UIsubPrimaryKey"].value
  secondary_key       = data.azurerm_key_vault_secret.secretMultipleTest["UIsubSecondaryKey"].value

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_api_management.apim,
    azurerm_api_management_product.uiProduct
  ]
}