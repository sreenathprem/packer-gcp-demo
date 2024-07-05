provider "hcp" {}

provider "google" {
  project = var.project-id
  region  = "us-central1"
  zone    = "us-central1-a"
}

data "hcp_packer_version" "ubuntu" {
  bucket_name  = "learn-packer-ubuntu"
  channel_name = "production"
}

data "hcp_packer_artifact" "ubuntu_us_east_2" {
  bucket_name         = "learn-packer-ubuntu"
  platform            = "aws"
  version_fingerprint = data.hcp_packer_version.ubuntu.fingerprint
  region              = "us-east-2"
}

resource "google_compute_network" "default" {
  name = "default-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "my-vm"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = data.hcp_packer_artifact.ubuntu_us_east_2.external_identifier
    }
  }

  network_interface {
    network = google_compute_network.default.name

    access_config {
      // Ephemeral IP
    }
  }
}

