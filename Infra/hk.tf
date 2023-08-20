locals {
  usc_hk_cce_master_cidr = cidrsubnet(var.ucs_hk_cidr,8,0)
  usc_hk_cce_pod_cidr = cidrsubnet(var.ucs_hk_cidr,4,1)
}

resource "huaweicloud_vpc" "ucs_hk" {
  name = "ucs_hk"
  cidr = var.ucs_hk_cidr

  tags = {
    foo = "Env"
    key = "ucs_workshop"
  }
}

resource "huaweicloud_vpc_subnet" "usc_hk_cce_master" {
  name       = "usc_hk_cce_master"
  cidr       = local.usc_hk_cce_master_cidr
  
  gateway_ip = cidrhost(local.usc_hk_cce_master_cidr,1)
  vpc_id     = huaweicloud_vpc.ucs_hk.id
}

resource "huaweicloud_vpc_subnet" "usc_hk_cce_pod" {
  name       = "usc_hk_cce_pod"
  cidr       = local.usc_hk_cce_pod_cidr
  
  gateway_ip = cidrhost(local.usc_hk_cce_pod_cidr,1)
  vpc_id     = huaweicloud_vpc.ucs_hk.id
}