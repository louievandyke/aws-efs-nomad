variable "name" {
}

variable "region" {
}

variable "ami" {
}

variable "server_instance_type" {
}

variable "client_instance_type" {
}

variable "key_name" {
}

variable "server_count" {
}

variable "client_count" {
}

variable "nomad_binary" {
}

variable "root_block_device_size" {
}

variable "whitelist_ip" {
  description = "A list of IP address to grant access via the LBs."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "retry_join" {
  type = map(string)

  default = {
    provider  = "aws"
    tag_key   = "ConsulAutoJoin"
    tag_value = "auto-join"
  }
}