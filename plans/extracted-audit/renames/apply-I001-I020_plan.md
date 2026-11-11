# Plan: apply the I001–I020 rename proposals to `db-us/names/`

Status: written before any edit; the outcome is in `apply-I001-I020_summary.md` (same folder).

## Scope decision

Applied: proposals whose target is a label in `db-us/names/bank*.json`, plus the `blocks.json` part/block keys that carry the same label (changing only one of the two has no effect or breaks the build). Every applied rename is propagated to `notes/` (block, part, comment text and keys), `db-us/transforms.json`, the two baserom patches that call a renamed routine, `docs/`, and `gaia-core/docs/patch-development.md`.

Not applied (kept in the ledgers for a later pass): mnemonic renames (`mnemonics.json`), `copdef.json` operand/opcode names, block renames that change `blocks.json` structure beyond a key, proposals that depend on an open question (OQ-63, OQ-67, OQ-68), proposals that need code changes, and pure documentation-fact corrections that do not involve a name.

## Steps

1. Build the old→new table and check that every new name is unused (db-us, extracted, baserom, IOGRetranslation modules).
2. Rename in `names/bank*.json`, `blocks.json`, `transforms.json` (targeted text replacement per name).
3. Add new names (`code_*` / `loc_*` / `binary_*` addresses) in numeric order in the matching bank file.
4. Propagate old→new through `notes/**`, `docs/**`, `baserom/**`, `gaia-core/docs/patch-development.md`. Frozen ledgers, the `edits/` specs and `artifacts/` are not touched.
5. `npm run extract:lt`; confirm the new labels appear, no orphaned part notes.
6. Add part notes for every new name and reword notes whose text said a name was wrong/pending (`npm run annotate`, new spec).
7. Gate: `npm run rebuild`, `artifacts/crc.json` must stay 223006080 / 2083230829 / 3062204; ingest dry-run no-op.
8. Write `apply-I001-I020_summary.md`.
