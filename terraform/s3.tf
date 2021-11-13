resource "aws_s3_bucket" "uploader" {
  bucket = "${var.environment}-tiny-s3-uploader"
  acl    = "public-read"

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

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "${var.environment}-tiny-s3-uploader"
  }
}

resource "aws_s3_bucket" "docs" {
  bucket = "${var.environment}-tiny-s3-docs"
  acl    = "private"

  tags = {
    Name = "${var.environment}-tiny-s3-docs"
  }
}

resource "aws_s3_bucket_policy" "uploader" {
  bucket = aws_s3_bucket.uploader.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.uploader.arn,
          "${aws_s3_bucket.uploader.arn}/*",
        ]
        Condition = {
          NotIpAddress = {
            "aws:SourceIp" = [for ip in var.source_ip_list : ip]
          }
        }
      },
    ]
  })
}

# destroy時にenvファイルが残っていてもS3バケットを削除する処理
#resource "null_resource" "uploader" {
#  triggers = {
#    bucket = aws_s3_bucket.uploader.bucket
#  }
#
#  depends_on = [aws_s3_bucket.uploader]
#
#  provisioner "local-exec" {
#    when    = destroy
#    command = "aws s3 rm s3://${self.triggers.bucket} --recursive"
#  }
#}
#
#resource "null_resource" "docs" {
#  triggers = {
#    bucket = aws_s3_bucket.docs.bucket
#  }
#
#  depends_on = [aws_s3_bucket.docs]
#
#  provisioner "local-exec" {
#    when    = destroy
#    command = "aws s3 rm s3://${self.triggers.bucket} --recursive"
#  }
#}
