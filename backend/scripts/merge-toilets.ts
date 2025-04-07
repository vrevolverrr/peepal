import * as fs from 'fs/promises';

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

interface FullToiletData extends ToiletsWithBidet {
    hasHandicap: boolean;
    hasShower: boolean | null;
    hasSanitiser: boolean | null;
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

    for (const toilet of toilets) {
        if (toilet.address.includes("Malaysia")) {
            continue;
        }

        fullToilets.push({
            ...toilet,
            hasHandicap: true,
            hasShower: null,
            hasSanitiser: null
        });
    }

    await fs.writeFile('./scripts/data/full-toilets.json', JSON.stringify(fullToilets, null, 2));
}

async function generateSeed() {
    const toiletsData = await fs.readFile('./scripts/data/full-toilets.json', 'utf-8');
    const toilets: FullToiletData[] = JSON.parse(toiletsData);
    
    var seedFile = "";

    for (const toilet of toilets) {
        seedFile += `INSERT INTO toilets (name, address, location, handicap_avail, bidet_avail, shower_avail, sanitiser_avail, crowd_level, rating) VALUES ('${toilet.name.replaceAll("'", "''")}', '${toilet.address.replaceAll("'", "''")}', ST_SetSRID(ST_MakePoint(${toilet.latlong.lng}, ${toilet.latlong.lat}), 4326), ${toilet.hasHandicap}, ${toilet.hasBidet}, ${toilet.hasShower}, ${toilet.hasSanitiser}, 0, ${toilet.rating});\n`;
    }

    await fs.writeFile('./scripts/data/toilets.sql', seedFile);
}

// checkDataset();
generateSeed();
