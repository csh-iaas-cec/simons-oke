#### VCN  #######

resource "oci_core_vcn" "oke-vcn" {
  cidr_block     = "10.0.0.0/16"
  dns_label      = "vcn1"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "vcn1"
}

resource "oci_core_nat_gateway" "oke_nat_gateway" {
    #Required
    compartment_id = "${var.compartment_ocid}"
    vcn_id = "${oci_core_vcn.oke-vcn.id}"
}

resource "oci_core_internet_gateway" "oke_internet_gateway" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "OKEInternetGateway"
  vcn_id         = "${oci_core_vcn.oke-vcn.id}"
}


##### Security Lists ######


resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = "${oci_core_vcn.oke-vcn.default_security_list_id}"
  display_name               = "defaultSecurityList"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    protocol  = 1
    source    = "0.0.0.0/0"
    stateless = true

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "10.0.0.0/16"
    stateless = false

    tcp_options {
      min = 1522
      max = 1522
    }
  }
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "10.0.0.0/16"
    stateless = false
  }

  ingress_security_rules {
    protocol  = 1
    source    = "10.0.0.0/16"
    stateless = true

    icmp_options {
      type = 3
    }
  }
}

resource "oci_core_security_list" "sl-lb" {
  display_name   = "sl-loadbalancer"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke-vcn.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
    stateless   = true
  }

  egress_security_rules {
    protocol    = "6"
    destination = "10.0.10.0/24"
    stateless   = false

    tcp_options {
      min = 		10256
      max = 		10256
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = "10.0.10.0/24"
    stateless   = false

    tcp_options {
      min = 		31762
      max = 		31762
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = "10.0.10.0/24"
    stateless   = false

    tcp_options {
      min = 	32203
      max = 	32203
    }
  }

  ingress_security_rules {
    protocol  = "all"
    source    = "10.0.0.0/16"
    stateless = true
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
  vcn_id         = oci_core_vcn.oke-vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
  egress_security_rules {
    protocol    = "all"
    destination = "10.0.11.0/24"
    stateless   = true
  }
  egress_security_rules {
    protocol    = "all"
    destination = "10.0.11.0/24"
    stateless   = true
  }
  egress_security_rules {
    protocol    = "all"
    destination = "10.0.10.0/24"
    stateless   = true
  }


  ingress_security_rules {
    protocol  = "all" // tcp
    source    = "10.0.10.0/24"
    stateless = true
  }

  ingress_security_rules {
    protocol  = "all" // tcp
    source    = "10.0.11.0/24"
    stateless = true
  }

  ingress_security_rules {
    protocol  = "all" // tcp
    source    = "10.0.12.0/24"
    stateless = true
  }

  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "10.0.0.0/16"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol  = "all" // tcp
    source    = "10.0.0.0/16"
    stateless = false
  }
  

  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "10.0.0.0/16"
    stateless = false

    tcp_options {
      min = 1522
      max = 1522
    }
  }

  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "10.0.20.0/24"
    stateless = false

    tcp_options {
      min = 32203
      max = 32203
    }
  }

  ingress_security_rules {
    protocol  = "all" // tcp
    source    = "10.0.20.0/24"
    stateless = false
  }



}


resource "oci_core_route_table" "rt_worker" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke-vcn.id}"
  display_name   = "routeTableWorker"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_nat_gateway.oke_nat_gateway.id}"
  }
}

resource "oci_core_route_table" "rt_lb" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke-vcn.id}"
  display_name   = "routeTableLb"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.oke_internet_gateway.id}"
  }
}


resource "oci_core_subnet" "s-worker" {
  cidr_block                 = var.subnet_cidr_worker
  display_name               = "subnet1-worker"
  dns_label                  = "workerdns"
  security_list_ids          = [oci_core_security_list.sl-w.id]
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke-vcn.id
  route_table_id             = oci_core_route_table.rt_worker.id
  dhcp_options_id            = oci_core_vcn.oke-vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}



resource "oci_core_subnet" "s-lb" {
  cidr_block          = var.subnet_cidr_lb
  dns_label           = "lbdns"
  display_name        = "subnet1-loadbalancer"
  security_list_ids   = [oci_core_security_list.sl-lb.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.oke-vcn.id
  route_table_id      = oci_core_route_table.rt_lb.id
  dhcp_options_id     = oci_core_vcn.oke-vcn.default_dhcp_options_id
}

resource "oci_core_network_security_group" "simmons_network_security_group" {
  #Required
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke-vcn.id}"
  display_name   = "${var.network_security_group_display_name}"
}

resource "oci_core_network_security_group_security_rule" "ingress_network_security_group_security_rule" {
  #Required
  network_security_group_id = oci_core_network_security_group.simmons_network_security_group.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.0.0.0/16"
  source_type               = "CIDR_BLOCK"
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
  direction                 = "EGRESS"
  protocol                  = "all"

  destination      = "all-iad-services-in-oracle-services-network"
  destination_type = "SERVICE_CIDR_BLOCK"
}

data "oci_core_services" "test_services" {
}

