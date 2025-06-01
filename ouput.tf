output "lb_endpoint" {
  description = "The DNS name of the load balancer"
  value       = [aws_lb.test-instance-lb.dns_name]
}
