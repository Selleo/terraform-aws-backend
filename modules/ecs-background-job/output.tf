output "service_id" {
  value       = aws_ecs_service.this.id
  description = "ARN that identifies the service."
}

output "task_definition" {
  value       = local.task_definition
  description = "Latest task definition (family:revision)."
}

output "task_family" {
  value       = aws_ecs_task_definition.this.family
  description = "ECS task family."
}
