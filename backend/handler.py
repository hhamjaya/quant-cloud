import json
import os
from urllib.parse import parse_qs
import logging 

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # API Gateway HTTP API delivers query string params either in event["queryStringParameters"]
    # or via rawQueryString; handle both defensively
    name = "World"
    logger.info("Received event: %s", json.dumps(event))  # <-- LOG EVENT

    qsp = event.get("queryStringParameters") or {}
    if qsp and "name" in qsp:
        name = qsp["name"]
    else:
        rqs = event.get("rawQueryString") or ""
        if rqs:
            parsed = parse_qs(rqs)
            if "name" in parsed and parsed["name"]:
                name = parsed["name"][0]

    body = {
        "message": f"Hello, {name}!",
        "runtime": os.environ.get("AWS_EXECUTION_ENV", "unknown"),
    }
    headers_in = event.get("headers") or {}
    origin = headers_in.get("origin") or headers_in.get("Origin") or ""

    # return {
    #     "statusCode": 200,
    #     # "headers": {
    #     #     "Content-Type": "application/json",
    #     #     # CORS for the S3 website
    #     #     "Access-Control-Allow-Origin": "*",
    #     #     "Access-Control-Allow-Methods": "GET,OPTIONS",
    #     # },
    #     "headers": {
    #         "Access-Control-Allow-Origin": "*",
    #         "Access-Control-Allow-Methods": "GET,OPTIONS",
    #         "Access-Control-Allow-Headers": "*"   # or a specific list like "content-type,authorization"
    #     },
    #     "body": json.dumps(body),
    # }

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": origin,  # no "*"
            "Vary": "Origin",
            "Access-Control-Allow-Methods": "GET,OPTIONS",
            "Access-Control-Allow-Headers": "content-type,authorization",
            "Access-Control-Allow-Credentials": "true",
        },
        "body": json.dumps(body),
    }

# import json, os
# from urllib.parse import parse_qs
 
# def _cors_headers(origin: str):
#     # If you don't use credentials, set origin to "*" and remove Allow-Credentials
#     return {
#         "Access-Control-Allow-Origin": origin or "*",
#         "Vary": "Origin",
#         "Access-Control-Allow-Methods": "GET,OPTIONS",
#         "Access-Control-Allow-Headers": "content-type,authorization",
#         # comment out the next line if you are NOT sending cookies/Authorization from the browser
#         # "Access-Control-Allow-Credentials": "true",
#     }
 
# def lambda_handler(event, context):
#     try:
#         headers_in = (event or {}).get("headers") or {}
#         origin = headers_in.get("origin") or headers_in.get("Origin") or ""
 
#         # Handle preflight explicitly (if OPTIONS hits Lambda)
#         method = (event.get("requestContext", {}).get("http", {}).get("method")
#                   or event.get("httpMethod") or "GET")
#         if method == "OPTIONS":
#             return {"statusCode": 204, "headers": _cors_headers(origin), "body": ""}
 
#         # App logic (defensive against None)
#         name = "World"
#         qsp = event.get("queryStringParameters") or {}
#         if isinstance(qsp, dict) and qsp.get("name"):
#             name = qsp["name"]
#         else:
#             rqs = event.get("rawQueryString") or ""
#             if rqs:
#                 parsed = parse_qs(rqs)
#                 if parsed.get("name"):
#                     name = parsed["name"][0]
 
#         body = {
#             "message": f"Hello, {name}!",
#             "runtime": os.environ.get("AWS_EXECUTION_ENV", "unknown"),
#         }
 
#         return {"statusCode": 200, "headers": _cors_headers(origin), "body": json.dumps(body)}
#     except Exception as e:
#         # Always return a body so API GW doesn't convert to a generic 5xx without CORS
#         return {
#             "statusCode": 500,
#             "headers": _cors_headers((event.get("headers") or {}).get("origin") or ""),
#             "body": json.dumps({"error": "internal_error", "detail": str(e)}),
#         }