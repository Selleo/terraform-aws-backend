# required

variable "name_prefix" {
  type        = string
  description = "Name prefix (hyphen suffix should be skipped)."
}

variable "region" {
  type        = string
  description = "AWS region for cluster."
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC id."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of AWS subent IDs for Autoscaling group."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type i.e. t3.medium."
}

variable "autoscaling_group" {
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
  })
  description = "Autoscaling group configuration."
}

# optional

variable "tags" {
  type        = map(string)
  description = "Additional tags attached to resources."
  default     = {}
}

variable "ami" {
  type        = string
  description = "Image ID for Autoscaling group. If left blank, latest ECS-optimized version will be used."
  default     = ""
}

variable "key_name" {
  type        = string
  description = "Key pair name for SSH access."
  default     = ""
}

variable "security_groups" {
  type        = list(string)
  description = "List of security groups attached to launch configuration."
  default     = []
}

