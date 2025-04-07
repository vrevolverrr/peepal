import * as fs from 'fs/promises';
import { parse } from 'csv-parse';
import { Client } from '@googlemaps/google-maps-services-js'

const client = new Client();

interface ToiletData {
    Region: string;
    Location: string;
    Remarks: string;
    Address: string;
    latlong?: {
        lat: number;
        lng: number;
    };
}

async function geocodeAddress(location: string, address: string): Promise<{ lat: number; lng: number } | undefined> {
    try {
        // Add Singapore to make the geocoding more accurate
        const searchAddress = `${address}, Singapore`;
        
        const response = await client.geocode({
            params: {
                address: searchAddress,
                key: process.env.GOOGLE_API_KEY || '',
            }
        });

        if (response.data.results && response.data.results.length > 0) {
            const result = response.data.results[0];
            return result.geometry.location;
        }
        
        return undefined;
    } catch (error) {
        console.error(`Error geocoding ${location}:`, error);
        return undefined;
    }
}

async function parseCSV(filePath: string): Promise<ToiletData[]> {
    const fileContent = await fs.readFile(filePath, 'utf-8');
    
    return new Promise((resolve, reject) => {
        parse(fileContent, {
            columns: ['Region', 'Location', 'Remarks', 'Address', ''],
            skip_empty_lines: true,
            from_line: 2 // Skip the first empty line and header
        }, (err, records: any[]) => {
            if (err) reject(err);
            
            const toilets: ToiletData[] = records
                .filter(record => record.Location && record.Location.trim()) // Skip empty locations
                .map(record => ({
                    Region: record.Region || '',
                    Location: (record.Location || '').trim().replace(/^\r?\n/, ''),
                    Remarks: record.Remarks || '',
                    Address: record.Address || ''
                }));
            
            resolve(toilets);
        });
    });
}

async function mergeToiletData() {
    const [maleToilets, femaleToilets] = await Promise.all([
        parseCSV('./scripts/data/Toilets with Bidets Singapore IG @toiletswithbidetsg - MALE TOILETS.csv'),
        parseCSV('./scripts/data/Toilets with Bidets Singapore IG @toiletswithbidetsg - FEMALE TOILETS.csv')
    ]);

    // Create a map to store unique locations
    const uniqueLocations = new Map<string, ToiletData>();
    
    // Process male toilets first
    maleToilets.forEach(toilet => {
        const key = `${toilet.Location}|${toilet.Address}`.toLowerCase();
        uniqueLocations.set(key, toilet);
    });
    
    // Process female toilets, concatenating remarks if location exists
    femaleToilets.forEach(toilet => {
        const key = `${toilet.Location}|${toilet.Address}`.toLowerCase();
        
        if (uniqueLocations.has(key)) {
            const existing = uniqueLocations.get(key)!;
            uniqueLocations.set(key, {
                ...existing,
                Remarks: existing.Remarks && toilet.Remarks && existing.Remarks !== toilet.Remarks
                    ? `${existing.Remarks}; ${toilet.Remarks}`
                    : existing.Remarks || toilet.Remarks
            });
        } else {
            uniqueLocations.set(key, toilet);
        }
    });

    const result = Array.from(uniqueLocations.values());

    // Sort by region and location
    result.sort((a, b) => {
        if (a.Region !== b.Region) return a.Region.localeCompare(b.Region);
        return a.Location.localeCompare(b.Location);
    });

    console.log('Geocoding locations...');
    let geocoded = 0;

    // Geocode addresses with a delay between requests to avoid rate limits
    for (const toilet of result) {
        const latlong = await geocodeAddress(toilet.Location, toilet.Address);
        if (latlong) {
            toilet.latlong = latlong;
            geocoded++;
            if (geocoded % 10 === 0) {
                console.log(`Geocoded ${geocoded}/${result.length} locations`);
            }
        }
        // Add a small delay between requests
        await new Promise(resolve => setTimeout(resolve, 200));
    }

    // Save to JSON file
    await fs.writeFile(
        './scripts/data/bidet-toilets.json',
        JSON.stringify(result, null, 2)
    );

    console.log('\nData Summary:');
    console.log(`Total unique locations: ${result.length}`);
    console.log(`Successfully geocoded: ${geocoded}`);
    console.log(`Male entries: ${maleToilets.length}`);
    console.log(`Female entries: ${femaleToilets.length}`);
}

// Run the script
mergeToiletData().catch(error => {
    console.error('Error:', error);
    process.exit(1);
});
