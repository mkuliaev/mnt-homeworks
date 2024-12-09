provider "yandex" {
  token     = ""
  cloud_id  = ""
  folder_id = ""
}

resource "yandex_compute_instance" "clickhouse" {
  name         = "clickhouse-01"
  zone         = "ru-central1-b"
  platform_id  = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ema06v300v11l5q7s" // ID образа Rocky Linux 9
    }
  }

  network_interface {
    ipv4_address = "10.129.0.20"
    subnet_id    = ""
  }
}

resource "yandex_compute_instance" "vector" {
  name         = "vector-01"
  zone         = "ru-central1-b"
  platform_id  = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ema06v300v11l5q7s" // ID образа Rocky Linux 9
    }
  }

  network_interface {
    ipv4_address = "10.129.0.9"
    subnet_id    = ""
  }
}

resource "yandex_compute_instance" "lighthouse" {
  name         = "lighthouse"
  zone         = "ru-central1-b"
  platform_id  = "standard-v1"
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ema06v300v11l5q7s" // ID образа Ubuntu 20.04
    }
  }

  network_interface {
    ipv4_address = "110.129.0.8"
    subnet_id    = ""
  }
}
