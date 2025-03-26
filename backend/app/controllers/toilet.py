from fastapi import HTTPException
from sqlalchemy.orm import Session 

import services.toilet as toilet_services
import schemas.toilet as toilet_schemas

class ToiletController:
    def createToilet(db: Session, toilet: toilet_schemas.ToiletCreate):
        toilet = toilet_services.create_toilet(db, toilet);
        if toilet is None:
            raise HTTPException(status_code = 400, detail = "Toilet cannot be created")
        return toilet