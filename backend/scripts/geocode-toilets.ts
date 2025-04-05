import * as fs from 'fs/promises';
import { Client } from '@googlemaps/google-maps-services-js'

const client = new Client();

// Track API calls
let apiCallCount = 0;

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

interface ToiletDataWithAddress extends ToiletData {
    address: string;
}

interface ProcessingProgress {
    processedCount: number;
    totalCount: number;
    lastProcessedId: string;
    timestamp: string;
}

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

async function addAddressToToiletData(toiletData: ToiletData): Promise<ToiletDataWithAddress> {
    try {
        apiCallCount++;
        const response = await retryOperation(() =>
            client.reverseGeocode({
                params: {
                    key: process.env.GOOGLE_API_KEY || '',
                    latlng: toiletData.latlong
                }
            })
        );

        // Wait 200ms between requests to respect rate limits
        await delay(200);

        if (!response.data.results || response.data.results.length === 0) {
            throw new Error(`No address found for toilet: ${toiletData.name}`);
        }

        return {
            ...toiletData,
            address: response.data.results[0].formatted_address
        };
    } catch (error) {
        console.error(`Failed to geocode toilet ${toiletData.name}:`, error);
        // Return the original data without address in case of error
        return {
            ...toiletData,
            address: 'Address not found'
        };
    }
}

async function loadProgress(): Promise<ProcessingProgress | null> {
    try {
        const progress = await fs.readFile('./scripts/data/geocoding-progress.json', 'utf-8');
        return JSON.parse(progress);
    } catch {
        return null;
    }
}

async function saveProgress(progress: ProcessingProgress): Promise<void> {
    await fs.writeFile(
        './scripts/data/geocoding-progress.json',
        JSON.stringify(progress, null, 2)
    );
}

async function saveResults(results: ToiletDataWithAddress[], isTest: boolean = false): Promise<void> {
    const filename = isTest ? 'test-toilets-with-address' : 'toilets-with-address';
    const mainFile = `./scripts/data/${filename}.json`;
    const backupFile = `./scripts/data/${filename}.backup.json`;

    await Promise.all([
        fs.writeFile(mainFile, JSON.stringify(results, null, 2)),
        fs.writeFile(backupFile, JSON.stringify(results, null, 2))
    ]);

    console.log(`Saved ${results.length} results to ${mainFile} (with backup)`);
}

async function processToilets(isTest: boolean = false) {
    console.log(`Starting geocoding process${isTest ? ' (TEST MODE)' : ''}`);
    apiCallCount = 0;

    // Load toilet data
    const toilets = await fs.readFile('./scripts/data/processed-toilets.json', 'utf-8');
    let toiletData: ToiletData[] = JSON.parse(toilets);

    // In test mode, only process 5 toilets
    if (isTest) {
        toiletData = toiletData.slice(0, 5);
        console.log('Test mode: Processing only 5 toilets');
    }

    // Load progress if any
    const progress = await loadProgress();
    if (progress && !isTest) {
        console.log(`Resuming from toilet ${progress.processedCount} of ${progress.totalCount}`);
        toiletData = toiletData.slice(progress.processedCount);
    }

    const results: ToiletDataWithAddress[] = [];
    let processedCount = progress?.processedCount || 0;

    for (const toilet of toiletData) {
        try {
            const toiletWithAddress = await addAddressToToiletData(toilet);
            results.push(toiletWithAddress);
            processedCount++;

            // Save progress every 10 toilets
            if (processedCount % 10 === 0) {
                await saveProgress({
                    processedCount,
                    totalCount: toiletData.length,
                    lastProcessedId: toilet.placeId,
                    timestamp: new Date().toISOString()
                });
                await saveResults(results, isTest);
                console.log(`Processed ${processedCount}/${toiletData.length} toilets (API calls: ${apiCallCount})`);
            }
        } catch (error) {
            console.error(`Failed to process toilet ${toilet.name}:`, error);
            // Continue with next toilet
            continue;
        }
    }

    // Final save
    await saveResults(results, isTest);
    console.log(`Completed! Processed ${results.length} toilets`);
    console.log(`Total API calls made: ${apiCallCount}`);
    return results;
}

// // Run test mode first
// processToilets(true).then(() => {
//     console.log('Test run completed successfully!');
// });

processToilets(false).then(() => {
    console.log('Full process completed successfully!');
});
