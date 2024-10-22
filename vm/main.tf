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

data "hcp_packer_artifact" "ubuntu_europe_west3" {
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
  machine_type = "n1-standard-1"
  zone         = "us-west1-a"

  boot_disk {
    initialize_params {
      image = data.hcp_packer_artifact.ubuntu_europe_west3.external_identifier
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
  machine_type = "n1-standard-1"
  zone         = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20240701"
    }
  }

  network_interface {
    network = google_compute_network.default.name

    access_config {
      // Ephemeral IP
    }
  }
}

