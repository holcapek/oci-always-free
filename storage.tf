resource "oci_identity_compartment" "storage" {
  compartment_id = var.tenancy_id
  description    = "Storage resources"
  name           = "storage"
}

resource "oci_objectstorage_bucket" "public_bucket" {
  compartment_id        = oci_identity_compartment.storage.id
  name                  = "public"
  namespace             = "fr3a9jifq6xo"
  access_type           = "ObjectRead"
  object_events_enabled = true
}

resource "oci_objectstorage_bucket" "private_bucket" {
  compartment_id        = oci_identity_compartment.storage.id
  name                  = "private"
  namespace             = "fr3a9jifq6xo"
  access_type           = "NoPublicAccess"
  object_events_enabled = true
}

resource "oci_core_volume" "instance_1_volume" {
  compartment_id      = oci_identity_compartment.storage.id
  availability_domain = data.oci_identity_availability_domain.ad_2.name // in compute
  size_in_gbs         = "50"
}

resource "oci_core_volume_attachment" "instance_1_attachment" {
  attachment_type = "PARAVIRTUALIZED"
  instance_id     = oci_core_instance.instance_1.id
  volume_id       = oci_core_volume.instance_1_volume.id
}

resource "oci_core_volume" "instance_2_volume" {
  compartment_id      = oci_identity_compartment.storage.id
  availability_domain = data.oci_identity_availability_domain.ad_2.name // in compute
  size_in_gbs         = "50"
}

resource "oci_core_volume_attachment" "instance_2_attachment" {
  attachment_type = "PARAVIRTUALIZED"
  instance_id     = oci_core_instance.instance_2.id
  volume_id       = oci_core_volume.instance_2_volume.id
}

