job "dummy-batch" {
type = "batch"
datacenters = ["dc1"]
#namespace = "test"

parameterized {}

group "default" {
count = 2

task "default" {
driver = "docker"
config {
image = "busybox"
args = ["sleep", "60"]
}

resources {
cpu = 1000
memory = 32
}
}
}
}
