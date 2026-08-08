resource "azurerm_role_assignment" "pipeline_sp" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.pipeline_sp_object_id
}