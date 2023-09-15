#######################################################################
## setup wordpress
#######################################################################

resource "terraform_data" "wordpress_setup" {
  count = var.wordpress == true ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = google_compute_instance.demo_origin_instance.network_interface.0.access_config.0.nat_ip
  }

  provisioner "file" {
    source      = "wordpress.sh"
    destination = "wordpress.sh"
  }

  provisioner "file" {
    source      = "fastly-wordpress-plugin.sh"
    destination = "fastly-wordpress-plugin.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x wordpress.sh fastly-wordpress-plugin.sh",
      "url=${var.site_name}.freetls.fastly.net ./wordpress.sh",
      "url=${var.site_name}.freetls.fastly.net service_id=${fastly_service_vcl.demo_service.id} api_key=${var.fastly_api_key} ./fastly-wordpress-plugin.sh"
    ]
  }
}