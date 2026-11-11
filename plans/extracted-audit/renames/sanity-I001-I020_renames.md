# Rename proposals from the I001–I020 sanity check (not applied)

Legacy rows 1..96 are in [I001-I020_rename-proposals.md](I001-I020_rename-proposals.md). IDs here use the prefix `R-SAN-`.

| ID | Target (current) | Proposal | Reason / evidence | Blast radius |
|----|------------------|----------|-------------------|--------------|
| R-SAN-1 | `EnemyHitPlayer_Epilogue` (part in `combat_collision`, begins with `TXY`/`RTS` at 245636) | `ApplyHitDamageToVictim_DamagePath` (to be done together with legacy row 13, `EnemyHitPlayerHandler` → `ApplyHitDamageToVictim`) | The label sits mid-routine: its two first instructions are the RTS-trick landing of the knockback path, and the rest (entered at `loc_03BF86` when `$24` is zero) is the whole combat-damage path (DEF/characterForm formula, HP clamp, digits, death, stagger, iframes, callbacks). E1: see the `PEA $&EnemyHitPlayer_Epilogue-1` at 245591 and the `BEQ loc_03BF86` at 245553. | One `PEA` reference in the same file; `names/bank03.json` entry; the part note key and `blocks.json` part name if present |
