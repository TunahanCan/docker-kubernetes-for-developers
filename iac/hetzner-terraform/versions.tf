terraform {
  required_version = ">= 1.5.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.60"
    }
  }
}

# HCLOUD_TOKEN is read from the environment variable automatically.
# Export it in your ~/.zshrc:
#   export HCLOUD_TOKEN="your-hetzner-api-token"
provider "hcloud" {}
