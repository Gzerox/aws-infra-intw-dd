locals {
  alb_origin_id="alb-${aws_lb.web.id}"
  s3_origin_id="s3-${aws_s3_bucket.static_assets.id}"
}

resource "aws_s3_bucket" "static_assets" {
  bucket = var.aws_s3_static_assets
  acl    = "private"
  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.cf.id}"
                },
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::${var.aws_s3_static_assets}/*"
            }
        ]
    }
    )
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.static_assets.bucket
  key    = "images/logo.jpg"
  source = "${path.module}/logo.jpg"

  etag = filemd5("${path.module}/logo.jpg")
}


resource "aws_cloudfront_origin_access_identity" "cf" {
  comment = "${var.aws_resource_suffix}-cf"
}
resource "aws_cloudfront_distribution" "s3_distribution" {

  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_lb.web.dns_name
    origin_id   = local.alb_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2", "SSLv3"]
    }

    custom_header {
      name = "X-Custom-Header"
      value = "random-value-cFFDfmpU8eimk6CR@@3yU49@"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.alb_origin_id

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }


  origin {
    domain_name = aws_s3_bucket.static_assets.bucket_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.cf.cloudfront_access_identity_path}"
    }
  }

  ordered_cache_behavior  {
    path_pattern           = "images/*.jpg"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}