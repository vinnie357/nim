# startup script
data "http" "template_onboard" {
  url = var.onboardScript != "none" ? var.onboardScript : "https://raw.githubusercontent.com/vinnie357/bash-onboard-templates/main/nginx/gcp/nim/onboard.sh.tpl"
}

data "template_file" "vm_onboard" {
  template = var.onboardScript != "none" ? data.http.template_onboard.body : file("${path.module}/templates/startup.sh.tpl")

  vars = {
    secretName   = google_secret_manager_secret.docker-secret.secret_id
    user         = var.adminAccountName
    GITHUB_TOKEN = var.githubToken
    agent        = var.nimAgent
  }
}

# GCE instance
resource "google_compute_instance" "vm_instance" {
  name                      = format("%s-%s-%s", var.projectPrefix, var.name, var.buildSuffix)
  machine_type              = var.instanceType
  min_cpu_platform          = "Intel Haswell"
  allow_stopping_for_update = true
  tags                      = var.tags
  boot_disk {
    initialize_params {
      image = var.image
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
    email  = google_service_account.gce-docker-sa.email
    scopes = ["cloud-platform"]
  }

}
