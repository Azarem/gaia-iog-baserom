# A15 findings: tooling backlog (specs only)

Step A15 of the audit of the audit. Analysis and specs only: nothing in `src/`, `gaia-core/`, `db-us/`, `notes/`, `extracted/` or `baserom/` was changed. Every change below needs your explicit go-ahead. No names or notes were changed, so no rebuild gate was run (the gate is only required after a step that changes names or notes).

Evidence is static (E1 code trace, E2 cross-reference). There is no Mesen2 ROM or state, so no runtime claim is made. Tags: VERIFIED = checked in the live files in this session (file:line); REPORTED = taken from a ledger or an earlier A-step and not re-checked.

---

## 1. Scope and files read

Plan and report: `PLAN.md` (A15 row, T01-T03 prompts), `report.md` §6 (G-1..G-9), §11 (AP-01, AP-12, AP-14..AP-18, AP-23).
Companion findings: `A08_findings.md` §2.3, `A09_findings.md` (A09-01..06), `A10_findings.md` (§3.2, F10), `A11_findings.md` (AP17-01/02), `A05_findings.md` (D-S5160-2, `loc_03B928`), `A02_findings.md` (A02-08).
Ledgers (frozen, read only): `questions/I056_questions.md` (OQ-I056-9), `results/I056_results.md:63`, `results/I069_results.md:61`, `results/I071_results.md:69`, `results/I001-I020_results.md:659`.
Tooling: `src/merge.ts`, `src/notes-common.ts`, `src/names-merge.ts` (`checkNames` :87, scope :30 and :309), `src/names.ts`, `src/index.ts`, `package.json` scripts, `db-us/transforms.json`, `db-us/structs.json`, `db-us/blocks.json` (entries cited below).
`gaia-core`: `src/rom/extraction/parser.ts` (`parseType`), `blocks.ts` (`processPart`, `processContinuousEntry`, `partCanContinue`, struct-file pass), `writer.ts` (transform loop, part-note lookup), `database/structs.ts`, `database/root.ts` (`applyFolder`, `rebuildAllContent`), `rom/rebuild/processor.ts` (`repack`, `applyPatches`), `utils/file.ts` (`listDirectory`), `package.json`.
Extracted files used as evidence: `mansion/solid_arm_lair/sEA_solid_arm.asm`, `pyramid/mummy_queen_lair/pyDD_teleporter.asm`, `pyramid/pyramid_vader_b/pyD7_sliding_wall.asm`, `system/diary_menu/sFA_diary_menu.asm`, `system/diary_menu/diary_menu_window_dma.asm`, `system/inventory/item_use_system.asm`, `system/engine/cop_handlers_*.asm`, `mountain_temple/mtA0_skulker.asm`, `tables/spriteset_will_abilities.asm`, `tables/scene_meta.asm`, `baserom/auto-use-items/CrystalBallAutoUse.patch.asm`, `extracted/sky_garden/garden_main/sg4C_platforms.asm`.

How the transform pipeline works (VERIFIED, `gaia-core/src/rom/extraction/writer.ts:150-158`): the whole block text is generated first (part notes before their label, `; {n}` tags and comments at line ends, `writer.ts:388-393`, `:481-483`), then every rule of the block runs as `content.replace(new RegExp(key, 'g'), value)`. So a rule sees notes, separators, comments and tags. The part-note lookup key is the engine label before transforms (`writer.ts:388`, `:432`). `merge` and `--check` only see the text after transforms.

---

## 2. Findings

