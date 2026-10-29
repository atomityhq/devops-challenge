locals {
  app_dir    = "${path.module}/../../intern-task-app"
  dockerfile = file("${local.app_dir}/Dockerfile")
  app_port   = tonumber(regex("(?m)^[^#\\n]*\\bPORT=([0-9]+)", local.dockerfile)[0])
}