output "loadbalancer_id" {
  value = aws_alb.this.id
}

output "loadbalancer_sg_id" {
  value = aws_security_group.lb_sg.id
}

