module "vpc" {
  source = "../../modules/dev/vpc"

  aws_region = var.aws_region

  vpc_name = "${var.project_name}-${var.environment}-vpc"
  vpc_cidr = var.vpc_cidr

  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  #database_subnet_cidrs = var.database_subnet_cidrs

  flow_log_retention_days = 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

#########################################
################ EC2 ###################
#########################################

/*module "ec2" {
  source = "../../modules/dev/ec2"

  project_name = var.project_name
  environment  = var.environment

  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.private_subnet_ids[0]
  availability_zone = var.availability_zones[0]

  ami_id           = var.ami_id
  instance_type    = var.instance_type
  root_volume_size = var.root_volume_size
  data_volume_size = var.data_volume_size
  data_device_name = var.data_device_name

  ssh_cidr_blocks   = var.ssh_cidr_blocks
  http_cidr_blocks  = var.http_cidr_blocks
  https_cidr_blocks = var.https_cidr_blocks

  associate_public_ip_address = var.associate_public_ip_address
  enable_detailed_monitoring  = var.enable_detailed_monitoring

  backup_schedule       = var.backup_schedule
  backup_retention_days = var.backup_retention_days

  tags = var.tags
} */


############################################
#####################ALB####################
############################################

/*module "alb" {
  source = "../../modules/dev/alb"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

  public_subnet_ids = module.vpc.public_subnet_ids

  application_port = 80

  target_instance_id = module.ec2.instance_id

  health_check_path = "/"
} */

############################################
#####################ASG####################
############################################


/*module "asg" {
  source = "../../modules/dev/asg"

  name          = "evareg-dev-asg"
  ami_id        = "ami-08eb58865930c986c"
  instance_type = "t3.micro"

  subnet_ids = module.vpc.private_subnet_ids

  security_group_ids = [
    module.ec2.security_group_id
  ]

  target_group_arns = [
    module.alb.target_group_arn
  ]

  min_size         = 1
  desired_capacity = 2
  max_size         = 4

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable --now nginx
    echo "Evareg QA server" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Environment = "dev"
    Project     = "Evareg"
    ManagedBy   = "Terraform"
  }
} */



######################################################
########################RDS   #########################
#######################################################

/*module "rds" {
  source = "../../modules/dev/rds"

  name = "evareg-qa-mysql"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  application_security_group_id = module.ec2.security_group_id

  engine         = "mysql"
  database_name  = "evareg"
  master_username = "dbadmin"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  multi_az                  = false
  backup_retention_period   = 1
  deletion_protection       = true
  skip_final_snapshot       = false
  performance_insights_enabled = true

  tags = {
    Environment = "QA"
    Project     = "Evareg"
    ManagedBy   = "Terraform"
  }
} */