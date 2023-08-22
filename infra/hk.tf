locals {
  ucs_hk_cce_master_cidr = cidrsubnet(var.ucs_hk_cidr, 8, 0)
  ucs_hk_elb_cidr        = cidrsubnet(var.ucs_hk_cidr, 8, 2)
  ucs_hk_cce_pod_cidr    = cidrsubnet(var.ucs_hk_cidr, 4, 1)
}

resource "huaweicloud_vpc" "ucs_hk" {
  provider = huaweicloud.hk
  name     = "ucs_hk"
  cidr     = var.ucs_hk_cidr

  tags = {
    foo = "Env"
    key = "ucs_workshop"
  }
}

resource "huaweicloud_vpc_subnet" "ucs_hk_cce_master" {
  provider = huaweicloud.hk
  name     = "ucs_hk_cce_master"
  cidr     = local.ucs_hk_cce_master_cidr

  gateway_ip = cidrhost(local.ucs_hk_cce_master_cidr, 1)
  vpc_id     = huaweicloud_vpc.ucs_hk.id
}

resource "huaweicloud_vpc_subnet" "ucs_hk_cce_pod" {
  provider = huaweicloud.hk
  name     = "ucs_hk_cce_pod"
  cidr     = local.ucs_hk_cce_pod_cidr

  gateway_ip = cidrhost(local.ucs_hk_cce_pod_cidr, 1)
  vpc_id     = huaweicloud_vpc.ucs_hk.id
}

resource "huaweicloud_vpc_subnet" "ucs_hk_elb" {
  provider = huaweicloud.hk
  name     = "ucs_hk_elb"
  cidr     = local.ucs_hk_elb_cidr

  gateway_ip = cidrhost(local.ucs_hk_elb_cidr, 1)
  vpc_id     = huaweicloud_vpc.ucs_hk.id
}

resource "huaweicloud_vpc_eip" "cce_hk" {
  provider = huaweicloud.hk
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "cce-hk"
    size        = 10
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_cce_cluster" "ucs_hk" {
  provider               = huaweicloud.hk
  name                   = "ucs-hk"
  flavor_id              = "cce.s2.small"
  vpc_id                 = huaweicloud_vpc.ucs_hk.id
  subnet_id              = huaweicloud_vpc_subnet.ucs_hk_cce_master.id
  container_network_type = "eni"
  eni_subnet_id          = huaweicloud_vpc_subnet.ucs_hk_cce_pod.ipv4_subnet_id
  eip                    = huaweicloud_vpc_eip.cce_hk.address
}

resource "huaweicloud_cce_node_pool" "ucs_hk" {
  provider                 = huaweicloud.hk
  cluster_id               = huaweicloud_cce_cluster.ucs_hk.id
  name                     = "ucs-hk"
  os                       = "Ubuntu 18.04"
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

output "hk_elb_subnet_id" {
  value = huaweicloud_vpc_subnet.ucs_hk_elb.id
}