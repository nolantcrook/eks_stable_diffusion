resource "aws_security_group" "neptune" {
  name        = "rag-neptune-sg"
  description = "Security group for Neptune cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8182
    to_port     = 8182
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow ICMP/ping from within the VPC"
  }


  tags = ({
    Name = "rag-neptune-sg"
  })
}

resource "aws_security_group" "opensearch" {
  name        = "rag-opensearch-sg"
  description = "Security group for OpenSearch domain"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow ICMP/ping from within the VPC"
  }

  tags = ({
    Name = "rag-opensearch-sg"
  })
}