| ID | Tag | File:line | What is wrong | Proposed fix | Class |
|---|---|---|---|---|---|
| A15-01 | VERIFIED | `db-us/transforms.json:4, 142-143, 517-520, 532-533, 761` | Ten rules in five blocks only match when no `; {n}` tag follows the line ends (§2.1). In the tagged build they never fire; in the plain build they do. This explains the whole 15-byte difference (-4 -33 +6 +16 = -15). | T01: make them tag-tolerant (§2.1 gives each form). | 12 |
| A15-02 | VERIFIED | `PLAN.md:307` (T01 prompt) | The T01 acceptance line says both builds must give 3062204 / 223006080 / 2083230829. That cannot happen: a tolerant rule makes the **tagged** build apply the edits, so both builds converge on the **plain** numbers (REPORTED I026: 3,062,189, checksum 222967024, crc -1004081563). The recorded gate moves once. | Change the T01 acceptance before running it (§3.1 item 1). | 12 |
| A15-03 | VERIFIED | `sFA_diary_menu.asm:429-430, 442-443, 458-459, 869-870, 885-886, 1094-1095, 1420-1421`; `item_use_system.asm:388-389, 463-464` | Besides the size, the two builds differ in content: 7 `LDA #imm / TSB $joypadHeld` sites in the diary menu keep `#$0380` / `#$8000` in the tagged build (plain gives `#$8300` / `#$4000`, rules `:517-518`), and the two Inca statue `BNE` become `BEQ` only in plain (`:532-533`). The `item_use_system` block note (`:37`) says these edits "repair vanilla quirks", so plain is the intended product. | Decide the product mode (AP-01); T01 then makes the other mode equal. Runtime effect not observed (static only). | 12 |
| A15-04 | VERIFIED | `transforms.json:4, 142-143, 517-520, 532-533, 761` | A comment on any line inside one of those spans breaks the match in the plain build, and the tagged gate cannot see it (§2.2 lists the addresses). | Until T01: do not add comments at those addresses. After T01 the guard (§2.2) is only needed for label-spanning rules. | 12 |
| A15-05 | VERIFIED | `transforms.json:181`; `diary_menu_window_dma.asm:8, 144, 150` | The swap rule needs `diary_band_empty` and `diary_band_slot1` adjacent. A part note on `diary_band_slot1` stops the match (ROM changes by one byte, REPORTED I057). A part note on `diary_band_empty` does not stop the match but ends up above the swapped block (misplaced). No notes exist on either today (`rg` over `notes/` finds none). | Guard both labels (§2.2); optional tolerant form in §2.1 R5. | 12 |
| A15-06 | VERIFIED | `transforms.json:18-84` (keys at 18, 24, 30, 36, 42, 48, 54, 60, 66, 72, 78, 84); `blocks.json:4-53`; `cop_handlers_script_control.asm:43-45` | Of the 12 `cop_handlers_*` / `actor_pool` rules: 4 are active (`sprite`, `player_sprite`, `movement`, `effects`: 18 `LDA $0A / STA $00 / STA $02,S` triples in the extracted text), 4 name blocks that no longer exist (`lifecycle`, `solid`, `spatial`, `map`: `blocks.json` has no such key), 4 are inert (`audio`, `palette`, `spawn`, `actor_pool`: the block exists, zero triples). `cop_handlers_script_control` has the same triple (`:43-45`) but no rule. Whether that is intended is not shown by any file I read. | User-owned `transforms.json`: list for T01. Remove or keep is your decision; the guard (§2.2) ignores dead keys. | 12 |
| A15-07 | VERIFIED | `transforms.json:761`; `pyD7_sliding_wall.asm:77-80, 87-90` | The sliding-wall rule is `$1$1` (the whole span twice). A tolerant version that keeps the tail group would also duplicate the `; {n}` tags, so 8 comment keys become ambiguous (`merge` error "tag appears on 2 lines", `merge.ts:373`). | Tolerant form with an untagged second copy (§2.1 R4). | 12 |
| A15-08 | VERIFIED | `merge.ts:387-391` | The only transform awareness in `merge` is a warning when a comment **text** matches a transform key. Nothing checks where a note lands relative to a multi-line rule. | Guard (§2.2). | 12 |
| A15-09 | VERIFIED | `merge.ts:247, 317, 368`; `index.ts:231-233` | `merge` cannot remove an orphan (a comment key needs its tag, a block-note key needs its `.asm`, a part-note key needs its label, even for `null`), and `merge` with no spec prints usage, so a `--check` needs a `src/` change. | `merge --check` and an orphan prune path (§2.3). | 14 (proposed) |
| A15-10 | REPORTED + VERIFIED (one key) | `notes/comments/bank00.json:1791` (key 47052); `blocks.json:293` | Orphans found so far: 53 comment keys in bank00 (A09-01..03) + 27 in bank02 (A10-11/11b) = 80, 6 block-note keys in bank00 (A09-04) + 1 in bank02, 2 part-note keys in bank1E (A10). Banks 04-0F were only sampled. 47052 is the first byte of the `thinker-def` header of `oneshot_palette_flash_18` (`blocks.json:293`: start 47052), where the extractor prints no instruction and so no tag. | Prune after a per-key read (F07 / F10) using §2.3. | 14 |
| A15-11 | VERIFIED | `notes/blockNotes/bank09.json:23`, `notes/blockNotes/bank13.json:3`; `blocks.json:696` | New: block note `CreditPositionLookup` exists in two bank files (same text). The block starts at 649444 = bank 09. `index.ts:29-40` loads all files with `Object.assign` (alphabetical, last wins), so the engine does not notice; `merge` (`NoteStore.index`, first file wins) would update bank09 only and leave bank13 stale. Found by chance, not by a sweep. | `--check` rule "a key lives in exactly one bank file, and in the bank the file resolves to" (§2.3). Removing the bank13 copy is a notes edit (`merge` can do it: the label file exists). | 14 |
| A15-12 | VERIFIED | `notes-common.ts:101-151` | `detectBank` has six strategies. S1 trusts `?BANK` without comparing it with `blocks.json`. S3 takes the first line with `code_XXXXXX` / `loc_XXXXXX` anywhere in the file, including an operand that points into another bank (for example `@code_05F522` in `sg4C_platforms.asm:15`). S4 takes the first `; {n}` tag. Block notes keep an existing bank silently (`merge.ts:303`), part notes warn (`merge.ts:345-348`), comments use the address (`merge.ts:404`). | `--check` bank rules (§2.3, AP-15 "one regression case per rule"). | 14 |
| A15-13 | VERIFIED | `parser.ts:123-210`; `blocks.ts:325-333, 352-356`; `structs.json:13-15` | AP-12 root cause confirmed: `sprite-group`'s last member `sprite-part` is parsed by a loop with no delimiter, bounded only by the part end or the next known struct start (`partCanContinue`, `blocks.ts:259-261`). The 13th header byte (the row count) is read as a `Byte` and ignored. A group with no reference to it is swallowed as extra rows. | Design note §2.4. | 8 |
| A15-14 | VERIFIED | `gaia-core/package.json`; `gaia-iog-baserom/package-lock.json:34-37` | `gaia-core` has no test files and no `test` script (`Glob` for `*.test.ts` and `test*/` finds none; scripts only `build`). T02's "add a test, run the gaia-core tests" cannot be done as written. The baserom uses `@gaialabs/core` through a link to `../gaia-core` and its `dist/` (`exports` -> `dist/index.mjs`), so a `src/` change in `gaia-core` takes effect only after `npm run build` (tsdown) there. The baserom lock records 1.0.5, `gaia-core` is 1.0.6. | T02 must include the build step and use a baserom-side check instead of a unit test, unless you approve adding test tooling. | - |
| A15-15 | VERIFIED + REPORTED | `package.json:26-27` | `extract` and `extract:lt` start with `rm -rf extracted/* && node ...`. Failures: REPORTED in I011/I012 (`extracted/system/engine`), I069 and I071 (`extracted/tables`), I072. Analysis and spec in §2.5. | T04 (new): stale-file sweep instead of directory delete, plus a completeness marker. | - |
| A15-16 | VERIFIED + REPORTED | `processor.ts:98-116, 167`; `file.ts:257`; `CrystalBallAutoUse.patch.asm:5` | OQ-I056-9: the error text is produced when a patch override label is missing from the labels of the files read from `extracted/` + `baserom/`. A fully absent `extracted/` gives a different message (`Directory not found`), so the tree existed but was incomplete or differed. Hypotheses and the evidence that settles each: §2.6. | T04; user repro in §2.6. | - |
| A15-17 | VERIFIED + REPORTED | `index.ts:133-168`; `processor.ts:92-116` | `rebuild` accepts an incomplete tree when no patch override hits a missing label and then writes `artifacts/crc.json` (`index.ts:167`). This is how I058 (REPORTED) ended with a bad checksum. | Completeness marker (§2.5). | - |
| A15-18 | VERIFIED | `src/index.ts:226-229` | Side finding: `rebuild-jp` calls `rebuild(...)` (the US paths), not `rebuildJp(...)`. | One-line fix in T03 or T04 if you want it; not part of the audit. | - |
| A15-19 | VERIFIED | `names-merge.ts:30, 309` | `names` rewrites references in `baserom/`, `db-us/` and `docs/`. So a rename of `code_05F522` through `npm run names` would also fix `CrystalBallAutoUse.patch.asm`. This lowers H2 in §2.6. | None. | - |
| A15-20 | VERIFIED | `item_use_system.asm:37, 368, 389, 450, 464` | These five notes describe the plain-versus-tagged difference ("extract:lt text still shows BNE ... OQ-I026-1") and become false when T01 makes the rules tolerant. Also `sEA_solid_arm`, `sFA_diary_menu`, `pyDD_teleporter`, `pyD7_sliding_wall` notes should be searched for the same wording. | An F-step `merge` spec after T01 (F11, new). | 3 |
| A15-21 | REPORTED | `gaia-core/docs/notes-and-comments.md:599-700` (A11 AP17-01) | The doc carries two embedded Python scripts for the orphan check and the reference scan, against the no-scripts rule. There is no tool for doc edits (G-4). | T03 doc work: replace by a pointer to `merge --check` and `names`; policy for docs: F05 style manual `StrReplace`, no new tool unless you ask for one. | - |
| A15-22 | VERIFIED | `transforms.json:117-119`; `merge.ts:312-319` | A label-rename rule (`mtA0_skulker`: `sub_0B9CE8` -> `sub2_0B9CE8`, `loc_0B9CF9`, `loc_0B9D0E`) means the extracted file shows the new name but the engine looks the part note up under the old name. `merge` validates against the visible name, so a note written for `sub2_0B9CE8` would be accepted and never rendered. No such note exists today (`rg` finds no key with these labels in `notes/`). | Alias translation in `merge` and the check (§2.2). | 12 |

