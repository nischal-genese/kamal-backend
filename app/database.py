from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.engine import URL

from env_loader import db_host, db_database, db_username, db_password

# Database configuration
URL_DATABASE = url = URL.create(
    drivername="mysql+pymysql",
    username=db_username,
    password=db_password,
    host=db_host,
    port=3306,
    database=db_database,
)
engine = create_engine(URL_DATABASE)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
