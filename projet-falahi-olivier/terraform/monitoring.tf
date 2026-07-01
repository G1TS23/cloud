resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${local.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_monitor_action_group" "ops" {
  name                = "ag-${local.prefix}-ops"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "novaops"
  tags                = local.common_tags

  email_receiver {
    name          = "equipe-ops"
    email_address = var.ops_email
  }
}

resource "azurerm_monitor_metric_alert" "cpu_web1" {
  name                = "alert-cpu-${local.prefix}-web-1"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_virtual_machine.web[0].id]
  description         = "Alerte lorsque le processeur de la premiere machine web depasse 70 pourcent pendant cinq minutes."
  severity            = 2
  window_size         = "PT5M"
  frequency           = "PT1M"
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}

resource "azurerm_monitor_metric_alert" "lb_backend" {
  name                = "alert-backend-${local.prefix}-lb"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_lb.web.id]
  description         = "Alerte lorsque la disponibilite des machines derriere le repartiteur de charge diminue."
  severity            = 1
  window_size         = "PT5M"
  frequency           = "PT1M"
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Network/loadBalancers"
    metric_name      = "DipAvailability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}
