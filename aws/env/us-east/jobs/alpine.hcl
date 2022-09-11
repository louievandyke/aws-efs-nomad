job "alpine" {
  datacenters = ["dc1"]

  update {
  max_parallel     = 1
  }

  group "alloc" {
    #count = 2
    restart {
      attempts = 1
      interval = "30s"
      delay    = "25s"
      mode     = "fail"
    }
    reschedule {}
     
    volume "jobVolume" {
      type      = "csi"
      read_only = false
      source    = "disk0"
      access_mode = "single-node-writer"
      attachment_mode = "file-system"

    }

    task "docker" {
      driver = "docker"

      volume_mount {
        volume      = "jobVolume"
        destination = "/srv"
        read_only   = false
      }

      config {
        image = "alpine"
        command = "sh"
        args = ["-c","while true; do sleep 10 && echo 'alive'; done"]
      }
    }
  }
}
