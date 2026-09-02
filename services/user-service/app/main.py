from fastapi import FastAPI

app = FastAPI(title="ShopSphere User Service")


@app.get("/")
def root():
    return {
        "service": "user-service",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/users/{user_id}")
def get_user(user_id: int):
    return {
        "id": user_id,
        "name": f"user-{user_id}",
        "email": f"user{user_id}@shopsphere.local"
    }
