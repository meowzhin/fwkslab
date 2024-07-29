terraform {
    required_providers {
      cloudflare = { source = "cloudflare/cloudflare", version = "~> 4" }
    }
}

resource "cloudflare_zone" "zone" {
  account_id = var.account_id
  zone       = var.zone.name
  plan       = try(var.zone.plan, "free")
}

resource "cloudflare_zone_settings_override" "zone_settings" {
  zone_id = cloudflare_zone.zone.id
  settings {
    automatic_https_rewrites = "on"
    always_use_https         = "on"
    brotli                   = "on"
  }
}

resource "cloudflare_record" "zone_subdomains_dns_records" {
  for_each = try({ for i, record in var.zone.subdomains : record.name => record }, {})
  zone_id  = cloudflare_zone.zone.id
  type     = "CNAME"
  name     = each.value.name
  value    = var.zone.name
  proxied  = true
}

resource "cloudflare_record" "zone_domain_dns_records" {
  for_each = try({ for i, record in var.zone.dns_records : record.name => record }, {})
  zone_id  = cloudflare_zone.zone.id
  type     = each.value.type
  name     = each.value.name == "@" ? var.zone.name : each.value.name
  value    = each.value.value == "@" ? var.zone.name : each.value.value
  proxied  = try(each.value.proxied, null)
  priority = try(each.value.priority, null)
}


resource "cloudflare_record" "zone_common_dns_records" {
  for_each = { for i, record in var.dns_records : record.id => record }
  zone_id  = cloudflare_zone.zone.id
  type     = each.value.type
  name     = each.value.name == "@" ? var.zone.name : each.value.name
  value    = each.value.value == "@" ? var.zone.name : each.value.value
  proxied  = try(each.value.proxied, null)
  priority = try(each.value.priority, null)
}
