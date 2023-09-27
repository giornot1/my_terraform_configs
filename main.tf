provider "google" {
  project = "nengu23"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_kms_key_ring" "nengu_key_ring" {
  name     = "Nengu-key-ring"
  location = "us-central1"  # Adjust the location if needed
}

resource "google_kms_crypto_key" "nengu_crypto_key" {
  name     = "Nengu-key-kms"
  key_ring = google_kms_key_ring.nengu_key_ring.id
  depends_on = [
    google_kms_key_ring.nengu_key_ring
  ]
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.vpc_network.name
    access_config {}
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

#resource "google_storage_bucket" "terraform_store_config" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  force_destroy = false
  location      = "us-central1"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
  encryption {
    default_kms_key_name = google_kms_crypto_key.nengu_crypto_key.id  # Updated this line
  }
  # The `depends_on` block for `google_project_iam_member.default` was removed as it was commented in the original code.
}


