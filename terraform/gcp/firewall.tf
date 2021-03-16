

resource "google_compute_firewall" "app" {
  name    = format("%s-allow-app-%s", var.projectPrefix, var.buildSuffix)
  network = module.google_network.vpcs["public"].name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = var.adminSourceAddress
}

resource "google_compute_firewall" "mgmt" {

  name    = format("%s-allow-mgmt-%s", var.projectPrefix, var.buildSuffix)
  network = module.google_network.vpcs["public"].name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "11000"]
  }

  source_ranges = var.adminSourceAddress
}

resource "google_compute_firewall" "default-allow-internal-int" {
  name    = format("%s-allow-internal-fw-%s", var.projectPrefix, var.buildSuffix)
  network = module.google_network.vpcs["public"].name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  priority = "65534"

  source_ranges = ["10.0.30.0/24"]
}
resource "google_compute_firewall" "allow-internal-egress" {
  name      = format("%s-allow-egress-%s", var.projectPrefix, var.buildSuffix)
  network   = module.google_network.vpcs["public"].name
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  priority = "65533"

  destination_ranges = ["10.0.30.0/24"]
}



resource "google_compute_firewall" "iap-ingress" {
  name    = format("%s-allow-iap-%s", var.projectPrefix, var.buildSuffix)
  network = module.google_network.vpcs["public"].name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "80"]
  }

  source_ranges = ["35.235.240.0/20"]
}
