resource "aws_codecommit_repository" "codecommit_repo" {
  repository_name = "from_gitlab"
  description     = "Clone git repo grom Gitlab"
}
