from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas, auth, database

router = APIRouter(tags=["alerts"])

# Helper to get an alert owned by the current user
def _get_user_alert(alert_id: int, current_user: models.User, db: Session):
    """Fetch an alert that belongs to the current user's rover."""
    rover = db.query(models.Rover).filter(models.Rover.owner_id == current_user.id).first()
    if not rover:
        return None
    alert = db.query(models.Alert).filter(
        models.Alert.id == alert_id,
        models.Alert.rover_id == rover.id
    ).first()
    return alert

# Client App Endpoints

@router.get("/alerts", response_model=List[schemas.AlertOut])
def get_alerts(current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(database.get_db)):
    rover = db.query(models.Rover).filter(models.Rover.owner_id == current_user.id).first()
    if not rover:
        return []
    alerts = db.query(models.Alert).filter(models.Alert.rover_id == rover.id).order_by(models.Alert.time.desc()).all()
    return alerts

@router.post("/alerts/{alert_id}/acknowledge")
def acknowledge_alert(alert_id: int, current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(database.get_db)):
    alert = _get_user_alert(alert_id, current_user, db)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    alert.status = "Acknowledged"
    db.commit()
    return {"message": "Alert acknowledged"}

@router.post("/alerts/{alert_id}/mute")
def mute_alert(alert_id: int, current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(database.get_db)):
    alert = _get_user_alert(alert_id, current_user, db)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    return {"message": "Alert muted"}

@router.post("/alerts/{alert_id}/resolve")
def resolve_alert(alert_id: int, current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(database.get_db)):
    alert = _get_user_alert(alert_id, current_user, db)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    alert.status = "Resolved"
    db.commit()
    return {"message": "Alert resolved"}

# ESP32 Endpoint

@router.post("/alert")
def create_alert(alert_data: schemas.AlertCreate, db: Session = Depends(database.get_db)):
    rover = db.query(models.Rover).filter(models.Rover.rover_key == alert_data.rover_key).first()
    if not rover:
        raise HTTPException(status_code=404, detail="Rover not found")

    new_alert = models.Alert(
        rover_id=rover.id,
        type=alert_data.type,
        message=alert_data.message,
        status="Active",
        location="Location Unavailable"  # Mock location, could be passed from ESP32
    )
    db.add(new_alert)
    db.commit()
    db.refresh(new_alert)
    return {"message": "Alert created successfully", "alert_id": new_alert.id}
