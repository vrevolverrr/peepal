from pydantic import BaseModel

class ToiletBase(BaseModel):
    name: str
    address: str
    latitude: float
    longitude: float
    toilet_avail: bool
    handicap_avail: bool
    bidet_avail: bool
    baby_changing_avail: bool
    rating: float

class ToiletCreate(ToiletBase):
    pass  # In this case, we can just inherit ToiletBase as we don't need to add anything extra for creation

class ToiletUpdate(ToiletBase):
    toilet_id: int