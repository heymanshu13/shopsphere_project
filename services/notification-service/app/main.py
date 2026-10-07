from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title="ShopSphere Notification Service")
Instrumentator().instrument(app).expose(app)


@app.get("/")
def root():
    return {
        "service": "notification-service",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.post("/notifications")
def send_notification():

    return {
        "notification_id": "NOTIFY-10001",
        "status": "SENT"
    }
