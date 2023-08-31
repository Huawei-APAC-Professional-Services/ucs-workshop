resource "null_resource" "ucs_file_copy_to_test_ecs" {
  depends_on = [ huaweicloud_compute_keypair.ecs_keypair ]
  triggers = {
    ecs_public_ip = huaweicloud_compute_instance.test.id
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
    source      = "propagation_policy.yaml"
    destination = "/root/app/propagation_policy.yaml"
  }
}