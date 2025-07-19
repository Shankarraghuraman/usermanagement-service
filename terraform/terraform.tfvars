aws_region     = "us-east-1"
vpc_id         = "vpc-06bc7d52970be2acb"
public_subnets = ["subnet-0346e6a7e56b71359", "subnet-0f98666a4bbb16c0f"]

ecr_registry   = "434748569008.dkr.ecr.us-east-1.amazonaws.com"
ecr_repository = "shankar/usermgmt"

# Will be dynamically passed by Jenkins
image_tag = "override-me-from-jenkins"

ecs_task_execution_role_name = "ecsTaskExecutionRole"
