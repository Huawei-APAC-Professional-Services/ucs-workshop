// Need to wait for cloud-init to finish
resource "time_sleep" "wait_60_seconds" {
  depends_on = [ huaweicloud_compute_keypair.ecs_keypair,huaweicloud_compute_instance.test ]

  create_duration = "60s"
}

resource "null_resource" "ucs_file_copy_app_to_test_ecs" {
  depends_on = [ time_sleep.wait_60_seconds ]
  triggers = {
#    ecs_public_ip = huaweicloud_compute_instance.test.id
     always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("ecs.pem")
    host        = huaweicloud_vpc_eip.ecs_test_singapore.address
  }

  provisioner "file" {
    source      = "app.yaml"
    destination = "/root/app/app.yaml"
  }

  provisioner "file" {
    source      = "propagation.yaml"
    destination = "/root/app/propagation.yaml"
  }

#  provisioner "file" {
#    source      = "kubeconfig.json"
#    destination = "/root/.kube/config"
#  }
}