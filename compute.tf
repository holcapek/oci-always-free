resource "oci_identity_compartment" "compute" {
  compartment_id = var.tenancy_id
  description    = "Compute resources"
  name           = "compute"
}

data "oci_core_images" "ol8_image" {
  compartment_id = oci_identity_compartment.compute.id
  display_name   = "Oracle-Linux-8.5-2021.12.08-0"
  sort_by        = "DISPLAYNAME"
}

data "oci_identity_availability_domain" "ad_2" {
  compartment_id = oci_identity_compartment.compute.id
  ad_number      = "2"
}

resource "oci_core_instance" "instance_1" {
  availability_domain = data.oci_identity_availability_domain.ad_2.name
  compartment_id      = oci_identity_compartment.compute.id
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = "Instance 1"

  create_vnic_details {
    subnet_id        = oci_core_subnet.private_subnet.id
    assign_public_ip = false
  }
  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
    firmware         = "UEFI_64"
    network_type     = "PARAVIRTUALIZED"
  }
  shape_config {
    memory_in_gbs = "1"
    ocpus         = "1"
  }
  source_details {
    source_id   = data.oci_core_images.ol8_image.images[0].id
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.public_ssh_key
  }
}

resource "oci_core_instance" "instance_2" {
  availability_domain = data.oci_identity_availability_domain.ad_2.name
  compartment_id      = oci_identity_compartment.compute.id
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = "Instance 2"

  create_vnic_details {
    subnet_id        = oci_core_subnet.private_subnet.id
    assign_public_ip = false
  }
  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
    firmware         = "UEFI_64"
    network_type     = "PARAVIRTUALIZED"
  }
  shape_config {
    memory_in_gbs = "1"
    ocpus         = "1"
  }
  source_details {
    source_id   = data.oci_core_images.ol8_image.images[0].id
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.public_ssh_key
  }
}
