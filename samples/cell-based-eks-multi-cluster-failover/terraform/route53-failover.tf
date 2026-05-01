# Route53 failover records example

resource "aws_route53_record" "primary" {
  zone_id = "Z123456"
  name    = "app.example.com"
  type    = "A"

  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = "alb-cell-a.example.com"
    zone_id                = "ZALB123"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "secondary" {
  zone_id = "Z123456"
  name    = "app.example.com"
  type    = "A"

  set_identifier = "secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = "alb-cell-b.example.com"
    zone_id                = "ZALB456"
    evaluate_target_health = true
  }
}
