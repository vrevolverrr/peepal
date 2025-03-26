#toilet stuff

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from db import get_db

from controllers.toilet import ToiletController ##
import schemas.toilet as toilet_schemas ##

router = APIRouter()

@router.post("/api/toilets", response_model = toilet_schemas.Toilet) 
def add_toilet(toilet: toilet_schemas.ToiletCreate, db: Session = Depends(get_db)):
    return ToiletController.createToilet(db, toilet)