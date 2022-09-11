job "ethereum" {
  datacenters = ["dc1"]
  #namespace = "explorer"
  type = "service"

  update {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "50m"
    healthy_deadline = "1h"
    progress_deadline = "2h"
    auto_revert = false
    canary = 0
  }

  group "chain" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    network {
      mode = "bridge"
      port "eth" { }
      port "postgre" { }
    }

    service {
      name = "ethereum"
      port = "eth"

      check {
        name     = "eth-tcp"
        port     = "eth"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "ceph-volume" {
      type            = "csi"
      read_only       = false
      source          = "ethereum"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "eth" {
      driver = "docker"

      config {
        image = "ethereum/client-go:v1.10.20"
        ports = ["eth"]
        args = [
          "--syncmode=full",
          "--cache=6144",
          "--txlookuplimit=0",
          "--nat=none",
          "--port=38336",
          "--ws",
          "--ws.addr=0.0.0.0",
          "--ws.port=8036",
          "--ws.origins=*",
          "--http",
          "--http.port=8136",
          "--http.addr=0.0.0.0",
          "--nousb",
          "--http.corsdomain=*",
          "--http.vhosts=*",
        ]
      }
image = "busybox"
args = ["sleep", "60"]
}
      volume_mount {
        volume = "ceph-volume"
        destination = "/root"
        read_only   = false
      }

      resources {
        cpu = 100	
        memory = 100
      }
    }
  }
}

