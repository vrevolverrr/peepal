import { Client, PlacesNearbyRanking } from '@googlemaps/google-maps-services-js';
import { placePhoto } from '@googlemaps/google-maps-services-js/dist/places/photo';
import * as fs from 'fs/promises';
import * as path from 'path';

// API call tracking
let apiCalls = {
    total: 0,
    nearbySearch: 0
};

// Types
type LatLng = {
    lat: number;
    lng: number;
};

type ToiletData = {
    placeId: string;
    name: string;
    latlong: LatLng;
    address: string;
    rating?: number;
};

// Configuration
const SEARCH_RADIUS = 30000; // meters - increased for better coverage

// Predefined grid points covering Singapore
const SINGAPORE_GRID_POINTS = [
    // Central Region
    { lat: 1.3644, lng: 103.8077 }, // Central
    { lat: 1.3050, lng: 103.8200 }, // Central South
    { lat: 1.3300, lng: 103.8450 }, // Central East
    { lat: 1.3200, lng: 103.7900 }, // Central West
    { lat: 1.3800, lng: 103.8300 }, // Central North

    // North Region
    { lat: 1.4195, lng: 103.8208 }, // North Central
    { lat: 1.4300, lng: 103.7900 }, // North West
    { lat: 1.4400, lng: 103.8500 }, // North East
    { lat: 1.4180, lng: 103.7650 }, // Woodlands
    { lat: 1.4443, lng: 103.8172 }, // Sembawang

    // South Region
    { lat: 1.2967, lng: 103.8485 }, // South Central
    { lat: 1.2700, lng: 103.8200 }, // South West
    { lat: 1.2800, lng: 103.8600 }, // South East

    // East Region
    { lat: 1.3450, lng: 103.9550 }, // Bedok
    { lat: 1.3720, lng: 103.9530 }, // Tampines
    { lat: 1.3600, lng: 103.9800 }, // Changi

    // West Region
    { lat: 1.3350, lng: 103.7400 }, // West Central
    { lat: 1.3500, lng: 103.7200 }, // Tuas
    { lat: 1.3280, lng: 103.7650 }, // Jurong West

    // North-East Region
    { lat: 1.3510, lng: 103.8891 }, // Serangoon
    { lat: 1.3850, lng: 103.8930 }, // Sengkang
    { lat: 1.4050, lng: 103.9020 }, // Punggol

    // Additional Coverage Points
    { lat: 1.3263, lng: 103.9291 }, // Bedok Mall
    { lat: 1.3205, lng: 103.9070 }, // Geylang
    { lat: 1.3013, lng: 103.8848 }, // Marine Parade
    { lat: 1.3191, lng: 103.7069 }, // Pioneer
    { lat: 1.3868, lng: 103.7474 }, // Choa Chu Kang
    { lat: 1.3496, lng: 103.7636 }, // Bukit Batok
    { lat: 1.4053, lng: 103.7928 }, // Singapore Zoo
    { lat: 1.3814, lng: 103.6889 }, // CCK Cemetery
    { lat: 1.3279, lng: 103.6787 }, // Joo Koon
    { lat: 1.3148, lng: 103.6533 }, // NetCo Marine
    { lat: 1.2930, lng: 103.7941 }, // Haw Par
    { lat: 1.3680, lng: 103.8514 }, // Ang Mo Kio
    { lat: 1.3576, lng: 103.9257 }, // Tampines Ave
    { lat: 1.3320, lng: 103.9725 }  // Changi Area 2
];
const DELAY_BETWEEN_REQUESTS = 200; // milliseconds

// Initialize Google Maps client
const client = new Client({});

