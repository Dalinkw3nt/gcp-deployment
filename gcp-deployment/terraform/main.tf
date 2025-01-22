# GCP Infrastructure Deployment with Terraform

# Provider Configuration
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Variables
variable "project_id" {}
variable "region" {}
variable "zone" {}

# VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  auto_create_subnetworks = false
}

# Subnets
resource "google_compute_subnetwork" "subnets" {
  count                  = 2 # Example: 2 subnets in different zones
  name                   = "subnet-${count.index}"
  ip_cidr_range          = "10.0.${count.index}.0/24"
  region                 = var.region
  network                = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

# Firewall Rules
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/16"]
}

resource "google_compute_firewall" "allow_external" {
  name    = "allow-external"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# NAT Gateway
resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network = google_compute_network.vpc_network.id
  region  = var.region
}

resource "google_compute_router_nat" "nat_config" {
  name                               = "nat-config"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# GKE Cluster
resource "google_container_cluster" "gke_cluster" {
  name     = "gke-cluster"
  location = var.region

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  initial_node_count = 3
  remove_default_node_pool = true
  private_cluster_config {
    enable_private_nodes = true
    master_ipv4_cidr_block = "172.16.0.0/28"
  }
}

# Cloud SQL
resource "google_sql_database_instance" "default" {
  name             = "mysql-instance"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-n1-standard-1"
  }
}

resource "google_sql_user" "root" {
  instance = google_sql_database_instance.default.name
  name     = "root"
  password = "secure-password"
}

output "gke_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

output "cloud_sql_instance_ip" {
  value = google_sql_database_instance.default.public_ip_address
}

