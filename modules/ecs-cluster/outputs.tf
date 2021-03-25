output "ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "instance_role" {
  value = aws_iam_role.instance_role.id
}