async function delay(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function searchToilets(location: LatLng, searchRadius: number = SEARCH_RADIUS): Promise<ToiletData[]> {
    const allResults: ToiletData[] = [];
    let pageToken: string | undefined;

    try {
        do {
            // Wait before making a new request if we have a pageToken
            if (pageToken) {
                // Places API requires a delay before using pageToken
                await delay(2000);
            }

            apiCalls.total++;
            apiCalls.nearbySearch++;
            const response = await client.placesNearby({
                params: {
                    location: location,
                    rankby: PlacesNearbyRanking.distance,
                    keyword: 'Toilet',
                    key: process.env.GOOGLE_API_KEY || '',
                    pagetoken: pageToken
                }
            });
            console.log(`API calls - Total: ${apiCalls.total}, NearbySearch: ${apiCalls.nearbySearch}`);

            if (response.data.results) {
                const results = response.data.results
                    .filter(place => place.place_id && place.name && place.geometry?.location)
                    .map(place => ({
                        status: place.business_status!,
                        placeId: place.place_id!,
                        name: place.name!,
                        latlong: {
                            lat: place.geometry!.location.lat,
                            lng: place.geometry!.location.lng
                        },
                        address: place.formatted_address || '',
                        rating: place.rating,
                        photoReference: place.photos?.[0]?.photo_reference,
                        country: 'Singapore',
                        hasBidet: false,
                        hasHandicap: true,
                        hasShower: null,
                        hasSanitiser: null
                    }));

                allResults.push(...results);
            }

            // Update pageToken for next page
            pageToken = response.data.next_page_token;

            // Log progress
            console.log(`Found ${allResults.length} toilets so far at ${location.lat}, ${location.lng}`);

        } while (pageToken);

        return allResults;
    } catch (error) {
        console.error('Error searching for toilets:', error);
        return allResults; // Return what we have even if we encounter an error
    }
}

async function main() {
    let allToilets: ToiletData[] = [];
    let processedPlaceIds = new Set<string>();
    let totalPoints = SINGAPORE_GRID_POINTS.length;
    let currentPoint = 0;

    // Create data directory if it doesn't exist
    const dataDir = path.join(__dirname, 'new');
    await fs.mkdir(dataDir, { recursive: true });

    // Try to load progress from previous run
    const progressPath = path.join(dataDir, 'progress.json');
    try {
        const progress = JSON.parse(await fs.readFile(progressPath, 'utf-8'));
        currentPoint = progress.currentPoint;
        allToilets = progress.toilets;
        processedPlaceIds = new Set(progress.processedIds);
        console.log(`Resuming from point ${currentPoint} with ${allToilets.length} toilets`);
    } catch (error) {
        console.log('Starting fresh search');
    }

    console.log(`Starting toilet search across Singapore using ${totalPoints} grid points...`);

    console.log(`Search radius: ${SEARCH_RADIUS}m`);

    try {
        // Search for toilets at each grid point
        for (const point of SINGAPORE_GRID_POINTS) {
            currentPoint++;
            console.log(`[${currentPoint}/${totalPoints}] Searching near: ${point.lat.toFixed(6)}, ${point.lng.toFixed(6)}`);
            
            const toilets = await searchToilets(point);
            console.log(`Found ${toilets.length} toilets at this point`);

            // Process each toilet
            for (const toilet of toilets) {
                if (!processedPlaceIds.has(toilet.placeId)) {
                    processedPlaceIds.add(toilet.placeId);
                    allToilets.push(toilet);
                }
            }

            // If we got close to the maximum results (60), do additional searches in the area
            if (toilets.length >= 55) {
                console.warn(`WARNING: Got ${toilets.length} results at ${point.lat.toFixed(6)}, ${point.lng.toFixed(6)}`);
                console.warn('Sampling additional points in this area...');
                
                // Generate well-distributed points within the area
                const additionalPoints: LatLng[] = [];
                const OFFSET_RANGE = 0.01; // Roughly 1km
                const MIN_DISTANCE = 0.003; // Roughly 300m minimum between points
                const MAX_ATTEMPTS = 50; // Maximum attempts to find a valid point
                
                // Helper to calculate distance between two points
                const distance = (p1: LatLng, p2: LatLng) => {
                    const dx = p1.lat - p2.lat;
                    const dy = p1.lng - p2.lng;
                    return Math.sqrt(dx * dx + dy * dy);
                };
                
                // Generate points with minimum spacing
                for (let i = 0; i < 5; i++) { // Reduced from 10 to 8 for better spacing
                    let attempts = 0;
                    let validPoint = false;
                    
                    while (!validPoint && attempts < MAX_ATTEMPTS) {
                        // Use polar coordinates for more even distribution
                        const r = OFFSET_RANGE * Math.sqrt(Math.random());
                        const theta = Math.random() * 2 * Math.PI;
                        
                        const randomLat = point.lat + r * Math.cos(theta);
                        const randomLng = point.lng + r * Math.sin(theta);
                        const newPoint = { lat: randomLat, lng: randomLng };
                        
                        // Check minimum distance from all existing points
                        validPoint = additionalPoints.every(p => distance(p, newPoint) >= MIN_DISTANCE);
                        
                        if (validPoint) {
                            additionalPoints.push(newPoint);
                            break;
                        }
                        attempts++;
                    }
                    
                    if (!validPoint) {
                        console.warn(`Could not find valid point after ${MAX_ATTEMPTS} attempts`);
                    }
                }
                
                // Search at each additional point with smaller radius
                const SAMPLED_SEARCH_RADIUS = 2000; // 2km radius for sampled points
                for (const additionalPoint of additionalPoints) {
                    console.log(`Searching additional point near: ${additionalPoint.lat.toFixed(6)}, ${additionalPoint.lng.toFixed(6)}`);
                    const additionalToilets = await searchToilets(additionalPoint, SAMPLED_SEARCH_RADIUS);
                    console.log(`Found ${additionalToilets.length} toilets at additional point`);
                    
                    // Process additional toilets
                    for (const toilet of additionalToilets) {
                        if (!processedPlaceIds.has(toilet.placeId)) {
                            processedPlaceIds.add(toilet.placeId);
                            allToilets.push(toilet);
                        }
                    }
                    
                    await delay(DELAY_BETWEEN_REQUESTS);
                }
            }

            // Save progress after each point
            const progress = {
                currentPoint,
                toilets: allToilets,
                processedIds: Array.from(processedPlaceIds)
            };
            
            await fs.writeFile(progressPath, JSON.stringify(progress, null, 2));
            console.log(`Progress saved at point ${currentPoint}/${totalPoints}`);

            await delay(DELAY_BETWEEN_REQUESTS);
        }
    } catch (error) {
        console.error('Error in main search loop:', error);
        // Save what we have so far in case of error
        const errorPath = path.join(dataDir, 'toilets-error.json');
        await fs.writeFile(errorPath, JSON.stringify(allToilets, null, 2));
        console.log(`Saved ${allToilets.length} toilets to error file`);
    } finally {
        console.log('\nFinal API call statistics:');
        console.log(`Total API calls: ${apiCalls.total}`);
        console.log(`Nearby Search calls: ${apiCalls.nearbySearch}`);
    }

    // Save results
    const outputPath = path.join(dataDir, 'all-toilets.json');
    await fs.writeFile(outputPath, JSON.stringify(allToilets, null, 2));

    console.log(`Found ${allToilets.length} unique toilets`);
    console.log(`Results saved to ${outputPath}`);
}

main().catch(console.error);