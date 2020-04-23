data "http" "instance-metadata" {
  url = "http://169.254.169.254/opc/v1/instance/"
}

locals {
  blob = "${replace(data.http.instance-metadata.body, "/\n*/", "")}"
  compartment_id = "${replace(local.blob, "/.*compartmentId\" : \"(.*?)\",.*/", "$1")}"
}

output "instance-compartment" {
  value = "${local.compartment_id}"
}

data "oci_identity_compartment" "instance-compartment" {
  id = "${local.compartment_id}"
}

output "tenancy_ocid" {
  value = "${data.oci_identity_compartment.instance-compartment.compartment_id}"
}