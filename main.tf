resource "aws_vpc" "info-tech-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Info-Tech-VPC"

  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.info-tech-vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Public Subnet"
  }
}


resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.info-tech-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private Subnet"
  }
}



resource "aws_security_group" "info-tech-sg" {
  name        = "Info-Tech-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.info-tech-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "Info-Tech-SG"
  }
}


resource "aws_internet_gateway" "info-tech-igw" {
  vpc_id = aws_vpc.info-tech-vpc.id

  tags = {
    Name = "Info-Tech-IGW"
  }
}


resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.info-tech-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.info-tech-igw.id
  }

  tags = {
    Name = "Public-RouteTable"
  }
}

resource "aws_route_table_association" "public-rt-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_instance" "web-server" {
  ami             = "ami-0715c1897453cabd1"
  instance_type   = "t2.micro"
  key_name        = "test01"
  subnet_id       = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.info-tech-sg.id]
  

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./test01.pem")
    host        = self.public_ip
  }
}

resource "aws_eip" "info-tech-aws-eip" {
  instance = aws_instance.web-server.id
  vpc   = true
}


resource "aws_instance" "db-server" {
  ami             = "ami-0715c1897453cabd1"
  instance_type   = "t2.micro"
  key_name        = "test01"
  subnet_id       = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.info-tech-sg.id]


  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./test01.pem")
    #host        = self.public_ip
  }

   tags = {
     Name = "Database Server"
 }
}

resource "aws_eip" "info-tech-aws-ngw-id" {
  vpc   = true
}

resource "aws_nat_gateway" "aws-ngw" {
  allocation_id = aws_eip.info-tech-aws-ngw-id.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "NAT Gateway"

 }
}
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.info-tech-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.aws-ngw.id
  }

  tags = {
    Name = "Private RT"

  }
}


resource "aws_route_table_association" "private-rt-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}


