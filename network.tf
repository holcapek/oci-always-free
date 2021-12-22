resource "oci_identity_compartment" "network" {
  compartment_id = var.tenancy_id
  description    = "Networking resources"
  name           = "network"
}

resource "oci_core_vcn" "vcn" {
  compartment_id = oci_identity_compartment.network.id
  cidr_blocks    = ["192.168.0.0/16"]
  dns_label      = "ocaexam"
  is_ipv6enabled = false
}

resource "oci_core_subnet" "public_subnet" {
  cidr_block                 = "192.168.0.0/20"
  compartment_id             = oci_identity_compartment.network.id
  vcn_id                     = oci_core_vcn.vcn.id
  dns_label                  = "pb"
  display_name               = "Public subnet"
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = oci_identity_compartment.network.id
  vcn_id         = oci_core_vcn.vcn.id
  enabled        = true
}

resource "oci_core_default_route_table" "route_table" {
  compartment_id             = oci_identity_compartment.network.id
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
  route_rules {
    network_entity_id = oci_core_internet_gateway.internet_gateway.id

    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_public_ip" "reserved_public_ip" {
  compartment_id = oci_identity_compartment.network.id
  lifetime       = "RESERVED"
  lifecycle {
    ignore_changes = [private_ip_id]
  }
}

resource "oci_load_balancer_load_balancer" "load_balancer" {
  compartment_id = oci_identity_compartment.network.id
  display_name   = "Public Loadbalancer"
  shape          = "flexible"
  subnet_ids     = [oci_core_subnet.public_subnet.id]
  ip_mode        = "IPV4"
  is_private     = false
  reserved_ips {
    id = oci_core_public_ip.reserved_public_ip.id
  }
  shape_details {
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }
}

resource "oci_core_subnet" "private_subnet" {
  cidr_block                 = "192.168.16.0/20"
  compartment_id             = oci_identity_compartment.network.id
  vcn_id                     = oci_core_vcn.vcn.id
  dns_label                  = "pr"
  display_name               = "Private subnet"
  prohibit_internet_ingress  = true
  prohibit_public_ip_on_vnic = true
}

resource "oci_load_balancer_backend_set" "instance_1_ssh_backend_set" {
  health_checker {
    protocol = "TCP"
    port     = "22"
  }
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "instance-1-ssh-backend-set"
  policy           = "ROUND_ROBIN"

}

resource "oci_load_balancer_backend" "instance_1_ssh_backend" {
  backendset_name  = "instance-1-ssh-backend-set"
  ip_address       = oci_core_instance.instance_1.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  port             = "22"
}

resource "oci_load_balancer_listener" "instance_1_ssh_listener" {
  default_backend_set_name = "instance-1-ssh-backend-set"
  load_balancer_id         = oci_load_balancer_load_balancer.load_balancer.id
  name                     = "instance-1-ssh-listener"
  port                     = "30221"
  protocol                 = "TCP"
}

resource "oci_load_balancer_backend_set" "instance_2_ssh_backend_set" {
  health_checker {
    protocol = "TCP"
    port     = "22"
  }
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "instance-2-ssh-backend-set"
  policy           = "ROUND_ROBIN"

}

resource "oci_load_balancer_backend" "instance_2_ssh_backend" {
  backendset_name  = "instance-2-ssh-backend-set"
  ip_address       = oci_core_instance.instance_2.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  port             = "22"
}

resource "oci_load_balancer_listener" "instance_2_ssh_listener" {
  default_backend_set_name = "instance-2-ssh-backend-set"
  load_balancer_id         = oci_load_balancer_load_balancer.load_balancer.id
  name                     = "instance-2-ssh-listener"
  port                     = "30222"
  protocol                 = "TCP"
}

