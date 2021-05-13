# nginx
# create secret
resource "google_secret_manager_secret" "docker-secret" {
  secret_id = format("%s-docker-secrets-%s", var.projectPrefix, var.buildSuffix)
  labels = {
    label = "nginx-docker"
  }

  replication {
    automatic = true
  }
}
# create secret version
resource "google_secret_manager_secret_version" "docker-secret" {
  depends_on  = [google_secret_manager_secret.docker-secret]
  secret      = google_secret_manager_secret.docker-secret.id
  secret_data = <<-EOF
  {
  "nginxCert": ${jsonencode(var.nginxCert)},
  "nginxKey": ${jsonencode(var.nginxKey)}
  }
  EOF
}
