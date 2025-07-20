aws_region     = "us-east-1"
vpc_id         = "vpc-0e751b6e61caae7c4"
public_subnets = ["subnet-0acbe5c0a85ae3036", "subnet-0b7416afa26f4a297"]

ecr_registry   = "529088274428.dkr.ecr.us-east-1.amazonaws.com"
ecr_repository = "shaecr"

# Will be dynamically passed by Jenkins
image_tag = "override-me-from-jenkins"

ecs_task_execution_role_name = "ecsTaskExecutionRole-new"
