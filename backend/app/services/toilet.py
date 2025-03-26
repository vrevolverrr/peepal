from sqlalchemy.orm import Session
from fastapi import HTTPException
import json

import schemas.toilet as toilet_schemas
from models.toilet import Toilet

def createToilet(db: Session, toilet: toilet_schemas.ToiletCreate):
    db_toilet = Toilet (
        #id using MySQL AUTO_INCREMENT
        name = toilet.name,
        address = toilet.address,
        latitude = toilet.latitude,
        longitude = toilet.longitude,
        toilet_avail = toilet.toilet_avail,
        handicap_avail = toilet.handicap_avail,
        bidet_avail = toilet.bidet_avail,
        baby_changing_avail = toilet.baby_changing_avail,
        rating = toilet.rating,
        image_url = toilet.image_url,
        report_count = toilet.report_count
    )

    db.add(db_toilet)
    db.commit()
    db.refresh(db_toilet)

    return db_toilet