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

variable "force_https" {
  type        = bool
  description = "Creates redirection from HTTP to HTTPS."
  default     = true
}

variable "allow_http" {
  type        = bool
  description = "Create ingress rule for port 80."
  default     = true
}

variable "allow_https" {
  type        = bool
  description = "Create ingress rule for port 443."
  default     = true
}

variable "allow_all_outbound" {
  type        = bool
  description = "Create ingress rule for port 443."
  default     = true
}

variable "cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks used for ingress rules."
  default     = ["0.0.0.0/0"]
}

variable "ipv6_cidr_blocks" {
  type        = list(string)
  description = "CIDR IPv6 blocks used for ingress rules."
  default     = ["::/0"]
}

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
