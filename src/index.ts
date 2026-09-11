import { fileURLToPath } from 'url';
import { dirname, join, resolve } from 'path';
import { DbBlock, DbFile, DbGroup, DbStringType, DbStruct, CopDef, DbFileType, AsmBlock, saveFileAsText, RomProcessingConstants, crc32_buffer } from '@gaialabs/core';
import { DbRootUtils } from '@gaialabs/core';
import type { DbAddressingMode, DbConfig, DbGameRomModule } from '@gaialabs/core';
import { snes } from '@gaialabs/core';

const __pkgRoot = join(dirname(fileURLToPath(import.meta.url)), '..');

import config from '../db-us/config.json' with { type: 'json' };
import blocks from '../db-us/blocks.json' with { type: 'json' };
import copdef from '../db-us/copdef.json' with { type: 'json' };
import files from '../db-us/files.json' with { type: 'json' };
import groups from '../db-us/groups.json' with { type: 'json' };
import labels from '../db-us/labels.json' with { type: 'json' };
import mnemonics from '../db-us/mnemonics.json' with { type: 'json' };
import overrides from '../db-us/overrides.json' with { type: 'json' };
import rewrites from '../db-us/rewrites.json' with { type: 'json' };
import strings from '../db-us/stringTypes.json' with { type: 'json' };
import structs from '../db-us/structs.json' with { type: 'json' };
import transforms from '../db-us/transforms.json' with { type: 'json' };
import fileTypes from '../db-us/fileTypes.json' with { type: 'json' };
import names from '../db-us/names.json' with { type: 'json' };
import comments0 from '../db-us/comments/comments_bank0.json' with { type: 'json' };
import comments2 from '../db-us/comments/comments_bank2.json' with { type: 'json' };
import comments3 from '../db-us/comments/comments_bank3.json' with { type: 'json' };
import blockNotes from '../db-us/blockNotes.json' with { type: 'json' };
import partNotes from '../db-us/partNotes.json' with { type: 'json' };
import types from '../db-us/types.json' with { type: 'json' };

import configJP from '../db-jp/config.json' with { type: 'json' };
import blocksJP from '../db-jp/blocks.json' with { type: 'json' };
import copdefJP from '../db-us/copdef.json' with { type: 'json' };
import filesJP from '../db-jp/files.json' with { type: 'json' };
import groupsJP from '../db-jp/groups.json' with { type: 'json' };
import labelsJP from '../db-jp/labels.json' with { type: 'json' };
import mnemonicsJP from '../db-us/mnemonics.json' with { type: 'json' };
import overridesJP from '../db-jp/overrides.json' with { type: 'json' };
import rewritesJP from '../db-jp/rewrites.json' with { type: 'json' };
import stringsJP from '../db-jp/stringTypes.json' with { type: 'json' };
import structsJP from '../db-jp/structs.json' with { type: 'json' };
import transformsJP from '../db-jp/transforms.json' with { type: 'json' };
import fileTypesJP from '../db-us/fileTypes.json' with { type: 'json' };
import namesJP from '../db-jp/names.json' with { type: 'json' };
import commentsJP from '../db-jp/comments.json' with { type: 'json' };
import blockNotesJP from '../db-jp/blockNotes.json' with { type: 'json' };
import partNotesJP from '../db-jp/partNotes.json' with { type: 'json' };

export const db : DbGameRomModule = {
    mnemonics: { ...snes.vectors, ...mnemonics },
    overrides: overrides as unknown as Record<string, Record<string, number>>,
    rewrites,
    blocks: blocks as unknown as Record<string, Record<string, Partial<DbBlock>>>,
    copdef: copdef as unknown as Record<string, Partial<CopDef>>,
    files: files as unknown as Record<string, Record<string, Record<string, Partial<DbFile>>>>,
    groups: groups as unknown as Record<string, Partial<DbGroup>>,
    labels, //: labels as unknown as Record<string, string>,
    strings: strings as unknown as Record<string, Partial<DbStringType>>,
    structs: structs as unknown as Record<string, DbStruct>,
    transforms,
    config: config as unknown as DbConfig,
    fileTypes: fileTypes as unknown as Record<string, Partial<DbFileType>>,
    addrModes: snes.addressingModes as unknown as Record<string, Partial<DbAddressingMode>>,
    headers: snes.headers,
    names,
    types,
    comments: { ...comments0, ...comments2, ...comments3 },
    blockNotes,
    partNotes
};

export const jp : DbGameRomModule = {
    mnemonics: { ...snes.vectors, ...mnemonicsJP },
    overrides: overridesJP as unknown as Record<string, Record<string, number>>,
    rewrites: rewritesJP,
    blocks: blocksJP as unknown as Record<string, Record<string, Partial<DbBlock>>>,
    copdef: copdefJP as unknown as Record<string, Partial<CopDef>>,
    files: filesJP as unknown as Record<string, Record<string, Record<string, Partial<DbFile>>>>,
    groups: groupsJP as unknown as Record<string, Partial<DbGroup>>,
    labels: labelsJP, // as unknown as Record<number, string>,
    strings: stringsJP as unknown as Record<string, Partial<DbStringType>>,
    structs: { ...structs, ...structsJP } as unknown as Record<string, DbStruct>,
    transforms: transformsJP,
    config: configJP as unknown as DbConfig,
    fileTypes: fileTypesJP as unknown as Record<string, Partial<DbFileType>>,
    addrModes: snes.addressingModes as unknown as Record<string, Partial<DbAddressingMode>>,
    headers: snes.headers,
    names: namesJP,
    comments: commentsJP,
    blockNotes: blockNotesJP,
    partNotes: partNotesJP
};

