resource "aws_ecs_service" "ecs_service" {
  name            = var.service_name
  task_definition = aws_ecs_task_definition.task_definition.id
  cluster         = aws_ecs_cluster.ecs_cluster.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.0.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  launch_type                        = "EC2"
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [aws_lb_listener.listener_https]
}
