from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str
    confirm_password: str
    phone: str
    rover_key: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

class UserOut(BaseModel):
    id: int
    name: str
    email: str
    phone: str
    rover_key: str
    email_verified: bool
    phone_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True

class RoverOut(BaseModel):
    id: int
    rover_key: str
    status: str
    battery: int
    activity: str
    last_seen: Optional[datetime] = None

    class Config:
        from_attributes = True

class RoverUpdate(BaseModel):
    rover_key: str
    status: str
    battery: int
    activity: str

class AlertCreate(BaseModel):
    rover_key: str
    type: str
    message: str

class AlertOut(BaseModel):
    id: int
    rover_id: int
    type: str
    message: str
    status: str
    time: datetime
    location: Optional[str] = None

    class Config:
        from_attributes = True
