job "ebs-csi-sleep" {
  region      = "global"
  datacenters = ["dc1"]
  namespace   = "default"

  group "example" {
    volume "ebs" {
      type      = "csi"
      source    = "vol01"
      read_only = false

      attachment_mode = "file-system"
      access_mode     = "single-node-writer"

      mount_options {
        fs_type = "ext4"
      }
    }

    task "alpine" {
      driver = "docker"
      config {
        image      = "alpine"
        entrypoint = ["/bin/sh"]
        args       = ["-c", "sleep 3 && echo 'fail' && exit 1"]
      }

      volume_mount {
        volume      = "ebs"
        destination = "/data"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
