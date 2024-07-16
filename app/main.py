from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Annotated, List
from sqlalchemy.orm import Session
from database import SessionLocal, engine
import models
from env_loader import allowed_origins

# Initialize FastAPI application
app = FastAPI()


# Health check endpoint for Traefik
@app.get("/")
async def check():
    return {"message": "Server is running"}


app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class TransactionBase(BaseModel):
    amount: float
    category: str
    description: str
    is_income: bool
    date: str


class TransactionModel(TransactionBase):
    id: int

    # class Config:
    #     orm_mode = True


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


models.Base.metadata.create_all(bind=engine)


@app.post("/transactions/", response_model=TransactionModel)
async def create_transaction(
    transaction: TransactionBase, db: Annotated[Session, Depends(get_db)]
):
    db_transaction = models.Transaction(**transaction.model_dump())
    db.add(db_transaction)
    db.commit()
    db.refresh(db_transaction)
    return db_transaction


@app.get("/transactions/", response_model=List[TransactionModel])
async def read_transactions(
    db: Annotated[Session, Depends(get_db)], skip: int = 0, limit: int = 100
):
    transactions = db.query(models.Transaction).offset(skip).limit(limit).all()
    return transactions
