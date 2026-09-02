from fastapi import FastAPI

app = FastAPI(title="ShopSphere Product Service")


products = {
    1: {
        "id": 1,
        "name": "Laptop",
        "price": 75000
    },
    2: {
        "id": 2,
        "name": "Keyboard",
        "price": 2500
    },
    3: {
        "id": 3,
        "name": "Mouse",
        "price": 1200
    }
}


@app.get("/")
def root():
    return {
        "service": "product-service",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/products")
def get_products():
    return list(products.values())


@app.get("/products/{product_id}")
def get_product(product_id: int):

    product = products.get(product_id)

    if not product:
        return {
            "error": "Product not found"
        }

    return product