### 2.1 G-1: multi-line regex inventory and tolerant forms

Method: the key text of every rule in `db-us/transforms.json` (about 210 block keys) was checked for `\s`, `\r`, `\n` with `rg`. Result: 169 rules contain `joypadMaskStd` (already tag-tolerant: `LDA #\$XFF0([^\r\n]*\s+T[SR]B \$joypadMaskStd)`), 6 rules contain `joypadHeld` (4 tolerant: `:196, :198, :199, :489`; 2 intolerant: `:517-518`), and the rules in the table. The check "tolerant" means: does the key still match when the tag and comment tail of each line is present. `[^\r\n]*` before `\s+` is the tolerance used by the existing family; `(;[^\r\n]+)?` is the one used by `cop_handlers_*`.

How I tested sites (VERIFIED): in the tagged extracted text the intolerant rules have **not** fired, so their key text is still there. `rg -U` with the key and an end-of-line tail (`[^\r\n]*\r?\n\s+`) finds the sites below. Tagged addresses come from the `; {n}` values.

| Rule | Block | Lines in transforms.json | Spans | Tolerant today? | Sites in extracted text | Plain-build effect (tag arithmetic) |
|---|---|---|---|---|---|---|
| R1 | `sEA_solid_arm` | 4 | `WaitByte(#d7)` / `FadeThenStartMusic(#1B)` / `WaitByte(#B3)`, 3 lines, no label | no | `sEA_solid_arm.asm:55-57` (tags 587588..587594), `:350-352` (588300..588306) | 9 bytes become 7: -2 per site, **-4** |
| R2 | `sEA_solid_arm` | 7 | `LDA #$EFF0 ... T[SR]B $joypadMaskStd` | yes | - | none |
| R3 | `pyDD_teleporter` | 142 and 143 | `LDA $00` + `PHA`, and `PLA` + `STA $00` | no | `pyDD_teleporter.asm:144-145` (765644, 765646), `:150-151` (765658, 765659) | adds `LDA $02 / PHA` and `PLA / STA $02`: 3 + 3 = **+6** |
| R4 | `pyD7_sliding_wall` | 761 | `DEC|INC` / `STA $0026,Y` / `DEC $26` / `BEQ x`, 4 lines, duplicated (`$1$1`) | no | `pyD7_sliding_wall.asm:77-80` (574811..574817), `:87-90` (574828..574834) | span is 1+3+2+2 = 8 bytes, twice: **+16** |
| R5 | `diary_menu_window_dma` | 181 | label `diary_band_empty [ ]` then label `diary_band_slot1 [ ... ]`; swaps them | tag-neutral (data lines carry no tags); spans two labels | `diary_menu_window_dma.asm:144, 150` | 0 bytes when it fires; breaks when a part note sits between the labels |
| R6 | `scene_meta` | 175 | `scene_meta_0041 [` + first row `display-mode < #00 >` | yes (data) | `scene_meta.asm:1054` | none |
| R7 | `sFA_diary_menu` | 517, 518 | `LDA #$8000` / `LDA #$0380` + `TSB $joypadHeld` | **no** (`(\s+TSB ...)` right after the immediate) | 7 sites, `sFA_diary_menu.asm:429, 442, 458, 869, 885` (`#$0380`), `:1094, :1420` (`#$8000`) | 0 bytes, **content differs** (A15-03) |
| R8 | `sFA_diary_menu` | 519 | `LDA #$8000 / STA $remapB / LDA #$4000 / STA $remapY` removed | no | `:1422-1425` (781138..781147), `:1433-1436` (781153..781162) | 12 bytes per site, **-24** |
| R9 | `sFA_diary_menu` | 520 | `LDA #$4000 / STA $remapB / STZ $remapY` removed | no | `:1401-1403` (781111..781117) | 9 bytes, **-9** |
| R10 | `item_use_system` | 532, 533 | `CMP #$0027` + `BNE loc_0386FA`; `CMP #$0038` + `BNE loc_03880D` | no (`[\s]+`) | `item_use_system.asm:388-389`, `:463-464` | 0 bytes, `BNE` -> `BEQ`, **content differs** |
| R11 | `cop_handlers_{sprite, player_sprite, movement, effects}` | 30, 36, 66, 84 | `LDA $0A` / `STA $00` / `STA $02,S` with the lookbehind | yes (`(;[^\r\n]+)?`) | 18 triples | none |
| R12 | `joypadMaskStd` family | 169 rules | `LDA #imm` tail + `T[SR]B $joypadMaskStd` | yes | - | none |

