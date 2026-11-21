terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "tecsup-bucket-juan-2026"
    key          = "ec2-lab/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0b064c912c726f739"
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}
