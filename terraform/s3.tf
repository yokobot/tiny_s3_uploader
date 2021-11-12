resource "aws_s3_bucket" "uploader" {
  bucket = "${var.environment}-tiny-s3-uploader"
  acl    = "private"

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
