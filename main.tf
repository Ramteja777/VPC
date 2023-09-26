provider "aws" {
  region=var.location

}


resource "aws_vpc" "myvpc"{
  cidr_block = "10.0.0.0/16"
  tags={
    Name = "MyTerraformVPC"
  }
}

resource "aws_subnet" "PublicSubnet"{
    
   vpc_id =aws_vpc.myvpc.id
   count = var.public_subnet_count  
   cidr_block = "10.0.${count.index + 1}.0/24"
  # availability_zone       = "us-east-1a"
   map_public_ip_on_launch = true

}

resource "aws_subnet" "PrivateSubnet"{
   vpc_id =aws_vpc.myvpc.id
   count = var.public_subnet_count
   cidr_block = "10.0.${count.index + var.public_subnet_count + 1}.0/24"
   #availability_zone  = "us-east-1b"
   map_public_ip_on_launch = false

} 

resource "aws_internet_gateway" "igw"{
   vpc_id =aws_vpc.myvpc.id

}

resource "aws_route_table" "PublicRT"{
   vpc_id = aws_vpc.myvpc.id
   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
   }
}

# route table association public subnet
resource "aws_route_table_association" "PublicRTassociation"{
     count = var.public_subnet_count
     subnet_id = aws_subnet.PublicSubnet[count.index].id
     route_table_id = aws_route_table.PublicRT.id
}

# create security group
resource "aws_security_group" "myvpc-sg" {
  name="myvpc-sg"

  vpc_id=aws_vpc.myvpc.id

  ingress {

    from_port=22
    to_port=22
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]


  }

  egress {
    from_port = 0
    to_port=0
    protocol="-1"
    cidr_blocks=["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name="allow_tls"
  }

}

