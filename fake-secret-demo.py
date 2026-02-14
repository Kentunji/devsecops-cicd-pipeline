# THIS FILE IS FOR DEMONSTRATION ONLY
# It contains a fake secret to trigger the Gitleaks scanner

import os

# FAKE credentials - DO NOT USE IN PRODUCTION
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
DATABASE_PASSWORD = "super_secret_password_123!"
API_TOKEN = "ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef12"

def connect_to_db():
    return f"postgresql://admin:{DATABASE_PASSWORD}@localhost:5432/mydb"
