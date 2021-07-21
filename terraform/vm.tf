resource "aws_security_group" "devops-challenge-vm-sg" {
  name   = "devops-challenge-vm-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${module.bastion_instance.private_ip}/32"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["${module.vpc.private_subnets[0]}", "${module.vpc.private_subnets[1]}", "${module.vpc.private_subnets[2]}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vm_instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 2.0"
  name                        = "devops-challenge-vm-node"
  instance_count              = 1
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = "t3.small"
  key_name                    = var.key_name
  monitoring                  = false
  vpc_security_group_ids      = [aws_security_group.devops-challenge-vm-sg.id]
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = true
  tags = {
    usage = "hosting nginx and prometheus container"
  }
}
