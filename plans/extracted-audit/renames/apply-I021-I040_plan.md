# Plan: apply I021–I040 rename proposals to `db-us/names/`, `blocks.json`, notes and docs

Scope (user decision): names files (`db-us/names/bankNN.json`) and `db-us/blocks.json` (plus `transforms.json` where a regex quotes a renamed label). Not `mnemonics.json`, not `copdef.json`. Rows that the ledgers mark "apply only after OQ-xxx" are skipped unless runtime evidence from Mesen2 settles the question (outcome in the summary). Structural moves (R-I024-3 block split, R-I032-2 delete a routine, R-I024-6 transforms anchoring) are code/structure changes and are not part of this pass.

Frozen (not edited): `results/`, `renames/I0*_renames.md`, `questions/`, `edits/I0*.json`, `artifacts/`.

## Checklist

- [x] 1. Read all 21 ledgers; split rows into APPLY / GATED / NOT-A-NAME (mnemonics, COP, docs-only).
- [ ] 2. Write the reviewed old→new map (`apply-I021-I040_map.json`) with decimal addresses for every new auto-label name.
- [ ] 3. Validate the map: each old name exists (names file value, blocks key, or auto label at the given address); each new name is unused in `db-us`, `extracted`, `baserom`, IOGRetranslation modules.
- [ ] 4. Apply to `db-us/names/bankNN.json` (rename values; add new entries; keep keys sorted numerically) and `db-us/blocks.json` (block / part keys).
- [ ] 5. `db-us/transforms.json`: update the item_use_system regexes that quote `loc_0386F2` / `loc_038818` / `code_03876D`; update block keys that are renamed.
- [ ] 6. Propagate the map (single pass, word boundaries) to `notes/**` (re-key part/block notes), `docs/**`, `baserom/**/*.patch.asm`, IOGRetranslation modules, `gaia-core/docs/patch-development.md`, gaia-knowledge copies.
- [ ] 7. Rewrite note/doc sentences that said a name was wrong or described the old (incorrect) meaning.
- [ ] 8. Add part notes for new names that have none (spec in `edits/rename-pass-I021-I040.json`, applied with `npm run annotate` / `merge`).
- [ ] 9. Doc fact corrections from the ledgers (R-I021-6, R-I022-5/6, R-I025-5/7, R-I029-5, R-I030-3, R-I032-4, R-I033-4, R-I034-4, R-I035-8, R-I036-7, R-I037-5, R-I038-4, R-I039-4, R-I040-4).
- [ ] 10. Gate: `npm run extract:lt` (no old name left in `extracted/`), `npm run rebuild` with `artifacts/crc.json` unchanged (checksum 223006080 / crc 2083230829 / totalSize 3062204), `npm run ingest:dry` baseline only.
- [ ] 11. Mesen2: try to settle gating OQs; apply any rename that becomes safe.
- [ ] 12. Write `apply-I021-I040_summary.md`; suggest the commit message (agents never commit).

## Progress

Items 1–10 and 12 done; item 11 (Mesen2) attempted without usable evidence. Gated rows stay unapplied. Details: `apply-I021-I040_summary.md`.
