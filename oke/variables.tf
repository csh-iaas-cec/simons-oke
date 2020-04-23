variable "tenancy_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaajehugl3ryss2gaxf3os7g5w4xdztfhy4coqnoizm2wpmrclnv5da"
}

# variable "user_ocid" {
#   default = "ocid1.user.oc1..aaaaaaaaalv4ayoqqop6cl3rtyxkzx56cbfqmwtlooshq5ug7uy7akzgqeda"
# }

# variable "fingerprint" {
#   default = "0f:ba:71:ad:39:28:ad:c9:28:87:d8:00:3c:61:0d:a9"
# }

# variable "private_key_path" {
#   default = "~/.oci/oci_api_key.pem"
# }

variable "region" {
  default = "us-ashburn-1"
}

variable "ssh_private_key" {
  default = "~/.oci/private_key.ppk"
}

variable "ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDD+wmh23V01OAl/+mr9FTPrgRspg8EAXp93CnkcOKf8EkycmQUPS9bRdvofkY+GBmT+pO6X+ac2a5kgDCuEWHbamIVAw9Vy5350BpxUCPa9b8pdQw6daTpg5W7l0NFEgjdHArG26SP5F7WnXOIUxxW0Glxxbx6NODvvPCsIvROl3paA7Lasr84Pd5pMtDi9VS/QAxXJitsg2iAFzPb+AFK6dN5gDGr5lSOxhhTyR4KBCnYL3znp0l3Na0VMJZwd5JyOdnsP+nNJ0Zm8lv8Z4mjkPKicVSjdiXqnVmgphkvlewxVn8dz2xk/JuhuyGrZuyTqTxEp8GzvbBYq2Y2+bJV amarpsi@AMARPSI-IN"
}

variable "compartment_ocid" {
  default = "ocid1.compartment.oc1..aaaaaaaae4364npm55dpakr5e6sfpce5su2nhj6ane27344cjsvgb2e5lkra"
}

provider "oci" {
  auth = "InstancePrincipal"
  region = var.region
}

data "oci_identity_availability_domains" "ashburn" {
  compartment_id = var.tenancy_ocid
}

### Network Variables ##### 

variable "vcn_cidr_block" {
  default = "10.0.0.0/16"
}

variable "dns_label_vcn" {
  default = "dnsvcn"
}

variable "subnet_cidr_w1" {
  default = "10.0.1.0/24"
}

variable "subnet_cidr_w2" {
  default = "10.0.2.0/24"
}

variable "subnet_cidr_lb1" {
  default = "10.0.10.0/24"
}

variable "subnet_cidr_lb2" {
  default = "10.0.20.0/24"
}

variable "cluster_kubernetes_version" {
  default = "v1.15.7"
}

variable "cluster_name" {
  default = "OKE_Cluster"
}

variable "availability_domain" {
  default = 3
}

variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  default = true
}

variable "cluster_options_add_ons_is_tiller_enabled" {
  default = true
}

variable "cluster_options_kubernetes_network_config_pods_cidr" {
  default = "10.1.0.0/16"
}

variable "cluster_options_kubernetes_network_config_services_cidr" {
  default = "10.2.0.0/16"
}

variable "node_pool_initial_node_labels_key" {
  default = "project"
}

variable "node_pool_initial_node_labels_value" {
  default = "dev"
}

variable "node_pool_kubernetes_version" {
  default = "v1.15.7"
}

variable "node_pool_name" {
  default = "NodePool_1"
}

variable "node_pool_node_image_name" {
  default = "Oracle-Linux-7.5"
}

variable "node_pool_node_shape" {
  default = "VM.Standard2.1"
}

variable "instance_shape" {
  default = "VM.Standard1.2"
}

variable "node_pool_quantity_per_subnet" {
  default = 1
}

variable "node_pool_ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDD+wmh23V01OAl/+mr9FTPrgRspg8EAXp93CnkcOKf8EkycmQUPS9bRdvofkY+GBmT+pO6X+ac2a5kgDCuEWHbamIVAw9Vy5350BpxUCPa9b8pdQw6daTpg5W7l0NFEgjdHArG26SP5F7WnXOIUxxW0Glxxbx6NODvvPCsIvROl3paA7Lasr84Pd5pMtDi9VS/QAxXJitsg2iAFzPb+AFK6dN5gDGr5lSOxhhTyR4KBCnYL3znp0l3Na0VMJZwd5JyOdnsP+nNJ0Zm8lv8Z4mjkPKicVSjdiXqnVmgphkvlewxVn8dz2xk/JuhuyGrZuyTqTxEp8GzvbBYq2Y2+bJV amarpsi@AMARPSI-IN"
}

