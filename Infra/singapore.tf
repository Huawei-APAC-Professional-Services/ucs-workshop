locals {
  ucs_singapore_cce_master_cidr = cidrsubnet(var.ucs_singapore_cidr, 8, 0)
  ucs_singapore_elb_cidr        = cidrsubnet(var.ucs_singapore_cidr, 8, 2)
  ucs_singapore_test_cidr       = cidrsubnet(var.ucs_singapore_cidr, 8, 3)
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

resource "huaweicloud_vpc_subnet" "ucs_singapore_elb" {
  name = "ucs_singapore_elb"
  cidr = local.ucs_singapore_elb_cidr

  gateway_ip = cidrhost(local.ucs_singapore_elb_cidr, 1)
  vpc_id     = huaweicloud_vpc.ucs_singapore.id
}

resource "huaweicloud_vpc_subnet" "ucs_singapore_test" {
  name = "ucs_singapore_test"
  cidr = local.ucs_singapore_test_cidr

  gateway_ip = cidrhost(local.ucs_singapore_test_cidr, 1)
  vpc_id     = huaweicloud_vpc.ucs_singapore.id
}

data "huaweicloud_availability_zones" "zones" {}

data "huaweicloud_compute_flavors" "ecsflavor" {
  availability_zone = data.huaweicloud_availability_zones.zones.names[0]
  performance_type  = "normal"
  cpu_core_count    = 2
  memory_size       = 4
}

data "huaweicloud_images_image" "ubuntu" {
  name        = "Ubuntu 22.04 server 64bit"
  most_recent = true
}

resource "huaweicloud_compute_keypair" "ecs_keypair" {
  name     = "ecs-keypair"
  key_file = "ecs.pem"
}

resource "huaweicloud_networking_secgroup" "ecs_secgroup" {
  name        = "ecs_secgroup"
  description = "Allow SSH to ECS"
}

resource "huaweicloud_networking_secgroup_rule" "ecs_secgroup_allow_ssh" {
  security_group_id = huaweicloud_networking_secgroup.ecs_secgroup.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_compute_instance" "test" {
  name                        = "test"
  image_id                    = data.huaweicloud_images_image.ubuntu.id
  user_data                   = file("ecs.yaml")
  key_pair                    = huaweicloud_compute_keypair.ecs_keypair.name
  flavor_id                   = data.huaweicloud_compute_flavors.ecsflavor.ids[0]
  security_group_ids          = [huaweicloud_networking_secgroup.ecs_secgroup.id]
  availability_zone           = data.huaweicloud_availability_zones.zones.names[0]
  delete_disks_on_termination = true

  network {
    uuid = huaweicloud_vpc_subnet.ucs_singapore_test.id
  }
}

resource "huaweicloud_vpc_eip" "ecs_test_singapore" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "ecs-test-singapore"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_compute_eip_associate" "associated" {
  public_ip   = huaweicloud_vpc_eip.ecs_test_singapore.address
  instance_id = huaweicloud_compute_instance.test.id
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

output "ecs_public_ip" {
  value = huaweicloud_vpc_eip.ecs_test_singapore.address
}

output "singapore_elb_subnet_id" {
  value = huaweicloud_vpc_subnet.ucs_singapore_elb.id
}