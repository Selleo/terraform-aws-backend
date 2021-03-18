# required

variable "vpc_id" {
  type        = string
  description = "VPC id."
}

variable "name" {
  type        = string
  description = "ECS Service name."
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
    cpu_units      = number
    mem_units      = number
    command        = list(string)
    image          = string
    container_port = number
    envs           = map(string)
  })
  description = "Service container configuration."
}
# optional

variable "tags" {
  type        = map(string)
  description = "Additional tags attached to resources."
  default     = {}
}
