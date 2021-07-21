resource "aws_service_discovery_private_dns_namespace" "example" {
  name        = var.app_domain
  description = "example"
  vpc         = aws_vpc.terraform-vpc.id
}

resource "aws_service_discovery_service" "example" {
  name = "nim"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.example.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    # <-- we want multiple IP addresses returned.
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

}

resource "aws_service_discovery_service" "nginx" {
  name = "nginx"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.example.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    # <-- we want multiple IP addresses returned.
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

}
