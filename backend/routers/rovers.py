from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import models, schemas, auth, database

router = APIRouter(tags=["rovers"])

# Client App Endpoints

@router.get("/rover/status", response_model=schemas.RoverOut)
def get_rover_status(current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(database.get_db)):
    rover = db.query(models.Rover).filter(models.Rover.owner_id == current_user.id).first()
    if not rover:
        raise HTTPException(status_code=404, detail="Rover not found")
    return rover

@router.get("/rover/battery")
def get_rover_battery(current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(database.get_db)):
    rover = db.query(models.Rover).filter(models.Rover.owner_id == current_user.id).first()
    if not rover:
        raise HTTPException(status_code=404, detail="Rover not found")
    return {"battery": rover.battery}

@router.get("/rover/activity")
def get_rover_activity(current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(database.get_db)):
    rover = db.query(models.Rover).filter(models.Rover.owner_id == current_user.id).first()
    if not rover:
        raise HTTPException(status_code=404, detail="Rover not found")
    return {"activity": rover.activity}

# ESP32 Endpoint

@router.post("/rover/update")
def update_rover_status(update_data: schemas.RoverUpdate, db: Session = Depends(database.get_db)):
    rover = db.query(models.Rover).filter(models.Rover.rover_key == update_data.rover_key).first()
    if not rover:
        raise HTTPException(status_code=404, detail="Rover not found")
    
    rover.status = update_data.status
    rover.battery = update_data.battery
    rover.activity = update_data.activity
    db.commit()
    db.refresh(rover)
    return {"message": "Rover status updated successfully"}
