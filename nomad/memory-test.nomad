job "memory-test" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "nm-podman"
  }

  group "memory-test-group" {

    task "memory-test-task" {
      driver = "podman"

      resources {
        cpu    = 500
        memory = 64
      }
      config {
        image       = "docker://valentinomiazzo/jvm-memory-test"
        memory_swap = "180m"
      }
      env {
        ALLOC_HEAP_MB    = "5"
        MAX_HEAP_SIZE_MB = "10000"
      }
    }
  }
}