# required

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
    desired_count = optional(number)
    cpu_units     = optional(number)
    mem_units     = optional(number)
    command       = tuple(string)
    image         = string
    containerPort = number
    envs          = optional(map(string))
  })
  description = "Service container configuration."
}
# optional

variable "tags" {
  type        = map(string)
  description = "Additional tags attached to resources."
  default     = {}
}
