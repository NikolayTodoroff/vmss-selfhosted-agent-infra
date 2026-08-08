output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings"
  value       = azurerm_log_analytics_workspace.log_analytics.id
}

output "action_group_id" {
  value = azurerm_monitor_action_group.action_group.id
}
