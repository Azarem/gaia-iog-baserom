import 'dotenv/config';
import { PrismaClient } from '@gaialabs/core/prisma';
import { crc32_buffer, readFileAsBinary, crc32_text_utf8, readFileAsText, listDirectory } from '@gaialabs/core';
import { createId } from '@paralleldrive/cuid2';
import { db } from '../src/index.ts';
import type { DirectoryEntry } from '@gaialabs/core';
import { PrismaPg } from '@prisma/adapter-pg';

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL }),
});

const BR_PATH = './baserom';

// --- Game and Release Master Data ---
const GAME_TITLE = 'Illusion of Gaia';
const GAME_PLATFORM = 'SNES';
const RELEASE_ROM_CRC = 0x1C3848C0;
const BASE_ROM_NAME = 'GaiaLabs BaseROM';

async function main() {
  try {
        
    console.log('Starting seed process...');


    console.log('Clearing existing game data...');
      
    await prisma.projectBranchFile.deleteMany({});
    await prisma.projectBranch.deleteMany({});
    await prisma.projectFile.deleteMany({});
    await prisma.project.deleteMany({});
    await prisma.baseRomBranchFile.deleteMany({});
    await prisma.baseRomFile.deleteMany({});
    await prisma.baseRomBranch.deleteMany({});
    await prisma.baseRom.deleteMany({});
    await prisma.gameRomBranchArtifact.deleteMany({});
    await prisma.gameRomBranch.deleteMany({});
    await prisma.gameRomArtifact.deleteMany({});
    await prisma.gameRom.deleteMany({});
    // await prisma.game.deleteMany({});
    // await prisma.developer.deleteMany({});
    // await prisma.region.deleteMany({});
    // await prisma.platformBranch.deleteMany({});
    // await prisma.platform.deleteMany({});
    
    console.log('Game data cleared.');


    const game = await prisma.game.findFirst({
      where: {
        name: GAME_TITLE
      }
    });

    const region = await prisma.region.findFirst({
      where: {
        name: "US"
      }
    });

    const platformBranch = await prisma.platformBranch.findFirst({
      where: {
        platform: {
          name: GAME_PLATFORM
        },
        isActive: true
      }
    });

    const { romId, romBranchId } = await createGameRom(game!.id, region!.id, platformBranch!.id);
    const { baseRomId, baseRomBranchId } = await createBaseRom(game!.id, romId, romBranchId);

    // await createProject(gameId, baseRomId, baseRomBranchId);
    console.log('Seed process finished successfully.');
  } finally {
    await prisma.$disconnect();
  }
}

async function createGameRom(gameId: string, regionId: string, platformBranchId: string){
  console.log(`Creating Game ROM`);

  const romId = createId();
  await prisma.gameRom.create({
    data: {
      id: romId,
      gameId: gameId,
      regionId: regionId,
      crc: RELEASE_ROM_CRC,
      meta: {
        compression: 'QuintetLZ',
        sfxLocation: 327680,
        sfxCount: 60,
        sfxType: 'Striped',
        sfxPack: 'Individual',
        memoryMode: 'Hi',
        cpuMode: 'Fast',
        developerId: 0x33,
        chipset: 0x02,
        ramSize: 0x03,
        countryCode: 0x01,
        makerCode: '01',
        gameCode: 'JG',
        gameTitle: 'ILLUSION OF GAIA USA',
        gameVersion: 0
      }
    },
  });

  //Create the rom branch
  const romBranchId = createId();
  await prisma.gameRomBranch.create({
    data: {
      id: romBranchId,
      gameRomId: romId,
      platformBranchId: platformBranchId,
      name: '1.0',
      version: 1,
      isActive: true,
      notes: [],
      config: db.config as any,
      coplib: db.copdef as any,
      files: db.files as any,
      blocks: db.blocks as any,
      labels: db.labels as any,
      mnemonics: db.mnemonics as any,
      overrides: db.overrides as any,
      rewrites: db.rewrites as any,
      transforms: db.transforms as any,
      structs: db.structs as any,
      strings: db.strings as any,
      groups: db.groups as any,
      fileTypes: db.fileTypes as any
    },
  });

  return { romId: romId, romBranchId: romBranchId };
}

async function createBaseRom(gameId: string, romId: string, romBranchId: string){

  console.log('Creating baseRom');
  const baseRomId = createId();
  await prisma.baseRom.create({
    data: {
      id: baseRomId,
      name: BASE_ROM_NAME,
      gameId: gameId,
      gameRomId: romId
    },
  });

  console.log('Creating baseRomBranch');
  const baseRomBranchId = createId();
  await prisma.baseRomBranch.create({
    data: {
      id: baseRomBranchId,
      baseRomId: baseRomId,
      gameRomBranchId: romBranchId,
      name: '2.0',
      version: 1,
      isActive: true,
      notes: [],
    },
  });

  const fileIds = await createBaseRomFilesFromFolder(baseRomId);

  await prisma.baseRomBranchFile.createMany({
    data: fileIds.map(fileId => ({
      id: createId(),
      branchId: baseRomBranchId,
      fileId: fileId
    }))
  });

  return { baseRomId: baseRomId, baseRomBranchId: baseRomBranchId };
}

async function createBaseRomFile(baseRomId: string, file: DirectoryEntry) : Promise<string | null> {
  if(!file.isFile) return null;
  if(!file.extension) return null;
  
  let crc: number | undefined;
  let text: string | undefined;
  let data: Uint8Array | undefined;
  let isText: boolean = false;

  let typeEntry = Object.entries(db.fileTypes).find((value) => value[1].extension === file.extension);
  if(!typeEntry) return null;

  if(typeEntry[1].isBlock || typeEntry[1].isPatch || typeEntry[1].struct) {
    text = await readFileAsText(file.path);
    crc = crc32_text_utf8(text);
    isText = true;
  } else {
    data = await readFileAsBinary(file.path);
    crc = crc32_buffer(data);
  }

  console.log('Creating baseRomFile for ' + file.name + ' with crc ' + crc);
  const id = createId();
  await prisma.baseRomFile.create({
    data: {
      id,
      baseRomId,
      name: file.name,
      type: typeEntry[0],
      crc,
      data: data as Uint8Array<ArrayBuffer>,
      text,
      isText
    },
  });

  return id;
}


async function createBaseRomFilesFromFolder(baseRomId: string) {
  console.log('Creating baseRomFiles');

  const fileIds: string[] = [];
  const items = await listDirectory(BR_PATH, { recursive: true });

  for (const item of items) {
    if (item.isFile) {
        const id = await createBaseRomFile(baseRomId, item);
        if(id) fileIds.push(id);
    }
  }

  return fileIds;
}

main()
  .catch((e) => {
    console.error('An error occurred during the seed process:');
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  }); 

//export default main;