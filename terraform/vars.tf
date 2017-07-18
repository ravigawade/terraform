variable "aws_region" {
        description = "Region for stack"
        default = "us-east-1"
}

variable "aws_default_az" {
        description = "Default AZ. Must be AZ of vpc_subnet_id"
        default = "us-east-1d"
}

variable "vpc_id" {
        description = "VPC ID. Must be default VPC"
        default = "vpc-c3aca6a4"
}

variable "vpc_subnet_id" {
        description = "Subnet ID. Must be ID inside aws_default_az"
        default = "subnet-89e438a4"
}

variable "ec2_key_name" {
        description = "SSH key name to access EC2 instances"
        default = "mykey"
}

variable "ec2_ami" {
        description = "AMI ID used for ec2 instances"
        default = {
                us-east-1 = "ami-d15a75c7" # ubuntu 16.04, https://cloud-images.ubuntu.com/locator/ec2/
        }
}

variable "ec2_type" {
        description = "Type for EC2 instances"
        default = "t2.micro"
}

variable "ec2_count_frontend" {
        description = "Number of frontend EC2 instances"
        default = 2

}

variable "ec2_count_backend" {
        description = "Number of backend EC2 instances"
        default = 2

}

variable "ec2_count_database" {
        description = "Number of database EC2 instances"
        default = 3

}

variable "ec2_root_ebs_size" {
        description = "Size of root EBS of instances"
        default = 30
}

variable "mongodb_port" {
        description = "MongoDB port number"
        default = 27017
}

variable "database_ebs_size" {
        description = "Size of EBS for database servers"
        default = 50
}

variable "database_ebs_device" {
        description = "EBS volume device name in Linux"
        default = "/dev/xvdf"
}

variable "ebs_mount_point" {
        description = "EBS volume mount point"
        default = "/mnt/data/"
}
