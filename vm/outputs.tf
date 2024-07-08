output "ubuntu_version" {
  value = data.hcp_packer_version.ubuntu
}

output "ubuntu_europe_west3" {
  value = data.hcp_packer_artifact.ubuntu_europe_west3
}