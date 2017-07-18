terraform {
        required_version = ">= 0.9"
}

provider "aws" {
        region = "${var.aws_region}"
}

resource "aws_security_group" "frontend" {
        name = "frontend"
        vpc_id = "${var.vpc_id}"

        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = "443"
                to_port = "443"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }

        tags {
                Name = "sg-frontend"
        }

}

resource "aws_security_group" "backend" {
        name = "backend"
        vpc_id = "${var.vpc_id}"

        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                security_groups = ["${aws_security_group.frontend.id}"]
        }

        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }

        tags {
                Name = "sg-backend"
        }

}


resource "aws_security_group" "database" {
        name = "database"
        vpc_id = "${var.vpc_id}"

        ingress {
                from_port = "${var.mongodb_port}"
                to_port = "${var.mongodb_port}"
                protocol = "tcp"
                security_groups = ["${aws_security_group.backend.id}"]
        }

        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                security_groups = ["${aws_security_group.backend.id}"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }

        tags {
                Name = "sg-database"
        }

}

### template
data "template_file" "mount_ebs" {
        template = "${file("mount_ebs.sh")}"
        count = "${var.ec2_count_database}"
        vars {
                aws_region = "${var.aws_region}"
                data_ebs_device = "${var.database_ebs_device}"
                ebs_mount_point = "${var.ebs_mount_point}"
                volume_id = "${element(aws_ebs_volume.database.*.id, count.index)}"

        }
}

### IAM


resource "aws_iam_instance_profile" "database" {
        name = "database-ec2-profile"
        role = "${aws_iam_role.database.name}"
}

resource "aws_iam_role" "database" {
        name = "database-ec2-role"
        assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "database" {
        name = "database-ec2-policy"
        role = "${aws_iam_role.database.id}"
        policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

### EC2

resource "aws_key_pair" "ec2-key" {
        key_name = "${var.ec2_key_name}"
        public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDM901uGUn2Uh7FJn81hXCqsqr49JhOXY6nQ0ed0Dq90AAwfQcrfZbxN/xX4IXlAxiWMSIR/ncbsVrfVoazvU0PmJ6fo7W7eIqBUMQRECJJc3SQXBgCev3Ap4n6gKFtF47PfdpABjklmLmrU65mRoMxgUa46fO7HtTpilAhTj5it9f2vL9B3v8gKiAGGaTdeFk8WonN8cbKnkqRZf2DB3dzpL7PssC4UF9Am91XKk1mPgRTB2Td+AmSyEQx2IXrdFc5c/3S4mmPsdtzu5X9TtGsXdWaLqQuzw1j/6MVOsCnq9qhhbcxbe1wEOVw84kRyCqB15gN4Jya5dfqwEojZqMx"
}

resource "aws_instance" "frontend" {
        ami = "${lookup(var.ec2_ami, var.aws_region)}"
        instance_type = "${var.ec2_type}"
        count = "${var.ec2_count_frontend}"
        subnet_id = "${var.vpc_subnet_id}"
        vpc_security_group_ids = ["${aws_security_group.frontend.id}"]
        key_name = "${aws_key_pair.ec2-key.key_name}"
        associate_public_ip_address = "True"
        root_block_device {
              volume_size = "${var.ec2_root_ebs_size}"
        }

        tags {
                Name = "frontend-${count.index}",
                role = "frontend"
        }

}

resource "aws_instance" "backend" {
        ami = "${lookup(var.ec2_ami, var.aws_region)}"
        instance_type = "${var.ec2_type}"
        count = "${var.ec2_count_backend}"
        subnet_id = "${var.vpc_subnet_id}"
        vpc_security_group_ids = ["${aws_security_group.backend.id}"]
        key_name = "${aws_key_pair.ec2-key.key_name}"
        associate_public_ip_address = "True"
        root_block_device {
              volume_size = "${var.ec2_root_ebs_size}"
        }

        tags {
                Name = "backend-${count.index}",
                role = "backend"
        }

}

resource "aws_instance" "database" {
        ami = "${lookup(var.ec2_ami, var.aws_region)}"
        instance_type = "${var.ec2_type}"
        availability_zone = "${var.aws_default_az}"
        count = "${var.ec2_count_database}"
        subnet_id = "${var.vpc_subnet_id}"
        vpc_security_group_ids = ["${aws_security_group.database.id}"]
        key_name = "${aws_key_pair.ec2-key.key_name}"
        associate_public_ip_address = false
        root_block_device {
              volume_size = "${var.ec2_root_ebs_size}"
        }
        iam_instance_profile = "${aws_iam_instance_profile.database.id}"
        user_data = "${element(data.template_file.mount_ebs.*.rendered, count.index)}"

        tags {
                Name = "database-${count.index}",
                role = "database"
        }

        lifecycle {
                create_before_destroy = true
        }

}

resource "aws_ebs_volume" "database" {
        availability_zone = "${var.aws_default_az}"
        count = "${var.ec2_count_database}"
        size = "${var.database_ebs_size}"
        tags = {
                Name = "mongodb-${count.index}"
                role = "database"
        }
}


