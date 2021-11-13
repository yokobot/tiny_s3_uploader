resource "aws_cognito_identity_pool" "js" {
  identity_pool_name               = "${var.environment}-js"
  allow_unauthenticated_identities = true

  tags = {
    Name = "${var.environment}-tiny-s3-uploader-idp"
  }
}

resource "aws_iam_role" "unauthenticated_user" {
  name               = "${var.environment}-tiny-s3-uploader-unauthed-user-role"
  assume_role_policy = ""
}

resource "aws_iam_role_policy" "unauthenticated_user" {
  name = "${var.environment}-tiny-s3-uploader-unauthenticated-policy"
  role = aws_iam_role.unauthenticated_user.id

  policy = jsonencode({
    Version = 2012 - 10 - 17
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-sync:*",
          "cognito-identity:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.docs.arn
        ]
      }
    ]
  })
}