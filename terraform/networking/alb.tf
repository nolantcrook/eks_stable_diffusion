# Certificate
resource "aws_acm_certificate" "argocd" {
  domain_name       = "argocd.hello-world-domain.com"
  validation_method = "DNS"

  tags = {
    Name = "argocd-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation record
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.argocd.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.route53_zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "argocd" {
  certificate_arn         = aws_acm_certificate.argocd.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# WAF IPSet for allowed IPs
resource "aws_wafv2_ip_set" "allowed_ips" {
  name               = "allowed-ips"
  description        = "Allowed IP addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["76.129.127.17/32"]  # Your IP from the security group
}

# WAF WebACL
resource "aws_wafv2_web_acl" "argocd" {
  name        = "argocd-waf"
  description = "WAF for ArgoCD ALB"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "AllowedIPs"
    priority = 1

    override_action {
      none {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowed_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "AllowedIPsMetric"
      sampled_requests_enabled  = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name               = "ArgocdWafMetric"
    sampled_requests_enabled  = true
  }
}

# Application Load Balancer
resource "aws_lb" "argocd" {
  name               = "argocd-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.argocd.id]
  subnets           = aws_subnet.public[*].id

  tags = {
    Name = "argocd-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "argocd" {
  name        = "argocd-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200-399"
    path               = "/"
    port               = "traffic-port"
    timeout            = 5
    unhealthy_threshold = 2
  }
}

# ALB Listener
resource "aws_lb_listener" "argocd" {
  load_balancer_arn = aws_lb.argocd.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.argocd.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argocd.arn
  }
}

# WAF association with ALB
resource "aws_wafv2_web_acl_association" "argocd" {
  resource_arn = aws_lb.argocd.arn
  web_acl_arn  = aws_wafv2_web_acl.argocd.arn
}

# DNS record for ALB
resource "aws_route53_record" "argocd" {
  zone_id = local.route53_zone_id
  name    = "argocd.hello-world-domain.com"
  type    = "A"

  alias {
    name                   = aws_lb.argocd.dns_name
    zone_id                = aws_lb.argocd.zone_id
    evaluate_target_health = true
  }
} 