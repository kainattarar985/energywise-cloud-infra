output "dashboard_url" {
  description = "CloudFront URL for the dashboard"
  value       = "https://${aws_cloudfront_distribution.dashboard.domain_name}"
}

output "api_endpoint" {
  description = "Invoke URL for the prediction API"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/predict"
}

output "sagemaker_endpoint_name" {
  description = "Name of the deployed SageMaker endpoint"
  value       = aws_sagemaker_endpoint.prediction.name
}

output "data_bucket_name" {
  value = aws_s3_bucket.data.bucket
}

output "dashboard_bucket_name" {
  value = aws_s3_bucket.dashboard.bucket
}
