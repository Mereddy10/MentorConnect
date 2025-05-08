import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    # General configuration
    SECRET_KEY = os.getenv('SECRET_KEY', 'mysecretkey')
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'supersecretjwt')
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URI', 'sqlite:///mentor.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # AWS S3 configuration
    AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
    AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")

    S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME")
    S3_REGION = os.getenv("S3_REGION")
