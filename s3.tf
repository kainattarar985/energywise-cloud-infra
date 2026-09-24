# Stores historical usage/weather data and the trained model artifact
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-${var.environment}-data-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Hosts the static dashboard site, served via CloudFront (never public directly)
resource "aws_s3_bucket" "dashboard" {
  bucket = "${var.project_name}-${var.environment}-dashboard-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "dashboard" {
  bucket                  = aws_s3_bucket.dashboard.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# Uploads the trained model, so deployment no longer needs a manual `aws s3 cp`
resource "aws_s3_object" "model" {
  bucket = aws_s3_bucket.data.id
  key    = var.model_artifact_s3_key
  source = "${path.module}/model.tar.gz"
  etag   = filemd5("${path.module}/model.tar.gz")
}
# Uploads the dashboard page and fills in the real API address
resource "aws_s3_object" "dashboard_index" {
  bucket       = aws_s3_bucket.dashboard.id
  key          = "index.html"
  content_type = "text/html"
  content = templatefile("${path.module}/dashboard/index.html", {
    api_endpoint = "${aws_apigatewayv2_api.http_api.api_endpoint}/predict"
  })
}