Sum: R1 -4, R3 +6, R4 +16, R8 -24, R9 -9 = **-15** (VERIFIED: matches 3,062,204 - 3,062,189). R7, R10 and R5 do not change the size. This closes the "-15" question of G-1 and OQ-I026-1/OQ-49 for the size; whether the **content** differences change behaviour at run time is not shown.

Tolerant forms (design, **not run**; each must be gated, §3). Capture groups turn `$01` in a value into a group reference, so every literal `$` in a value must be written `$$` (this matters for R1: `#$0120` becomes `#$$0120`).

- R1: key `COP \[WaitByte\] \( #\d7 \)[^\r\n]*\s+COP \[FadeThenStartMusic\] \( #1B \)([^\r\n]*)\s+COP \[WaitByte\] \( #B3 \)`; value `COP [FadeThenStartMusic] ( #1B )$1\r\n    COP [WaitWord] ( #$$0120 )`. The Fade line keeps its tag; the removed WaitByte lines lose theirs.
- R3a: key `(LDA \$00[^\r\n]*\s+PHA[^\r\n]*)`; value `$1\r\n    LDA $$02\r\n    PHA`. R3b: key `(PLA[^\r\n]*\s+STA \$00[^\r\n]*)`; value `PLA\r\n    STA $$02\r\n    $1`. The inserted lines are untagged and the original lines keep their tags. Note (VERIFIED by reading): `STA \$00` also prefixes `STA $0012`; keep the existing behaviour so the bytes stay identical.
- R4: key `(DEC|INC)([^\r\n]*)\s+(STA \$0026, Y)([^\r\n]*)\s+(DEC \$26)([^\r\n]*)\s+(BEQ \S+)([^\r\n]*)\s+`; value `$1$2\r\n    $3$4\r\n    $5$6\r\n    $7$8\r\n    $1\r\n    $3\r\n    $5\r\n    $7\r\n    `. The second copy has no tags (A15-07).
- R5 (optional): key `(diary_band_empty\s\[\s*\])((?:\s|-{5,}|;[^\r\n]*)*)(diary_band_slot1\s\[[^\]]*\])`; value `$2$3\r\n\r\n$1`. This lets a note on `diary_band_slot1` through (it stays above its label) but a note on `diary_band_empty` still lands above the swapped block, so the guard keeps that label. Why the swap exists, and why an unmatched swap loses a byte, I could not establish from the files (the table text says a table is `3n + 1` bytes and an empty table is a lone terminator). That is a question for the T01 decision, not an answer here.
- R7: key `LDA #\$8000([^\r\n]*\s+TSB \$joypadHeld)` and `LDA #\$0380([^\r\n]*\s+TSB \$joypadHeld)` (same form as `:196`).
- R8: key `\s+LDA #\$8000[^\r\n]*\s+STA \$remapB[^\r\n]*\s+LDA #\$4000[^\r\n]*\s+STA \$remapY[^\r\n]*`; value empty. R9: key `\s+LDA #\$4000[^\r\n]*\s+STA \$remapB[^\r\n]*\s+STZ \$remapY[^\r\n]*`; value empty.
- R10: keys `(CMP #\$0027[^\r\n]*\s+)BNE loc_0386FA` and `(CMP #\$0038[^\r\n]*\s+)BNE loc_03880D`; values unchanged (`$1BEQ ...`).

### 2.2 G-6: where notes are forbidden today, and the merge guard

Forbidden today (plain build only, until T01; tagged addresses from the extracted files):

