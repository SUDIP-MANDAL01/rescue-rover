# pyrefly: ignore [missing-import]
from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import relationship
# pyrefly: ignore [missing-import]
from sqlalchemy.sql import func
from .database import Base


class User(Base):
    """User model representing a registered user of the Rescue Rover system."""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), index=True)
    email = Column(String(100), unique=True, index=True)
    password_hash = Column(String(255))
    phone = Column(String(20), unique=True, index=True)
    email_verified = Column(Boolean, default=False)
    phone_verified = Column(Boolean, default=False)
    rover_key = Column(String(50), unique=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Link to rovers via owner_id only (no FK on rover_key to avoid ambiguity)
    rovers = relationship("Rover", back_populates="owner")


class Rover(Base):
    """Rover model representing a physical rescue rover device."""
    __tablename__ = "rovers"

    id = Column(Integer, primary_key=True, index=True)
    rover_key = Column(String(50), unique=True, index=True)  # Plain column, NOT a FK
    owner_id = Column(Integer, ForeignKey("users.id"))        # Single FK to users
    status = Column(String(50), default="Offline")
    battery = Column(Integer, default=0)
    activity = Column(String(50), default="Idle")
    last_seen = Column(DateTime(timezone=True), onupdate=func.now())

    owner = relationship("User", back_populates="rovers")
    alerts = relationship("Alert", back_populates="rover")


class Alert(Base):
    """Alert model for SOS and notification events from a rover."""
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, index=True)
    rover_id = Column(Integer, ForeignKey("rovers.id"))
    type = Column(String(50))
    message = Column(String(255))
    status = Column(String(50), default="Active")  # Active, Acknowledged, Resolved
    time = Column(DateTime(timezone=True), server_default=func.now())
    location = Column(String(255), nullable=True)

    rover = relationship("Rover", back_populates="alerts")
