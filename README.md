# Quant Cloud Assignment – Simple Web App (AWS + Terraform)

This repo contains a minimal web app with a separate front end and back end, deployed reproducibly using Infrastructure as Code (Terraform). It implements the assignment requirements (separate FE/BE, at least one HTTP request, cloud resources, idempotent IaC, and documentation). Containerization of the back end for local dev is included as a plus. (See the original brief.) 

## Architecture
- *Frontend:* S3 Static Website Hosting (public, HTTP).
- ⁠*Backend:* AWS Lambda (Python 3.11) behind API Gateway *HTTP API*.
- ⁠*IaC:* Terraform provisions S3, Lambda, API Gateway, IAM, and outputs.
- ⁠*Request flow:* Frontend ⁠ fetch() ⁠ → API Gateway → Lambda → JSON response.

> **Note:** The S3 static website is HTTP-only. The API is HTTPS. Browsers allow HTTP pages to call HTTPS APIs, so this keeps the setup simple, functional, and within the AWS free tier. For full-site HTTPS, add CloudFront + ACM.

## Prerequisites
- ⁠AWS account (free tier is sufficient)
- ⁠IAM user/role with permissions for S3, Lambda, API Gateway, IAM, and CloudWatch Logs
- ⁠*AWS CLI* configured: ⁠ aws configure ⁠
- ⁠*Terraform* ≥ 1.6
- ⁠*Python* 3.11
- zip ⁠, ⁠ jq ⁠, and ⁠ make ⁠ (optional but recommended)

## One-time setup
```bash
# Clone and enter the repo
git clone <your-fork-url>
cd quant-cloud-assignment

# (Optional) confirm AWS identity and region
aws sts get-caller-identity
```

# Deploy

## 1) Init and apply Terraform
This step builds the Lambda ZIP, runs terraform init, applies the Terraform configuration, and automatically generates frontend/env.js with the deployed API URL.
```bash
make deploy
```

## 2) Upload frontend files to S3
After infrastructure is ready, sync the local frontend/ directory (including the generated env.js) to the S3 bucket hosting the website.
```bash
make fe-sync
```

## 3) Open the live website
Print the public URL of your deployed frontend. Copy and paste it into a browser to view the app.
```bash
make fe-open
```

### Deployment: http://quant-cloud-assignment-994bb02b.s3-website.eu-north-1.amazonaws.com/

#### Optional Local Backend Server:
```bash
docker build -t qca-backend ./backend
docker run -p 8000:8000 qca-backend
```
#### Local Test: curl "http://localhost:8000/hello?name=Alice"

## Cleanup
To destroy all AWS resources and clean local artifacts
```bash
make destroy
```

> **Warning:** make destroy permanently deletes cloud resources and local generated files (lambda.zip, frontend/env.js, etc.). 
