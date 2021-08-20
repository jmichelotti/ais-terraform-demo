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
    display_name     = "GBF API New Name"
    name             = "gbf"
    import_file_name = "GHKOAT-API-GBF-Doc.json"
    policy_file_name = "gbfPolicy.xml"
    product_name     = "gbf"
    version          = ""
    version_set_name = "gbf-version-set"
    parent_api       = "none"
  },
  {
    backend_url      = "https://localhost:4012"
    display_name     = "GBF API V2"
    name             = "gbf-v2"
    import_file_name = "GHKOAT-API-GBF-V2-Doc.json"
    policy_file_name = "gbfV2Policy.xml"
    product_name     = "gbf"
    version          = "v2"
    version_set_name = "gbf-version-set"
    parent_api       = "gbf"
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
    display_name     = "BU API V2"
    name             = "bu-v2"
    import_file_name = "GHKOAT-API-BU-V2-Doc.json"
    policy_file_name = "buV2Policy.xml"
    product_name     = "wellness-engine"
    version          = "v2"
    version_set_name = "bu-version-set"
    parent_api       = "bu"
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
  },
  {
    backend_url      = "https://localhost:12122"
    display_name     = "UI API V2"
    name             = "ui-v2"
    import_file_name = "GHKOAT-API-UI-Doc.json"
    policy_file_name = "uiPolicy.xml"
    product_name     = "ui"
    version          = "v2"
    version_set_name = "ui-version-set"
    parent_api       = "ui"
  },
  {
    backend_url      = "https://localhost:12123"
    display_name     = "UI API V3"
    name             = "ui-v3"
    import_file_name = "GHKOAT-API-UI-Doc.json"
    policy_file_name = "uiPolicy.xml"
    product_name     = "ui"
    version          = "v3"
    version_set_name = "ui-version-set"
    parent_api       = "ui"
  },
  {
    backend_url      = "https://localhost:12124"
    display_name     = "UI API V4"
    name             = "ui-v4"
    import_file_name = "GHKOAT-API-UI-Doc.json"
    policy_file_name = "uiPolicy.xml"
    product_name     = "ui"
    version          = "v4"
    version_set_name = "ui-version-set"
    parent_api       = "ui"
  }
]

policy_map = {
  gbf    = "gbfPolicy.xml"
  bu     = "buPolicy.xml"
  ui     = "uiPolicy.xml"
  gbf-v2 = "gbfV2Policy.xml"
  bu-v2  = "buV2Policy.xml"
}