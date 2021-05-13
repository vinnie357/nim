# nginx
# create secret
resource "google_secret_manager_secret" "nginx-secret" {
  secret_id = format("%s-nim-secrets-%s", var.projectPrefix, var.buildSuffix)
  labels = {
    label = "nginx-nim"
  }

  replication {
    automatic = true
  }
}
# create secret version
resource "google_secret_manager_secret_version" "nginx-secret" {
  depends_on  = [google_secret_manager_secret.nginx-secret]
  secret      = google_secret_manager_secret.nginx-secret.id
  secret_data = <<-EOF
  {
  "cert": ${jsonencode(var.nimCert)},
  "key": ${jsonencode(var.nimKey)},
  "license": ${jsonencode(var.nimLicense)},
  "nginxCert": ${jsonencode(var.nginxCert)},
  "nginxKey": ${jsonencode(var.nginxKey)}
  }
  EOF
}
