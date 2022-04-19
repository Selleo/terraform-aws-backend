output "id" {
  value       = aws_alb.this.id
  description = "The ARN of the load balancer."
}

output "security_group_id" {
  value       = aws_security_group.lb_sg.id
  description = "Security Group attached to the load balancer."
}

output "dns_name" {
  value       = aws_alb.this.dns_name
  description = "The DNS name of the load balancer."
}

output "zone_id" {
  value       = aws_alb.this.zone_id
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
}
