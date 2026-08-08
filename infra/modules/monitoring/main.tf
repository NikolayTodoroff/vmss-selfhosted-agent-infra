resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "log-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "action_group" {
  name                = "ag-${var.prefix}"
  resource_group_name = var.resource_group_name
  short_name          = "vmssadoag"

  email_receiver {
    name          = "primary-contact"
    email_address = var.alert_email
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "vmss_cpu" {
  name                = "alert-vmss-cpu-${var.prefix}"
  resource_group_name = var.resource_group_name
  scopes              = [var.vmss_id]
  description         = "Fires when average CPU across the VMSS stays above 85% for 15 minutes — notification only, distinct from the autoscale rule's own 75% scale-out threshold."
  severity            = 2
  window_size         = "PT15M"
  frequency           = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "lb_health" {
  name                = "alert-lb-health-${var.prefix}"
  resource_group_name = var.resource_group_name
  scopes              = [var.lb_id]
  description         = "Fires when the Load Balancer's healthy backend instance count drops below 1 — meaning the site may be fully unreachable."
  severity            = 1
  window_size         = "PT5M"
  frequency           = "PT1M"

  criteria {
    metric_namespace = "Microsoft.Network/loadBalancers"
    metric_name      = "DipAvailability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }

  tags = var.tags
}