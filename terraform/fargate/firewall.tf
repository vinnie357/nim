resource "aws_security_group" "fargate_sg" {
  name = format("%s-fargate_sg-%s", var.prefix, random_id.id.hex)

  vpc_id = aws_vpc.terraform-vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_mgmt_cidr
  }
  ingress {
    from_port   = 0
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_mgmt_cidr
  }
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [aws_vpc.terraform-vpc.cidr_block]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.terraform-vpc.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.terraform-vpc.cidr_block]
  }

}
