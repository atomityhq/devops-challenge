locals {
  # The app is built on the instance from the real intern-task-app sources,
  # embedded into user_data, so it's identical to the image built for k8s.
  app_src = "${path.module}/../../intern-task-app"
  app_files = {
    "Dockerfile"    = file("${local.app_src}/Dockerfile")
    ".dockerignore" = file("${local.app_src}/.dockerignore")
    "app/app.py"    = file("${local.app_src}/app/app.py")
  }

  # The port is whatever the Dockerfile says, not a free choice: parse it.
  app_port = tonumber(regex("(?m)^ENV PORT=([0-9]+)", local.app_files["Dockerfile"])[0])

  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    admin_user       = var.admin_user
    ssh_public_key   = var.ssh_public_key
    ssh_allowed_cidr = var.ssh_allowed_cidr
    app_name         = var.name
    app_port         = local.app_port
    app_files        = { for path, content in local.app_files : path => base64encode(content) }
  })
}

module "network" {
  source = "./modules/network"

  name               = var.name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
}

module "app_instance" {
  source = "./modules/app_instance"

  name             = var.name
  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.public_subnet_id
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  app_port         = local.app_port
  ssh_allowed_cidr = var.ssh_allowed_cidr
  user_data        = local.user_data
}
