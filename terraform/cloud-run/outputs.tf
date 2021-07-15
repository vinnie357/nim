output "service_url" {
  value = google_cloud_run_service.nim.status[0].url
}
