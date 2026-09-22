/**
 * Export IoG audio: SFX → WAV samples + SoundFont + MIDI conversion.
 *
 * Usage:  node export-audio.mjs [--wav-only] [--no-midi]
 *
 * Output (in temp/audio/):
 *   samples/sfxNN_name.wav    Raw BRR→PCM WAV files (32 kHz, round-trip safe)
 *   iog-instruments.sf2       SoundFont for MIDI playback
 *   midi/*.mid                MIDI files converted from extracted BGM
 */
import {
  SAMPLE_TABLE,
  BRR_SAMPLE_RATE,
  SF2_FILENAME,
  resolveSfxPath,
  extractBrrFromSfx,
  decodeBrr,
  pcmToWav,
  buildSoundFontFromSfxDir,
  exportSampleWavs,
  parseBgm,
  decodeBgm,
  bgmToMidi,
  countNoteEvents,
} from '@gaialabs/core';
import {
  readFileSync, writeFileSync, mkdirSync, readdirSync, existsSync,
} from 'node:fs';
import { join, basename, extname } from 'node:path';

const SFX_DIR = './extracted/sfx';
const MUSIC_DIR = './extracted/music';
const OUTPUT_DIR = './temp/audio';

const args = process.argv.slice(2);
const wavOnly = args.includes('--wav-only');
const noMidi = args.includes('--no-midi');

// ── WAV Samples ──────────────────────────────────────────────────────
// Raw BRR decode at 32 kHz — lossless, no resampling, no loop extension.
// These WAVs can be re-encoded back to identical BRR data.
const samplesDir = join(OUTPUT_DIR, 'samples');
mkdirSync(samplesDir, { recursive: true });

console.log('── WAV Samples (raw BRR decode, 32 kHz) ──');

let wavCount = 0;
for (const entry of SAMPLE_TABLE) {
  const hex = entry.id.toString(16).padStart(2, '0');
  const path = resolveSfxPath(SFX_DIR, entry.id);
  if (!path) { console.log(`  ✗ sfx${hex.toUpperCase()} (${entry.name}): not found`); continue; }

  const file = readFileSync(path);
  const brr = extractBrrFromSfx(file, entry.sampleLength);
  const { pcm } = decodeBrr(brr);

  const wav = pcmToWav(pcm, BRR_SAMPLE_RATE);

  const durMs = Math.round((pcm.length / BRR_SAMPLE_RATE) * 1000);
  const safe = entry.name.replace(/[^\w\s-]/g, '').replace(/\s+/g, '_').toLowerCase();
  writeFileSync(join(samplesDir, `sfx${hex}_${safe}.wav`), wav);
  wavCount++;

  console.log(`  ✓ sfx${hex.toUpperCase()} ${entry.name.padEnd(22)} ${pcm.length} samples, ${String(durMs).padStart(4)}ms`);
}
console.log(`  → ${wavCount} WAV files in ${samplesDir}\n`);

if (wavOnly) { console.log('Done (--wav-only).'); process.exit(0); }

// ── SoundFont ────────────────────────────────────────────────────────
console.log('── SoundFont ──');
try {
  const sf2 = buildSoundFontFromSfxDir(SFX_DIR);
  const sf2Path = join(OUTPUT_DIR, SF2_FILENAME);
  writeFileSync(sf2Path, sf2);
  console.log(`  ✓ ${sf2Path} (${(sf2.length / 1024).toFixed(1)} KB)\n`);
} catch (err) {
  console.error(`  ✗ SoundFont failed: ${err.message}\n`);
}

if (noMidi) { console.log('Done (--no-midi).'); process.exit(0); }

// ── MIDI Conversion ──────────────────────────────────────────────────
if (!existsSync(MUSIC_DIR)) {
  console.log(`── MIDI skipped (${MUSIC_DIR} not found) ──`);
  process.exit(0);
}

const midiDir = join(OUTPUT_DIR, 'midi');
mkdirSync(midiDir, { recursive: true });

const bgmFiles = readdirSync(MUSIC_DIR).filter(f => f.endsWith('.bgm')).sort();
console.log(`── MIDI Conversion (${bgmFiles.length} BGM files) ──`);

let ok = 0, fail = 0;
for (const file of bgmFiles) {
  const name = basename(file, extname(file));
  try {
    const data = readFileSync(join(MUSIC_DIR, file));
    const bgm = parseBgm(new Uint8Array(data));
    const decoded = decodeBgm(bgm, name);
    const noteCount = countNoteEvents(decoded.song);
    const midi = bgmToMidi(decoded, name);
    writeFileSync(join(midiDir, `${name}.mid`), midi);
    ok++;
    console.log(noteCount === 0 ? `  ✓ ${name}.mid (silent)` : `  ✓ ${name}.mid (${noteCount} notes)`);
  } catch (err) {
    fail++;
    console.log(`  ✗ ${name}: ${err.message}`);
  }
}

console.log(`  → ${ok} converted, ${fail} failed`);
console.log(`  → MIDI files in ${midiDir}\n`);
console.log('Done!');
console.log('');
console.log('=== HOW TO TEST ===');
console.log(`1. Open ${join(OUTPUT_DIR, SF2_FILENAME)} in Polyphone (free SF2 editor) to preview instruments`);
console.log('2. For MIDI playback with SF2 in VLC:');
console.log('   Tools → Preferences → Show All → Input/Codecs → Audio codecs → FluidSynth');
console.log(`   Set "SoundFont file" to the FULL PATH of ${SF2_FILENAME}`);
console.log('3. Or use FluidSynth CLI: fluidsynth -a dsound iog-instruments.sf2 song.mid');