export async function extract(romPath: string, outPath: string) {
    if (!romPath) romPath = process.env.ROM_PATH;
    if(!outPath) outPath = './extracted';

    var dbRoot = DbRootUtils.fromGameModule(db);

    await DbRootUtils.extractAllContent(dbRoot, romPath, outPath);
}

export async function extractJP(romPath: string, outPath: string) {
    if (!romPath) romPath = process.env.ROM_PATH_JP;
    if(!outPath) outPath = './extracted-jp';

    var dbRoot = DbRootUtils.fromGameModule(jp);

    await DbRootUtils.extractAllContent(dbRoot, romPath, outPath);
}

export async function rebuild(inPath: string, outPath: string, baseRomPath: string, modulePaths?: string[]) {
    if(!inPath) inPath = './extracted';
    if(!outPath) outPath = `./rebuilt/${process.env.ROM_NAME ?? 'Illusion of Gaia - Rebuilt'}.smc`;
    if(!baseRomPath) baseRomPath = join(__pkgRoot, 'baserom');
    
    var dbRoot = DbRootUtils.fromGameModule(db);

    const outData = await DbRootUtils.rebuildAllContent(dbRoot, [inPath, baseRomPath, ...(modulePaths || [])], outPath);
    
    const artifactPath = './artifacts';

    const fileLayoutArtifact = outData.files.filter((file) => file.size > 0).sort((a, b) => a.location - b.location).map((file) => {
        return `  "${file.location.toString(16).toUpperCase().padStart(6, '0')}" : "${file.name}"`;
    });

    const fileLayoutArtifactText = `{${RomProcessingConstants.NEWLINE}${fileLayoutArtifact.join(',' + RomProcessingConstants.NEWLINE)}${RomProcessingConstants.NEWLINE}}`;
    await saveFileAsText(join(artifactPath, 'file-layout.json'), fileLayoutArtifactText);

    const masterArtifact = Object.entries(outData.masterLookup)
      .filter((entry) => !entry[0].match(/[!+-]$/))
      .sort((a, b) => a[1].location - b[1].location)
      .map((entry) => {
        return `  "${entry[0]}": "${entry[1].location.toString(16).toUpperCase().padStart(6, '0')}"`;
    });

    const masterArtifactText = `{${RomProcessingConstants.NEWLINE}${masterArtifact.join(',' + RomProcessingConstants.NEWLINE)}${RomProcessingConstants.NEWLINE}}`;
    await saveFileAsText(join(artifactPath, 'master-lookup.json'), masterArtifactText);

    const crc = crc32_buffer(outData.romData);
    const crcText = JSON.stringify({ checksum: outData.header.checksum, crc }, null, 2);
    await saveFileAsText(join(artifactPath, 'crc.json'), crcText);
}

export async function rebuildJp(inPath: string, outPath: string, baseRomPath: string, modulePaths?: string[]) {
    if(!inPath) inPath = './extracted-jp';
    if(!outPath) outPath = `./rebuilt-jp/${process.env.ROM_NAME_JP ?? 'Gaia Gensouki - Rebuilt'}.smc`;
    if(!baseRomPath) baseRomPath = join(__pkgRoot, 'baserom-jp');
    
    var dbRoot = DbRootUtils.fromGameModule(jp);

    await DbRootUtils.rebuildAllContent(dbRoot, [inPath, baseRomPath, ...(modulePaths || [])], outPath);
}

// CLI handler - only execute when run directly (not when imported as a module)
// Check if this module is being run directly
const isMainModule = resolve(process.argv[1] || '') === fileURLToPath(import.meta.url);

if (isMainModule) {
    const command = process.argv[2];
    const args = process.argv.slice(3);

    (async () => {
        try {
            switch (command) {
                case 'extract':
                    console.log('Starting ROM extraction...');
                    console.log('ROM Path:', args[0]);
                    console.log('Output Path:', args[1] || '../extracted');
                    await extract(args[0], args[1]);
                    console.log('ROM extraction completed successfully!');
                    break;
                case 'extract-jp':
                    console.log('Starting ROM extraction...');
                    console.log('ROM Path:', args[0]);
                    console.log('Output Path:', args[1] || '../extracted-jp');
                    await extractJP(args[0], args[1]);
                    console.log('ROM extraction completed successfully!');
                    break;
                case 'rebuild':
                    console.log('Starting ROM rebuild...');
                    await rebuild(args[0], args[1], args[2]);
                    console.log('ROM rebuild completed successfully!');
                    break;
                case 'rebuild-jp':
                    console.log('Starting JP ROM rebuild...');
                    await rebuild(args[0], args[1], args[2]);
                    console.log('ROM rebuild completed successfully!');
                    break;
                default:
                    console.error('Unknown command:', command);
                    console.log('Available commands: extractRom, rebuildRom');
                    process.exit(1);
            }
        } catch (error) {
            console.error('Error:', error);
            process.exit(1);
        }
    })();
}
