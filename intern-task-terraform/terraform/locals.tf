locals {
  app_user_data = templatefile(
    "${path.module}/templates/user_data.sh.tftpl",
    {
      dockerfile_base64 = filebase64("${path.module}/../../intern-task-app/Dockerfile")
      app_base64        = filebase64("${path.module}/../../intern-task-app/app/app.py")
      app_port          = local.app_port
    }
  )
}