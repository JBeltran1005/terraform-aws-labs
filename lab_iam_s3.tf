# Buscar automáticamente la AMI oficial más reciente de Amazon Linux 2023 en us-east-2
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Paso 2: Crear IAM Policy con acceso exclusivo al bucket propio
resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "tecsup-s3-juan-policy"
  description = "Permite ListBucket y Get/Put/DeleteObject solo en tecsup-bucket-juan-2026"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::tecsup-bucket-juan-2026"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::tecsup-bucket-juan-2026/*"
      }
    ]
  })
}

# Paso 3: Crear IAM Role con Trusted Entity: EC2
resource "aws_iam_role" "ec2_s3_role" {
  name = "tecsup-ec2-s3-juan-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Asociar la política al rol
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}

# Crear el Instance Profile para poder asignarlo a la EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "tecsup-ec2-s3-juan-profile"
  role = aws_iam_role.ec2_s3_role.name
}

# Security Group para permitir conexión SSH (puerto 22)
resource "aws_security_group" "ssh_lab_sg" {
  name        = "tecsup-lab-ssh-sg"
  description = "Permitir SSH para pruebas de laboratorio"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Paso 4: Crear instancia EC2 (Amazon Linux 2023 + t3.micro + Rol asociado)
resource "aws_instance" "lab_ec2_s3" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ssh_lab_sg.id]

  tags = {
    Name = "Lab-IAM-EC2-S3-Juan"
  }
}

output "lab_ec2_public_ip" {
  value = aws_instance.lab_ec2_s3.public_ip
}
