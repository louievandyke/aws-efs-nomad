job "mysql-server-1" {
  datacenters = ["dc1"]
  type        = "service"

  group "mysql-server" {
    count = 4

    volume "aws-efs0" {
      type      = "csi"
      read_only = false
      source    = "aws-efs0"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "mysql-server-1" {
      driver = "docker"

      volume_mount {
        volume      = "aws-efs0"
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
          db = 3306
        }
      }

      resources {
        cpu    = 500
        memory = 1024

        network {
          port "db" {
            static = 3306
          }
        }
      }

      service {
        name = "mysql-server-1"
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
