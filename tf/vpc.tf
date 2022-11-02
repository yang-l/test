data "aws_availability_zones" "az_avail" {
  state = "available"
}

###

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_base}.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "pub_sub" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = "${var.vpc_cidr_base}.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.az_avail.names["${count.index}"]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "priv_sub" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = "${var.vpc_cidr_base}.1${count.index}.0/24"
  availability_zone = data.aws_availability_zones.az_avail.names["${count.index}"]
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat_eip" {
  count = var.az_count
  vpc   = true
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.pub_sub.*.id, count.index)
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  depends_on = [
    aws_eip.nat_eip,
    aws_subnet.pub_sub
  ]
}

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "pub_int_gw" {
  route_table_id         = aws_route_table.pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "priv" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_nat_gw" {
  count                  = var.az_count
  route_table_id         = element(aws_route_table.priv.*.id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.nat_gw.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  depends_on = [
    aws_route_table.priv,
    aws_nat_gateway.nat_gw
  ]
}

resource "aws_route_table_association" "pub_sub" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.pub_sub.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "priv_sub" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.priv_sub.*.id, count.index)
  route_table_id = element(aws_route_table.priv.*.id, count.index)
}

resource "aws_security_group" "alb" {
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
