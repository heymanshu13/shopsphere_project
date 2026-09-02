from fastapi import FastAPI

app = FastAPI(title="ShopSphere Notification Service")


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
