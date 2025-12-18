terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "~> 5.0"
    }
  }
}


provider "oci" {
  tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaafr2unkoew3hh2t5zlpxqf7vop5ji7fc746oacwsfaml5wiz4ncmq"
  user_ocid        = "ocid1.user.oc1..aaaaaaaam3h5ulc526rptmo62r5p2fg7anlhx6x5a7hodwanslfc5hxbrpqa"
  fingerprint      = "a0:74:ac:39:48:92:47:d3:df:62:7c:4f:77:d9:26:1a"
  private_key_path = "./oci_api_key.pem"
  region           = "sa-saopaulo-1"

}
