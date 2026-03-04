import { readFileSync, writeFileSync } from 'fs';
import { join } from 'path';

interface Asset {
  type: string;
  data?: string;
  meta: Record<string, any>;
}

interface Scene {
  id: number;
  description: string;
  assets: Asset[];
}

interface Group {
  prefix: string;
  scenes: Record<string, Scene>;
}

type Groups = Record<string, Group>;

// Map discriminator values to asset types
const DISCRIMINATOR_TO_TYPE: Record<number, string> = {
  2: 'ppu',
  3: 'bitmap',
  4: 'palette',
  5: 'tileset',
  6: 'tilemap',
  16: 'spritemap',
  17: 'music',
  19: 'branch',
  20: 'label',
  21: 'jump',
  23: 'meta17'
};

// Parse a hex string like "#$0001" or "#01" to a decimal number
function parseHex(hex: string): number {
  const cleaned = hex.replace(/[#$]/g, '');
  return parseInt(cleaned, 16);
}

// Extract the binary reference name from a string like "@binary_13597E"
function extractBinaryRef(str: string): string | null {
  const match = str.match(/@binary_([0-9A-Fa-f]+)/);
  return match ? `binary_${match[1].toUpperCase()}` : null;
}

// Parse a struct line like "ppu < #03 >" or "bitmap < #00, #10, #00, @binary_0B308E, #00 >"
function parseStructLine(line: string): { type: string; fields: string[] } | null {
  const match = line.match(/(\w+)\s*<\s*([^>]+)\s*>/);
  if (!match) return null;
  
  const type = match[1];
  const fieldsStr = match[2];
  const fields = fieldsStr.split(',').map(f => f.trim());
  
  return { type, fields };
}

// Parse a single mapdef block
function parseMapdef(lines: string[], startIndex: number): { sceneId: number; assets: Asset[] } | null {
  // Find the mapdef opening
  const firstLine = lines[startIndex];
  const idMatch = firstLine.match(/mapdef\s*<\s*#\$([0-9A-Fa-f]+)/);
  if (!idMatch) return null;
  
  const sceneId = parseInt(idMatch[1], 16);
  const assets: Asset[] = [];
  
  // Parse until we find the closing bracket
  let i = startIndex + 1;
  while (i < lines.length) {
    const line = lines[i].trim();
    
    // Check for end of mapdef
    if (line.startsWith('] >')) {
      break;
    }
    
    // Parse struct lines
    const parsed = parseStructLine(line);
    if (parsed) {
      const asset = convertToAsset(parsed.type, parsed.fields);
      if (asset) {
        assets.push(asset);
      }
    }
    
    i++;
  }
  
  return { sceneId, assets };
}

// Convert parsed struct to asset format
function convertToAsset(structType: string, fields: string[]): Asset | null {
  const asset: any = {
    type: structType
  };
  
  let meta: Record<string, any> = {};
  let data: string | undefined;
  
  switch (structType) {
    case 'ppu':
      meta.index = parseHex(fields[0]);
      break;
      
    case 'bitmap':
      data = extractBinaryRef(fields[3]) || undefined;
      meta.srcOffset = parseHex(fields[0]);
      meta.sizeW = parseHex(fields[1]);
      meta.dstOffset = parseHex(fields[2]);
      meta.isSprite = parseHex(fields[4]) === 1;
      break;
      
    case 'palette':
      data = extractBinaryRef(fields[3]) || undefined;
      meta.srcOffset = parseHex(fields[0]);
      meta.sizeW = parseHex(fields[1]);
      meta.dstOffset = parseHex(fields[2]);
      break;
      
    case 'tileset':
      data = extractBinaryRef(fields[4]) || undefined;
      meta.srcOffset = parseHex(fields[0]);
      meta.sizeW = parseHex(fields[1]);
      meta.dstOffset = parseHex(fields[2]);
      meta.layer = parseHex(fields[3]);
      break;
      
    case 'tilemap':
      data = extractBinaryRef(fields[1]) || undefined;
      meta.layer = parseHex(fields[0]);
      break;
      
    case 'spritemap':
      data = extractBinaryRef(fields[2]) || undefined;
      meta.size = parseHex(fields[0]);
      meta.dummy = parseHex(fields[1]);
      break;
      
    case 'music':
      data = extractBinaryRef(fields[2]) || undefined;
      meta.id = parseHex(fields[0]);
      meta.group = parseHex(fields[1]);
      break;
      
    case 'branch':
      meta.flag = parseHex(fields[0]);
      meta.label = parseHex(fields[1]);
      break;
      
    case 'label':
      meta.id = parseHex(fields[0]);
      break;
      
    case 'jump':
      meta.label = parseHex(fields[0]);
      break;
      
    case 'meta17':
      data = extractBinaryRef(fields[1]) || undefined;
      meta.param = parseHex(fields[0]);
      break;
      
    default:
      return null;
  }
  
  // Build asset with correct property order: type, data (if present), meta
  if (data) {
    asset.data = data;
  }
  asset.meta = meta;
  
  return asset as Asset;
}

// Find a scene by ID in the groups structure
function findSceneByIdInGroups(groups: Groups, sceneId: number): { groupKey: string; sceneKey: string; scene: Scene } | null {
  for (const [groupKey, group] of Object.entries(groups)) {
    for (const [sceneKey, scene] of Object.entries(group.scenes)) {
      if (scene.id === sceneId) {
        return { groupKey, sceneKey, scene };
      }
    }
  }
  return null;
}

// Main function
function main() {
  // Read files
  const sceneMetaPath = join(process.cwd(), 'extracted', 'system', 'scene_meta.asm');
  const usGroupsPath = join(process.cwd(), 'us', 'groups.json');
  const jpGroupsPath = join(process.cwd(), 'jp', 'groups.json');
  
  const sceneMetaContent = readFileSync(sceneMetaPath, 'utf-8');
  const usGroups: Groups = JSON.parse(readFileSync(usGroupsPath, 'utf-8'));
  
  // Create a deep copy of US groups for JP
  const jpGroups: Groups = JSON.parse(JSON.stringify(usGroups));
  
  // Parse scene_meta.asm
  const lines = sceneMetaContent.split('\n');
  const scenesData: Map<number, Asset[]> = new Map();
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line.startsWith('mapdef <')) {
      const result = parseMapdef(lines, i);
      if (result) {
        scenesData.set(result.sceneId, result.assets);
        console.log(`Parsed scene ${result.sceneId} with ${result.assets.length} assets`);
      }
    }
  }
  
  // Update JP groups with parsed assets
  let updatedCount = 0;
  let skippedCount = 0;
  
  for (const [sceneId, assets] of scenesData.entries()) {
    const found = findSceneByIdInGroups(jpGroups, sceneId);
    if (found) {
      found.scene.assets = assets;
      console.log(`Updated scene ${sceneId} (${found.groupKey}/${found.sceneKey})`);
      updatedCount++;
    } else {
      console.log(`Skipped scene ${sceneId} - not found in groups`);
      skippedCount++;
    }
  }
  
  // Custom JSON formatting: each asset on one line
  function formatGroupsJson(groups: Groups): string {
    const lines: string[] = ['{'];
    
    const groupKeys = Object.keys(groups);
    groupKeys.forEach((groupKey, gIndex) => {
      const group = groups[groupKey];
      lines.push(`  "${groupKey}": {`);
      lines.push(`    "prefix": "${group.prefix}",`);
      lines.push(`    "scenes": {`);
      
      const sceneKeys = Object.keys(group.scenes);
      sceneKeys.forEach((sceneKey, sIndex) => {
        const scene = group.scenes[sceneKey];
        lines.push(`      "${sceneKey}": {`);
        lines.push(`        "id": ${scene.id},`);
        lines.push(`        "description": "${scene.description}",`);
        lines.push(`        "assets": [`);
        
        // Each asset on one line
        scene.assets.forEach((asset, aIndex) => {
          const assetJson = JSON.stringify(asset);
          const comma = aIndex < scene.assets.length - 1 ? ',' : '';
          lines.push(`          ${assetJson}${comma}`);
        });
        
        const sceneComma = sIndex < sceneKeys.length - 1 ? ',' : '';
        lines.push(`        ]`);
        lines.push(`      }${sceneComma}`);
      });
      
      const groupComma = gIndex < groupKeys.length - 1 ? ',' : '';
      lines.push(`    }`);
      lines.push(`  }${groupComma}`);
    });
    
    lines.push('}');
    return lines.join('\n');
  }
  
  // Write the result with custom formatting
  const formattedJson = formatGroupsJson(jpGroups);
  writeFileSync(jpGroupsPath, formattedJson);
  
  console.log('\n--- Summary ---');
  console.log(`Total scenes parsed: ${scenesData.size}`);
  console.log(`Scenes updated: ${updatedCount}`);
  console.log(`Scenes skipped: ${skippedCount}`);
  console.log(`\nJP groups.json has been generated at: ${jpGroupsPath}`);
}

main();
