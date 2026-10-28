locals {
  # Must match ENV PORT in intern-task-app/Dockerfile.
  app_port = 8080

  user_data = templatefile("${path.module}/user_data.yaml.tftpl", {
    dockerfile = file("${path.module}/../../intern-task-app/Dockerfile")
    app_py     = file("${path.module}/../../intern-task-app/app/app.py")
    app_port   = local.app_port
  })
}