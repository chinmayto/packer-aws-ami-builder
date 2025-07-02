locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "ami_prefix" {
  type    = string
  default = "packer-linux-aws"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "al2023" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
    # owners      = ["099720109477"]
  }
  ssh_username = "ec2-user"
}

build {
  name = "ami-packer"
  sources = [
    "source.amazon-ebs.al2023"
  ]

  provisioner "shell" {
    scripts = ["install_httpd.sh"]
  }

  post-processor "manifest" {
    output = "ami_manifest.json"
  }

}
