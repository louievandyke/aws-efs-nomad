job "repro" {
  datacenters = ["dc1"]
  type = "batch"

  group "repro" {

    task "a" {
      driver = "docker"
      config {
        image = "alpine:3"
        command = "cat"
        args = ["${NOMAD_ALLOC_DIR}/shared.txt"]
      }

      template {
        destination = "${NOMAD_ALLOC_DIR}/shared.txt"
        data = <<EOH
Hello, world!
EOH
      }
    }

    task "b" {
      driver = "docker"
      config {
        image = "alpine:3"
        command = "cat"
        args = ["${NOMAD_ALLOC_DIR}/shared.txt"]
      }
    }
  }
}
