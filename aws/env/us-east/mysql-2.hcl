job "mysql-server-2" {
  datacenters = ["dc1"]
  type        = "service"

  group "mysql-server-2" {
    count = 4

    volume "efs_vol1" {
      type      = "csi"
      read_only = false
      source    = "efs_vol0"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "mysql-server-2" {
      driver = "docker"

      volume_mount {
        volume      = "efs_vol1"
        destination = "/srv"
        read_only   = false
      }

      env = {
        "MYSQL_ROOT_PASSWORD" = "password"
      }

      config {
        image = "hashicorp/mysql-portworx-demo:latest"
        args = ["--datadir", "/srv/drifter"]

        port_map {
          db = 3307
        }
      }

      resources {
        cpu    = 500
        memory = 1024

        network {
          port "db" {
            static = 3307
          }
        }
      }

      service {
        name = "mysql-server-2"
        port = "db"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
