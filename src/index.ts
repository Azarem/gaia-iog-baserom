import { fileURLToPath } from 'url';
import { dirname, join, resolve } from 'path';
import { existsSync, readdirSync, readFileSync } from 'fs';
import { createHash } from 'crypto';
import { DbBlock, DbFile, DbGroup, DbStringType, DbStruct, CopDef, DbFileType, AsmBlock, saveFileAsText, RomProcessingConstants, crc32_buffer } from '@gaialabs/core';
import { DbRootUtils } from '@gaialabs/core';
import type { DbAddressingMode, DbConfig, DbGameRomModule } from '@gaialabs/core';
import { snes } from '@gaialabs/core';
import { merge } from './merge.ts';
import { applyNames, checkNames } from './names-merge.ts';
import { exportLabels, exportScenes } from './export.ts';

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
import { names } from './names.ts';
import types from '../db-us/types.json' with { type: 'json' };

function loadNotesDir(subdir: string): Record<string, string> {
    const dir = join(__pkgRoot, 'notes', subdir);
    if (!existsSync(dir)) return {};

    const merged: Record<string, string> = {};
    for (const file of readdirSync(dir)) {
        if (!file.endsWith('.json')) continue;
        const data = JSON.parse(readFileSync(join(dir, file), 'utf-8'));
        Object.assign(merged, data);
    }
    return merged;
}

function loadLocalNotes(): { comments: Record<string, string>; blockNotes: Record<string, string>; partNotes: Record<string, string> } {
    const notesDir = join(__pkgRoot, 'notes');
    if (!existsSync(notesDir)) {
        return { comments: {}, blockNotes: {}, partNotes: {} };
    }
    return {
        comments: loadNotesDir('comments'),
        blockNotes: loadNotesDir('blockNotes'),
        partNotes: loadNotesDir('partNotes')
    };
}

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

const localNotes = loadLocalNotes();

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
    comments: localNotes.comments,
    blockNotes: localNotes.blockNotes,
    partNotes: localNotes.partNotes
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
    names: namesJP
};

export async function extract(romPath: string, outPath: string, options?: string[]) {
    if (!romPath) romPath = process.env.ROM_PATH;
    if(!outPath) outPath = './extracted';

    var dbRoot = DbRootUtils.fromGameModule(db);

    if(options?.includes('linetracking')) dbRoot.config.emitLineTracking = true;

    await DbRootUtils.extractAllContent(dbRoot, romPath, outPath);
}

export async function extractJP(romPath: string, outPath: string) {
    if (!romPath) romPath = process.env.ROM_PATH_JP;
    if(!outPath) outPath = './extracted-jp';

    var dbRoot = DbRootUtils.fromGameModule(jp);

    await DbRootUtils.extractAllContent(dbRoot, romPath, outPath);
}

export interface RebuildSettings {
    /** Folder for file-layout.json / master-lookup.json / crc.json (default `./artifacts`). */
    artifactsDir?: string;
    /** Build mode written to crc.json: `tagged` (extract:lt) or `plain` (extract). Detected from the extracted asm when omitted. */
    mode?: string;
}

/** `tagged` when the extracted asm carries `; {n}` line-tracking numbers (`npm run extract:lt`), `plain` when it does not, `unknown` if nothing could be read. */
export function detectBuildMode(extractedPath: string): string {
    const probeDir = join(extractedPath, 'system', 'engine');
    if (!existsSync(probeDir)) return 'unknown';
    for (const file of readdirSync(probeDir).filter(f => f.endsWith('.asm')).slice(0, 20)) {
        const text = readFileSync(join(probeDir, file), 'utf-8');
        if (/;\s*\{\d+\}/.test(text)) return 'tagged';
    }
    return 'plain';
}

