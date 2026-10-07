from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title="ShopSphere Payment Service")
Instrumentator().instrument(app).expose(app)


@app.get("/")
def root():
    return {
        "service": "payment-service",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.post("/payments")
def make_payment():

    return {
        "payment_id": "PAY-10001",
        "status": "SUCCESS"
    }
