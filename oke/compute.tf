/* Instances */
resource "oci_core_instance" "Bastion" {
  availability_domain = data.oci_identity_availability_domains.ashburn.availability_domains[0]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "Bastion-Test"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.s-lb.id
    display_name     = "primaryvnic"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.iad.aaaaaaaaiu73xa6afjzskjwvt3j5shpmboxtlo7yw4xpeqpdz5czpde7px2a"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(var.user-data)
  }

  timeouts {
    create = "60m"
  }
}

variable "user-data" {
  default = <<EOF
#!/bin/bash -x
echo '################### webserver userdata begins #####################'
touch ~opc/userdata.`date +%s`.start

# echo '########## yum update all ###############'
yum update -y
sudo su -
mkdir atp
cd atp
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/9Oks1KgFdpmGrTrKps0pQHF0IyIoSJ-Jr5UexcMHyok/n/orasenatdpltinfomgmt01/b/BUCKETM07/o/clientrpms.zip
unzip clientrpms.zip
rpm -ivh clientrpms/oracle-instantclient18.5-basic-18.5.0.0.0-3.x86_64.rpm clientrpms/oracle-instantclient18.5-sqlplus-18.5.0.0.0-3.x86_64.rpm clientrpms/oracle-instantclient18.5-tools-18.5.0.0.0-3.x86_64.rpm
EOF

}

output "Bastion" {
  value = [oci_core_instance.Bastion.public_ip]
}

