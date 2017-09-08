# Autospotting on Rancher


This is a set of terraform plans to setup to AWS Auto Scaling Groups to demonstrate
the features of [Autospotting](https://github.com/cristim/autospotting) on [Rancher](http://rancher.com/).

## Requirements

* [Terraform](http://terraform.io) (tested on v0.10.2)
* AWS account with VPC

## Getting Started

### Deploy ASGs
1. **Create management-cluster ASG**: From the `management-cluster/` directory run: `terraform init` and then `terraform apply`.
2. **Create node ASG**: From the `node/` directory run: `terraform init` and then `terraform apply`.
3. **Create AWS User for Autospotting API Calls**. Using IAM create a user with a set of API keys to be used by the autospotting process. The user will need the following permissions:
```
        autoscaling:DescribeAutoScalingGroups
        autoscaling:DescribeLaunchConfigurations
        autoscaling:AttachInstances
        autoscaling:DetachInstances
        autoscaling:DescribeTags
        autoscaling:UpdateAutoScalingGroup
        ec2:CreateTags
        ec2:DescribeInstances
        ec2:DescribeRegions
        ec2:DescribeSpotInstanceRequests
        ec2:DescribeSpotPriceHistory
        ec2:RequestSpotInstances
        ec2:TerminateInstances
```

### Launch Autospotting Container Service

#### Cattle

From the Community Catalog, find the item called Autospotting and configure it with required parameters, including the AWS API Keypair from the above step.

 #### Kubernetes

 From the Rancher UI, go to Kubernetes > Infrastructure Stacks. Click `Add Stack` and supply the following files, replacing the variables in `${}` with the correct value for your environment:

rancher-compose.yml

```
aws-spot-instance-helper:
    health_check:
        port: 9777
        interval: 2000
        unhealthy_threshold: 3
        strategy: recreate
        response_timeout: 2000
        request_line: GET /ping HTTP/1.0
        healthy_threshold: 2
```
docker-compose.yml

```
aws-spot-instance-helper:
      image: chrisurwin/autospotting:v0.1.0
      tty: true
      labels:
        io.rancher.container.pull_image: always
      environment:
        AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
        AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
        regions: "${regions}"
        min_on_demand_number: "${min_on_demand_number}"
        min_on_demand_percentage: "${min_on_demand_percentage}"
        allowed_instance_types: "${allowed_instance_types}"
        tag_name: "${tag_name}"

```

Then you will need to run the spot termination detector stack. From the same Infrastructure Stacks click "Add Stack" and supply the following files:

docker-compose.yml:

```
version: '2'
services:
  aws-spot-instance-helper-k8:
    image: chrisurwin/aws-spot-instance-helper-k8s:v0.0.1
    stdin_open: true
    tty: true
    labels:
      io.rancher.container.agent_service.kubernetes_stack: 'true'
      io.rancher.container.agent.role: environmentAdmin
      io.rancher.container.create_agent: 'true'
      io.rancher.container.pull_image: always
```

rancher-compose.yml:

```
version: '2'
services:
  aws-spot-instance-helper-k8:
    scale: 1
    start_on_create: true
```

## Conclusion

After you've followed these steps, Autospotter should begin to replace nodes in your "node" ASG with spot market instances. You can see its activity in the container log.
