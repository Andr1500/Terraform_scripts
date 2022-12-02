############################
# SNS topic and subscription
############################

#Create SNS topic for notifications from CodeDeploy
resource "aws_sns_topic" "sns_topic" {
  name = "Codepipeline_SNS_topic"
}
#Creation of SNS subscription
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.sns_endpoint
}

#policy for SNS topic
data "aws_iam_policy_document" "notif_access" {
  statement {
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }
    resources = [aws_sns_topic.sns_topic.arn]
  }
}

#sns notification policy attachment
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.sns_topic.arn
  policy = data.aws_iam_policy_document.notif_access.json
}

#Notification rule for Codedebuild
resource "aws_codestarnotifications_notification_rule" "codedeploy" {
  detail_type    = "BASIC"
  event_type_ids = ["codebuild-project-build-phase-failure", "codebuild-project-build-phase-success"]

  name     = "codebuild_commits"
  resource = aws_codebuild_project.codebuild_project.arn

  target {
    address = aws_sns_topic.sns_topic.arn
  }
}

#Notification rule for Codedeploy
resource "aws_codestarnotifications_notification_rule" "commits" {
  detail_type    = "BASIC"
  event_type_ids = ["codedeploy-application-deployment-failed", "codedeploy-application-deployment-succeeded"]

  name     = "codedeploy_commits"
  resource = aws_codedeploy_app.codedeploy_app.arn

  target {
    address = aws_sns_topic.sns_topic.arn
  }
}
