from sqlalchemy import Column, Integer, String, Boolean
from sqlalchemy.orm import DeclarativeBase

class Toilet(DeclarativeBase):
    __tablename__ = "toilets"

    toilet_id = Column(Integer, primary_key=True, index=True, autoincrement=True)  # AUTO_INCREMENT for MySQL
    name = Column(String)
    address = Column(String)
    latitude = Column(Float) #
    longitude = Column(Float) #
    toilet_avail = Column(Boolean)
    handicap_avail = Column(Boolean)
    bidet_avail = Column(Boolean)
    baby_changing_avail = Column(Boolean)
    rating = Column(Float) #
