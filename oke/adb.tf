// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "random_string" "autonomous_database_admin_password" {
  length      = 16
  min_numeric = 1
  min_lower   = 1
  min_upper   = 1
  min_special = 1
}

data "oci_database_autonomous_db_versions" "test_autonomous_db_versions" {
  #Required
  compartment_id = "${var.compartment_ocid}"

  #Optional
  db_workload = "${var.autonomous_database_db_workload}"
}

resource "oci_database_autonomous_database" "autonomous_database" {
  #Required
  admin_password           = "${random_string.autonomous_database_admin_password.result}"
  compartment_id           = "${var.compartment_ocid}"
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = "SimmonsATPtest"

  #Optional
  db_version                                     = "${data.oci_database_autonomous_db_versions.test_autonomous_db_versions.autonomous_db_versions.0.version}"
  db_workload                                    = "${var.autonomous_database_db_workload}"
  display_name                                   = "SimmonsATPTest"
  freeform_tags                                  = "${var.autonomous_database_freeform_tags}"
  is_auto_scaling_enabled                        = "true"
  license_model                                  = "${var.autonomous_database_license_model}"
  is_preview_version_with_service_terms_accepted = "false"
  subnet_id                                      = oci_core_subnet.s-worker.id
  nsg_ids                                        = [oci_core_network_security_group.simmons_network_security_group.id]
}

data "oci_database_autonomous_databases" "autonomous_databases" {
  #Required
  compartment_id = "${var.compartment_ocid}"

  #Optional
  display_name = "${oci_database_autonomous_database.autonomous_database.display_name}"
  db_workload  = "${var.autonomous_database_db_workload}"
}

output "autonomous_database_admin_password" {
  value = "${random_string.autonomous_database_admin_password.result}"
}

output "autonomous_database_high_connection_string" {
  value = "${lookup(oci_database_autonomous_database.autonomous_database.connection_strings.0.all_connection_strings, "high", "unavailable")}"
}

output "autonomous_databases" {
  value = "${data.oci_database_autonomous_databases.autonomous_databases.autonomous_databases}"
}