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

/*
module "shared-nomad-jobs" {
  source = "../../modules/shared-nomad-jobs"

  nomad_addr = "http://${module.hashistack.server_lb_ip}:4646"
}
*/

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
  #whitelist_ip           = ["${module.my_ip_address.stdout}/32"]
  whitelist_ip           = var.whitelist_ip
  #aws_access_key_id      = var.aws_access_key_id
  #aws_secret_access_key  = var.aws_secret_access_key
  #aws_session_token      = var.aws_session_token
  #nomad_addr             = var.nomad_addr
  nomad_addr             = "http://${module.hashistack.server_lb_ip}:4646"
}
