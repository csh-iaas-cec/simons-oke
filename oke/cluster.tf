#Creates a container cluster and a node pool 

resource "oci_containerengine_cluster" "oke_cluster" {
  #Required
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.cluster_kubernetes_version
  name               = var.cluster_name
  vcn_id             = oci_core_vcn.oke-vcn.id

  #Optional
  options {
    service_lb_subnet_ids = [oci_core_subnet.s-lb.id]

    #Optional
    add_ons {
      #Optional
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = var.cluster_options_add_ons_is_tiller_enabled
    }

    kubernetes_network_config {
      #Optional
      pods_cidr     = var.cluster_options_kubernetes_network_config_pods_cidr
      services_cidr = var.cluster_options_kubernetes_network_config_services_cidr
    }
  }
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = "${var.tenancy_ocid}"
  ad_number      = 1
}

resource "oci_containerengine_node_pool" "node_pool1" {
  #Required
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.node_pool_kubernetes_version
  name               = var.node_pool_name
  node_image_name    = var.node_pool_node_image_name
  node_shape         = var.node_pool_node_shape

  #Optional
  initial_node_labels {
    #Optional
    key   = var.node_pool_initial_node_labels_key
    value = var.node_pool_initial_node_labels_value
  }

  node_config_details {
    placement_configs {
      availability_domain = "${data.oci_identity_availability_domain.ad.name}"
      subnet_id           = oci_core_subnet.s-worker.id
    }
    size = 2

  }

  ssh_public_key      = var.node_pool_ssh_public_key
}

output "cluster" {
  value = {
    id                 = oci_containerengine_cluster.oke_cluster.id
    kubernetes_version = oci_containerengine_cluster.oke_cluster.kubernetes_version
    name               = oci_containerengine_cluster.oke_cluster.name
  }
}

output "node_pool" {
  value = {
    id                 = oci_containerengine_node_pool.node_pool1.id
    kubernetes_version = oci_containerengine_node_pool.node_pool1.kubernetes_version
    name               = oci_containerengine_node_pool.node_pool1.name
    subnet_ids         = oci_containerengine_node_pool.node_pool1.subnet_ids
  }
}

