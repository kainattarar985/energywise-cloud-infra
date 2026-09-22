resource "aws_sagemaker_model" "prediction" {
  name               = "${var.project_name}-${var.environment}-model"
  execution_role_arn = aws_iam_role.sagemaker_execution.arn

  primary_container {
    image          = var.sagemaker_image_uri
    model_data_url = "s3://${aws_s3_bucket.data.bucket}/${var.model_artifact_s3_key}"
  }
}

resource "aws_sagemaker_endpoint_configuration" "prediction" {
  name = "${var.project_name}-${var.environment}-endpoint-config"

  production_variants {
    variant_name = "primary"
    model_name   = aws_sagemaker_model.prediction.name

    serverless_config {
      max_concurrency   = var.sagemaker_max_concurrency
      memory_size_in_mb = var.sagemaker_memory_size_mb
    }
  }
}

resource "aws_sagemaker_endpoint" "prediction" {
  name                 = "${var.project_name}-${var.environment}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.prediction.name
}
