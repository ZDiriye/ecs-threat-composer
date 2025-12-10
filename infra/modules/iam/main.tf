//creates the trust policy for the iam role
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }
}

//creates the iam role
resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecsThreatComposerExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

//attaches the permission to the iam role
resource "aws_iam_role_policy_attachment" "ecs_exec_permissions" {
  role      = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
