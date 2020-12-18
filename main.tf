terraform {
  required_providers {
    gcp  =  {
      source = "hashicorp/google"
    }
  }

  backend "remote" {
    organization = "e-d"

    workspaces {
      name = "terraform-testing"
    }
  }
}

provider "gcp" {
  region = "us-central1"
  
resource "google_compute_instance" "default" {
  name         = "vm-web-test"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
    }
  }

    metadata_startup_script = "sudo apt-get update && sudo apt-get install apache2 -y && echo '<!doctype html><html><body><h1>Goodbye World!</h1></body></html>' | sudo tee /var/www/html/index.html"

    tags = ["http-server"]
 }
}
  
resource "google_compute_firewall" "http-server" {
  name    = "default-allow-http-terraform"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

output "ip" {
  value = "google_compute_instance.default.network_interface.0.access_config.0.nat_ip"
}
