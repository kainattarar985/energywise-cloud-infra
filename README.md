# EnergyWise – Task 2 Cloud Infrastructure

Terraform code that deploys the AWS architecture for the EnergyWise energy
consumption prediction platform (see `docs/architecture-diagram.png` from
Phase 1).

## Architecture

Data sources -> S3 -> SageMaker -> API Gateway + Lambda -> Dashboard (S3 + CloudFront) -> Users

## Prerequisites

- Terraform >= 1.5 installed (`terraform --version`)
- AWS CLI configured with credentials (`aws configure`)
- The trained model artifact `model.tar.gz` in the project folder. Terraform
  uploads it to the data bucket at the path set in `model_artifact_s3_key`
  (this repo covers the cloud infrastructure, not the model training itself)
- The SageMaker inference container image URI for your region/framework.
  Find it with the SageMaker Python SDK, e.g.:
```python
  from sagemaker import image_uris
  image_uris.retrieve(framework="sklearn", region="eu-central-1", version="1.2-1")
```

## Deploy

```bash
terraform init
terraform plan  -var="sagemaker_image_uri=<your-image-uri>"
terraform apply -var="sagemaker_image_uri=<your-image-uri>"
```

Or set `sagemaker_image_uri` (and any other variables you want to override)
in a `terraform.tfvars` file instead of passing `-var` each time.

## What Terraform manages

Everything is deployed with `terraform apply`, with no manual upload steps:
- the model file (`model.tar.gz`) in the data bucket
- the dashboard page (`dashboard/index.html`) in the dashboard bucket; the
  real API address is filled in automatically
- CORS on the API, which allows requests only from the CloudFront dashboard address

## Outputs

After `apply`, Terraform prints:
- `dashboard_url` – CloudFront URL to view the dashboard
- `api_endpoint` – URL to POST prediction requests to
- `sagemaker_endpoint_name` – the deployed SageMaker endpoint

## Tear down

```bash
terraform destroy
```