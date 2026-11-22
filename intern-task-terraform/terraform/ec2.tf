locals {
  app_dockerfile = <<-DOCKERFILE
    FROM python:3.12-slim

    ENV PORT=8080

    WORKDIR /app

    RUN useradd --system --uid 10001 appuser

    COPY --chown=appuser:appuser app/ ./app/

    USER appuser

    EXPOSE 8080

    CMD ["python", "app/app.py"]
  DOCKERFILE
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    app_py_b64       = base64encode(file("${path.module}/../../intern-task-app/app/app.py"))
    dockerfile_b64   = base64encode(local.app_dockerfile)
    ssh_allowed_cidr = var.ssh_allowed_cidr
  })

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name = "intern-task-app"
  }
}
