# Story dialogue port

South Cape and the earlier scenes use the fork's existing dialogue. The rest of the game uses the English Retranslation script at revision `1bedfba`. The patches in `baserom/retranslation-dialogue/` cover 1,008 dialogue entries from chapters 4 through 36. They use the fork's actor names and retain the donor's wording, border styles, speaker palettes, typing sounds, window geometry, and pauses. English name placeholders are resolved to the donor's English names. Box openings reapply the donor's colors and sound after the fork's renderer resets them.

The chapter import contains dialogue only. Existing actors still control choices, rewards, and flags. The prior v0.051-based `StoryDialogue` and `EdwardCastleDialogue` patches are available in `archived/` for comparison during the next script pass.

## Edward Castle through the escape

The v15 playtest layers 63 v0.051 dialogue entries over the Retranslation baseline. The scope ends when Will and Kara leave the castle. Kara's repeat uses the existing suffix, the flute dialogue follows the two existing wall-stone callbacks, and the aqueduct retry enters the updated countdown instructions. The Prison Key text reflects automatic use. Reward and item placements follow the fork, including the sleeping guard's shared Jewel flag.

The fork supplies the shared Gaia and item messages. The timed greetings, brief guard lines, and countdown responses use Retranslation where this pass found no confirmed v0.051 replacement. The awake guard mentions the shiny object only on the unclaimed path.

## After the castle escape

The v16 playtest restores 334 v0.051 entries after the castle escape, including scenes in Inca, the Gold Ship, Freejia, Mu, Watermia, Dao, and Babel Tower. It uses the fork's text-speed settings for character pacing and retains the imported pause and page controls.

The active Retranslation entries cover the remaining dialogue. The port manifest in the build artifacts records routes that need stronger source matching, as well as item, choice, and timed sequences that require individual review.

## Item and flag dependencies

| Interaction | Reason to keep its existing fork dialogue |
|---|---|
| Gold Ship Seth and fountain fallback | The earlier hack and the fork have different rewards. Keep the offer, inventory check, receipt and retry together. |
| Turbo and Ann | The original hack changes the Jewel giver or Apple exchange. |
| Freejia clues, Edward Prison and Ishtar comparison rooms | Wording depends on the actual hidden pickup or chest pair. |
| Gem | The fork allows both physical Jewel deposits and Herb buyback. |
| Locke, Dark Crest and later glasses sources | The exchange or alternate source must agree with the item and flags implemented in this fork. |

The sleeping Edward Castle guard now offers the existing Red Jewel. Both guard interactions share collection flag `$D8`. The sleeping route uses the standard item grant and allows a retry if the inventory is full.

## Entries flagged during the earlier v0.051 pass

Review these entries when layering v0.051 over Retranslation. Compare item references with the fork and check any calls that enter midway through a string.

| Original ID | Owner | Reason |
|---|---|---|
| 09BE70 | ec11_countdown | shared entry or dynamic text |
| 04AAAD | sc06_kara_return | shared entry or dynamic text |
| 04F1BA | it15_lola | item review |
| 04EDF4 | it15_elder | shared entry or dynamic text |
| 04EF1C | it15_elder | shared entry or dynamic text |
| 058394 | gs2C_crew4 | shared entry or dynamic text |
| 058A30 | gs2E_queen | shared entry or dynamic text |
| 0596C1 | gs2B_seth | item review |
| 05ABC6 | dc31_rescuer | shared entry or dynamic text |
| 05B94D | fr32_slaver2 | item review |
| 05B9AF | fr32_slaver2 | shared entry or dynamic text |
| 05C67C | fr39_lily | shared entry or dynamic text |
| 05CFFD | fr32_locked_door | item review |
| 0694AA | sp5D_fountain | item review |
| 06C6A0 | av6A_erik | item review |
| 07B8AD | gw8B_lance_lily | shared entry or dynamic text |
| 0792F7 | wa78_glass_game | item review |
| 07C0F3 | eu91_merchant_counter | item review |
| 07DF7A | eu95_ann | item review |
| 07E03D | eu95_ann | item review |
| 07E092 | eu95_ann | item review |

Rows in the source ledgers without an exact matching native dialogue symbol require separate caller tracing. In particular, chapters 28–35 list consolidated source owners instead of original logical IDs. This pass does not assign them by chapter order.

## Retranslation entries handled by existing fork patches

| Chapter | Dialogue ID | Owner | Fork patch |
|---|---|---|---|
| 06 | `dialogstring_048CDB` | `sc08_priest` | `SouthCapeDialogue.patch.asm` |
| 06 | `dialogstring_08D332` | `jeweler_gem` | `GemHerbBuyback.patch.asm` |
| 10 | `dialogstring_05966E` | `gs2B_seth` | `SethsJewelGoldShip.patch.asm` |
| 14 | `dialogstring_05D819` | `dm40_trapped_slave` | `TrappedSlaveSparkle.patch.asm` |
| 22 | `dialogstring_08D459` | `jeweler_gem` | `GemHerbBuyback.patch.asm` |
| 28 | `dialogstring_08D4E3` | `jeweler_gem` | `GemHerbBuyback.patch.asm` |
| 29 | `dialogstring_0893BF` | `nvAE_stone_girl2` | `GorgonFlowerAutoUse.patch.asm` |
| 29 | `dialogstring_0894B3` | `nvAE_stone_girl3` | `GorgonFlowerAutoUse.patch.asm` |
| 30 | `dialogstring_089415` | `nvAE_stone_girl2` | `GorgonFlowerAutoUse.patch.asm` |
| 30 | `dialogstring_089509` | `nvAE_stone_girl3` | `GorgonFlowerAutoUse.patch.asm` |
| 31 | `dialogstring_08B052` | `daC6_snake_panic` | `SnakePanicSparkle.patch.asm` |
| 34 | `dialogstring_08D5AE` | `jeweler_gem` | `GemHerbBuyback.patch.asm` |
