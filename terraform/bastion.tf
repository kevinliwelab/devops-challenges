data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "devops-challenge-bastion-sg" {
  name   = "devops-challenge-bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["115.160.150.58/32"] # replace with your own public IP
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = var.key_name
  public_key = tls_private_key.this.public_key_openssh
}

module "bastion_instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 2.0"
  name                        = "devops-challenge-bastion-node"
  instance_count              = 1
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = "t3.micro"
  key_name                    = var.key_name
  monitoring                  = false
  vpc_security_group_ids      = [aws_security_group.devops-challenge-bastion-sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  tags = {
    usage = "ssh agent forwarding"
  }
}
