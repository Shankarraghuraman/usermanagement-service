variable "image_uri" {
  type        = string
  description = "ECR image URI with tag"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS tasks"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for ECS tasks"
}
