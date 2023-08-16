
# set provider info

provider "aws" {
    profile = "default"


}

resource "aws_instance" "web-server-instance" {
     ami                  = "ami-053b0d53c279acc90"
     instance_type        = "t2.micro"
     availability_zone    = "us-east-1b"
     key_name             = "cloudbrains_key"
     subnet_id            =  aws_subnet.test-subnet.id
     vpc_security_group_ids = [aws_security_group.test-vpc-sg.id]
 }

# vpc resource
resource "aws_vpc" "testvpc" {
    cidr_block = "10.10.0.0/16"
   
   }

   # subet resource
   resource "aws_subnet" "test-subnet" {
  vpc_id     = aws_vpc.testvpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "test-subnet"
  }
}

#internetgateway resource
 
 resource "aws_internet_gateway" "test-igw" {
   vpc_id = aws_vpc.testvpc.id

    tags = {
    Name = "test-igw"
 }
 }

# Route table resource 
resource "aws_route_table" "test-rt" {
  vpc_id = aws_vpc.testvpc.id


route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
    }

    tags = {
      Name = "test-rt"
    }
}


# subnet resource association

resource "aws_route_table_association" "test-rt-association" {
  subnet_id      = aws_subnet.test-subnet.id
  route_table_id = aws_route_table.test-rt.id
}

# security group resource

 resource "aws_security_group" "test-vpc-sg" {
    name           = "test-vpc-sg"
    
    vpc_id         = aws_vpc.testvpc.id
 
    ingress {
        
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    
    ingress {
        
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port    = 0
        to_port      = 0
        protocol     = "-1"
        cidr_blocks  = ["0.0.0.0/0"]
    }
  
 }

# Assign eip on launch 

resource "aws_eip" "elasticip" {
  instance = aws_instance.web-server-instance.id
}

output "EIP" {
  value = aws_eip.elasticip.public_ip
}