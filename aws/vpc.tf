resource "aws_vpc" "tenable_cs_demo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = merge(
    var.default_tags,
    {
      Name = "tenable_cs_demo_vpc"
    }
  )
}
resource "aws_flow_log" "tenable_cs_demo_vpc" {
  vpc_id          = "${aws_vpc.tenable_cs_demo_vpc.id}"
  iam_role_arn    = "<iam_role_arn>"
  log_destination = "${aws_s3_bucket.tenable_cs_demo_vpc.arn}"
  traffic_type    = "ALL"

  tags = {
    GeneratedBy      = "Accurics"
    ParentResourceId = "aws_vpc.tenable_cs_demo_vpc"
  }
}
resource "aws_s3_bucket" "tenable_cs_demo_vpc" {
  bucket        = "tenable_cs_demo_vpc_flow_log_s3_bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled    = true
    mfa_delete = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_s3_bucket_policy" "tenable_cs_demo_vpc" {
  bucket = "${aws_s3_bucket.tenable_cs_demo_vpc.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "tenable_cs_demo_vpc-restrict-access-to-users-or-roles",
      "Effect": "Allow",
      "Principal": [
        {
          "AWS": [
            <principal_arn>
          ]
        }
      ],
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.tenable_cs_demo_vpc.id}/*"
    }
  ]
}
POLICY
}