# HA Secure App Terraform Project
## High Availability Opencart E-Commerce Site with IaC.

This project is a highly available and secure infrastructure setup for deploying a web application using Terraform. It leverages AWS services to ensure scalability, reliability, and security. For this project I chose OpenCart (Open Source E-Commerce) as the application to be deployed.

## Project Overview

The infrastructure includes the following components:

1. **VPC and Subnets**:
   - A Virtual Private Cloud (VPC) with both public and private subnets.
   - Public subnets are used for internet-facing resources like the Application Load Balancer (ALB).
   - Private subnets are used for backend resources like EC2 instances and RDS.
   - NAT gateway is setup for Private Subnets.

2. **Application Load Balancer (ALB)**:
   - An ALB is configured to distribute traffic across multiple EC2 instances.
   - Supports HTTP to HTTPS redirection and integrates with an ACM certificate for secure communication.

3. **Auto Scaling Group (ASG)**:
   - EC2 instances are managed by an ASG to ensure high availability and scalability.
   - Instances are launched using a Launch Template with user data scripts for configuration.

4. **Elastic File System (EFS)**:
   - A shared file system is mounted on all EC2 instances for storing application data.

5. **MariaDB RDS**:
   - A managed MariaDB database instance is deployed in private subnets for secure data storage.

6. **Bastion Host**:
   - A bastion host is deployed in a public subnet to allow secure SSH access to private instances.

7. **IAM Roles and Policies**:
   - IAM roles and instance profiles are configured to allow EC2 instances to interact with AWS services like SSM and CloudWatch.

8. **Route53 and ACM**:
   - Route53 is used for DNS management, and ACM is used for SSL/TLS certificates.

9. **WAF (Web Application Firewall)**:
   - A WAF is associated with the ALB to protect against common web exploits. Free WAF Rules are applied.

10. **CloudWatch Logs**:
    - Logs from various services (e.g., Apache, MySQL, cloud-init) are sent to CloudWatch for centralized monitoring.

## File Structure

- **`vpc.tf`**: Defines the VPC, subnets, Internet gateway and NAT gateway.
- **`alb.tf`**: Configures the Application Load Balancer and its listeners. `Note:` By Default it needs two public AZs to be deployed.
- **`asg.tf`**: Sets up the Auto Scaling Group and Launch Template.
- **`efs.tf`**: Configures the Elastic File System and its mount targets. `Note:` EFS will store the Data for the application.
- **`rds.tf`**: Defines the MariaDB RDS instance and its security group.
- **`bastion.tf`**: Creates the bastion host and its security group. `Note:` The Bastion will the the entrance to access the Private Subnet Instances
- **`iam.tf`**: Configures IAM roles, policies, and instance profiles.
- **`route53.tf`**: Manages DNS records for the domain.
- **`acm.tf`**: Sets up the ACM certificate and validation records.
- **`waf.tf`**: Configures the Web Application Firewall. `Note:` Free WAF Rules have been applied.
- **`variables.tf`**: Defines input variables for the project.
- **`outputs.tf`**: Outputs key information like ALB DNS name and RDS endpoint.
- **`scripts/`**: Contains bash scripts for configuring instances (e.g., Apache, OpenCart, EFS).

## Scripts. 
#### This applies specifically to your application. In this case, the scripts were create to install and configure Opencart

- **`01-apache.sh`**: Sets up the Apache web server and PHP environment.
- **`02-user.sh`**: Creates a new user with sudo privileges and configures SSH for password authentication from the Bastion Host. (`Note:` This is not ideal... In my case, I wanted to use VS-Code Terminal to troubleshot the Opencart Scripts on the new Private Instances). You can use `Session Mannager` instead and disable SSH Password authentication.
- **`03-efs.sh`**: Mounts the Elastic File System (EFS) and prepares the directory structure.
- **`04-rds.sh`**: Installs the MariaDB client for interacting with the RDS database.
- **`05-logs.sh`**: Configures and starts the CloudWatch Agent for centralized log monitoring.
- **`06-opencart.sh`**: Installs and configures the OpenCart application.
- **`07-oc-config.sh`**: Updates OpenCart configuration files (config.php) for HTTPS and storage directory paths.
- **`09-system-update.sh`**: Performs a final system update and upgrade.

## Prerequisites

- `AWS CLI Installed:` Ensure the AWS CLI is installed on your local machine.
- `Terraform Installed:` Ensure Terraform is installed on your local machine.
- `AWS IAM Identity Center (SSO):` We will use AWS IAM Identity Center to provision access for our user. Make sure to provide the necessary access to all the AWS Services used in this project. You can setup AWS `Access Keys` as well; but for `security` I never save any AWS access keys on my local machine.
- `SSO Authentication:` Our user account will authenticate via SSO into the target AWS account where resources will be deployed.
- `Review and customize` the variables in `variables.tf` and `terraform.tfvars.example` files to override defaults.

    | Variable           | Description                             | 
    |--------------------|-----------------------------------------|
    | `domain`           | Domain name for the website             |
    | `aws region`       | AWS region for the bucket               |
    | `profile`          | AWS SSO Profile to be used              |
    | `route53`          | ZXXXX ... Domain Hosted Zone ID         |
    | `instance_tupe`    | e.g: T2.micro                           |
    | `ami_id`           | ami-XXXXX used. This projects Ubuntu    |
    | `new_user`         | sudo user to login EC2 Instances        |
    | `new_password`     | sudo user password                      |
    | `local_ip`         | Your IP Address. to secure log in /32   |
    | `db_username`      | DB username with full access            |
    | `db_password`      | DB password                             |
    | `install_dir`      | Directory to install application        | 

## Usage

1. Clone the repository:
    ```bash
    git clone https://github.com/jdiaz2001/ha-secure-app.git
    cd ha-secure-app
    ```
2. Authenticate with your AWS SSO Profile
    ```bash
    aws sso login --sso-session "Profile_Name" 
    ```

3. Initialize the Terraform working directory:
    ```bash
    terraform init
    ```

4. Validate the infrastructure changes:
    ```bash
    terraform validate
    ```

5. Plan the infrastructure changes:
    ```bash
    terraform plan
    ```

6. Apply the configuration to create the S3 bucket:
    ```bash
    terraform apply
    ```

7. Confirm the changes and note the output values.

## Outputs
- `Domian URL`: The URL of the website
- `ALB DNS`: The DNS for the ALB
- `DB Endpoint`: The Endpoint for the new DB
- `EFS ID`: The EFS ID 
- `Bastion Host DNS`: The DNS for the new Bastion Host

## Cleanup

To destroy the resources created by this project, run:
```bash
terraform destroy
```

## Creator

Project created by `JAVIER DIAZ`