locals {
  tags = merge(
    var.tags,
    {
      ModuleName    = "terraform-azure-statcan-aaw-network",
      ModuleVersion = "1.3.5",
    }
  )
}
