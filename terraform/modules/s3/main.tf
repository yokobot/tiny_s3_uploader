resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = var.s3_acl

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [
      "HEAD",
      "GET",
      "PUT",
      "POST",
      "DELETE"
    ]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
  }

  dynamic "website" {
    for_each = var.website_document
    content {
      index_document = website.value
    }
  }

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_policy" "bocket_policy" {
  bucket = aws_s3_bucket.bucket.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "IPDeny"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.bucket.arn,
          "${aws_s3_bucket.bucket.arn}/*",
        ]
        Condition = {
          NotIpAddress = {
            "aws:SourceIp" = [for ip in var.source_ip_list : ip]
          }
        }
      },
      {
        Sid       = "IPAllow"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.bucket.arn,
          "${aws_s3_bucket.bucket.arn}/*",
        ]
        Condition = {
          IpAddress = {
            "aws:SourceIp" = [for ip in var.source_ip_list : ip]
          }
        }
      },
    ]
  })
}
