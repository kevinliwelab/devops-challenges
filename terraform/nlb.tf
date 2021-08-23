data "aws_subnet_ids" "all" {
  vpc_id = module.vpc.vpc_id
}

module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name               = "devops-challenge-nlb"
  internal           = false
  load_balancer_type = "network"
  vpc_id             = module.vpc.vpc_id
  subnets            = tolist(data.aws_subnet_ids.all.ids)

  target_groups = [
    {
      name             = "nginx"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/nginx-health"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
      targets = [
        {
          target_id = module.bastion_instance.id[0]
          port      = 80
        }
      ]
    },
    {
      name             = "prometheus"
      backend_protocol = "TCP"
      backend_port     = 9090
      target_type      = "ip"
      targets = [
        {
          target_id = module.vm_instance.id[0]
          port      = 9090
        }
      ]
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 9090
      protocol           = "TCP"
      target_group_index = 1
    }
  ]

  https_listener_rules = []

  tags = {
    usage = "expose nginx and prometheus to public web"
  }
}
