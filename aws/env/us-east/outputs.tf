output "IP_Addresses" {
  value = <<CONFIGURATION

Client public IPs: ${join(", ", module.hashistack.client_public_ips)}

Server public IPs: ${join(", ", module.hashistack.server_public_ips)}

To connect, add your private key and SSH into any client or server with
`ssh ubuntu@PUBLIC_IP`. You can test the integrity of the cluster by running:

  $ consul members
  $ nomad server members
  $ nomad node status

If you see an error message like the following when running any of the above
commands, it usually indicates that the configuration script has not finished
executing:

"Error querying servers: Get http://127.0.0.1:4646/v1/agent/members: dial tcp
127.0.0.1:4646: getsockopt: connection refused"

Simply wait a few seconds and rerun the command if this occurs.

The Nomad UI can be accessed at http://${module.hashistack.server_lb_ip}:4646/ui.
The Consul UI can be accessed at http://${module.hashistack.server_lb_ip}:8500/ui.

Set the following for access from the Nomad CLI:

  export NOMAD_ADDR=http://${module.hashistack.server_lb_ip}:4646

CONFIGURATION

}

output "aws_efs_file_system" {
    value = <<EOM
# volume registration
type = "csi"
id = "aws-efs0"
name = "aws-efs0"
external_id = "${module.hashistack.aws_efs_file_system}"
access_mode = "multi-node-multi-writer"
attachment_mode = "file-system"
plugin_id = "aws-efs0"
EOM
}

/*
output "ebs_volume" {
    value = <<EOM
# volume registration
type = "csi"
id = "aws-ebs0"
name = "aws-ebs0"
external_id = "${module.hashistack.aws_ebs_volume}"
access_mode = "single-node-writer"
attachment_mode = "file-system"
plugin_id = "aws-ebs0"
EOM
}
*/