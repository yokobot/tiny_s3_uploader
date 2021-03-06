resource "aws_cognito_identity_pool" "js" {
  identity_pool_name               = "${var.s3_bucket_prefix}-js"
  allow_unauthenticated_identities = true

  tags = {
    Name = "${var.s3_bucket_prefix}-idp"
  }
}

resource "aws_iam_role" "unauthenticated_user" {
  name               = "${var.s3_bucket_prefix}-unauthed-user-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": ${jsonencode(aws_cognito_identity_pool.js.id)}
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "unauthenticated"
        }
      }
    }
  ]
}
  POLICY
}

resource "aws_iam_role_policy" "unauthenticated_user" {
  name = "${var.s3_bucket_prefix}-unauthenticated-policy"
  role = aws_iam_role.unauthenticated_user.id

  policy = jsonencode({
    Version = "2012-10-17"
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
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          module.docs.arn,
          "${module.docs.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_cognito_identity_pool_roles_attachment" "js" {
  identity_pool_id = aws_cognito_identity_pool.js.id

  roles = {
    "unauthenticated" = aws_iam_role.unauthenticated_user.arn
  }
}