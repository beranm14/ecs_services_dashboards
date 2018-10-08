data "aws_iam_policy_document" "lambda_services_dashboard" {
  statement {
    effect = "Allow"

    actions = [
      "ecs:*",
      "cloudwatch:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:*",
      "ecs:*",
      "elasticloadbalancing:*",
    ]

    resources = [
      "*",
    ]
  }
}

data "null_data_source" "lambda-path-to-some-file" {
  inputs {
    filename = "${substr("${path.module}/lambda_services_dashboard.zip", length(path.cwd) + 1, -1)}"
  }
}

module "lambda_services_dashboard" {
  source      = "telia-oss/lambda/aws"
  version     = "0.2.0"
  name_prefix = "${var.ecs_cluster_name}"
  filename    = "${data.null_data_source.lambda-path-to-some-file.outputs.filename}"

  environment = {
    ECS_CLUSTER = "${var.ecs_cluster_name}"
  }

  tags = "${merge(
      var.tags,
      map("Name", var.global_name),
      map("Project", var.global_project),
      map("Environment", var.local_environment)
  )}"

  handler = "main.lambda_handler"
  runtime = "python2.7"
  policy  = "${data.aws_iam_policy_document.lambda_services_dashboard.json}"
}

resource "aws_lambda_permission" "cloudwatch_services_dashboard" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda_services_dashboard.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambda_services_dashboard.arn}"
}

resource "aws_cloudwatch_event_rule" "lambda_services_dashboard" {
  name                = "${module.lambda_services_dashboard.name}"
  schedule_expression = "rate(10 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_services_dashboard" {
  target_id = "${module.lambda_services_dashboard.name}"
  rule      = "${aws_cloudwatch_event_rule.lambda_services_dashboard.name}"
  arn       = "${module.lambda_services_dashboard.arn}"
}
