output "nim" {
  value = module.nim.info
}
output "docker" {
  value = module.docker.info
}

// output "nginxPlusNoAgent" {
//   value = module.nginx-plus-noagent.info
// }

output "nginxPlus" {
  value = module.nginxPlus.info
}

output "nginx" {
  value = module.nginx.info
}
