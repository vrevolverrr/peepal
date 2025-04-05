import * as fs from 'fs/promises';
import { Client } from '@googlemaps/google-maps-services-js'

const client = new Client()

// Track API calls
let apiCallCount = 0;

// Define grid points across Singapore to ensure complete coverage
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

// Test points - just central Singapore
const TEST_GRID_POINTS = [
  { lat: 1.3644, lng: 103.8077 } // Central only
];

async function retryOperation<T>(operation: () => Promise<T>, maxRetries: number = 3): Promise<T> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (attempt === maxRetries) throw error;
      console.log(`Attempt ${attempt} failed, retrying after ${attempt * 2} seconds...`);
      await new Promise(resolve => setTimeout(resolve, attempt * 2000));
    }
  }
  throw new Error('Should not reach here');
}

async function fetchToiletsForLocation(location: { lat: number, lng: number }, pageToken?: string): Promise<any[]> {
  try {
    console.log(`Fetching toilets near lat: ${location.lat}, lng: ${location.lng}${pageToken ? ' with page token' : ''}`);
    
    apiCallCount++;
    const response = await retryOperation(() => 
      client.placesNearby({
        params: {
          key: process.env.GOOGLE_API_KEY || '',
          location: location,
          radius: 10000, // 10km radius (maximum allowed)
          keyword: 'Toilet',
          pagetoken: pageToken
        }
      })
    );

    // Wait 2 seconds between requests to respect rate limits
    await new Promise(resolve => setTimeout(resolve, 2000));

    const results = response.data.results;
    console.log(`Found ${results.length} results${pageToken ? ' in this page' : ''} (API call #${apiCallCount})`);

    // If there's a next page token, fetch the next page
    if (response.data.next_page_token) {
      try {
        // Need to wait a bit before using the next_page_token
        await new Promise(resolve => setTimeout(resolve, 2000));
        const nextPageResults = await fetchToiletsForLocation(location, response.data.next_page_token);
        return [...results, ...nextPageResults];
      } catch (error) {
        console.error('Error fetching next page, returning current results:', error);
        return results;
      }
    }

    return results;
  } catch (error) {
    console.error(`Error fetching toilets at location ${location.lat},${location.lng}:`, error);
    return [];
  }
}

async function loadExistingResults(): Promise<Set<string>> {
  try {
    const data = await fs.readFile('./scripts/data/google-toilets.json', 'utf-8');
    const existingResults = JSON.parse(data);
    return new Set(existingResults.map((result: any) => JSON.stringify(result)));
  } catch (error) {
    console.log('No existing results found, starting fresh');
    return new Set();
  }
}

async function saveIntermediateResults(results: Set<string>, point: { lat: number, lng: number }) {
  const uniqueResults = Array.from(results).map(result => JSON.parse(result));
  const backupFile = `./scripts/data/google-toilets.backup.json`;
  const progressFile = './scripts/data/fetch-progress.json';

  await Promise.all([
    fs.writeFile('./scripts/data/google-toilets.json', JSON.stringify(uniqueResults, null, 2)),
    fs.writeFile(backupFile, JSON.stringify(uniqueResults, null, 2)),
    fs.writeFile(progressFile, JSON.stringify({ lastProcessedPoint: point, timestamp: new Date().toISOString() }, null, 2))
  ]);

  console.log(`Saved ${uniqueResults.length} results to disk (with backup)`);  
}

async function fetchToilets(isTest: boolean = false) {
  // Reset API call counter
  apiCallCount = 0;
  
  // Load any existing results
  const allResults = await loadExistingResults();

  const points = isTest ? TEST_GRID_POINTS : SINGAPORE_GRID_POINTS;
  console.log(`Starting toilet search with ${points.length} grid points${isTest ? ' (TEST MODE)' : ''}`);
  console.log(`Starting with ${allResults.size} existing results`);

  for (const point of points) {
    try {
      const results = await fetchToiletsForLocation(point);
      
      // Add results to Set to remove duplicates (based on place_id)
      let newResults = 0;
      results.forEach(result => {
        const resultStr = JSON.stringify(result);
        if (!allResults.has(resultStr)) {
          allResults.add(resultStr);
          newResults++;
        }
      });

      console.log(`Found ${newResults} new results at this location`);
      console.log(`Total unique results so far: ${allResults.size} (Total API calls: ${apiCallCount})`);

      // Save progress after each location
      await saveIntermediateResults(allResults, point);

    } catch (error) {
      console.error(`Failed to process location ${point.lat},${point.lng}:`, error);
      // Continue with next point, we've already saved our progress
      continue;
    }
  }

  // Final save and cleanup
  const uniqueResults = Array.from(allResults).map(result => JSON.parse(result));
  console.log(`Completed! Found ${uniqueResults.length} unique toilets across Singapore`);
  console.log(`Total API calls made: ${apiCallCount}`);
  return uniqueResults;
}

// Run full search
fetchToilets(false).then(() => {
  console.log('Full search completed successfully!');
}).catch(error => {
  console.error('Search failed:', error);
  process.exit(1);
});