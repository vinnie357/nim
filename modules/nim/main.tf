# startup script
data "http" "template_onboard" {
  url = var.onboardScript != "none" ? var.onboardScript : "https://raw.githubusercontent.com/vinnie357/bash-onboard-templates/main/nginx/gcp/nim/onboard.sh.tpl"
}
# nim-config
data "local_file" "conf-manager" {
    filename = "${path.module}/templates/nim-config/nginx-manager.conf"
}
# nginx-config
data "local_file" "conf-grpc" {
    filename = "${path.module}/templates/nginx-config/nginx-manager-grpc.conf"
}
data "local_file" "conf-grpc-errors" {
    filename = "${path.module}/templates/nginx-config/errors.grpc_conf"
}
data "local_file" "conf-manager-noauth" {
    filename = "${path.module}/templates/nginx-config/nginx-manager-noauth.conf"
}
data "local_file" "conf-status-api" {
    filename = "${path.module}/templates/nginx-config/status-api.conf"
}
data "local_file" "conf-manager-upstreams" {
    filename = "${path.module}/templates/nginx-config/nginx-manager-upstreams.conf"
}
data "local_file" "conf-stub-status" {
    filename = "${path.module}/templates/nginx-config/stub-status.conf"
}
data "template_file" "vm_onboard" {
  template = var.onboardScript != "none" ? data.http.template_onboard.body : file("${path.module}/templates/startup.sh.tpl")

  vars = {
    secretName  = google_secret_manager_secret.nginx-secret.secret_id
    nginx-plus  = var.nginxPlus
    nimVersion  = var.nimVersion
    // nim-config
    conf-manager = data.local_file.conf-manager.content
    // nginx-config
    conf-grpc = data.local_file.conf-grpc.content
    conf-grpc-errors = data.local_file.conf-grpc-errors.content
    conf-manager-noauth = data.local_file.conf-manager-noauth.content
    conf-status-api = data.local_file.conf-status-api.content
    conf-manager-upstreams = data.local_file.conf-manager-upstreams.content
    conf-stub-status = data.local_file.conf-stub-status.content
  }
}

# GCE instance
resource "google_compute_instance" "vm_instance" {
  name             = format("%s-%s-%s", var.projectPrefix, var.name, var.buildSuffix)
  machine_type     = var.machineType
  min_cpu_platform = "Intel Haswell"
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = var.deviceImage
      size  = var.diskSize
    }
  }

  // ssh-keys = join("\n", [for user, key in var.ssh_keys : "${user}:${key}"])
  metadata = {

    ssh-keys               = "${var.adminAccountName}:${var.sshPublicKey}"
    block-project-ssh-keys = false
  }
  metadata_startup_script = data.template_file.vm_onboard.rendered

  network_interface {
    network    = var.vpc
    subnetwork = var.subnet
    dynamic "access_config" {
      for_each = var.publicIp ? [{}] : []
      content {}
    }
  }


  service_account {
    // https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes
    // https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets
    email  = google_service_account.gce-nim-sa.email
    scopes = ["cloud-platform"]
  }

}
