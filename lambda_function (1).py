import json
import boto3
import os
from datetime import datetime

s3 = boto3.client('s3')
BUCKET_NAME = os.environ.get('BUCKET_NAME', 'your-bucket-name')


def lambda_handler(event, context):
    print("Event:", json.dumps(event))

    path = event.get('rawPath') or event.get('path', '/')
    method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')
    params = event.get('queryStringParameters') or {}

    # ── Route: GET /hello ─────────────────────────────────────
    if '/hello' in path:
        name = params.get('name', 'World')
        return respond(200, {
            "message": f"Hello, {name}!",
            "timestamp": datetime.utcnow().isoformat(),
            "invokedBy": "API Gateway → Lambda",
            "region": os.environ.get('AWS_REGION', 'us-east-1')
        })

    # ── Route: GET /presign (generate presigned upload URL) ───
    if '/presign' in path:
        filename = params.get('filename', 'upload.txt')
        content_type = params.get('type', 'application/octet-stream')
        key = f"uploads/{filename}"
        try:
            url = s3.generate_presigned_url(
                'put_object',
                Params={
                    'Bucket': BUCKET_NAME,
                    'Key': key,
                    'ContentType': content_type
                },
                ExpiresIn=300
            )
            return respond(200, {"url": url, "key": key})
        except Exception as e:
            return respond(500, {"error": str(e)})

    # ── Default route ─────────────────────────────────────────
    return respond(200, {
        "message": "Serverless API is running",
        "routes": ["/hello?name=YourName", "/presign?filename=test.txt"],
        "lambda": context.function_name,
        "version": context.function_version
    })


def respond(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type"
        },
        "body": json.dumps(body)
    }
