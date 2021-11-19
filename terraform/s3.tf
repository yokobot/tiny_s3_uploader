module "uploader" {
  source      = "./modules/s3"
  s3_acl      = "public-read"

  website_document = [
    "index.html"
  ]

  bucket_name    = var.s3_bucket_prefix
  source_ip_list = var.source_ip_list
}

module "docs" {
  source      = "./modules/s3"
  s3_acl           = "private"
  website_document = []
  bucket_name      = "${var.s3_bucket_prefix}-docs"
  source_ip_list   = var.source_ip_list
}