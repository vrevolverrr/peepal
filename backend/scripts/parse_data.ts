import * as fs from 'fs/promises';

interface ToiletData {
  region: string;
  location: string;
  address: string;
  hasHandicap: string;
  hasBidet: string;
  hasSanitizer: string;
  hasShower: string;
}

async function parseData() {
  const data = await fs.readFile('./scripts/data/data.json', 'utf-8');
  const toilets: ToiletData[] = JSON.parse(data);
  return toilets;
}

parseData().then((toilets) => {
  console.log(toilets);
});
