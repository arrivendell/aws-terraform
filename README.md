# aws-terraform

## Overview
This repo aims to manage aws infrastructure.
- Under `./jenkins` you can find terraform code related to have a Jenkin host running. Installing python 3.6 and jenkins is still to be done on the host. Soon I should update the image used to my image for easier configuration
- Under `./kubernetes` you can find code related to the orchestration of url_shortener service. This is not up to date with the lastest version, but present steps to run for starting a kubernetes cluster and deploying the app inside.
- Under `./url_shortener`, you will find the ecs folder containing all the terraform config enabling the url_shortener service to run in an ECS autoscaling cluster.


Here is a simplified and fast overview of what terraform creates for url_shortener:
![alt text](https://i.imgur.com/CIag4SI.png)

To be able to run the terraform on your account, you need some permissions, for a fast set up you those would be enough (but too much sometimes)
- `dynamodb:*`
- `ec2:*`
- `elasticloadbalancing:*`
- `autoscaling:*`
- `route53:*`
- `"s3:*`
- `iam:*`
- `ecs:*`
- `cloudwatch:*`
- `elasticache:*`

Go to the `./url_shortener/ecs` folder for the next steps if you wish to recreate the infrastructure.


## Required:
Install aws cli:
http://docs.aws.amazon.com/cli/latest/userguide/installing.html

### Get terraform up and running:

Download terraform here => https://www.terraform.io/downloads.html
Unzip the package and move terraform to your bins ( /usr/local/bin/ for instance on linux) or add terraform to your PATH variable

Now you should be able to run terraform as a command on your terminal, start by running

`terraform init`

Then you can start the plan step:

`terraform plan`

Apply it:

`terraform plan`

At this step it might fail complaining about concurrency, rerun the apply once more

Then you can destroy your infra:

`terraform destroy`
