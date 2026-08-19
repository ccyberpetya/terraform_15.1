resource "yandex_iam_service_account" "ig_sa" {
  name = "ig-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "ig_compute_editor" {
  folder_id = var.folder_id
  role      = "compute.editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "ig_lb_editor" {
  folder_id = var.folder_id
  role      = "load-balancer.editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}
resource "yandex_compute_instance_group" "lamp_group" {
  name               = "lamp-instance-group"
  service_account_id = yandex_iam_service_account.ig_sa.id

  instance_template {
    name        = "lamp-{instance.index}"
    platform_id = "standard-v3"

    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }

    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = 10
      }
    }

    network_interface {
      network_id = yandex_vpc_network.network.id
      subnet_ids = [yandex_vpc_subnet.public.id]
    }

    metadata = {
      user-data = <<-EOF
        #cloud-config
        write_files:
          - path: /var/www/html/index.html
            permissions: '0644'
            content: |
              <!DOCTYPE html>
              <html>
              <head>
                <meta charset="UTF-8">
                <title>Netology LAMP</title>
              </head>
              <body>
                <h1>Netology 15.2</h1>
                <p>Instance Group LAMP</p>
                <img src="https://storage.yandexcloud.net/cucuberpetya-netology-2026/image.jpg"
                     alt="Object Storage image">
              </body>
              </html>
        runcmd:
          - systemctl restart apache2
      EOF
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
    max_creating    = 1
    max_deleting    = 1
  }

  health_check {
    interval            = 5
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2

    http_options {
      port = 80
      path = "/"
    }
  }

  load_balancer {
    target_group_name = "lamp-target-group"
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.ig_compute_editor,
    yandex_resourcemanager_folder_iam_member.ig_lb_editor
  ]
}