import {nanoid } from 'nanoid';
import { Client } from '@googlemaps/google-maps-services-js';
import * as fs from 'fs/promises';
import path from 'path';

const client = new Client();

interface Toilet {
    placeId: string;
    status: string;
    name: string;
    rating: number;
    latlong: {
        lat: number;
        lng: number;
    };
    photoReference: string;
    address: string;
}

interface ToiletWithCountry extends Toilet {
    country: string;
}

interface ToiletsWithBidet extends ToiletWithCountry {
    hasBidet: boolean;
}

export interface FullToiletData extends ToiletsWithBidet {
    hasHandicap: boolean;
    hasShower: boolean | null;
    hasSanitiser: boolean | null;
}

async function delay(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function mergeToilets() {
    const bidetToiletsData = await fs.readFile('./scripts/data/bidet-toilets-with-places.json', 'utf-8');
    const bidetToilets: Toilet[] = JSON.parse(bidetToiletsData);

    const googleToiletsData = await fs.readFile('./scripts/data/toilets-with-address.json', 'utf-8');
    const googleToilets: ToiletWithCountry[] = JSON.parse(googleToiletsData);

    const mergedToilets: ToiletsWithBidet[] = [];

    for (const toilet of bidetToilets) {
        mergedToilets.push({
            ...toilet,
            country: 'Singapore',
            hasBidet: true
        });
    }

    for (const toilet of googleToilets) {
        mergedToilets.push({
            ...toilet,
            hasBidet: false
        });
    }

    await fs.writeFile('./scripts/data/merged-toilets.json', JSON.stringify(mergedToilets, null, 2));
}

async function checkDataset() {
    const toiletsData = await fs.readFile('./scripts/data/merged-toilets.json', 'utf-8');
    const toilets: ToiletsWithBidet[] = JSON.parse(toiletsData);

    const fullToilets: FullToiletData[] = [];

    const duplicates: Record<string, boolean> = {}

    var numDuplicates = 0

    for (const toilet of toilets) {
        if (toilet.address.includes("Malaysia")) {
            continue;
        }

        if (duplicates[`${toilet.name}`]) {
            numDuplicates++
            continue;
        }

        duplicates[`${toilet.name}`] = true;

        fullToilets.push({
            ...toilet,
            hasHandicap: true,
            hasShower: null,
            hasSanitiser: null
        });
    }

    console.log(`Number of duplicates: ${numDuplicates}`)
    await fs.writeFile('./scripts/data/full-toilets.json', JSON.stringify(fullToilets, null, 2));
}

export interface FinalToiletData extends FullToiletData {
    id: string;
}

async function generateSeed() {
    const imagesDir = path.join(__dirname, 'downloaded_images')
    const images = await fs.readdir(imagesDir)

    const toiletsData = await fs.readFile('./scripts/data/final-toilets.json', 'utf-8');
    const toilets: FinalToiletData[] = JSON.parse(toiletsData);
    
    var seedFile = "";

    for (const toilet of toilets) {
        if (images.includes(toilet.placeId + ".png")) {
            seedFile += `INSERT INTO toilets (id, name, address, location, handicap_avail, bidet_avail, shower_avail, sanitiser_avail, crowd_level, rating, image_token) VALUES ('${toilet.id}', '${toilet.name.replaceAll("'", "''")}', '${toilet.address.replaceAll("'", "''")}', ST_SetSRID(ST_MakePoint(${toilet.latlong.lng}, ${toilet.latlong.lat}), 4326), ${toilet.hasHandicap}, ${toilet.hasBidet}, ${toilet.hasShower}, ${toilet.hasSanitiser}, 0, ${toilet.rating || 0.00}, '${toilet.placeId}');\n`;
        } else {
            seedFile += `INSERT INTO toilets (id, name, address, location, handicap_avail, bidet_avail, shower_avail, sanitiser_avail, crowd_level, rating, image_token) VALUES ('${toilet.id}', '${toilet.name.replaceAll("'", "''")}', '${toilet.address.replaceAll("'", "''")}', ST_SetSRID(ST_MakePoint(${toilet.latlong.lng}, ${toilet.latlong.lat}), 4326), ${toilet.hasHandicap}, ${toilet.hasBidet}, ${toilet.hasShower}, ${toilet.hasSanitiser}, 0, ${toilet.rating || 0.00}, NULL);\n`;
        }
    }

    await fs.writeFile('./scripts/sql/toilets.sql', seedFile);
}

async function countDuplicates() {
    const toiletsData = await fs.readFile('./scripts/data/merged-toilets.json', 'utf-8');
    const toilets: ToiletsWithBidet[] = JSON.parse(toiletsData);

    const duplicates: Record<string, boolean> = {}
    var numDuplicates = 0

    for (const toilet of toilets) {
        if (duplicates[`${toilet.address}`]) {
            console.log(`Duplicate found: ${toilet.address}`)
            numDuplicates++
            continue;
        }

        duplicates[`${toilet.address}`] = true;
    }

    console.log(`Number of duplicates: ${numDuplicates}`)
}

async function purgeDuplicates() {
    const toiletsData = await fs.readFile('./scripts/data/full-toilets.json', 'utf-8');
    const toilets: FullToiletData[] = JSON.parse(toiletsData);

    const duplicates: Record<string, boolean> = {}
    var numDuplicates = 0

    const uniqueToilets: FullToiletData[] = []

    for (const toilet of toilets) {
        if (duplicates[`${toilet.latlong.lat}-${toilet.latlong.lng}`]) {
            console.log(`Duplicate found: ${toilet.name}`)
            numDuplicates++
            continue;
        }

        duplicates[`${toilet.latlong.lat}-${toilet.latlong.lng}`] = true;
        uniqueToilets.push(toilet);
    }

    await fs.writeFile('./scripts/data/full-no-dups-toilets.json', JSON.stringify(uniqueToilets, null, 2));
    console.log(`Number of duplicates: ${numDuplicates}`)
}

async function countToilets() {
    const toiletsData = await fs.readFile('./scripts/data/full-no-dups-toilets.json', 'utf-8');
    const toilets: FullToiletData[] = JSON.parse(toiletsData);
    console.log(`Number of toilets: ${toilets.length}`);
}

async function mergeGoogleToilets() {
    const toiletsData = await fs.readFile('./scripts/data/backup/google-toilets.json', 'utf-8')
    const toilets: any = JSON.parse(toiletsData);

    const newToiletData: FullToiletData[] = []

    /**
     *   {
    "placeId": "ChIJVVVlQI4a2jERifjCxAVJCng",
    "status": "OPERATIONAL",
    "name": "Grantral Mall @ Clementi",
    "rating": 3.6,
    "latlong": {
      "lat": 1.3142983,
      "lng": 103.7651586
    },
    "photoReference": "AeeoHcLb8MpfKab8gjvvWgdS5yzIwJG2K4ruT8ayHXmFm8MbuN_h4FeZE37tXEMGAW4twIfTFtlb-5lmO9ZQFyDx8XnswOJT-yZekp15LBhzLaVAOKcrTVXwn3TQHRAprWYDbvHKklgy-0rJRX_T0kCeWZGyZP-wlRWvErEMVkM1fpycnQHw4xUxq1Z3ayK9lL0AZChiDapY2iFedmAckJSihm_6eLhPAyYSKHy_hRqS2WtEO1ZhfwwulqbQR9dRcpvwZPQFqLJegtvrQPxE9qdKKH3-iIkal3r9dTJ1_OF8blrlFVZ9oHW1Jf1oJIbpx6c6mVJQ8hhTBEzpW4uR5-GOhg36oAm1ANAlMtEx4MJuqBkeIWiHZ3tIrNQy3DZhVbYTBGC8wzGGxWWh9zUx2X8KkrCd5u-eKVzROhIVQMlKT7AERm2oxUWNoUPRT2TwS_znohq_-yU81qKH3E9Vz0kXwg1Hm8f2nzY-fk0-t84lUXdK388TS_-mtmU0rlFE5oOrZqenbu-RtipPqWdjimfWj66_rBLsj3xTlouxJ7AcAVDddS7fdMC1uIkT-yA2OBg-BYYJfHuqYf3rZCaK84e-SrQff_SC6S7hKhMzjayISHSZgQ5B3WutXS47XSCyxaNTy_r1sg",
    "address": "3151 Commonwealth Ave W, Singapore 129581",
    "country": "Singapore",
    "hasBidet": true,
    "hasHandicap": true,
    "hasShower": null,
    "hasSanitiser": null
  },
     */
    
    for (const toilet of toilets) {
        const response = await client.reverseGeocode({
            params: {
                key: process.env.GOOGLE_API_KEY || '',
                latlng: toilet['geometry']['location']
            }
        })
    
        newToiletData.push({
            placeId: toilet['place_id'],
            status: toilet['business_status'],
            name: toilet['name'],
            address: response.data.results[0].formatted_address,
            rating: toilet['rating'],
            latlong: toilet['geometry']['location'],
            photoReference: toilet['photoReference'],
            country: 'Singapore',
            hasBidet: false,
            hasHandicap: true,
            hasShower: null,
            hasSanitiser: null
        })

        await fs.writeFile('./scripts/data/google-toilets-v2.json', JSON.stringify(newToiletData, null, 2));
        await delay(200);
    }
}

async function mergeOsmToilets() {
    const osmToiletsData = await fs.readFile('./scripts/data/osm-processed-toilets.json', 'utf-8');
    const osmToilets: FullToiletData[] = JSON.parse(osmToiletsData);

    const googleToiletsData = await fs.readFile('./scripts/data/full-no-dups-toilets.json', 'utf-8');
    const googleToilets: FullToiletData[] = JSON.parse(googleToiletsData);

    const mergedToilets: FullToiletData[] = [];

    // Merge OSM toilets if there are no duplicates with google toilets
    // criteria for duplicates is that the toilets are less than 10m away
    for (const osmToilet of osmToilets) {
        const duplicate = googleToilets.find((toilet) => {
            const distance = getDistanceBetweenPoints(osmToilet.latlong, toilet.latlong);
            console.log(distance)
            return distance < 10;
        });

        if (!duplicate) {
            mergedToilets.push(osmToilet);
        } else {
            console.log(`Duplicate found: ${osmToilet.name}`)
        }
    }

    // Merge google toilets with OSM toilets
    for (const googleToilet of googleToilets) {
        mergedToilets.push(googleToilet);
    }

    await fs.writeFile('./scripts/data/merged-osm-toilets.json', JSON.stringify(mergedToilets, null, 2));
}

async function cleanUpData() {
    const toiletsData = await fs.readFile('./scripts/data/merged-osm-toilets.json', 'utf-8');
    const toilets = JSON.parse(toiletsData);

    const uniqueToilets: FullToiletData[] = [];

    for (const toilet of toilets) {
        if (toilet.address.includes("Malaysia") || toilet.name.includes("Pte Ltd")) {
            continue;
        }

        if (toilet.name.includes("+")) {
            toilet.name = "Public Toilet";
        }

        toilet["id"] = nanoid();

        uniqueToilets.push(toilet);
    }

    await fs.writeFile('./scripts/data/final-toilets.json', JSON.stringify(uniqueToilets, null, 2));
}

// Implement getDistanceBetweenPoints using Haversine formula
function getDistanceBetweenPoints(point1: { lat: number; lng: number }, point2: { lat: number; lng: number }) {
    const R = 6371; // Earth's radius in kilometers
    const lat1 = point1.lat;
    const lng1 = point1.lng;
    const lat2 = point2.lat;
    const lng2 = point2.lng;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLng / 2) * Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c * 1000; // Distance in meters
}

