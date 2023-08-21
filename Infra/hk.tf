locals {
  ucs_hk_cce_master_cidr = cidrsubnet(var.ucs_hk_cidr, 8, 0)
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

resource "huaweicloud_cce_cluster" "ucs_hk" {
  provider               = huaweicloud.hk
  name                   = "ucs-hk"
  flavor_id              = "cce.s2.small"
  vpc_id                 = huaweicloud_vpc.ucs_hk.id
  subnet_id              = huaweicloud_vpc_subnet.ucs_hk_cce_master.id
  container_network_type = "eni"
  eni_subnet_id          = huaweicloud_vpc_subnet.ucs_hk_cce_pod.ipv4_subnet_id
}