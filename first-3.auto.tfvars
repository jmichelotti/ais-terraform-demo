resource_group_name = "justin-terraform-demo"

location = "eastus"

subscription_id = "efb8364e-d399-435a-9e62-e29faf268501"

tenant_id = "f32b97f0-efb8-4bc3-91ee-18a6e5f635c9"

apim_name = "GHKOAT-API-M"

key_vault_name = "quest-testing-vault"

secret_names = ["UIsubPrimaryKey", "UIsubSecondaryKey", "wellnessSubPrimaryKey", "wellnessSubsecondaryKey", "GBFsubPrimaryKey", "GBFsubSecondaryKey"]

api_array = [
  {
    backend_url      = "https://localhost:4033"
    display_name     = "GBF API"
    name             = "gbf"
    import_file_name = "GHKOAT-API-GBF-Doc.json"
    policy_file_name = "gbfPolicy.xml"
    product_name     = "gbf"
    version          = ""
    version_set_name = "gbf-version-set"
    parent_api       = "none"
  },
  {
    backend_url      = "https://localhost:7071"
    display_name     = "BU API"
    name             = "bu"
    import_file_name = "GHKOAT-API-BU-Doc.json"
    policy_file_name = "buPolicy.xml"
    product_name     = "wellness-engine"
    version          = ""
    version_set_name = "bu-version-set"
    parent_api       = "none"
  },
  {
    backend_url      = "https://localhost:1212"
    display_name     = "UI API"
    name             = "ui"
    import_file_name = "GHKOAT-API-UI-Doc.json"
    policy_file_name = "uiPolicy.xml"
    product_name     = "ui"
    version          = ""
    version_set_name = "ui-version-set"
    parent_api       = "none"
  }
]

policy_map = {
  gbf = "gbfPolicy.xml"
  bu  = "buPolicy.xml"
  ui  = "uiPolicy.xml"
}