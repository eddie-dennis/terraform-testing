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
}
  
resource "google_compute_instance" "default" {
  name         = "vm-web-test"
  machine_type = "f1-micro"
  project      = "ee-terraform-test"
  zone         = "us-central1-a"
  
  metadata_startup_script = "sudo apt-get update && sudo apt-get install apache2 -y && echo '<!doctype html><html><body><h1>Goodbye World!</h1></body></html>' | sudo tee /var/www/html/index.html"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {}
  }

  tags = ["http-server"]
}
  
resource "google_compute_firewall" "http_server" {
  name    = "default-allow-http-terraform"
  network = "default"
  project = "ee-terraform-test"

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

output "ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
