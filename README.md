# Autospotting on Rancher


This is a set of terraform plans to setup to AWS Auto Scaling Groups to demonstrate
the features of [Autospotting](https://github.com/cristim/autospotting) on [Rancher](http://rancher.com/).

### Requirements

* [Terraform](http://terraform.io) (tested on v0.10.2)
* AWS account with VPC 

### Getting Started
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

4. **Launch Autospotting Catalog Item**. From the Community Catalog, find the item called "Autospotting" and configure it with required parameters, including the AWS API Keypair from the above step.

After you've followed these steps, Autospotter should begin to replace nodes in your "node" ASG with spot market instances. You can see its activity in the container log.
