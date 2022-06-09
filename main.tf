terraform {
    required_version = "1.2.2"

    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "4.15.1"
        }
    }
}

provider "aws" {    
    region  = var.aws_region   
}

resource "aws_db_instance" "rds-tf" {
    allocated_storage    = 20
    engine               = "postgres"
    identifier           = "tf-db"     
    engine_version       = "13"
    instance_class       = "db.t3.medium"
    username             = "postgres"
    password             = "postgres"
    skip_final_snapshot  = true
    publicly_accessible  = true
    vpc_security_group_ids = ["${aws_security_group.tf-sg.id}"]
}

resource "aws_instance" "web" {
    ami           = var.instance_ami
    instance_type = var.instance_type
    key_name = var.key_name
    user_data = file("init-script.sh")
    tags          = var.instance_tags

    vpc_security_group_ids = ["${aws_security_group.tf-sg.id}"]
    depends_on = [
        aws_db_instance.rds-tf
    ]
    associate_public_ip_address = true
}
resource "aws_security_group" "tf-sg" {
    name        = "tf-sg"
    description = "tf-sg"

ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.cidrs_acesso_remoto
}

ingress {
    description = "HTTP to EC2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cidrs_acesso_remoto
}

ingress {
    description = "HTTPS to EC2"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cidrs_acesso_remoto
}

ingress {
    description = "HTTP to EC2"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = var.cidrs_acesso_remoto
}

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    tags = {
    Name = "tf-sg"
    }
}

