locals {
  # https://www.packer.io/docs/templates/hcl_templates/functions/datetime/formatdate
  datestamp = formatdate("YYYYMMDD", timestamp())
}

# https://www.packer.io/docs/builders/googlecompute#required
source "googlecompute" "base-docker" {
  project_id   = var.project_id
  zone         = var.zone
  machine_type = "n1-standard-2"
  ssh_username = "packer"
  use_os_login = "false"

  # use custom base image that was built
  source_image_family = var.source_image_family

  image_family      = var.image_family
  image_name        = "tfe-base-${var.arch}-${local.datestamp}"
  image_description = "Consul base image"

  tags = ["packer"]
}

build {
  sources = ["sources.googlecompute.base-docker"]

  hcp_packer_registry {
    bucket_name = "ubuntu-tfe-base"
    description = <<EOT
Some nice description about the image being published to HCP Packer Registry.
    EOT
    bucket_labels = {
      "owner"          = "platform-team"
      "os"             = "Ubuntu",
      "ubuntu-version" = "Focal 20.04",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }

  # https://discuss.hashicorp.com/t/how-to-fix-debconf-unable-to-initialize-frontend-dialog-error/39201/2
  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "echo '=============================================='",
      "echo 'APT INSTALL PACKAGES & UPDATES'",
      "echo '=============================================='",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get update",
      "sudo apt-get -y install --no-install-recommends dialog apt-utils git unzip wget apt-transport-https ca-certificates curl gnupg lsb-release",
      "sudo apt-get -y upgrade",
      "sudo apt-get -y dist-upgrade",
      "sudo apt-get -y autoremove",
      "echo 'Rebooting...'",
      "sudo reboot"
    ]
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "echo '=============================================='",
      "echo 'ADD DOCKER APT REPO'",
      "echo 'https://docs.docker.com/engine/install/debian/'",
      "echo '=============================================='",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "echo 'Adding Docker GPG key...'",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo 'Adding Docker apt repo...'",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "echo 'Rebooting...'",
      "sudo reboot"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL DOCKER'",
      "echo '=============================================='",
      "ls /etc/apt/keyrings/",
      "cat /etc/apt/sources.list.d/docker.list",
      "sudo apt-get update",
      "sudo apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      "sudo systemctl disable docker"
    ]
    pause_before = "10s"
    max_retries  = 5
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "which docker",
      "sudo apt-get clean",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }
}