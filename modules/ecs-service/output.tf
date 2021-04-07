output "lb_target_group_id" {
  value = aws_alb_target_group.this.id
}

output "service_id" {
  value = aws_ecs_service.this.id
}

output "task_definition" {
  value = local.task_definition
}

output "task_family" {
  value = aws_ecs_task_definition.this.family
}
