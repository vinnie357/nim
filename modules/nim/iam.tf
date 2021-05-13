# nginx
resource "google_service_account" "gce-nim-sa" {
  account_id   = format("%s-sa-%s", var.projectPrefix, var.buildSuffix)
  display_name = "nim service account for secret access"
}
# add service account read permissions to secret
resource "google_secret_manager_secret_iam_member" "gce-nim-sa-iam" {
  depends_on = [google_service_account.gce-nim-sa]
  secret_id  = google_secret_manager_secret.nginx-secret.secret_id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.gce-nim-sa.email}"
}
resource "google_project_iam_member" "project" {
  project = var.gcpProjectId
  role    = "roles/compute.networkViewer"
  member  = "serviceAccount:${google_service_account.gce-nim-sa.email}"
}
