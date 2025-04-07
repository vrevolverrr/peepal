import * as fs from 'fs/promises';
import { Client, PlaceInputType } from '@googlemaps/google-maps-services-js';

// Track API calls
let apiCallCount = 0;

interface ToiletData {
    Region: string;
    Location: string;
    Address: string;
    Remarks?: string;
    latlong?: {
        lat: number;
        lng: number;
    };
}

interface ProcessingProgress {
    processedCount: number;
    totalCount: number;
    lastProcessedLocation: string;
    timestamp: string;
}

const client = new Client();

interface GoogleToilet {
    placeId: string;
    status: string;
    name: string;
    rating?: number;
    latlong: {
        lat: number;
        lng: number;
    };
    photoReference?: string;
    address: string;
}

async function findPlace(toilet: ToiletData): Promise<GoogleToilet | null> {
    try {
        apiCallCount++;
        
        // First find the place using the Places API
        const findResponse = await client.findPlaceFromText({
            params: {
                input: `${toilet.Location} ${toilet.Address}`,
                inputtype: PlaceInputType.textQuery,
                locationbias: `circle:1000@${toilet.latlong?.lat},${toilet.latlong?.lng}`,
                key: process.env.GOOGLE_API_KEY || '',
                fields: ['place_id']
            }
        });

        if (!findResponse.data.candidates?.[0]?.place_id) {
            return null;
        }

        const placeId = findResponse.data.candidates[0].place_id;

        // Then get the place details
        apiCallCount++;
        const detailsResponse = await client.placeDetails({
            params: {
                place_id: placeId,
                key: process.env.GOOGLE_API_KEY || '',
                fields: ['name', 'formatted_address', 'geometry', 'rating', 'business_status', 'photos']
            }
        });

        const place = detailsResponse.data.result;
        if (!place) return null;

        return {
            placeId,
            status: place.business_status || 'OPERATIONAL',
            name: place.name || toilet.Location,
            rating: place.rating,
            latlong: place.geometry?.location || toilet.latlong!,
            photoReference: place.photos?.[0]?.photo_reference,
            address: place.formatted_address || toilet.Address
        };
    } catch (error) {
        console.error(`Error finding place for ${toilet.Location}:`, error);
        return null;
    }
}

async function processToilets(isTest: boolean = false) {
    if (!process.env.GOOGLE_API_KEY) {
        throw new Error('GOOGLE_API_KEY environment variable is required');
    }

    // Load bidet toilets
    const bidetToilets: ToiletData[] = JSON.parse(
        await fs.readFile('./scripts/data/bidet-toilets.json', 'utf-8')
    );

    // Clean up the data
    bidetToilets.forEach(toilet => {
        toilet.Location = toilet.Location.trim().replace(/\r\n/g, '');
    });

    // In test mode, only process first 3 toilets
    const toiletsToProcess = isTest ? bidetToilets.slice(0, 3) : bidetToilets;
    const outputFile = isTest ? 
        './scripts/data/test-bidet-toilets-with-places.json' : 
        './scripts/data/bidet-toilets-with-places.json';

    console.log(`Processing ${toiletsToProcess.length} toilets${isTest ? ' (TEST MODE)' : ''}...`);
    const results: GoogleToilet[] = [];
    let processed = 0;

    for (const toilet of toiletsToProcess) {
        if (!toilet.latlong) {
            console.log(`Skipping ${toilet.Location} - no latlong data`);
            continue;
        }

        const placeDetails = await findPlace(toilet);
        if (placeDetails) {
            results.push(placeDetails);
            console.log(`✓ Found place details for: ${toilet.Location}`);
        } else {
            console.log(`✗ No place details found for: ${toilet.Location}`);
        }

        processed++;
        if (processed % 10 === 0) {
            console.log(`Processed ${processed}/${toiletsToProcess.length} toilets (API calls: ${apiCallCount})`);
            // Save progress in case of interruption
            await fs.writeFile(outputFile, JSON.stringify(results, null, 2));
        }

        // Add a delay to avoid hitting rate limits
        await new Promise(resolve => setTimeout(resolve, 200));
    }

    // Save final results
    await fs.writeFile(outputFile, JSON.stringify(results, null, 2));

    console.log('\nProcessing complete!');
    console.log(`Found place details for ${results.length}/${toiletsToProcess.length} toilets`);
    console.log(`Total API calls made: ${apiCallCount}`);
    return results;
}

// Run the script
processToilets().catch(error => {
    console.error('Error:', error);
    process.exit(1);
});
async function delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function retryOperation<T>(operation: () => Promise<T>, maxRetries: number = 3): Promise<T> {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            return await operation();
        } catch (error) {
            if (attempt === maxRetries) throw error;
            console.log(`Attempt ${attempt} failed, retrying after ${attempt * 2} seconds...`);
            await delay(attempt * 2000);
        }
    }
    throw new Error('Should not reach here');
}

async function loadProgress(): Promise<ProcessingProgress | null> {
    try {
        const progress = await fs.readFile('./scripts/data/bidet-progress.json', 'utf-8');
        return JSON.parse(progress);
    } catch {
        return null;
    }
}

async function saveProgress(progress: ProcessingProgress): Promise<void> {
    await fs.writeFile(
        './scripts/data/bidet-progress.json',
        JSON.stringify(progress, null, 2)
    );
}

async function saveResults(results: ToiletData[], isTest: boolean = false): Promise<void> {
    const filename = isTest ? 'test-bidet-toilets' : 'bidet-toilets';
    const mainFile = `./scripts/data/${filename}.json`;
    const backupFile = `./scripts/data/${filename}.backup.json`;

    await Promise.all([
        fs.writeFile(mainFile, JSON.stringify(results, null, 2)),
        fs.writeFile(backupFile, JSON.stringify(results, null, 2))
    ]);

    console.log(`Saved ${results.length} results to ${mainFile} (with backup)`);
}



// Run test mode first
processToilets(true).then(() => {
    console.log('Test run completed successfully!');
}).catch(error => {
    console.error('Error during test run:', error);
    process.exit(1);
});

// Uncomment to run full process:
// processToilets(false).then(() => {
//     console.log('Full process completed successfully!');
// }).catch(error => {
//     console.error('Error during full run:', error);
//     process.exit(1);
// });
