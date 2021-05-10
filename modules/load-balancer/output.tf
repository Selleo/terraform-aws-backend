output "loadbalancer_id" {
  value = aws_alb.this.id
}

output "loadbalancer_sg_id" {
  value = aws_security_group.lb_sg.id
}

output "loadbalancer_dns_name" {
  value = aws_alb.this.dns_name
}

output "loadbalancer_zone_id" {
  value = aws_alb.this.zone_id
}
