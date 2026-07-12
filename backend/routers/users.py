# pyrefly: ignore [missing-import]
from fastapi import APIRouter, Depends, HTTPException, status
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import Session
from datetime import timedelta
from .. import models, schemas, auth, database

router = APIRouter(tags=["users"])

# Mock valid rover keys in the database for validation
VALID_ROVER_KEYS = ["RV001", "RV002", "RV003", "RV004", "RV005"]

@router.post("/register", response_model=schemas.UserOut)
def register(user: schemas.UserCreate, db: Session = Depends(database.get_db)):
    if user.password != user.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")
    
    # Check if user email or phone already exists
    if db.query(models.User).filter(models.User.email == user.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    if db.query(models.User).filter(models.User.phone == user.phone).first():
        raise HTTPException(status_code=400, detail="Phone number already registered")
    
    # Check if rover key is valid and not already claimed
    if user.rover_key not in VALID_ROVER_KEYS:
        raise HTTPException(status_code=400, detail="Invalid Authentication Key")
    if db.query(models.User).filter(models.User.rover_key == user.rover_key).first():
        raise HTTPException(status_code=400, detail="Authentication Key already claimed")

    hashed_password = auth.get_password_hash(user.password)
    new_user = models.User(
        name=user.name,
        email=user.email,
        password_hash=hashed_password,
        phone=user.phone,
        rover_key=user.rover_key
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Also create the rover entry automatically
    new_rover = models.Rover(rover_key=user.rover_key, owner_id=new_user.id)
    db.add(new_rover)
    db.commit()
    
    return new_user

@router.post("/login", response_model=schemas.Token)
def login(user_credentials: schemas.UserLogin, db: Session = Depends(database.get_db)):
    user = db.query(models.User).filter(models.User.email == user_credentials.email).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid Credentials")
    
    if not auth.verify_password(user_credentials.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid Credentials")
    
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/verify-email")
def verify_email(current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(database.get_db)):
    # Mocking email verification
    current_user.email_verified = True
    db.commit()
    return {"message": "Email verified successfully"}

@router.post("/verify-phone")
def verify_phone(otp: dict, current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(database.get_db)):
    # Mocking phone verification (OTP is accepted as long as it's '1234' for this mock)
    if otp.get("code") == "1234":
        current_user.phone_verified = True
        db.commit()
        return {"message": "Phone verified successfully"}
    raise HTTPException(status_code=400, detail="Invalid OTP")

@router.post("/forgot-password")
def forgot_password(email: dict, db: Session = Depends(database.get_db)):
    # Mock forgot password flow
    user = db.query(models.User).filter(models.User.email == email.get("email")).first()
    if user:
        return {"message": "Password reset link sent to email"}
    raise HTTPException(status_code=404, detail="Email not found")

@router.get("/profile", response_model=schemas.UserOut)
def get_profile(current_user: models.User = Depends(auth.get_current_user)):
    return current_user
