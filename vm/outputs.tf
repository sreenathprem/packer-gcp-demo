output "ubuntu_version" {
  value = data.hcp_packer_version.ubuntu
}

output "ubuntu_europe_west1" {
  value = data.hcp_packer_artifact.ubuntu_us_west1
}