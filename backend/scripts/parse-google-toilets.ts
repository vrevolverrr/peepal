import * as fs from 'fs/promises';

interface GoogleToiletData {
  business_status: string;
  geometry: {
    location: {
      lat: number;
      lng: number;
    };
    viewport: {
      northeast: {
        lat: number;
        lng: number;
      };
      southwest: {
        lat: number;
        lng: number;
      };
    };
  };

  name: string;
  opening_hours: {
    open_now: boolean;
  };

  photos: {
    height: number;
    html_attributions: string[];
    photo_reference: string;
    width: number;
  }[];
  place_id: string;
  plus_code: {
    compound_code: string;
    global_code: string;
  };
  rating: number;
  reference: string;
  scope: string;
  types: string[];
  user_ratings_total: number;
  vicinity: string;
}

interface ToiletData {
  placeId: string;
  status: string;
  name: string;
  rating: number;
  latlong: {
    lat: number;
    lng: number;
  };
  photoReference: string;
  country: string;
}

function convertGoogleToiletDataToToiletData(googleToiletData: GoogleToiletData): ToiletData {
  return {
    placeId: googleToiletData.place_id,
    status: googleToiletData.business_status,
    name: googleToiletData.name,
    rating: googleToiletData.rating,
    latlong: googleToiletData.geometry.location,
    photoReference: (googleToiletData.photos && googleToiletData.photos.length > 0) ? googleToiletData.photos[0].photo_reference : '',
    country: 'Singapore'
  };
}

async function processGoogleToilets() {
  const googleToilets = await fs.readFile('./scripts/data/google-toilets.json', 'utf-8');
  const toilets = JSON.parse(googleToilets);
  const toiletData = toilets.map(convertGoogleToiletDataToToiletData);
  await fs.writeFile('./scripts/data/processed-toilets.json', JSON.stringify(toiletData, null, 2));
}

processGoogleToilets();