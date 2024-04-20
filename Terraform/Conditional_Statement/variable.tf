variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 5
}

variable "environment" {
  description = "Environment type, e.g., Production or Development"
  default     = ["Develop", "Production"]
}
