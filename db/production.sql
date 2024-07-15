CREATE DATABASE IF NOT EXISTS backend;
USE backend;

CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    amount DOUBLE PRECISION,
    category VARCHAR(255),
    description VARCHAR(255),
    is_income BOOLEAN,
    date VARCHAR(255)
);