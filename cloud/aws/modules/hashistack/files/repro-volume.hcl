job "repro" {
  datacenters = ["dc1"]
  type = "batch"

  group "repro" {

  volume "ebs-volume" {
      type            = "csi"
      read_only       = false
      source          = "aws-ebs0"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "a" {
      driver = "docker"

      config {
        image = "alpine:3"
        #command = "cat"
        args = ["sleep", "600"]
      }
      volume_mount {
        volume = "ebs-volume"
        destination = "/root"
        read_only   = false
       }

      template {
        destination = "/root/shared.txt"
        data = <<EOH
Hello, world!
EOH
      }
    }

    task "b" {
      driver = "docker"
      config {
        image = "alpine:3"
        #command = "while true `ls /root/shared.txt`; do "
       # args = ["sleep", "600"]
      }
       volume_mount {
         volume = "ebs-volume"
         destination = "/root"
         read_only   = false
       }
    }
  }
}
