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

variable "container" {
  type = object({
    cpu_units             = number
    mem_units             = number
    mem_reservation_units = number
    image                 = string
    command               = list(string)
    envs                  = map(string)
  })
  description = <<EOS
    Service container configuration.
    `mem_reservation_units` is used for allocation, exceeding `mem_units` will kill the container. 
    Memory units should be greater than reservation units.
  EOS
}

# optional

variable "tags" {
  type        = map(string)
  description = "Additional tags attached to resources."
  default     = {}
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."

  type    = number
  default = 50
}

variable "deployment_maximum_percent" {
  description = "Upper limit (as a percentage of the service's `desired_count`) of the number of running tasks that can be running in a service during a deployment. Not valid when using the `DAEMON` scheduling strategy."

  type    = number
  default = 200
}

variable "log_retention_in_days" {
  type        = string
  description = "Log retention in days for Cloudwatch."
  default     = 365
}
