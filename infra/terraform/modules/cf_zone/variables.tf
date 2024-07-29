# Variable for Cloudflare Account ID
variable "account_id" {
  description = "The Cloudflare Account ID for your Cloudflare account."
  type        = string
  sensitive   = true
}

# Variable for Cloudflare Zone
variable "zone" {
  description = "The Cloudflare zone (domain) for which DNS records are managed."
}

# Variable for Cloudflare DNS Records
variable "dns_records" {
  description = "A list of Cloudflare DNS records to manage."
}