async function addMissingPlaceDetails() {
    const toiletsData = await fs.readFile('./scripts/data/final-toilets.json', 'utf-8');
    const toilets: FinalToiletData[] = JSON.parse(toiletsData);

    const finalToilets: FinalToiletData[] = [];

    for (const toilet of toilets) {
        if (toilet.address === "" || toilet.photoReference == undefined) {
            const { data: placeDetailsData } = await client.placeDetails({
                params: {
                    key: process.env.GOOGLE_API_KEY || '',
                    place_id: toilet.placeId
                }
            });

            const placeDetails = placeDetailsData.result;
            const photoReference = placeDetails.photos?.[0]?.photo_reference;

            finalToilets.push({
                ...toilet,
                photoReference: photoReference || "",
                address: placeDetails.formatted_address || "",
                status: placeDetails.business_status || ""
            })
        } else {
            finalToilets.push(toilet);
        }
        console.log(`Done ${finalToilets.length} of ${toilets.length}`)
        await fs.writeFile('./scripts/data/final-toilets.json', JSON.stringify(finalToilets, null, 2));
    }
}

// countToilets()

// // countDuplicates();
// purgeDuplicates();

// // // checkDataset();
generateSeed();

// mergeGoogleToilets();

// mergeOsmToilets();

// cleanUpData();

// addMissingPlaceDetails()