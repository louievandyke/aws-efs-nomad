# `name` (required) is used to override the default decorator for elements in
# the stack.  This allows for more than one environment per account.
#  - This name can only contain alphanumeric characters.  If it is not provided
#    here, it will be requested interactively.
name = "driftwood"

# `key_name` (required) -  The name of the AWS SSH keys to be loaded on the
# instance at provisioning.

# If it is not provided here, it will be requested interactively.
#key_name = "nomadic"
key_name = "lv-nomad"

# `nomad_binary` (optional, null) - URL of a zip file containing a nomad
# executable with which to replace the Nomad binaries in the AMI.
#  - Typically this is left commented unless necessary.
nomad_binary = "https://releases.hashicorp.com/nomad/1.5.6/nomad_1.5.6_linux_amd64.zip"

# `region` ("us-east-1") - sets the AWS region to build your cluster in.
region = "us-east-1"

# `ami` (required) - The base AMI for the created nodes, This AMI must exist in
# the requested region for this environment to build properly.
#  - If it is not provided here, it will be requested interactively.
#ami = "ami-086bae513bb7ab66d"
#ami = "ami-0ee35b004feae4bb6"
ami = "ami-0344721081504cd29"

# `server_instance_type` ("t2.medium"), `client_instance_type` ("t2.medium"),
# `server_count` (3),`client_count` (4) - These options control instance size
# and count. They should be set according to your needs.
#
# * For the GPU demos, we used p3.2xlarge client instances.
# * For the Spark demos, you will need at least 4 t2.medium client
#   instances.
server_instance_type = "t2.medium"
#server_count         = "3"
server_count         = "1"
client_instance_type = "t2.medium"
#client_count         = "4"
client_count         = "1"


# `whitelist_ip` (required) - IP to whitelist for the security groups (set
# to 0.0.0.0/0 for world).
#  - If it is not provided here, it will be requested interactively.
#whitelist_ip = ["73.109.72.170/32","72.207.74.177/32","104.6.136.190/32","54.225.221.176/32","54.80.6.182/32"]
#whitelist_ip = "73.109.72.170/32"
whitelist_ip = ["72.207.74.177/32"]
#whitelist_ip = ["72.207.74.177/32","72.207.74.177/32"]
#nomad_addr = "http://${module.hashistack.server_lb_ip}:4646"

