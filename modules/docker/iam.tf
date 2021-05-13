# nginx
resource "google_service_account" "gce-docker-sa" {
  account_id   = format("%s-docker-sa-%s", var.projectPrefix, var.buildSuffix)
  display_name = "docker service account for secret access"
}
# add service account read permissions to secret
resource "google_secret_manager_secret_iam_member" "gce-docker-sa-iam" {
  depends_on = [google_service_account.gce-docker-sa]
  secret_id  = google_secret_manager_secret.docker-secret.secret_id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.gce-docker-sa.email}"
}
resource "google_project_iam_member" "project" {
  project = var.gcpProjectId
  role    = "roles/compute.networkViewer"
  member  = "serviceAccount:${google_service_account.gce-docker-sa.email}"
}
