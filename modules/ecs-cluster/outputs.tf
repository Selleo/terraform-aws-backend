output "ecs_cluster_id" {
  value       = aws_ecs_cluster.this.id
  description = "ECS cluster ID (contains randomized suffix)."
}

output "instance_role" {
  value       = aws_iam_role.instance_role.id
  description = "IAM role that is attached to EC2 instances."
}

output "prefix" {
  value       = random_id.prefix.hex
  description = "Random prefix to use for associated resources."
}
