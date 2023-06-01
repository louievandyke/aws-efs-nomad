# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "null_resource" "wait_for_nomad_api" {
  provisioner "local-exec" {
    command = "while ! nomad server members > /dev/null 2>&1; do echo 'waiting for nomad api...'; sleep 10; done"
    environment = {
      NOMAD_ADDR = var.nomad_addr
    }
  }
}

data "local_file" "grafana_dashboard" {
  filename = "${path.module}/files/grafana_dashboard.json"
}

resource "nomad_job" "traefik" {
  depends_on = [null_resource.wait_for_nomad_api]
  jobspec    = file("${path.module}/files/traefik.nomad")
}

resource "nomad_job" "prometheus" {
  depends_on = [null_resource.wait_for_nomad_api]
  jobspec    = file("${path.module}/files/prometheus.nomad")
}
/*
resource "nomad_job" "ebs-test" {
  depends_on = [null_resource.wait_for_nomad_api]
  jobspec    = file("${path.module}/files/ebs-test.hcl")
}
*/
resource "nomad_job" "drifter-mysql" {
  jobspec    = file("jobs/mysql-server-drifter.nomad")
  depends_on = [null_resource.wait_for_nomad_api]
}

resource "nomad_job" "mysql-server" {
  jobspec    = file("jobs/mysql-server.nomad")
  depends_on = [null_resource.wait_for_nomad_api]
}
/*
resource "nomad_job" "repro-volume" {
  jobspec    = file("${path.module}/files/repro-volume.hcl")
  depends_on = [null_resource.wait_for_nomad_api]
}
*/
resource "nomad_job" "grafana" {
  depends_on = [null_resource.wait_for_nomad_api]
  jobspec = templatefile("${path.module}/files/grafana.nomad.tpl", {
    grafana_dashboard = data.local_file.grafana_dashboard.content
  })
}

resource "nomad_job" "efs_plugin" {
  jobspec    = file("jobs/plugin-drifter.efs.nomad")
  depends_on = [null_resource.wait_for_nomad_api]
  purge_on_destroy = true
}


resource "nomad_job" "ebs_plugin_ctl" {
  jobspec    = file("jobs/plugin-ebs-controller.nomad")
  depends_on = [null_resource.wait_for_nomad_api]
  purge_on_destroy = true
}

resource "nomad_job" "ebs_plugin_node" {
  jobspec    = file("jobs/plugin-ebs-node.nomad")
  depends_on = [null_resource.wait_for_nomad_api]
  purge_on_destroy = true
}
