locals {
  app_port = 5000
}

locals {
  app_user_data = replace(
    templatefile("${path.module}/user_data.sh.tftpl", {
      dockerfile_base64 = filebase64("${path.module}/../../intern-task-app/Dockerfile")
      app_base64        = filebase64("${path.module}/../../intern-task-app/app/app.py")
      app_port          = local.app_port
    }),
    "\r\n",
    "\n"
  )
}