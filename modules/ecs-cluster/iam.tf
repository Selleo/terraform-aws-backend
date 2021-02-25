resource "aws_iam_role" "instance_role" {
  name               = "${random_id.prefix.hex}-ec2"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json

  tags = merge(var.tags, { owner = "self" })
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${random_id.prefix.hex}-ec2"
  role = aws_iam_role.instance_role.name
}

