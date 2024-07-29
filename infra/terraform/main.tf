terraform {
    required_providers {
      cloudflare = { source = "cloudflare/cloudflare", version = "~> 4" }
      vault = { source = "hashicorp/vault", version = "~> 2" }
    }
}

provider "vault" {
  address = var.vault.address
  token = var.vault.token
}

data "vault_generic_secret" "cloudflare" {
  path = var.vault.cloudflare_keys
}

locals {
    root                = "../../blueprints/infra/network/cloudflare"
    dns_records         = yamldecode(file("${local.root}/common/dns_records.yml"))    
    zones = {
      fwkslabcom        = yamldecode(file("${local.root}/zones/fwkslabcom.yml"))
      muriloalmeidadev  = yamldecode(file("${local.root}/zones/muriloalmeidadev.yml"))
      mlerouxcc  = yamldecode(file("${local.root}/zones/mlerouxcc.yml"))
    }
    cloudflare = {
      account_id        = data.vault_generic_secret.cloudflare.data["account_id"]
      api_token         = data.vault_generic_secret.cloudflare.data["api_token"]
    }
}

provider "cloudflare" {
    api_token = local.cloudflare.api_token
}

module "cf_zone_fwkslab_com" {
  source        = "./modules/cf_zone"
  account_id    = local.cloudflare.account_id
  zone          = local.zones.fwkslabcom
  dns_records   = local.dns_records
  providers     = { cloudflare = cloudflare }
}

module "cf_zone_muriloalmeida_dev" {
  source        = "./modules/cf_zone"
  account_id    = local.cloudflare.account_id
  zone          = local.zones.muriloalmeidadev
  dns_records   = local.dns_records
  providers     = { cloudflare = cloudflare }
}

module "cf_zone_mleroux_cc" {
  source        = "./modules/cf_zone"
  account_id    = local.cloudflare.account_id
  zone          = local.zones.mlerouxcc
  dns_records   = local.dns_records
  providers     = { cloudflare = cloudflare }
}