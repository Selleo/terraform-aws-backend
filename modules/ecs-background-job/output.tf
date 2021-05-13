output "service_id" {
  value = aws_ecs_service.this.id
}

output "task_definition" {
  value = local.task_definition
}

output "task_family" {
  value = aws_ecs_task_definition.this.family
}
