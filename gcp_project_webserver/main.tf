provider "google" {
  credentials = file("mygcp-creds.json")
}

resource "google_compute_instance" "us_instance" {
  name         = "my-gcp-server"
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network = "default" #enables private IP addr
    access_config {}    #enables public IP addr
  }
}

resource "google_project_service" "api" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com"
  ])
  disable_on_destroy = false
  service            = each.value
}

resource "google_compute_firewall" "web" {
  name          = "web-access"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_instance" "my_web_server" {
  name         = "my-gcp-web-server"
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9" // Image to use for VM
    }
  }
  network_interface {
    network = "default" // This Enable Private IP Address
    access_config {}    // This Enable Public IP Address
  }
  metadata_startup_script = <<EOF
#!/bin/bash
apt update -y
apt install apache2 -y
echo "<h2>WebServer on GCP Build by Terraform!<h2>"  >  /var/www/html/index.html
systemctl restart apache2
EOF

  depends_on = [google_project_service.api, google_compute_firewall.web]
}