export async function rebuild(inPath: string, outPath: string, baseRomPath: string, modulePaths?: string[], options?: string[], settings?: RebuildSettings) {
    if(!inPath) inPath = './extracted';
    if(!outPath) outPath = `./rebuilt/${process.env.ROM_NAME ?? 'Illusion of Gaia - Rebuilt'}.smc`;
    if(!baseRomPath) baseRomPath = join(__pkgRoot, 'baserom');
    
    var dbRoot = DbRootUtils.fromGameModule(db);

    const outData = await DbRootUtils.rebuildAllContent(dbRoot, [inPath, baseRomPath, ...(modulePaths || [])], outPath);

    const romSha1 = createHash('sha1').update(outData.romData).digest('hex');
    const mode = settings?.mode ?? detectBuildMode(inPath);
    console.log(`ROM: ${resolve(outPath)}`);
    console.log(`SHA-1: ${romSha1}`);
    console.log(`Size: ${outData.romData.length} bytes, mode: ${mode}, checksum: ${outData.header.checksum}`);
    
    if(options?.includes('artifacts')) {
        console.log('Generating artifacts...');
        const artifactPath = settings?.artifactsDir ?? './artifacts';
        let totalSize = 0;

        const fileLayoutArtifact = outData.files.filter((file) => file.size > 0).sort((a, b) => a.location - b.location).map((file) => {
            totalSize += file.size;
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
        const crcText = JSON.stringify({ checksum: outData.header.checksum, crc, totalSize, mode, sha1: romSha1 }, null, 2);
        await saveFileAsText(join(artifactPath, 'crc.json'), crcText);
    }
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

    const flags = [];
    //--key=value options keep the case of the value (paths); they are not flags.
    const values: Record<string, string> = {};
    for(let index = 0; index < args.length; index++) {
        const arg = args[index];
        const valueMatch = /^--([A-Za-z][A-Za-z0-9-]*)=(.*)$/.exec(arg);
        if(valueMatch) {
            values[valueMatch[1].toLowerCase()] = valueMatch[2];
            args.splice(index, 1);
            index--;
            continue;
        }
        if(arg.startsWith('--')) {
            flags.push(arg.slice(2).toLowerCase());
            args.splice(index, 1);
            index--;
        }
    }

    // const options = flags.reduce((acc, flag) => {
    //     acc[flag] = true;
    //     return acc;
    // }, {});

    (async () => {
        try {
            switch (command) {
                case 'extract':
                    console.log('Starting ROM extraction...');
                    console.log('ROM Path:', args[0]);
                    console.log('Output Path:', args[1] || '../extracted');
                    await extract(args[0], args[1], flags);
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
                    await rebuild(args[0], values['out'] ?? args[1], args[2], undefined, flags, {
                        artifactsDir: values['artifacts-dir'],
                        mode: values['mode'],
                    });
                    console.log('ROM rebuild completed successfully!');
                    break;
                case 'rebuild-jp':
                    console.log('Starting JP ROM rebuild...');
                    await rebuild(args[0], args[1], args[2]);
                    console.log('ROM rebuild completed successfully!');
                    break;
                case 'merge': {
                    if (args.length === 0) {
                        console.error('Usage: merge <spec.json> [--dry-run]');
                        process.exit(1);
                    }
                    const mergeResult = merge(__pkgRoot, args[0], {
                        dryRun: flags.includes('dry-run') || flags.includes('dryrun'),
                    });
                    if (!mergeResult.ok) process.exit(1);
                    break;
                }
                case 'names': {
                    if (flags.includes('check')) {
                        if (!checkNames(__pkgRoot)) process.exit(1);
                        break;
                    }
                    if (args.length === 0) {
                        console.error('Usage: names <spec.json> [--dry-run] [--local-only] | names --check');
                        process.exit(1);
                    }
                    const namesResult = applyNames(__pkgRoot, args[0], {
                        dryRun: flags.includes('dry-run') || flags.includes('dryrun'),
                        localOnly: flags.includes('local-only'),
                    });
                    if (!namesResult.ok) process.exit(1);
                    break;
                }
                case 'export': {
                    const what = args[0];
                    if (what === 'labels') {
                        const result = exportLabels(__pkgRoot, {
                            outDir: values['out-dir'],
                            masterLookupPath: values['master-lookup'],
                            rebuiltOut: values['out'],
                        });
                        console.log(`Names: ${result.names}`);
                        if (result.originalPath) console.log(`Original: ${result.original} labels -> ${result.originalPath}`);
                        console.log(`Rebuilt:  ${result.rebuilt} labels -> ${result.rebuiltPath}`);
                        if (result.unresolvedInRebuilt.length > 0) {
                            console.log(`Not in master-lookup (left out of the rebuilt file): ${result.unresolvedInRebuilt.length}`);
                            console.log('  e.g. ' + result.unresolvedInRebuilt.slice(0, 10).join(', '));
                        }
                        if (result.renamedForMesen > 0) console.log(`Names with characters Mesen2 does not accept (replaced by _): ${result.renamedForMesen}`);
                    } else if (what === 'scenes') {
                        const result = exportScenes(__pkgRoot, { out: values['out'] });
                        console.log(`Scenes: ${result.sceneCount} (${result.withFlags} with required event flags) -> ${result.path}`);
                        if (result.duplicateIds.length > 0) {
                            console.error('Duplicate scene ids: ' + result.duplicateIds.map(id => '$' + id.toString(16)).join(', '));
                            process.exit(1);
                        }
                    } else {
                        console.error('Usage: export labels [--out-dir=<dir>] | export labels --master-lookup=<file> --out=<file.mlb> | export scenes [--out=<file>]');
                        process.exit(1);
                    }
                    break;
                }
                default:
                    console.error('Unknown command:', command);
                    console.log('Available commands: extract, extract-jp, rebuild, rebuild-jp, merge, names, export');
                    process.exit(1);
            }
        } catch (error) {
            console.error('Error:', error);
            process.exit(1);
        }
    })();
}
