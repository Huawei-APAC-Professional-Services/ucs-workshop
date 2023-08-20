locals {
  usc_singapore_cce_master_cidr = cidrsubnet(var.ucs_singapore_cidr,8,0)
  usc_singapore_cce_pod_cidr = cidrsubnet(var.ucs_singapore_cidr,4,1)
}

resource "huaweicloud_vpc" "ucs_singapore" {
  name = "ucs_singapore"
  cidr = var.ucs_singapore_cidr

  tags = {
    foo = "Env"
    key = "ucs_workshop"
  }
}

resource "huaweicloud_vpc_subnet" "usc_singapore_cce_master" {
  name       = "usc_singapore_cce_master"
  cidr       = local.usc_singapore_cce_master_cidr
  
  gateway_ip = cidrhost(local.usc_singapore_cce_master_cidr,1)
  vpc_id     = huaweicloud_vpc.ucs_singapore.id
}

resource "huaweicloud_vpc_subnet" "usc_singapore_cce_pod" {
  name       = "usc_singapore_cce_pod"
  cidr       = local.usc_singapore_cce_pod_cidr
  
  gateway_ip = cidrhost(local.usc_singapore_cce_pod_cidr,1)
  vpc_id     = huaweicloud_vpc.ucs_singapore.id
}

#resource "huaweicloud_cce_cluster" "ucs_singapore" {
#  name                   = "ucs_singapore"
#  flavor_id              = "cce.s1.small"
#  vpc_id                 = huaweicloud_vpc.ucs_singapore.id
#  subnet_id              = huaweicloud_vpc_subnet.mysubnet.id
#  container_network_type = "eni"
#  eni_subnet_id          = join(",", [
#    huaweicloud_vpc_subnet.eni_test_1.ipv4_subnet_id,
#    huaweicloud_vpc_subnet.eni_test_2.ipv4_subnet_id,
#  ])
#}