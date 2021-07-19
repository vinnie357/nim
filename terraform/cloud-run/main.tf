#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service
# provider
provider "google" {
  project = var.gcpProjectId
}
// # Enables the Cloud Run API
// resource "google_project_service" "run_api" {
//   service = "run.googleapis.com"

//   disable_on_destroy = true
// }
resource "google_cloud_run_service" "nim" {
  name     = format("%s-nim-srv-%s", var.projectPrefix, random_pet.buildSuffix.id)
  location = var.gcpRegion

  template {
    spec {
      containers {
        image = var.image
        ports {
          container_port = 8080
        }
        resources {
          limits = {
            cpu    = "4000m"
            memory = "2048Mi"
          }
          requests = {
            cpu    = "4"
            memory = "1024"
          }
        }
      }
      service_account_name = var.serviceAccount
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

// data "google_iam_policy" "noauth" {
//   binding {
//     role = "roles/run.invoker"
//     members = [
//       "allUsers",
//     ]
//   }
// }

// resource "google_cloud_run_service_iam_policy" "noauth" {
//   location = google_cloud_run_service.nim.location
//   project  = google_cloud_run_service.nim.project
//   service  = google_cloud_run_service.nim.name

//   policy_data = data.google_iam_policy.noauth.policy_data
// }
#terraform import google_cloud_run_domain_mapping.default {{location}}/{{name}}
resource "google_cloud_run_domain_mapping" "web-ui-domain" {
  location = var.gcpRegion
  name     = var.serviceDomainWeb

  metadata {
    namespace = var.gcpProjectId
  }

  spec {
    route_name = google_cloud_run_service.nim.name
  }
}
resource "google_cloud_run_domain_mapping" "grpc-domain" {
  location = var.gcpRegion
  name     = var.serviceDomainGrpc

  metadata {
    namespace = var.gcpProjectId
  }

  spec {
    route_name = google_cloud_run_service.nim.name
  }
}
