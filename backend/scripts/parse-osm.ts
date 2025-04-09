import { Client } from "@googlemaps/google-maps-services-js";
import * as fs from 'fs/promises';
import * as path from 'path';

type OsmToilet = {
  type: string;
  properties: {
    name?: string;
    amenity: string;
    toilets?: string;
    toilets_access?: string;
    toilets_disposal?: string;
    toilets_type?: string;
    wheelchair?: string;
    shower?: string;
    bidet?: string;
  };
  geometry: {
    type: string;
    coordinates: [number, number]; // [longitude, latitude]
  };
};

type GeoJsonFeatureCollection = {
  type: string;
  features: OsmToilet[];
};

type ToiletOutput = {
  placeId: string;
  status: string;
  name: string;
  rating: number;
  latlong: {
    lat: number;
    lng: number;
  };
  photoReference?: string;
  address: string;
  country: string;
  hasBidet: boolean | null;
  hasHandicap: boolean | null;
  hasShower: boolean | null;
  hasSanitiser: boolean | null;
};

type OSMGoogleOutput = {
    name: string;
  placeId: string;
  status: string | undefined;
  address: string;
  location: {
    lat: number;
    lng: number;
  };
  photoReference: string | undefined;
  rating: number;
};

async function delay(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function getPlaceDetails(lat: number, lng: number): Promise<OSMGoogleOutput> {
  const client = new Client();
  
  const { data: reverseGeocodeDetails } = await client.reverseGeocode({
    params: {
        key: process.env.GOOGLE_API_KEY || '',
        latlng: {
            lat,
            lng
        }
    }
  });

  const data = reverseGeocodeDetails.results[0];

  const { place_id, formatted_address, geometry } = data;

  const {data: placeDetailsData} = await client.placeDetails({
    params: {
      key: process.env.GOOGLE_API_KEY || '',
      place_id
    }
  });

  const placeDetails = placeDetailsData.result;
  const photoReference = placeDetails.photos?.[0]?.photo_reference;

  return {
    placeId: place_id,
    name: placeDetails.name || 'Public Toilet',
    status: placeDetails.business_status,
    address: formatted_address,
    rating: placeDetails.rating || 0.0,
    location: {
      lat: geometry.location.lat,
      lng: geometry.location.lng
    },
    photoReference
  };
}

async function main() {
  try {
    // Read the GeoJSON file
    const dataDir = path.join(__dirname, '../scripts', 'data');
    const osmData = await fs.readFile(
      path.join(dataDir, 'osm-toilets.geojson'),
      'utf-8'
    );
    const toiletFeatures = JSON.parse(osmData) as GeoJsonFeatureCollection;

    console.log(`Found ${toiletFeatures.features.length} toilets in OSM data`);

    const outputPath = path.join(dataDir, 'osm-processed-toilets.json');

    // Process each toilet
    const toiletRecords: ToiletOutput[] = []

    for (const feature of toiletFeatures.features) {
      const [lng, lat] = feature.geometry.coordinates;
      const props = feature.properties;

      // Generate a name if not provided
      const name = props.name || `Public Toilet`;

      // Create a simple address from coordinates
      const address = '';

      const placeDetails = await getPlaceDetails(lat, lng);

      toiletRecords.push({
        placeId: placeDetails.placeId,
        status: placeDetails.status || 'OPERATIONAL',
        name: placeDetails.name,
        rating: placeDetails.rating,
        latlong: placeDetails.location,
        photoReference: placeDetails.photoReference,
        address: placeDetails.address,
        country: 'Singapore',
        hasBidet: props.bidet === 'yes',
        hasHandicap: props.wheelchair === 'yes',
        hasShower: props.shower === 'yes',
        hasSanitiser: null
      })

      console.log(`Processed ${toiletRecords.length} out of ${toiletFeatures.features.length} toilets`);

      await delay(200);

      // Write to JSON file
      await fs.writeFile(outputPath, JSON.stringify(toiletRecords, null, 2));
    }

    console.log(`Successfully wrote ${toiletRecords.length} toilets to ${outputPath}`);

  } catch (error) {
    console.error('Error processing OSM data:', error);
  }
}

main().catch(console.error);
