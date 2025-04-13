import * as Minio from 'minio'
import fs from 'fs/promises'
import path from 'path'
import { FinalToiletData } from './merge-toilets'
import { pool } from '../src/db/db'

export const minio = new Minio.Client({
    endPoint: process.env.S3_ENDPOINT || '',
    port: 443,
    pathStyle: true,
    useSSL: true,
    region: process.env.S3_REGION || '',
    accessKey: process.env.S3_ACCESS_KEY || '',
    secretKey: process.env.S3_SECRET_KEY || '',
})

const BUCKET_NAME = process.env.S3_BUCKET || ''
const imagesDir = path.join(__dirname, 'downloaded_images')

async function uploadImage(filePath: string, objectName: string) {
    try {
        await minio.fPutObject(BUCKET_NAME, objectName, filePath, {
            'Content-Type': 'image/png'
        })
        console.log(`Successfully uploaded ${objectName}`)
    } catch (err) {
        console.error(`Error uploading ${objectName}:`, err)
    }
}

async function transformNames() {
    const images = await fs.readdir(imagesDir)

    const toilets = await fs.readFile('./scripts/data/final-toilets.json', 'utf-8')
    const toiletsData: FinalToiletData[] = JSON.parse(toilets)

     // Create a map of toilet id to place id
     const toiletsMap = new Map(toiletsData.map(toilet => [toilet.id, toilet.placeId]))

    for (const image of images) {
        if (image.startsWith(".")) {
            continue;
        }

        await fs.rename(path.join(imagesDir, image), path.join(imagesDir, toiletsMap.get(image.split('.')[0]) + ".png"))
    }
 }

async function generateSeed() {
    const images = await fs.readdir(imagesDir)

    const toilets = await fs.readFile('./scripts/data/final-toilets.json', 'utf-8')
    const toiletsData: FinalToiletData[] = JSON.parse(toilets)

    // Create a map of toilet id to place id
    const toiletsMap = new Map(toiletsData.map(toilet => [toilet.id, toilet.placeId]))

    var seedFile = "";

    const includedImages: Record<string, boolean> = {};
  
    for (const image of images) {
    if (image.startsWith(".")) {
        continue;
    }

    const token = toiletsMap.get(image.split('.')[0])
    const extension = image.split('.')[1]
    const filename = `${token}.${extension}`

    if (includedImages[filename]) {
        continue;
    }
    
    seedFile += `INSERT INTO images (token, type, user_id, filename) VALUES ('${token}', 'toilet', NULL, '${filename}');\n`;
    includedImages[filename] = true;
    }
  
    await fs.writeFile('./scripts/sql/toilet-images.sql', seedFile);
}

async function generateSeedTransformed() {
    const images = await fs.readdir(imagesDir)

    var seedFile = "";
  
    for (const image of images) {
        if (image.startsWith(".")) {
            continue;
        }

        const token = image.split('.')[0]
        const extension = image.split('.')[1]
        const filename = `${token}.${extension}`

        seedFile += `INSERT INTO images (token, type, user_id, filename) VALUES ('${token}', 'toilet', NULL, '${filename}');\n`;
    }
  
    await fs.writeFile('./scripts/sql/images.sql', seedFile);
}

async function main() {
    // Read final-toilets.json
    const toiletsData = await fs.readFile('./scripts/data/final-toilets.json', 'utf-8')
    const toilets: FinalToiletData[] = JSON.parse(toiletsData)

    // Ensure bucket exists
    const bucketExists = await minio.bucketExists(BUCKET_NAME)
    if (!bucketExists) {
        throw new Error(`Bucket ${BUCKET_NAME} does not exist`)
    }

    let i = 0
    for (const toilet of toilets) {
        i++
        console.log(`Processing toilet ${i} of ${toilets.length}`)

        const imagePath = path.join(imagesDir, `${toilet.id}.png`)
        
        try {
            await fs.access(imagePath)
            await uploadImage(imagePath, `${toilet.placeId}.png`)
        } catch (err) {
            console.log(`No image found for toilet ${toilet.id}`)
            continue
        }
    }
}

// main().catch(console.error)

// generateSeed().catch(console.error)

generateSeedTransformed().catch(console.error)