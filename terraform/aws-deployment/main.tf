data "aws_vpc" "default" {
  default = true
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_key_pair" "beamops" {
  key_name   = "beamops-aws-key"
  public_key = file(pathexpand("~/.ssh/beamops-aws.pub"))

  tags = {
    Name    = "beamops-aws-key"
    Project = "hologram-beamops-kanban"
  }
}

resource "aws_security_group" "beamops" {
  name        = "beamops-ssh-only"
  description = "SSH access restricted to developer IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from developer IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["117.231.192.135/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "beamops-ssh-only"
    Project = "hologram-beamops-kanban"
  }
}

resource "aws_instance" "beamops" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = "t3.small"
  credit_specification {
    cpu_credits = "standard"
  }
  subnet_id                   = "subnet-0ccdde6563c9e483a"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.beamops.id
  ]

  key_name = aws_key_pair.beamops.key_name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<-USERDATA
    #!/bin/bash
    set -euxo pipefail

    dnf install -y docker
    systemctl enable --now docker
    usermod -aG docker ec2-user
  USERDATA

  tags = {
    Name        = "hologram-beamops-kanban"
    Project     = "hologram-beamops-kanban"
    Environment = "temporary-production"
    ManagedBy   = "Terraform"
  }
}
