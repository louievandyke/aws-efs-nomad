provider "aws" {
  region = "us-east-1" 
  #var.region
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
  whitelist_ip           = var.whitelist_ip
}
