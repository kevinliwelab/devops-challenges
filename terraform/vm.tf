resource "aws_security_group" "devops-challenge-vm-sg" {
  name   = "devops-challenge-vm-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = []
    self        = true
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${module.bastion_instance.private_ip[0]}/32"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_kms_key" "this" {
  description              = "for encryption of nginx vm ebs volume"
  deletion_window_in_days  = 30
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled               = true
  enable_key_rotation      = true
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
  root_block_device = [{
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = aws_kms_key.this.arn
    volume_size           = 10
    volume_type           = "gp3"
  }]
  tags = {
    usage = "hosting nginx and prometheus container"
  }
}
