job "lvtest" {
  datacenters = ["dc1"]
  type        = "service"

  group "lvtest" {
    count = 1

    volume "lvtest" {
      type      = "csi"
      read_only = false
      source    = "lvtest"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "lvtest-server" {
      driver = "docker"

      volume_mount {
        volume      = "lvtest"
        destination = "/srv"
        read_only   = false
      }

      env = {
        "MYSQL_ROOT_PASSWORD" = "password"
      }

      config {
        image = "hashicorp/mysql-portworx-demo:latest"
        args = ["--datadir", "/srv/lvtest"]

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
        name = "mysql-server"
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