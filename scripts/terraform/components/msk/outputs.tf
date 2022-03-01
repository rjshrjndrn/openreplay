output "msk_endpoint" {
  value = aws_msk_cluster.msk.bootstrap_brokers_tls
  description = "msk conncection endpoint"
}
