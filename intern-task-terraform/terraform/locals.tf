locals {
  app_dir = "${path.module}/../../intern-task-app"

  # Git for Windows can check files out with CRLF line endings. Normalise to
  # LF so user_data is identical on every machine and matches the repository.
  app_dockerfile = replace(file("${local.app_dir}/Dockerfile"), "\r\n", "\n")
  app_py         = replace(file("${local.app_dir}/app/app.py"), "\r\n", "\n")
  app_port       = tonumber(regex("(?m)^ENV PORT=([0-9]+)", local.app_dockerfile)[0])

  user_data = replace(templatefile("${path.module}/user_data.sh.tftpl", {
    app_port       = local.app_port
    dockerfile_b64 = base64encode(local.app_dockerfile)
    app_py_b64     = base64encode(local.app_py)
  }), "\r\n", "\n")
}