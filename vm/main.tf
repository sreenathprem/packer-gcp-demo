provider "hcp" {}

provider "google" {
  project = var.project-id
  region  = "us-west1"
  zone    = "us-west1-a"
}

data "hcp_packer_version" "ubuntu" {
  bucket_name  = "dbag-debian-tfe-base"
  channel_name = "development"
}

data "hcp_packer_artifact" "ubuntu_europe_west1" {
  bucket_name         = "dbag-debian-tfe-base"
  platform            = "gce"
  version_fingerprint = data.hcp_packer_version.ubuntu.fingerprint
  region              = "us-west1-a"
}

resource "google_compute_network" "default" {
  name = "default-network"
}

resource "google_compute_instance" "packer_instance" {
  name         = "my-packer-vm"
  machine_type = var.vm-type
  zone         = "us-west1-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = data.hcp_packer_artifact.ubuntu_europe_west1.external_identifier
    }
  }

  network_interface {
    network = google_compute_network.default.name

    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "vm_instance" {
  name         = "my-nonstandard-vm"
  machine_type = var.vm-type
  zone         = "us-west1-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "tfe-base-amd64-67c0bd8f"
    }
  }

  network_interface {
    network = google_compute_network.default.name

    access_config {
      // Ephemeral IP
    }
  }
}

