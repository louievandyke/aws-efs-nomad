provider "aws" {
  region = "us-east-1" 
  #var.region
}

# Configure the Nomad provider
provider "nomad" {
  address = "http://${module.hashistack.server_lb_ip}:4646"
  region  = "global"
}

module "my_ip_address" {
  source = "matti/resource/shell"

  command = "curl https://ipinfo.io/ip"
}

module "hashistack" {
  source = "../../modules/hashistack"

  name                   = var.name
  region                 = "us-east-1"
  ami                    = var.ami
  server_instance_type   = var.server_instance_type
  client_instance_type   = var.client_instance_type
  key_name               = var.key_name
  server_count           = var.server_count
  client_count           = var.client_count
  retry_join             = var.retry_join
  nomad_binary           = var.nomad_binary
  root_block_device_size = var.root_block_device_size
  whitelist_ip           = ["${module.my_ip_address.stdout}/32"]
}
