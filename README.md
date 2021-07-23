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

Install docker-compose
```sh
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
``` 

Start Prometheus and below containers by docker-compose   
```sh
$ cd docker
$ docker-compose up -d
```
  - Nginx container exposes port 80 with default page and stub_status at `/nginx-health`
  - nginx-prometheus-exporter container exposes port 9113 for prometheus to scrape later
  - cAdvisor container exposes resource usage and performance data from running containers

## How to monitor the healthiness of nginx container

In Prometheus, `nginx_up{instance="nginx-exporter:9113", job="nginx"} > 0` will return `1` if Nginx container runs OK    
Can configure alert rule with furhter notification if Nginx instance down detected   

## How to log the resource usage of the container every 10 seconds
In cAdvisor, watch the CPU and Memory usage metrics, Filesystem usage amount & ratios, also Network throughput of different Interfaces   
Can also manually run docker stats to track a specific container resource usage from command line   
```sh
$ docker ps
$ docker stats <CONTAINER_ID>
```
