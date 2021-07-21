
## VPC
output "vpc_id" {
  value = aws_vpc.terraform-vpc.id
}
## app
output "appPort" {
  value = var.app_port
}
output "appFqdn" {
  value = "${aws_service_discovery_service.example.name}.${aws_service_discovery_private_dns_namespace.example.name}"
}
output "appDomain" {
  value = aws_service_discovery_private_dns_namespace.example.name
}
