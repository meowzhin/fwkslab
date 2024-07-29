variable "vault" {
  type = object({
    address         = string
    token           = string
    cloudflare_keys = string
  })
  description = <<EOT
  Configuration for Vault:
    - address: Vault server address
    - token: Vault authentication token
    - cloudflare_keys: Vault path to Cloudflare keys
  EOT
}