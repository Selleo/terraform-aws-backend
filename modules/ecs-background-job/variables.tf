# required

variable "name" {
  type        = string
  description = "ECS Service name."
}

variable "instance_role" {
  type        = string
  description = "EC2 instance role."
}

variable "ecs_cluster_id" {
  type        = string
  description = "ECS Cluster id."
}

variable "desired_count" {
  type        = number
  description = "Desired task count."
}

variable "container_definition" {
  type = object({
    cpu_units = number
    mem_units = number
    command   = list(string)
    image     = string
    envs      = map(string)
  })
  description = "Service container configuration."
}

# optional

variable "tags" {
  type        = map(string)
  description = "Additional tags attached to resources."
  default     = {}
}

variable "log_retention_in_days" {
  type        = string
  description = "Log retention in days for Cloudwatch."
  default     = 365
}
