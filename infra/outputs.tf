output "api_url" {
  value = aws_apigatewayv2_stage.this.invoke_url
}

output "s3_website_endpoint" {
  value = aws_s3_bucket_website_configuration.frontend.website_endpoint
}