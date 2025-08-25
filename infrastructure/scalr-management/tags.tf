locals {
  scalr_tags = toset([
    "test",
    "production",
    "og-homelab",
    "doggos-homelab",
  ])
}

resource "scalr_tag" "this" {
  for_each   = local.scalr_tags
  name       = each.value
  account_id = var.scalr_account_id
}
