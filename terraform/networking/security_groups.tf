

# Security Groups
resource "aws_security_group" "argocd" {
  name        = "argocd-${var.environment}"
  description = "Security group for ArgoCD ALB"
  vpc_id      = aws_vpc.main.id

  # HTTP ingress for redirect
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic for redirect"
  }

  # HTTPS ingress
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic"
  }

  egress {
    from_port       = 30080
    to_port         = 30080
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
    description     = "Allow outbound traffic to cluster on port 30080 only"
  }

  egress {
    from_port       = 65535
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
    description     = "Allow outbound traffic to cluster on port 65535 only"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name        = "argocd-${var.environment}"
    Environment = var.environment
  }
}

# Cluster Security Group
resource "aws_security_group" "cluster" {
  name        = "eks-cluster-sg-${var.environment}"
  description = "Security group for EKS cluster nodes"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "eks-cluster-sg-${var.environment}"
    Environment = var.environment
  }
}

# # Cluster internal traffic
# resource "aws_security_group_rule" "cluster_internal" {
#   type                     = "ingress"
#   from_port                = 0
#   to_port                  = 65535
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.cluster.id
#   security_group_id        = aws_security_group.cluster.id
#   description              = "Allow internal cluster traffic"
# }

# ALB to NodePort (for NGINX Ingress)
resource "aws_security_group_rule" "alb_to_nginx" {
  type                     = "ingress"
  from_port                = 30080 # NGINX NodePort
  to_port                  = 30080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.argocd.id # ALB security group
  security_group_id        = aws_security_group.cluster.id
  description              = "Allow ALB to NGINX Ingress NodePort"
}
