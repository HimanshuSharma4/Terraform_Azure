output "kv_id" {
  value = azurerm_key_vault.keyvault.id
}

output "vault_uri" {
  value = azurerm_key_vault.keyvault.vault_uri
}


# output "vault_obj_id" {
#   value = data.azuread_user.user_data.object_id
# }

output "db_pwd_name" {
  value = azurerm_key_vault_secret.db-pwd.name
}

output "db_pwd_value" {
  value = azurerm_key_vault_secret.db-pwd.value
  sensitive = true
}