| Rule | Part-note labels | Comment keys that must stay empty |
|---|---|---|
| R1 | none (3 instruction lines) | 587588, 587591 (break the match), 588300, 588303; the last line of each span (587594, 588306) is safe |
| R3 | none | 765644 (LDA), 765658 (PLA) |
| R4 | none | 574811, 574812, 574815, 574817, 574828, 574829, 574832, 574834 (the BEQ line too: its comment would be duplicated or misplaced) |
| R5 | `diary_band_slot1` (breaks), `diary_band_empty` (misplaces) | none (data has no tags) |
| R7 | none | 779416, 779452, 779486, 780227, 780261, 780605, 781132 |
| R8 | none | 781138, 781141, 781144, 781147, 781153, 781156, 781159, 781162 (the last line too: its comment would stay behind as an empty line) |
| R9 | none | 781111, 781114, 781117 |
| R10 | none | 231157 (CMP #$0027), 231432 (CMP #$0038) |
| R6, R11, R12 | none (the optional tail group takes comments; no label is spanned) | none |

Today none of these addresses carries a comment (VERIFIED by the printed lines in the sites above), and neither R5 label has a note.

Guard spec (T03; `src/merge.ts`, no transform change). Inputs: the spec, the extracted file text, `db-us/transforms.json`. Algorithm for each file in the spec, using `baseName` as the block name (same as the block-note key):

1. Take the rules of that block. A rule is multi-line if its key contains `\s`, `\r`, `\n` or `[\s]`. Dead keys (block not in `blocks.json`/`files.json`) are ignored.
2. Build a "tail-free view" of the extracted text: each line with `\s*;.*$` removed, same line count. Run each multi-line key (flag `g`) over the joined view. For a rule that has not fired (the plain-only class) every match is a span `[first line, last line]`. Collect (a) the `{n}` tags on the span lines as guarded comment keys, (b) every label defined on a span line after the first as a guarded part-note label.
3. Labels named in a key with definition syntax (an identifier followed by `\s` or `\\s` and `\[` or `\{`, as in R5 and R6) are guarded part-note labels whether or not the rule has fired (a fired label-spanning rule no longer matches its own key).
4. Rename rules (key and value both plain identifiers, as in `mtA0_skulker`): build an alias map value -> key. A part note for a label that is a value of such a rule is written under the key (translation), and `--check` accepts a note key equal to either name.
5. Fail (nothing written) with, per hit:
   - `<file>: comment {<addr>}: line <n> is inside the multi-line transform rule #<i> of block '<block>' (<first 50 chars of key>...); the plain build would not apply the rule. Put the text in a part note on an unguarded label, or make the rule tag-tolerant.`
   - `<file>: part note '<label>': the label is spanned by the multi-line transform rule #<i> of block '<block>' (<first 50 chars of key>...); a note line between the labels stops the match and changes the ROM.`
6. After T01 only step 3 remains active (comments on tolerant spans are harmless); the guard then costs nothing for comments.

The same function is called by `--check` for **existing** notes, so a note added by hand is caught.

### 2.3 G-3 / G-9: `merge --check` and the orphan prune

Command (T03): `npm run merge -- --check [--bank NN]`. Read-only, exit 1 on any error, exit 0 with warnings only. Needs a tagged tree; if no `; {n}` tag exists anywhere in `extracted/`, stop with `extracted/ has no address tags; run npm run extract:lt`.

Checks (the first is the `{K}` test of A10 §1):

1. Comment key K (decimal) in `notes/comments/bankNN.json`: live iff exactly one line in `extracted/**/*.asm` has `; {K}`. Errors: `comments bankNN '<K>': no instruction line carries tag {K}` plus a hint from `blocks.json` (`address is inside block '<name>' at offset +<k>`; for 47052: `block 'oneshot_palette_flash_18', offset +0, a thinker-def header`), `tag appears on N lines` for ambiguity, and `key is in bankNN but floor(K / 65536) is MM`.
2. Part-note key: must be a label (top or sub) of at least one extracted file, or (rename alias, §2.2 step 4) the key of a rename rule whose value is such a label. Error: `partNotes bankNN '<key>': no label '<key>' in any extracted file`. If the key has the form `<prefix>_<6 hex digits>` look the address up in `db-us/names/bankNN.json` and add `names maps <address> to '<name>', printed in <file>:<line>` (this is the `loc_03B928` -> `dialogstring_03B928` case). Warn when the stored bank differs from the bank the file resolves to.
3. Block-note key: must be a file name (without `.asm` / `.sprite.asm`) under `extracted/` **and** a block in `blocks.json`/`files.json`. Error: `blockNotes bankNN '<key>': no extracted file and no blocks.json entry` (A09-04, A10 bank02). The stored bank must equal `floor(start / 65536)` of the block.
4. Duplicates: a key may live in one bank file only, per kind (A15-11): `blockNotes 'CreditPositionLookup' is in bank09.json:23 and bank13.json:3; the block starts at 649444 (bank 09)`.
5. Bank rules per extracted file (AP-15 regression cases, one per strategy of `detectBank`): the `?BANK` value, if present, must equal the `blocks.json`/`files.json` bank (error otherwise); a file with no `blocks.json`/`files.json` entry and no `?BANK` is a warning `bank guessed by strategy S3/S4/S5/S6` because those strategies read the first `code_`/`loc_` text or the first tag, which can point into another bank.
6. Guard rules of §2.2 step 3 applied to existing notes.

Prune path (T03): `npm run merge -- --prune <orphans.json> [--dry-run]`, where `orphans.json` is `{ "comments": ["47052", ...], "partNotes": [...], "blockNotes": [...] }`. It refuses any key that is **not** reported by the check as an orphan (so it cannot delete a live note), removes only listed keys, re-runs the check and the existing disk verify. Facts that a key still carries are moved first with a normal spec (A09-02 re-key 46991 -> 46999). This is the path F07 and F10 need (A09-06).

Acceptance cases (real data, current tree):

| Case | Input | Expected result |
|---|---|---|
| AC-1 | `notes/comments/bank00.json:1791`, key `47052` | error with the `oneshot_palette_flash_18` hint; after `--prune` the key is gone and the check no longer lists it |
| AC-2 | the 29 + 15 + 9 comment keys of A09-01..03 (REPORTED lists) and the 27 + 1 of A10 | all reported (count matches 80); none reported for banks 03, 05, 06, 08, 09, 0A, 0B (REPORTED exact counts in A10) |
| AC-3 | `partNotes` key `loc_03B928` (deleted since, A05 D-S5160-2; the live key is `dialogstring_03B928`, `partNotes/bank03.json:91`, label at `world_map_options.asm:725`) | The live key passes. The old state is a fixture: a copy of the tree with the key `loc_03B928` re-added must produce error 2 with the `names maps 244008 to 'dialogstring_03B928'` hint (0x03B928 = 244008) |
| AC-4 | `blockNotes/bank00.json` keys `cop_handlers_flags`, `cop_handlers_flow`, `cop_handlers_lifecycle`, `cop_handlers_map`, `cop_handlers_solid`, `cop_handlers_spatial`; bank02 `attack_trail_followers__removed` | all 7 reported as block-note orphans |
| AC-5 | `CreditPositionLookup` in bank09 and bank13 | error 4 |
| AC-6 | bank rules: `tables/spriteset_aura.asm:20` has `?BANK 17`, `blocks.json:1059` start 1544192 (bank 0x17) | passes. `layer1_scroll_actors` (movable, no `?BANK`, `blocks.json:265`, note at `blockNotes/bank00.json:96`) resolves by S2 to bank 00 | passes. A fixture with `?BANK 0A` and a bank-00 block start must fail |
| AC-7 | guard: a spec with a part note on `diary_band_slot1` | rejected with the part-note message of §2.2 |
| AC-8 | guard: a spec with a comment on key 587588 (before T01) | rejected with the comment message |

Fixtures: AC-3 and the `?BANK` mismatch need a scratch copy of `notes/` and `extracted/`; there is no existing test directory in the baserom or in `gaia-core`, so the test form is yours to choose (I did not create one).

### 2.4 AP-12: hidden sprite groups in the extractor (design note)

Root cause (VERIFIED, A15-13). `sprite-group` is `Byte x 13` then `sprite-part` (`db-us/structs.json:14`); `sprite-part` is six members (`:15`). In `parseType` (`gaia-core/src/rom/extraction/parser.ts:123-210`) the struct members are parsed one by one (`:172`). The member `sprite-part` is itself a struct with no delimiter, so its `while` loop (`:123`) exits only through `partCanContinue()` (`:208`; `blocks.ts:259-261`: end of the part, or the next position already registered as a struct). The 13th header byte is the sub-sprite count, parsed as a plain `Byte` and never used. A group that no pointer references is not registered, so its bytes are read as more rows of the previous group.

Evidence (VERIFIED, `tables/spriteset_will_abilities.asm:823-839`): group 0F8BCC prints header count `#04` and 14 rows. Row `;04` = `08 0C 24 08 F8 F0 01` and row `;05` = `01 F8 10 F0 10 08 00` give a 13-byte header `08 0C 24 08 F8 F0 01 01 F8 10 F0 10 08` with count `08`, so the real group holds 4 rows (13 + 28 = 41 bytes), and a second group of 13 + 8 x 7 = 69 bytes follows (A08: hidden at 0F8BF5). Total 110 bytes = 0F8C3A - 0F8BCC, the next label: nothing is left over.

Minimal change (needs your go-ahead; `gaia-core` only):

1. File `src/rom/extraction/parser.ts`, function `TypeParser.parseType`. Add an optional parameter `maxItems?: number`. In the struct member loop (`:166-173`), when a member type has the form `name[@N]` (new notation, `N` = index of an earlier member of the same struct), read `parts[N]` (a `Byte`, `.value`) and call `this.parseType(name, reg, depth + 1, bank, false, count)`. In the `while` loop (`:123`) stop after `maxItems` objects (`if (maxItems !== undefined && objects.length >= maxItems) break;` next to the `single` check at `:210`); with `maxItems === 0` return an empty list before the loop.
2. `db-us/structs.json:14`: change the last member of `sprite-group` from `"sprite-part"` to `"sprite-part[@12]"`. (Alternative: a struct field `countIndex` in `database/structs.ts`; the member notation needs no schema change.) The array notation `[hex]` already exists for fixed counts (`parser.ts:43-51`), so `[@N]` is a small extension of the same parse at `:42-44`.
3. No change in `blocks.ts`: after the bounded group, `processPart` (`blocks.ts:325-333`) sees a position that is not a registered struct, `last !== null`, and calls `processContinuousEntry` (`:352-356`) with the part's current struct (`sprite-group`). The hidden group therefore becomes a **second `sprite-group` entry in the same labelled part**, the way `sprite_set_0F804E` already prints several `sprite-set` lines. The same path serves the struct-file pass (`blocks.ts:481-495`, `.sprite.asm` files), which calls `processPart` too.
4. Rebuild side: nothing to change. The assembler builds bytes from the text, and a part with two `sprite-group < ... >` entries assembles to the same bytes.

Expected output change (shape; **not run**): in `spriteset_will_abilities.asm` group 0F8BCC prints two entries,

```
sprite_group_0F8BCC [
  sprite-group < #0C, #0D, #1F, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #04, [
    sprite-part < ... >   ;00
    ... (rows ;00-;03)
  ] >
  sprite-group < #08, #0C, #24, #08, #F8, #F0, #01, #01, #F8, #10, #F0, #10, #08, [
    sprite-part < ... >   ;00
    ... (rows ;00-;07)
  ] >
]
```

and the rebuilt bytes are unchanged. The first row of the hidden group will read `#00, ...` (the `00` that today sits at the end of row `;05`).

Files whose printed text changes. Audited (A08 §2.3, I067): `tables/spriteset_will_abilities.asm` (1 hidden group, label 0F8BCC), `tables/spriteset_pickups_effects.asm` (1, label 0EEE5E), `tables/inventory_spritemap.asm` (5 hidden groups in 2 labelled groups: 108B67 and 108BAA), `tables/spriteset_transform_poses.asm` (2 labelled groups with printed rows above the count). Candidates found in this step by a static sweep (VERIFIED: `rg -U` for `<12 header bytes>, #NN, [` followed by more than NN `sprite-part` rows, NN = 01..0E per label, plus a check that no `#00` count and none of 0F..14 occurs; groups with a count of 15 or more were **not** tested because the row threshold differs per value):

| File | Labelled groups with rows above the count (NN) |
|---|---|
| `south_cape/south_cape/spm_southcape_sprites.sprite.asm` | 2 (01, 03) |
| `sky_garden/viper_lair/spm_viper.sprite.asm` | 1 (01) |
| `pyramid/puzzle_room/spm_pyramid_puzzle_sprites.sprite.asm` | 1 (01) |
| `mu/spm_mu_enemies.sprite.asm` | 2 (01, 04) |
| `babel_tower/comet_lair/sprite_1607B0.sprite.asm` | 1 (01) |
| `edward_castle/edward_castle/spm_castle_sprites.sprite.asm` | 2 (03, 04) |
| `edward_castle/castle_prison/spm_sc06_castle_actors.sprite.asm` | 1 (03) |
| `itory/spm_itory_sprites.sprite.asm` | 1 (04) |
| `angkor_wat/spm_angkor_outer_sprites.sprite.asm` | 1 (06) |
| `pyramid/spm_pyramid_sprites.sprite.asm` | 2 (07, 0D) |
| `ending/ending_credits/spm_ending_credits_sprites.sprite.asm` | 1 (0C) |

So: 11 unaudited files, 15 labelled groups; 4 audited files, 6 labelled groups (`spriteset_will_abilities` NN = 04, `spriteset_pickups_effects` NN = 0B, `inventory_spritemap` 01 and 02, `spriteset_transform_poses` two groups at 07). Rows above the count are a symptom, not a proof of a hidden group; each candidate needs the byte check A08 did (13 + n x 7 = bytes). These 11 files were never audited, so T02 will change files whose notes nobody has read.

Risks to check in T02: a ROM whose count byte is wrong (smaller than the real rows) would print junk as a second group; the byte-identical rebuild catches that. The "roll back struct overflow" code (`parser.ts:196-205`, comment "should only happen for the inventory sprite map") may stop firing once counts bound the rows.

### 2.5 AP-14: what the `rm -rf` step does and why it fails

What it does (VERIFIED, `package.json:26-27`): `npm run extract` and `extract:lt` run `rm -rf extracted/* && node --env-file=.env.local src/index.ts extract [--linetracking]`. The shell expands `extracted/*` to the immediate children (dot-files excluded) and deletes them recursively. `&&` means the extractor runs only if `rm` exits 0. `rm` deletes everything it can and exits non-zero if one child fails. So a failure leaves a **partially deleted** tree and no new extraction (REPORTED I001-I020 line 659: "aborted the chained node step after the rest of extracted/ had been deleted").

Why it fails (REPORTED messages): `rm: cannot remove 'extracted/tables': Device or resource busy` (I071) and the same for `extracted/system/engine` (I011/I012), `extracted/tables` (I069). The message form is GNU `rm`. On Windows this error means some process holds the directory open without delete sharing: a shell whose working directory is inside it, an editor/IDE file watcher or indexer, a search, an antivirus scan. `system/engine` and `tables` are the two most-read directories of this audit, which fits an open handle from a tool, but the file records no holder.

Evidence that would settle it: the process list or Resource Monitor handle list at the moment of the failure; the working directory of each open terminal (the `terminals` metadata shows it); whether the same command succeeds after closing the IDE or with the terminal moved out of `extracted/`; whether the failing directory is always the one most recently read.

Spec (new step T04, needs your go-ahead; options in order of preference):

1. **Stale-file sweep, no directory delete.** In `src/index.ts` `extract()`: record `start = Date.now()`, run `extractAllContent`, then walk `extracted/` and delete every **file** whose mtime is before `start` (not written by this run), with Node `fs.rmSync(path, { force: true, maxRetries: 10, retryDelay: 200 })`; leave empty directories. Print the number of stale files removed. The extractor overwrites all names it writes, so no pre-delete is needed, and an open handle on a directory no longer matters. Remove `rm -rf extracted/* &&` from both scripts.
2. **Completeness marker.** Write `extracted/.extract-state.json` as `{ "status": "running", "mode": "tagged|plain", "startedAt": ... }` before the first file and `{ "status": "complete", "mode": ..., "files": N, "finishedAt": ... }` after the last. `rebuild` refuses with `extracted/ is incomplete (.extract-state.json says 'running'); run npm run extract:lt`, and `merge`/`--check` refuse when `mode` is `plain`. A leading-dot name is skipped by the engine (`listDirectory` gives it a null extension, `file.ts:223-225`; `applyFolder` skips entries without one, `root.ts:325`), so rebuild input is unaffected. Add `mode` to `artifacts/crc.json` so the gate numbers are labelled.
3. If you prefer to keep a delete: `fs.rmSync(dir, { recursive: true, force: true, maxRetries: 10, retryDelay: 200 })` per top-level child, and on final failure exit 1 naming the path **before** deleting anything else (two passes: probe, then delete).

Gate: no ROM change; run `extract:lt` and `rebuild` once and compare with the recorded numbers.

### 2.6 AP-23: `CrystalBallAutoUse` "rewrite that does not exist: CODE_05F522"

Facts (VERIFIED). The patch overrides the auto-generated label `code_05F522` (`CrystalBallAutoUse.patch.asm:5`, `code_05F522! {`). The label is printed at `extracted/sky_garden/garden_main/sg4C_platforms.asm:23` and referenced at `:15`. In `processor.ts:92-116` the lookup `masterLookup` is built from the labels of every block and patch file read from `extracted/` and `baserom/` (upper-cased); `applyPatches` throws at `processor.ts:167` when an override label is not in it. A completely missing `extracted/` throws a different error (`Directory not found`, `file.ts:257`). So in the failing run `extracted/` existed, but the label was not in any file read. Today the patch, the extracted file and `db-us/` agree (no hit for `05F522` in `db-us/`), and a second run passed (REPORTED I056). The patches in `baserom/auto-use-items/` pin about 30 auto-generated `code_XXXXXX` names, so any drift in extraction output gives exactly this error.

| Hypothesis | Fits | Evidence that settles it |
|---|---|---|
| H1: the tree was **incomplete** when `rebuild` ran, because `rm -rf` had failed (partial delete, extractor skipped by `&&`) | `Directory not found` not raised; I058 reports a transient missing tree; I071/I069 report the failing `rm` | The terminal log of the failing session: did `extract:lt` print `rm: cannot remove` or exit non-zero before the failing `rebuild`? Repro (user): in a scratch copy of the repo delete `extracted/sky_garden`, run `npm run rebuild`, expect `Patch <first patch in directory order> contains a rewrite that does not exist: <its label>`; the named patch depends on `readdir` order (`file.ts:217`), which I could not determine |
| H2: `rebuild` ran **while `extract:lt` was still writing** (a long foreground command moved to the background, then `rebuild` started) | the extractor writes files one after another with `await saveFileAsText` (`root.ts:378-382`), so a partial tree exists for a while | Timestamps of `extracted/**` against the rebuild start; the extract duration in the terminal log (longer than the 30 s foreground limit?) |
| H3: the label was **absent from the extracted text in that run** (the auto-name differed, for example `loc_05F522`) because a db file changed between runs (the digest records `types.json` entry 244008 changed between iterations; I056 notes uncommitted changes in `src/` and `package.json`) | the ledger says the working tree had uncommitted changes | `git diff` of `db-us/*.json` between the failing and the passing run (not available now); the first run's `sg4C_platforms.asm` text (not saved) |
| H4: a rename of `code_05F522` | ruled down: `names` rewrites `baserom/` too (`names-merge.ts:30, 309`) and the live label is still `code_05F522` | `git log -S code_05F522` on `db-us/names/` |

Most likely H1 or H2 (same cause as the I058 transient). Not settled by static evidence. The same T04 marker removes both: `rebuild` refuses an incomplete tree with an accurate message instead of a patch error. Second half of OQ-I056-9 (size 3,062,189 after a plain extract) is answered by A15-01.

---

## 3. Recommendations

### 3.1 Which change needs a gate, and in which mode

The recorded gate is the tagged build only. The plain build differs by 15 bytes and by content (A15-01..03). Until T01, a tagged gate cannot see a break in R1, R3, R4, R7-R10.

| Change | Gate | Mode | Expected result |
|---|---|---|---|
| T01 rules made tolerant (one rule at a time, as the T01 prompt says) | yes, after each rule | plain **and** tagged | both builds equal each other and equal the REPORTED plain numbers (3,062,189 / 222967024 / -1004081563, to be re-measured first); the baseline for all later steps moves once |
| T02 extractor change (needs `npm run build` in `gaia-core` first, A15-14) | yes | tagged (existing numbers must not change); one plain run before and after to show it is unchanged too | 223006080 / 2083230829 / 3062204; only the sprite files in §2.4 change in `git diff --stat extracted/` |
| T03 `--check`, guard, `--prune` | no ROM gate (no data change) | run `--check` on the real tree and the acceptance cases of §2.3 | the guard rejects AC-7/AC-8; `--check` lists the REPORTED orphans |
| Prune F-step (F07/F10 through `--prune`) | yes (notes change) | tagged; after T01 either mode | unchanged bytes |
| T04 extract/rebuild hygiene | one `extract:lt` + `rebuild` | tagged | unchanged numbers |
| Notes F-steps (F01-F04, F07) before T01 | existing tagged gate; plus a plain run only if they add a comment at an address of §2.2 (they should not) | tagged | unchanged |

Order: A decision on the product mode (AP-01) -> T01 (new baseline) -> T03 (so the guard and `--check` exist before bulk notes) -> prune F-steps -> T02 (sprite notes depend on it, A08 F07) -> T04 at any point (independent). If you want the notes steps to continue first, run them under the tagged gate and do not touch the addresses in §2.2.

### 3.2 Items for the fix specs

1. **T01**: change the acceptance line (A15-02); give the product mode; apply the tolerant forms of §2.1 one rule at a time; decide the dead and inert `cop_handlers_*` keys (A15-06) and the unpatched `cop_handlers_script_control` triple; record both builds after each rule; first re-measure the plain build (the plain numbers are REPORTED from I026 and have not been checked since).
2. **F11 (new)**: after T01, `merge` spec to rewrite the five notes of A15-20 and any note that says the tagged text "still shows" the vanilla code.
3. **T02**: AP-12 design §2.4: build step in `gaia-core`, baserom-side acceptance (file list, bytes unchanged), no unit-test framework exists (A15-14); list the notes that describe artefact sub-sprites afterwards (A08 §2.3 names three).
4. **T03**: `--check` (§2.3), `--prune`, guard (§2.2) including alias translation, docs in `gaia-core/docs/notes-and-comments.md` (AP-17; replace the two embedded scripts, A15-21; the no-scripts rule).
5. **T04 (new)**: extract/rebuild hygiene (§2.5), AP-23 message (§2.6), optionally the `rebuild-jp` fix (A15-18).
6. **F07 / F10**: prune with `--prune` after T03; re-key 46991 -> 46999 first (A09-02).
7. For the user: the CreditPositionLookup duplicate (A15-11) needs one `merge` removal in bank13 once the intended bank is confirmed (the block is at 649444, bank 09).

---

## 4. Not verified / needs Mesen2 or a user run

- Run-time effect of any transform content difference (R3 teleporter saves `$02`, R4 sliding wall repeats a decrement-and-branch, R7 diary remap, R10 Inca statue branch): static only; no ROM or state.
- The plain build numbers (3,062,189 / 222967024 / -1004081563) are REPORTED from I026 and were not reproduced; the per-rule byte deltas are VERIFIED only as tag arithmetic.
- The tolerant regex forms of §2.1 were not run. The R4 and R5 forms in particular need the dual-mode gate.
- Why the `diary_band` swap exists and why it matters by one byte (R5).
- Hidden-group status of the 15 candidate groups in 11 unaudited sprite files; groups with a count of 15 or more were not swept.
- Orphan sweeps of banks 04-0F (REPORTED partial in A10): `--check` will give the full list.
- AP-23 root cause (needs the original terminal log, file times, or a user repro).
- The holder of the open directory handle in the `rm -rf` failures.
- Patch discovery order (`readdir`) for the AP-23 repro.
- `names -- --check` was not run (no names were changed in this step).

---

## 5. Counts

- Findings: 22 (A15-01..A15-22).
- Tags: 17 VERIFIED, 4 VERIFIED + REPORTED (A15-10, A15-15, A15-16, A15-17), 1 REPORTED (A15-21).
- Multi-line rules inventoried: 12 groups of rules (R1-R12); 10 rules in 5 blocks are plain-only (A15-01); 169 `joypadMaskStd` rules plus 4 `joypadHeld` rules are tolerant; 12 `cop_handlers_*` / `actor_pool` rules = 4 active, 4 dead, 4 inert.
- Plain-build delta explained: -15 bytes = -4 (R1) + 6 (R3) + 16 (R4) - 24 (R8) - 9 (R9).
- Forbidden comment addresses before T01: 34 (R1 4, R3 2, R4 8, R7 7, R8 8, R9 3, R10 2); forbidden part-note labels: 2 (`diary_band_slot1`, `diary_band_empty`).
- Orphans to prune (REPORTED): 80 comment keys, 7 block-note keys, 2 part-note keys; 1 duplicate key found by hand (CreditPositionLookup).
- Acceptance cases written: 8 (AC-1..AC-8).
- Sprite files whose output changes under T02: 4 audited + 11 candidates (15 + 6 labelled groups).
- New fix items proposed: F11 (notes after T01), T04 (hygiene); changed items: T01 acceptance, T02 test form.
- Files changed in this step: this file and the A15 row of `PLAN.md`. No `src/`, `gaia-core/`, `db-us/`, `notes/`, `extracted/` or `baserom/` change; no gate run needed.
