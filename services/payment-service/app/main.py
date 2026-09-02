from fastapi import FastAPI

app = FastAPI(title="ShopSphere Payment Service")


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
