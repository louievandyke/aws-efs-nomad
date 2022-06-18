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
}

variable "retry_join" {
  type = map(string)

  default = {
    provider  = "aws"
    tag_key   = "ConsulAutoJoin"
    tag_value = "auto-join"
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "server_lb" {
  name   = "${var.name}-server-lb"
  vpc_id = data.aws_vpc.default.id

  # Nomad
  ingress {
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # Consul
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "primary" {
  name   = var.name
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # Nomad
  ingress {
    from_port       = 4646
    to_port         = 4646
    protocol        = "tcp"
    cidr_blocks     = [var.whitelist_ip]
    security_groups = [aws_security_group.server_lb.id]
  }

  # Fabio 
  ingress {
    from_port   = 9998
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # Consul
  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    cidr_blocks     = [var.whitelist_ip]
    security_groups = [aws_security_group.server_lb.id]
  }

  # HDFS NameNode UI
  ingress {
    from_port   = 50070
    to_port     = 50070
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # HDFS DataNode UI
  ingress {
    from_port   = 50075
    to_port     = 50075
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # Spark history server UI
  ingress {
    from_port   = 18080
    to_port     = 18080
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  # Jupyter
  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = [var.whitelist_ip]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data_server" {
  template = file("${path.root}/user-data-server.sh")

  vars = {
    server_count = var.server_count
    region       = var.region
    retry_join = chomp(
      join(
        " ",
        formatlist("%s=%s", keys(var.retry_join), values(var.retry_join)),
      ),
    )
    nomad_binary = var.nomad_binary
  }
}

data "template_file" "user_data_client" {
  template = file("${path.root}/user-data-client.sh")

  vars = {
    region = var.region
    retry_join = chomp(
      join(
        " ",
        formatlist("%s=%s ", keys(var.retry_join), values(var.retry_join)),
      ),
    )
    nomad_binary = var.nomad_binary
  }
}

resource "aws_instance" "server" {
  ami                    = var.ami
  instance_type          = var.server_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.server_count

  # instance tags
  tags = merge(
    {
      "Name" = "${var.name}-server-${count.index}"
    },
    {
      "${var.retry_join.tag_key}" = "${var.retry_join.tag_value}"
    },
  )

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  user_data            = data.template_file.user_data_server.rendered
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
}

resource "aws_instance" "client" {
  ami                    = var.ami
  instance_type          = var.client_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.client_count
  depends_on             = [aws_instance.server]

  # instance tags
  tags = merge(
    {
      "Name" = "${var.name}-client-${count.index}"
    },
    {
      "${var.retry_join.tag_key}" = "${var.retry_join.tag_value}"
    },
  )

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  ebs_block_device {
    device_name           = "/dev/xvdd"
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = "true"
  }

  user_data            = data.template_file.user_data_client.rendered
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
}

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = var.name
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = var.name
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "auto_discover_cluster" {
  name   = "auto-discover-cluster"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.auto_discover_cluster.json
}

data "aws_iam_policy_document" "auto_discover_cluster" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }
}

resource "aws_elb" "server_lb" {
  name               = "${var.name}-server-lb"
  availability_zones = distinct(aws_instance.server.*.availability_zone)
  internal           = false
  instances          = aws_instance.server.*.id
  listener {
    instance_port     = 4646
    instance_protocol = "http"
    lb_port           = 4646
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 8500
    lb_protocol       = "http"
  }
  security_groups = [aws_security_group.server_lb.id]
}

resource "time_sleep" "wait_2_min" {
  depends_on = [aws_elb.server_lb]

  create_duration = "2m"
}

output "server_public_ips" {
   value = aws_instance.server[*].public_ip
}

output "client_public_ips" {
   value = aws_instance.client[*].public_ip
}

output "server_lb_ip" {
  value = aws_elb.server_lb.dns_name
}


resource "aws_iam_role_policy" "mount_ebs_volumes" {
  name   = "mount-ebs-volumes"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.mount_ebs_volumes.json
}

data "aws_iam_policy_document" "mount_ebs_volumes" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
    ]
    resources = ["*"]
  }
}

resource "aws_ebs_volume" "mysql-ebs" {
  availability_zone = aws_instance.client[0].availability_zone
  size              = 40
}

output "aws_ebs_volume" {
  value = aws_ebs_volume.mysql-ebs.id
}

resource "aws_security_group" "drifter" {
  vpc_id      = data.aws_vpc.default.id
  description = "EFS Access Security Group"

  tags = {
    Name = "drifter-EFS"
  }
}

resource "aws_security_group_rule" "drifter-ingress" {
  description       = "Ingress rule to allow traffic to EFS"
  from_port         = 2049
  protocol          = "TCP"
  cidr_blocks       = ["172.31.0.0/16"]
  security_group_id = aws_security_group.drifter.id
  to_port           = 2049
  type              = "ingress"
}

resource "aws_security_group_rule" "drifter-egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.drifter.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_efs_file_system" "drifter" {
  creation_token = "drifter"
  encrypted      = true
  tags = {
    Name = "LvEfs"
  }
}

resource "aws_efs_mount_target" "drifter1" {
  file_system_id  = aws_efs_file_system.drifter.id
  subnet_id       = "subnet-fc1e8cb1"
  security_groups = [aws_security_group.drifter.id]
}
resource "aws_efs_mount_target" "drifter2" {
  file_system_id  = aws_efs_file_system.drifter.id
  subnet_id       = "subnet-6564e06b"
  security_groups = [aws_security_group.drifter.id]
}

output "aws_efs_file_system" {
  value = aws_efs_file_system.drifter.id
}

resource "nomad_job" "efs_plugin" {
  jobspec    = file("jobs/plugin-drifter.efs.nomad")
  depends_on = [time_sleep.wait_2_min]
  purge_on_destroy = true
}


resource "nomad_job" "ebs_plugin_ctl" {
  jobspec    = file("jobs/plugin-ebs-controller.nomad")
  depends_on = [time_sleep.wait_2_min]
  purge_on_destroy = true
}

resource "nomad_job" "ebs_plugin_node" {
  jobspec    = file("jobs/plugin-ebs-node.nomad")
  depends_on = [time_sleep.wait_2_min]
  purge_on_destroy = true
}
/*
resource "nomad_job" "drifter-mysql" {
  jobspec    = file("jobs/mysql-server-drifter.nomad")
  depends_on = [nomad_volume.efs]
  purge_on_destroy = true
}

resource "nomad_job" "mysql-ebs" {
  jobspec    = file("jobs/mysql-server.nomad")
  depends_on = [nomad_volume.ebs]
  purge_on_destroy = true
}
*/
/*
data "nomad_plugin" "efs" {
  plugin_id           = "aws-efs0"
  wait_for_healthy    = true
}
*/

resource "nomad_volume" "efs" {
  depends_on      = [nomad_job.efs_plugin]
  type            = "csi"
  plugin_id       = "aws-efs0"
  volume_id       = "aws-efs0"
  name            = "aws-efs0"
  external_id     = aws_efs_file_system.drifter.id
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
  deregister_on_destroy = true
}

/*
data "nomad_plugin" "ebs" {
  plugin_id        = "aws-ebs0"
  wait_for_healthy = true
}
*/
resource "nomad_volume" "ebs" {
  depends_on      = [nomad_job.ebs_plugin_ctl, nomad_job.ebs_plugin_node]
  type            = "csi"
  plugin_id       = "aws-ebs0"
  volume_id       = "aws-ebs0"
  name            = "aws-ebs0"
  external_id     = aws_ebs_volume.mysql-ebs.id
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
  deregister_on_destroy = true
}


