packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "docker_image" {
  type    = string
  default = "ubuntu:xenial"
}

source "docker" "ubuntu" {
  image  = var.docker_image
  commit = true
}

build {
  name = "learn-packer"
  hcp_packer_registry {
    bucket_name = "learn-packer-ubuntu"
    description = <<EOT
       Sample image.
    EOT
    bucket_labels = {
      "owner"          = "platform-team",
      "os"             = "Ubuntu",
      "ubuntu-version" = "Bionic",
    }

    sources = [
      "source.docker.ubuntu"
    ]

    provisioner "shell" {
      environment_vars = [
        "FOO=hello world",
      ]
      inline = [
        "echo Adding file to Docker Container",
        "echo \"FOO is $FOO\" > example.txt",
        "echo Running ${var.docker_image} Docker image",
      ]
    }

    post-processor "docker-tag" {
      repository = "learn-packer"
      tags       = ["ubuntu-bionic", "packer-rocks"]
      only       = ["docker.ubuntu"]
    }
  }
}
