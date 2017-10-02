provider "aws" {
    region = "eu-central-1"
}

variable domain {
  description = "Domain under which the website is served, also used as bucket name"
  default     = "s3blog.praqma.com"
}

variable index_document {
  description = "Document to serve if the root of the domain is requested"
  default     = "index.html"
}

variable error_404_document {
  description = "Document to serve if requested object doesn't exist in the bucket"
    default     = "404.html"
}

variable ssl_certificate_arn {
  # Once you have uploaded the certificate in AWS Certificate Manager, put the arn in here...
  #default     = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  default = ""
  description = "ARN of the certificate covering the domain plus subdomains under which the website is accessed, e.g. domain.com and *.domain.com"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.domain}"
  acl    = "public-read"

  website {
    index_document = "${var.index_document}"
    error_document = "404.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "bananas/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "about/jobs/"
    }
}]
EOF
  }
}

resource "aws_iam_user" "praqma_com_deploy" {
  name = "praqma_com_deploy"
  path = "/"
}

resource "aws_iam_access_key" "praqma_com_deploy" {
  user = "${aws_iam_user.praqma_com_deploy.name}"
}

resource "aws_iam_user_policy" "deploy_policy" {
  name        = "test_policy"
  user = "${aws_iam_user.praqma_com_deploy.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Action": [
      "s3:*"
    ],
    "Effect": "Allow",
    "Resource": [
      "arn:aws:s3:::${var.domain}",
      "arn:aws:s3:::${var.domain}/*"
    ]
  }
]}
EOF
}


# Cloudfront  - taken example from https://raw.githubusercontent.com/igor-kupczynski/terraform_static_aws_website/master/main.tf

# Cloudfront in front of the main site

resource "aws_cloudfront_distribution" "cdn" {
  count = "${var.ssl_certificate_arn != "" ? 1 : 0}"

  origin {
    domain_name = "${aws_s3_bucket.bucket.website_endpoint}"
    origin_id   = "origin-${var.domain}"

    # Secret sauce required for the aws api to accept cdn pointing to s3 website endpoint
    # http://stackoverflow.com/questions/40095803/how-do-you-create-an-aws-cloudfront-distribution-that-points-to-an-s3-static-ho#40096056
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port = "80"
      https_port = "443"
      origin_ssl_protocols = ["TLSv1"]
    }
  }

  enabled = true

  default_root_object = "${var.index_document}"

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "300"
    response_code         = "404"
    response_page_path    = "/${var.error_404_document}"
  }

  aliases = ["${var.domain}"]

  price_class = "PriceClass_100"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-${var.domain}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    #viewer_protocol_policy = "redirect-to-https"
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.ssl_certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

# Print out the secret access key for future use by deploy script
output "secret" {
  value = "${aws_iam_access_key.praqma_com_deploy.secret}"
}
