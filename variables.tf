variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Short name used to prefix resources"
  type        = string
  default     = "energywise"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "sagemaker_max_concurrency" {
  description = "Max concurrent invocations for the serverless SageMaker endpoint"
  type        = number
  default     = 5
}

variable "sagemaker_memory_size_mb" {
  description = "Memory size (MB) for the serverless SageMaker endpoint (1024-6144, multiple of 1024)"
  type        = number
  default     = 2048
}

variable "model_artifact_s3_key" {
  description = "S3 key (path) to the trained model.tar.gz inside the data bucket"
  type        = string
  default     = "model-artifacts/model.tar.gz"
}

variable "sagemaker_image_uri" {
  description = "ECR image URI for the SageMaker inference container (region/algorithm specific - see README)"
  type        = string
}
