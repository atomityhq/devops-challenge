locals {
  app_dir = "${path.module}/../../intern-task-app"

  app_port = tonumber(regex("ENV PORT=([0-9]+)", file("${local.app_dir}/Dockerfile"))[0])
}