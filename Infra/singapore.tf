locals {
  ucs_singapore_cce_master_cidr = cidrsubnet(var.ucs_singapore_cidr, 8, 0)
  ucs_singapore_nat_cidr = cidrsubnet(var.ucs_singapore_cidr, 8, 1)
  ucs_singapore_elb_cidr = cidrsubnet(var.ucs_singapore_cidr, 8, 2)
  ucs_singapore_cce_pod_cidr    = cidrsubnet(var.ucs_singapore_cidr, 4, 1)
}

resource "huaweicloud_vpc" "ucs_singapore" {
  name = "ucs_singapore"
  cidr = var.ucs_singapore_cidr

  tags = {
    foo = "Env"
    key = "ucs_workshop"
  }
}

resource "huaweicloud_vpc_subnet" "ucs_singapore_cce_master" {
  name = "ucs_singapore_cce_master"
  cidr = local.ucs_singapore_cce_master_cidr

  gateway_ip = cidrhost(local.ucs_singapore_cce_master_cidr, 1)
  vpc_id     = huaweicloud_vpc.ucs_singapore.id
}

resource "huaweicloud_vpc_subnet" "ucs_singapore_cce_pod" {
  name = "ucs_singapore_cce_pod"
  cidr = local.ucs_singapore_cce_pod_cidr

  gateway_ip = cidrhost(local.ucs_singapore_cce_pod_cidr, 1)
  vpc_id     = huaweicloud_vpc.ucs_singapore.id
}

resource "huaweicloud_vpc_subnet" "ucs_singapore_nat" {
  name = "ucs_singapore_nat"
  cidr = local.ucs_singapore_nat_cidr

  gateway_ip = cidrhost(local.ucs_singapore_nat_cidr, 1)
  vpc_id     = huaweicloud_vpc.ucs_singapore.id
}

resource "huaweicloud_vpc_subnet" "ucs_singapore_elb" {
  name = "ucs_singapore_elb"
  cidr = local.ucs_singapore_elb_cidr

  gateway_ip = cidrhost(local.ucs_singapore_elb_cidr, 1)
  vpc_id     = huaweicloud_vpc.ucs_singapore.id
}

resource "huaweicloud_vpc_eip" "cce_singapore" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "cce-singapore"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_cce_cluster" "ucs_singapore" {
  name                   = "ucs-singapore"
  flavor_id              = "cce.s2.small"
  vpc_id                 = huaweicloud_vpc.ucs_singapore.id
  subnet_id              = huaweicloud_vpc_subnet.ucs_singapore_cce_master.id
  container_network_type = "eni"
  eni_subnet_id          = huaweicloud_vpc_subnet.ucs_singapore_cce_pod.ipv4_subnet_id
  eip                    = huaweicloud_vpc_eip.cce_singapore.address
}

resource "huaweicloud_cce_node_pool" "ucs_singapore" {
  cluster_id               = huaweicloud_cce_cluster.ucs_singapore.id
  name                     = "ucs-singapore"
  os                       = "Ubuntu 22.04"
  initial_node_count       = 2
  flavor_id                = "c7n.large.4"
  password                 = "ucs@workshop2023"
  scall_enable             = true
  min_node_count           = 2
  max_node_count           = 5
  scale_down_cooldown_time = 100
  priority                 = 1
  type                     = "vm"

  root_volume {
    size       = 40
    volumetype = "SSD"
  }
  data_volumes {
    size       = 100
    volumetype = "SSD"
  }
}

resource "huaweicloud_nat_gateway" "ucs_singapore" {
  name        = "cce-singapore"
  description = "test for terraform"
  spec        = "1"
  vpc_id      = huaweicloud_vpc.ucs_singapore.id
  subnet_id   = huaweicloud_vpc_subnet.ucs_singapore_nat.id
}

resource "huaweicloud_vpc_eip" "ucs_singapore" {
  publicip {
    type = "5_bgp"
  }

  bandwidth {
    share_type  = "PER"
    name        = "cce_nat"
    size        = 10
    charge_mode = "traffic"
  }
}

resource "huaweicloud_nat_snat_rule" "ucs_singapore_cce_pod" {
  nat_gateway_id = huaweicloud_nat_gateway.ucs_singapore.id
  floating_ip_id = huaweicloud_vpc_eip.ucs_singapore.id
  subnet_id      = huaweicloud_vpc_subnet.ucs_singapore_cce_pod.id
}