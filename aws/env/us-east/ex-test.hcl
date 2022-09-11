job "ebs-test" {
  region      = "global"
  datacenters = ["dc1"]
  namespace   = "default"

  group "example" {
    volume "ebs" {
      type      = "csi"
      source    = "disk0"
      read_only = false

      attachment_mode = "file-system"
      access_mode     = "single-node-writer"

      mount_options {
        fs_type = "ext4"
      }
    }

    task "sleepy" {
      driver = "docker"
      config {
        image      = "alpine"
        command = ["sh"]
        #args       = ["-c", "sleep 3 && echo 'fail' && exit 1"]
        args       = ["-c","while true; do sleep 10 && echo 'hello'; done"]
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
