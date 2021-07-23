# devops-challenges
For implementing DevOps challenges

## Prerequisite

To go ahead with this demo, please ensure below tools or env have been properly installed and configured on your local Mac
  - awscli
  - terraform

## How to run from scratch

Create s3 bucket in your region, with the name defined in terraform/backend.tf
```sh
$ aws s3api create-bucket --bukect BUCKET --region REGION
```

Run below commands to initialize the terraform and check what resources are going to be created in AWS   
Run terraform commands with not requiring lock due to it's the first time plan/apply, DynamoDB talbe has not been provisioned yet
```sh
$ terraform init
$ terraform validate
$ terraform plan -lock=false
$ terraform apply -lock=false
```

Configure SSH agent forwarding via bastion node to VM instance in private subnet   
PEM key can be found in terraform state file in S3 bucket   
Bastion node public IP and VM instance private IP will be in terraform output   
```sh
$ ssh-add -k <PEM_FILE_NAME>
$ ssh-add -L
$ ssh -A ec2-user@<BASTION_NODE_PUBLIC_IP>
$ ssh ec2-user@<VM_INSTANCE_PRIVATE_IP>
```

Install Docker CE on latest Amazon Linux 2 AMI
```sh
$ sudo yum install docker
$ sudo service docker start
$ sudo chkconfig docker on
$ sudo usermod -a -G docker ec2-user
```
Start an Nginx container on VM instance and expose port 80 with default page and stub_status at /nginx-health   
```sh
$ docker run \
    --name my-nginx \
    -p 80:80 \
    -v ${PWD}/docker/nginx-default.conf:/etc/nginx/conf.d/default.conf:ro \
    -d nginx
```

Start nginx-prometheus-exporter container on VM instance and expose port 9113 for prometheus to scrape later   
```sh
$ docker run \
    --name my-nginx-exporter \
    -p 9113:9113 \
    -d nginx/nginx-prometheus-exporter:0.9.0 \
    -nginx.scrape-uri=http://PRIVATE_IP_VM_INSTANCE/nginx-health
```

Start Prometheus using customized config yml file in docker swarm   
```sh
$ docker swarm init
$ docker service create --replicas 1 --name my-prometheus \
    --mount type=bind,source=${PWD}/docker/prometheus.yml,destination=/etc/prometheus/prometheus.yml \
    --publish published=9090,target=9090,protocol=tcp \
    prom/prometheus
```

