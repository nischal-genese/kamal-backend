from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.engine import URL

URL_DATABASE = url = URL.create(
    drivername="mysql+pymysql",
    username="backend",
    password="P@ssword123",
    host="localhost",
    port=3306,
    database="backend",
)
engine = create_engine(URL_DATABASE)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
