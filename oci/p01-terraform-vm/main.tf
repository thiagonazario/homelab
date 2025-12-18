# --- DADOS (Buscas na API da Oracle) ---

# Busca os domínios de disponibilidade
data "oci_identity_availability_domains" "ads" {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaafr2unkoew3hh2t5zlpxqf7vop5ji7fc746oacwsfaml5wiz4ncmq"
}

# Busca a imagem mais recente do Ubuntu 22.04
data "oci_core_images" "ubuntu_latest" {
  compartment_id           = "ocid1.tenancy.oc1..aaaaaaaafr2unkoew3hh2t5zlpxqf7vop5ji7fc746oacwsfaml5wiz4ncmq"
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# --- REDE ---

resource "oci_core_vcn" "homelab_vcn" {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaafr2unkoew3hh2t5zlpxqf7vop5ji7fc746oacwsfaml5wiz4ncmq"
  display_name   = "homelab-vcn"
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "homelab"
}

resource "oci_core_subnet" "homelab_subnet" {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaafr2unkoew3hh2t5zlpxqf7vop5ji7fc746oacwsfaml5wiz4ncmq"
  vcn_id         = oci_core_vcn.homelab_vcn.id
  display_name   = "homelab-public-subnet"
  cidr_block     = "10.0.1.0/24"
  dns_label      = "public"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_internet_gateway" "homelab_ig" {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaafr2unkoew3hh2t5zlpxqf7vop5ji7fc746oacwsfaml5wiz4ncmq"
  display_name   = "homelab-gateway"
  vcn_id         = oci_core_vcn.homelab_vcn.id
}

resource "oci_core_default_route_table" "homelab_route_table" {
  manage_default_resource_id = oci_core_vcn.homelab_vcn.default_route_table_id
  display_name               = "homelab-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.homelab_ig.id
  }
}

# --- COMPUTE (A Máquina Virtual) ---

resource "oci_core_instance" "homelab_vm" {
  compartment_id      = "ocid1.tenancy.oc1..aaaaaaaafr2unkoew3hh2t5zlpxqf7vop5ji7fc746oacwsfaml5wiz4ncmq"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "ubuntu-homelab"
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id        = oci_core_subnet.homelab_subnet.id
    assign_public_ip = true
    display_name     = "primary-vnic"
  }

  source_details {
    source_type = "image"
    # Aqui ele usa o ID que o bloco 'data' lá de cima encontrar
    source_id   = data.oci_core_images.ubuntu_latest.images[0].id
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_ed25519.pub")
  }
}


# --- Portas de acesso ---

resource "oci_core_default_security_list" "homelab_security_list" {
  manage_default_resource_id = oci_core_vcn.homelab_vcn.default_security_list_id
  display_name               = "homelab-security-list"

  # SSH (Porta 22)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Porta Web Padrão (Porta 80)
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # Porta customizada (Porta 9000)
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    tcp_options {
      min = 9000
      max = 9000
    }
  }

  # PING (ICMP)
  ingress_security_rules {
    protocol = "1" 
    source   = "0.0.0.0/0"
  }

  # Permitindo saída
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}
