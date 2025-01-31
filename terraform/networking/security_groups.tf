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

# ALB Egress to Cluster
resource "aws_security_group_rule" "alb_to_cluster_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.argocd.id
  description              = "Allow ALB to send traffic to cluster"
}

# ALB Ingress Rules (HTTP/HTTPS from internet)
resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.argocd.id
  description       = "Allow HTTP traffic for redirect"
}

resource "aws_security_group_rule" "alb_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.argocd.id
  description       = "Allow HTTPS traffic"
}
