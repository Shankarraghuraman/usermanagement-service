variable "image_tag" {
  type        = string
  description = "Tag of the Docker image to deploy from ECR"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS tasks"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for ECS tasks"
}
