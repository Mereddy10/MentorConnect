import boto3

def upload_file_to_s3(file_obj, filename):
    bucket_name = "mentorconnect-sahasra"
    region = "ap-south-1"
    endpoint_url = f"https://s3.{region}.amazonaws.com"

    s3 = boto3.client(
        "s3",
        aws_access_key_id="AKIA6JB4DHTMPRIBQOV4",
        aws_secret_access_key="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",
        region_name=region,
        endpoint_url=endpoint_url  # ✅ force region endpoint
    )

    s3.upload_fileobj(file_obj, "mentorconnect-sahasra", filename)

    # Return the correct public URL format
    return f"https://{bucket_name}.s3.{region}.amazonaws.com/{filename}"


