from dotenv import load_dotenv
import os

# Load environment variables from .env
load_dotenv()

# Access variables
db_host = os.getenv("MYSQL_HOST")
db_username = os.getenv("MYSQL_USER")
db_database = os.getenv("MYSQL_DATABASE")
db_password = os.getenv("MYSQL_PASSWORD")
allowed_origins = os.getenv("ALLOWED_ORIGINS", "").split(",")
