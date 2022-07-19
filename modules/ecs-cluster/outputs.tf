output "cluster_id" {
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

output "instance_security_group_id" {
  value       = aws_security_group.instance_sg.id
  description = "ID of the security group attached to an instance."
}

output "autoscaling_group" {
  description = "Autoscaling Group data."
  value = {
    arn  = aws_autoscaling_group.this.arn
    name = aws_autoscaling_group.this.name
  }
}

