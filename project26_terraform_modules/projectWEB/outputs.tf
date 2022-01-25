output "server_standalone_ip" {
  value = module.server_standalone.web_server_public_ip
}

output "servers_loop_count_ips" {
  value = module.server_loop_count[*].web_server_public_ip
}
