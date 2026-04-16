resource "aws_instance" "this" {
  count = var.instance_count

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile

  user_data_base64 = base64encode(<<-EOF
              #!/bin/bash
              # 1. Extract application if present
              if [ -n "${var.app_zip_base64}" ]; then
                apt-get update
                apt-get install -y unzip
                mkdir -p /home/ubuntu/app
                echo "${var.app_zip_base64}" | base64 -d > /home/ubuntu/app.zip
                unzip /home/ubuntu/app.zip -d /home/ubuntu/app
                chown -R ubuntu:ubuntu /home/ubuntu/app
              fi

              # 2. Run custom user data script
              ${var.user_data}
              EOF
  )
  user_data_replace_on_change = true
  tags = merge(
    var.tags,
    {
      Name = var.instance_count > 1 ? "${var.name}-${count.index + 1}" : var.name
    }
  )
}

