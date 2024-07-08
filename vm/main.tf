provider "hcp" {}

provider "google" {
  project = var.project-id
  region  = "europe-west3"
  zone    = "europe-west3-a"
}

data "hcp_packer_version" "ubuntu" {
  bucket_name  = "dbag-debian-tfe-base"
  channel_name = "development"
}

data "hcp_packer_artifact" "ubuntu_europe_west3" {
  bucket_name         = "dbag-debian-tfe-base"
  platform            = "gce"
  version_fingerprint = data.hcp_packer_version.ubuntu.fingerprint
  region              = "europe-west3-a"
}

resource "google_compute_network" "default" {
  name = "default-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "my-vm"
  machine_type = "n1-standard-1"
  zone         = "europe-west3-a"

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

