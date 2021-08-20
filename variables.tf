variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "apim_name" {
  type = string
}

variable "policy_map" {
  type = map(string)
}

variable "key_vault_name" {
  type = string
}

variable "secret_names" {
  type = list(string)
}

variable "api_array" {
  type = list(object({
    name             = string
    display_name     = string
    version          = string
    version_set_name = string
    product_name     = string
    import_file_name = string
    policy_file_name = string
    backend_url      = string
    parent_api       = string
  }))
}
