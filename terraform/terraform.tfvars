aws_region = "us-east-1"

vpc_id = "vpc-06bc7d52970be2acb"

public_subnets = [
  "subnet-0346e6a7e56b71359",
  "subnet-01a04566dfc5befa7"
]

ecr_registry   = "434748569008.dkr.ecr.us-east-1.amazonaws.com"
ecr_repository = "shankar/usermgmt"
image_tag      = "override-me-from-jenkins"
ecs_task_execution_role_name = "ecsTaskExecutionRole"
