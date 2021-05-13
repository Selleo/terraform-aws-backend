# required

variable "vpc_id" {
  type        = string
  description = "VPC id."
}

variable "name" {
  type        = string
  description = "Load balancer name."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of AWS subent IDs for Autoscaling group."
}

# optional

variable "tags" {
  type        = map(string)
  description = "Additional tags attached to resources."
  default     = {}
}

variable "access_logs" {
  description = "Access logs config for load balancer."

  type = object({
    bucket  = string
    prefix  = string
    enabled = bool
  })

  default = {
    bucket  = ""
    prefix  = ""
    enabled = false
  }
}
