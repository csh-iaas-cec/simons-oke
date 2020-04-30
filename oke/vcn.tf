#### VCN  #######

resource "oci_core_virtual_network" "oke-vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = "oke-vcn"
  dns_label      = "okevcn"

  # provisioner "local-exec" {
  #   command = "sleep 5"
  # }
}

#### Internet Gateay ###

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  display_name   = "igw"
  vcn_id         = oci_core_virtual_network.oke-vcn.id
}

#### Route Table #####

resource "oci_core_route_table" "rt1" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.oke-vcn.id
  display_name   = "rt1"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

##### Security Lists ######

resource "oci_core_security_list" "sl-lb" {
  display_name   = "sl-loadbalancer"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.oke-vcn.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
    stateless   = true
  }

  ingress_security_rules {
    protocol  = "6"
    source    = "0.0.0.0/0"
    stateless = true
  }
}

resource "oci_core_security_list" "sl-w" {
  display_name   = "sl-workernodes"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.oke-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
  egress_security_rules {
    protocol    = "all"
    destination = var.vcn_cidr_block
    stateless   = true
  }

  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }

    protocol = 6
    source   = "130.35.0.0/16"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }

    protocol = 6
    source   = "138.1.0.0/17"
  }
  ingress_security_rules {
    icmp_options {
      type = 3
      code = 4
    }

    protocol = 1
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    protocol  = "all"
    source    = var.vcn_cidr_block
    stateless = true
  }
}

#### Subnet  #######

resource "oci_core_subnet" "s-w1" {
  availability_domain = data.oci_identity_availability_domains.ashburn.availability_domains[0]["name"]
  cidr_block          = var.subnet_cidr_w1
  display_name        = "subnet1-worker"
  security_list_ids   = [oci_core_security_list.sl-w.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.oke-vcn.id
  route_table_id      = oci_core_route_table.rt1.id
  dhcp_options_id     = oci_core_virtual_network.oke-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true

  # provisioner "local-exec" {
  #   command = "sleep 5"
  # }
}

resource "oci_core_subnet" "s-w2" {
  availability_domain = data.oci_identity_availability_domains.ashburn.availability_domains[1]["name"]
  cidr_block          = var.subnet_cidr_w2
  display_name        = "subnet2-worker"
  security_list_ids   = [oci_core_security_list.sl-w.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.oke-vcn.id
  route_table_id      = oci_core_route_table.rt1.id
  dhcp_options_id     = oci_core_virtual_network.oke-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true

  # provisioner "local-exec" {
  #   command = "sleep 5"
  # }
}

resource "oci_core_subnet" "s-lb1" {
  availability_domain = data.oci_identity_availability_domains.ashburn.availability_domains[0]["name"]
  cidr_block          = var.subnet_cidr_lb2
  display_name        = "subnet1-loadbalancer"
  security_list_ids   = [oci_core_security_list.sl-lb.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.oke-vcn.id
  route_table_id      = oci_core_route_table.rt1.id
  dhcp_options_id     = oci_core_virtual_network.oke-vcn.default_dhcp_options_id
  dns_label           = "loadbalancer1"

  # provisioner "local-exec" {
  #   command = "sleep 5"
  # }
}

resource "oci_core_subnet" "s-lb2" {
  availability_domain = data.oci_identity_availability_domains.ashburn.availability_domains[1]["name"]
  cidr_block          = var.subnet_cidr_lb1
  display_name        = "subnet2-loadbalancer"
  security_list_ids   = [oci_core_security_list.sl-lb.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.oke-vcn.id
  route_table_id      = oci_core_route_table.rt1.id
  dhcp_options_id     = oci_core_virtual_network.oke-vcn.default_dhcp_options_id
  dns_label           = "loadbalancer2"

  # provisioner "local-exec" {
  #   command = "sleep 5"
  # }
}

resource "oci_core_network_security_group" "simmons_network_security_group" {
    #Required
    compartment_id = "${var.compartment_ocid}"
    vcn_id = "${oci_core_virtual_network.oke-vcn.id}"
    display_name = "${var.network_security_group_display_name}"
}

resource "oci_core_network_security_group_security_rule" "ingress_network_security_group_security_rule" {
    #Required
    network_security_group_id = oci_core_network_security_group.simmons_network_security_group.id
    vcn_id = oci_core_virtual_network.oke-vcn.id
    direction = "INGRESS"
    protocol = "6"
    source = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    tcp_options {

        #Optional
        destination_port_range {
            #Required
            max = "1522"
            min = "1522"
        }
    }
}

resource "oci_core_network_security_group_security_rule" "egress_network_security_group_security_rule" {
    #Required
    network_security_group_id = "${oci_core_network_security_group.simmons_network_security_group.id}"
    direction = "EGRESS"
    protocol = "all"

    destination = "all-iad-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
}

data "oci_core_services" "test_services" {
}

