provider "aws" {
  region = var.aws_region
}

# ----------------------------
# Lambda package (zip from repo root)
# ----------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir = "${path.root}/../backend"
  output_path = "${path.root}/../lambda.dist.zip"
}

# ----------------------------
# IAM role for Lambda
# ----------------------------
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.project}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# Basic execution policy (logs)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ----------------------------
# Lambda function
# ----------------------------
resource "aws_lambda_function" "hello" {
  function_name = "${var.project}-hello"
  role          = aws_iam_role.lambda.arn
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"
  publish       = true
}

# ----------------------------
# API Gateway HTTP API
# ----------------------------
resource "aws_apigatewayv2_api" "http" {
  name          = "${var.project}-api"
  protocol_type = "HTTP"
 
  cors_configuration {

    # put your exact sites (S3 website + localhost)

    allow_origins     = ["*", "http://localhost:5173"]

    allow_methods     = ["GET","OPTIONS"]

    allow_headers     = ["content-type","authorization"]

    expose_headers    = ["content-type","content-length"]

    # allow_credentials = true

    max_age           = 86400

  }
 
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.hello.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "hello" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
}

# ----------------------------
# S3 static website (HTTP only, free-tier)
# ----------------------------
resource "aws_s3_bucket" "frontend" {
  bucket = coalesce(var.frontend_bucket_name, "${var.project}-${random_id.bucket.hex}")
  force_destroy = true
}

resource "random_id" "bucket" {
  byte_length = 4
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

data "aws_iam_policy_document" "public_read" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.public_read.json
}

output "api_base_url" {
  value = aws_apigatewayv2_api.http.api_endpoint
}
 
output "frontend_bucket" {
  value = aws_s3_bucket.frontend.bucket
}
 
output "frontend_website_url" {
  value = aws_s3_bucket_website_configuration.frontend.website_endpoint
}