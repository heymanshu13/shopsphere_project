import requests

from fastapi import FastAPI, HTTPException

app = FastAPI(title="ShopSphere Order Service")


USER_SERVICE_URL = "http://localhost:8001"
PRODUCT_SERVICE_URL = "http://localhost:8002"
PAYMENT_SERVICE_URL = "http://localhost:8004"


@app.get("/")
def root():
    return {
        "service": "order-service",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.post("/orders/{user_id}/{product_id}")
def create_order(user_id: int, product_id: int):

    # Get user
    user_response = requests.get(
        f"{USER_SERVICE_URL}/users/{user_id}",
        timeout=3
    )

    if user_response.status_code != 200:
        raise HTTPException(
            status_code=502,
            detail="User service unavailable"
        )

    user = user_response.json()

    # Get product
    product_response = requests.get(
        f"{PRODUCT_SERVICE_URL}/products/{product_id}",
        timeout=3
    )

    if product_response.status_code != 200:
        raise HTTPException(
            status_code=502,
            detail="Product service unavailable"
        )

    product = product_response.json()

    # Payment
    payment_response = requests.post(
        f"{PAYMENT_SERVICE_URL}/payments",
        timeout=3
    )

    if payment_response.status_code != 200:
        raise HTTPException(
            status_code=502,
            detail="Payment service unavailable"
        )

    payment = payment_response.json()

    return {
        "order_id": "ORD-10001",
        "user": user,
        "product": product,
        "payment": payment,
        "status": "CONFIRMED"
    }
