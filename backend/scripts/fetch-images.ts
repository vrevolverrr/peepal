import { Client } from '@googlemaps/google-maps-services-js'
import fs from 'fs/promises'
import path from 'path'
import { FinalToiletData } from './merge-toilets'

const outputDir = path.join(__dirname, 'downloaded_images')

const client = new Client()

async function delay(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function fetchPlacePhotos(photoReference: string, filename: string) {
  try {

    const photoResponse: any = await client.placePhoto({
        params: {
          photoreference: photoReference,
          key: process.env.GOOGLE_MAPS_API_KEY || '',
          maxwidth: 1000
        },
        responseType: 'arraybuffer'
      })

      if (photoResponse.data) {
        const outputPath = path.join(outputDir, filename)
        await fs.writeFile(outputPath, photoResponse.data)
        console.log(`Downloaded photo: ${filename}`)
      }
      
    return photoResponse

  } catch (error) {
    console.error(`Error fetching photos for photo reference ${photoReference}:`, error)
  }
}

async function main() {
  await fs.mkdir(outputDir, { recursive: true })

// Read final-toilets.json
const toiletsData = await fs.readFile('./scripts/data/final-toilets.json', 'utf-8');
const toilets: FinalToiletData[] = JSON.parse(toiletsData);

var i = 0;

for (const toilet of toilets) {
    i++;
    console.log(`Processing toilet ${i} of ${toilets.length}`);

    if (!toilet.photoReference) {
        console.log(`No photo reference for toilet ${toilet.id}`);
        continue;
    }

  await fetchPlacePhotos(toilet.photoReference, `${toilet.id}.png`);
  await delay(100);
}
}

main().catch(console.error)
