; Player death sequence (Bank 00, 54831-55263) with its helper actors. combat_collision.CheckPlayerDeath sets playerFlags $0200 when playerHp is zero, replaces the player actor's entry point with GameOverSequence and calls StopPlayerOnDeath, so the player actor itself runs this script from the next tick. Entry points: GameOverSequence (player), GameOverCutsceneSprites (spawned by it), GameOverSparkleOrbitA/B (spawned by that) and DeathWakeupMessage (spawned by player_character after the respawn).
; 
; === TIMELINE ===
; 
; Frame 0: player $10 |= $0040 (dead; shadow_shimmer reads it) and joypadMaskStd |= $FFFC (every button and the D-pad, Start and Select included).
; After 33 ticks (WaitByte #20): spawn DeathPaletteFadeThinker (palette bundles $10, then $0E) and GameOverCutsceneSprites (the sparkles).
; After 120 more ticks (WaitByte #77): clear player $10 bit $8000 (the player stops using DecomposePlayerSprites), SFX $0C on both channels (the same SFX as the Dark Space warp) and play animation #1C of spriteset_pickups_effects once (also used by the Dark Space warp).
; Fade: orbitAngle starts at 15; every pass writes counter - 1 to INIDISP (brightness 14 down to 0) and waits 4 ticks (WaitByte #03), 60 ticks in all. Forced blank is never set.
; Then two one-frame palette thinkers (PaletteResetAndKillThinker with bundle IDs $0B and $0D: sub-entry 0 of each bundle is applied once), one yield and the respawn choice.
; 
; === RESPAWN CHOICE ===
; 
; gemCount >= 100 (revive): gemCount -= 100, playerHp = playerMaxHp >> 1, and the respawn record is the one stored by the last warp the player took (reviveWarpPtr / reviveWarpBank, $0AF4 / $0AF6; ExecuteWarp writes a pointer to entry + 4 for every warp). Form and wramFlags are kept.
; gemCount < 100 (real game over): gemCount = 0, characterForm = 0 (Will), or 2 (Shadow) when sceneCurrent is $E8 (the Dark Gaia arena in the comet lair; presumably because that fight is played as Shadow), playerHp = playerMaxHp, the 16 words of wramFlags ($0A80-$0A9F: dungeon kill and puzzle flags) are cleared, and the respawn record is sceneSaveData / sceneSaveDataBank ($0AF0 / $0AF2), which ExecuteWarp writes only for warps whose entry byte 9 has bit 7 set.
; 
; === SHARED RESPAWN TAIL ===
; 
; Reads the warp record at DBR:Y: byte 0 = scene (sceneNext, 8-bit store), +1 and +3 = spawn X and Y (warpDestX / warpDestY), +5 = facing with bit 7 masked (warpFacing), +6 = packed camera window (warpScrollParams). Then gfxCacheIdxB := $0404, gameOverWakeupFlag += 1, worldReadyFlag := 0 (ExecuteSceneTransition then skips the exit transition, because the screen is already black, and runs the enter transition) and SetEntryHere + RTL; the scene change takes over.
; 
; === WAKE-UP MESSAGE ===
; 
; player_character spawns DeathWakeupMessage (SpawnAfterFlags $2000) at the start of the next scene when gameOverWakeupFlag ($0AF8) is set. It masks the joypad with $CFFC (Select and Start stay live), clears the flag, waits 3 ticks (WaitByte #02), prints one of three strings chosen by characterForm (0 Will, 1 Freedan, 2 Shadow), unmasks and dies. The message follows a revive as well as a real game over. After a real game over the form is Will (Shadow in $E8), so the Freedan line appears only after a revive as Freedan.
; 
; === CORRECTIONS ===
; 
; The ROM masks the joypad with $FFF0 (and $CFF0 in DeathWakeupMessage); db-us/transforms.json (block game_over_sequence) widens both to $FFFC / $CFFC so the software-only buttons $0004 and $0008 are masked too, and the extracted asm shows the transformed values. The old comment credited the first block with spawning both helpers (it is a 33-tick wait first); 'sound #$0C' is the 16-bit pair $0C0C on both channels. The old header did not say that 100 gems are paid in the revive case, that the wramFlags are cleared only on a real game over, or that two different warp records are used.
---------------------------------------------

?INCLUDE 'actor_pool'
?INCLUDE 'DeathPaletteFadeThinker'
?INCLUDE 'spriteset_pickups_effects'

!sceneNext                      0642
!sceneCurrent                   0644
!gfxCacheIdxB                   064A
!warpDestX                      064C
!warpDestY                      064E
!warpFacing                     0650
!warpScrollParams               0652
!worldReadyFlag                 0654
!joypadMaskStd                  065A
!wramFlags                      0A80
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!gemCount                       0AD6
!sceneSaveData                  0AF0
!sceneSaveDataBank              0AF2
!reviveWarpPtr                  0AF4
!reviveWarpBank                 0AF6
!gameOverWakeupFlag             0AF8
!INIDISP                        2100
!orbitAngle                     7F0010

---------------------------------------------

; Run by the player actor after CheckPlayerDeath. Sets the dead flag and masks all input, runs the palette fade and the sparkles, turns the player into a plain metasprite playing animation #1C, fades the screen to brightness 0, resets the palette, chooses between the revive (100 gems) and the real game-over respawn and queues the scene change. See the block note for the timeline and the two respawn records.

GameOverSequence {
    LDA #$0040            ; Player $10 |= $0040: dead (read by shadow_shimmer)
    TSB $10
    LDA #$FFFC            ; Mask every button and the D-pad (Start and Select too)
    TSB $joypadMaskStd
    COP [WaitByte] ( #20 ) ; WaitByte #20 = 33 ticks
    COP [SpawnThinker] ( @DeathPaletteFadeThinker ) ; Palette bundles $10 then $0E (OQ-I026-4)
    COP [SpawnAfter] ( @GameOverCutsceneSprites ) ; Sparkle spawner, placed at the player
    COP [WaitByte] ( #77 ) ; WaitByte #77 = 120 ticks
    LDA #$8000            ; Clear bit 15 of the player's $10: it leaves DecomposePlayerSprites and is drawn as a plain metasprite
    TRB $10
    COP [PlaySoundBoth] ( #$0C0C ) ; SFX $0C on both channels (same as the Dark Space warp)
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSpriteFrame] ( #1C ) ; Animation #1C of spriteset_pickups_effects, played once (also the Dark Space warp effect)
    COP [AnimOnce]
    LDA #$000F            ; Fade counter: brightness 15
    STA $orbitAngle, X

; Fade loop: 8-bit step of orbitAngle (15 down to 0) into INIDISP, 4 ticks per step (WaitByte #03); the DEC that goes below 0 leaves the loop.

  GameOverFadeLoop:
    SEP #$20              ; 8-bit: counter - 1 goes to INIDISP (14 down to 0), 4 ticks per step (WaitByte #03); below 0 leaves the loop
    LDA $orbitAngle, X
    DEC 
    BMI GameOverChooseRespawn
    STA $orbitAngle, X
    STA $INIDISP
    REP #$20
    COP [WaitByte] ( #03 )
    BRA GameOverFadeLoop

; After the fade: two PaletteResetAndKillThinker thinkers (bundle IDs $0B and $0D), a one-frame yield so they run, then the gem test (PHB saves the data bank for the record reads).

  GameOverChooseRespawn:
    REP #$20
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker ) ; Param = palette bundle ID: sub-entry 0 of bundle $0B applied once, then the thinker ends
    COP [SpawnThinkerParam] ( #0D, @actor_pool.PaletteResetAndKillThinker ) ; Same for bundle $0D
    COP [SetEntryHereAndYield] ; Yield once so the thinkers run; resume at the PHB
    PHB 
    LDA $gemCount
    CMP #$0064            ; 100 gems or more: revive
    BCC GameOverRealDeath
    SBC #$0064            ; Carry is set after the CMP: pay 100 gems
    STA $gemCount
    LDA $playerMaxHp      ; Revive HP = max HP / 2
    LSR 
    STA $playerHp
    SEP #$20
    LDA $reviveWarpBank   ; Revive record: last warp taken (pointer $0AF4, bank $0AF6)
    PHA 
    PLB 
    LDY $reviveWarpPtr
    BRA GameOverRespawnTail

; Real game over (fewer than 100 gems): gems := 0, form := Will (Shadow in scene $E8), playerHp := playerMaxHp, wramFlags cleared, record := sceneSaveData.

  GameOverRealDeath:
    STZ $gemCount         ; Real game over: gems := 0
    LDA $sceneCurrent
    AND #$00FF
    CMP #$00E8            ; Scene $E8 (Dark Gaia arena): respawn as Shadow, otherwise Will
    BNE GameOverFormWill
    LDA #$0002
    STA $characterForm
    BRA GameOverFullHp

; Any scene other than $E8: characterForm := 0 (Will).

  GameOverFormWill:
    STZ $characterForm

; Full HP, then clear the 16 words of wramFlags and load the save-point record pointer.

  GameOverFullHp:
    LDA $playerMaxHp      ; Full HP
    STA $playerHp
    LDY #$0000            ; Clear the 16 words of wramFlags ($0A80-$0A9F)
    LDA #$0000

; Loop clearing wramFlags ($0A80-$0A9F, 32 bytes).

  GameOverClearFlagsLoop:
    STA $wramFlags, Y
    INY 
    INY 
    CPY #$0020
    BNE GameOverClearFlagsLoop
    SEP #$20
    LDA $sceneSaveDataBank ; Save-point record: pointer $0AF0, bank $0AF2 (warps with bit 7 of entry byte 9)
    PHA 
    PLB 
    LDY $sceneSaveData

; Shared respawn tail for both paths: copy the warp record at DBR:Y into the transition words, restore DBR, set the transition speeds, the wake-up flag and worldReadyFlag := 0, then idle.

  GameOverRespawnTail:
    LDA $0000, Y          ; Warp record at DBR:Y: +0 scene, +1 X, +3 Y, +5 facing (bit 7 masked), +6 camera window
    STA $sceneNext
    LDA $0005, Y
    AND #$7F
    STA $warpFacing
    REP #$20
    LDA $0001, Y
    STA $warpDestX
    LDA $0003, Y
    STA $warpDestY
    LDA $0006, Y
    STA $warpScrollParams
    PLB 
    LDA #$0404            ; gfxCacheIdxB $0404: transition speeds 4 and 4
    STA $gfxCacheIdxB
    INC $gameOverWakeupFlag ; Wake-up flag: player_character spawns DeathWakeupMessage in the next scene
    STZ $worldReadyFlag   ; No exit transition (the screen is already black); the enter transition runs
    COP [SetEntryHere]
    RTL 
}

---------------------------------------------
; Invisible spawner (spawned by GameOverSequence at the player's position) that creates three marked sparkle actors, 12, 15 and 20 ticks after it starts (WaitByte #0B, #02, #04), at (-25, -40), (+25, -24) and (-25, -8) from the player, then dies 99 ticks later (119 in all), which also ends the sparkles. The $2000 write is already done by CopyActorState; SetMetasprite and SetSpritePalette #00 prepare the sprite data the sparkles inherit.

GameOverCutsceneSprites {
    LDA #$2000            ; Hidden spawner (already set by CopyActorState)
    TSB $10
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [SetSpritePalette] ( #00 )
    COP [WaitByte] ( #0B )
    COP [SpawnAfterOffsetMarked] ( @GameOverSparkleOrbitA, #E7, #D8, #$0700 ) ; Offsets -25, -40 from the player; flags $0700
    COP [WaitByte] ( #02 )
    COP [SpawnAfterOffsetMarked] ( @GameOverSparkleOrbitB, #19, #E8, #$0700 ) ; Offsets +25, -24
    COP [WaitByte] ( #04 )
    COP [SpawnAfterOffsetMarked] ( @GameOverSparkleOrbitA, #E7, #F8, #$0700 ) ; Offsets -25, -8
    COP [WaitByte] ( #62 ) ; WaitByte #62 = 99 ticks, then Die (marked sparkles die with it)
    COP [Die]
}

---------------------------------------------
; Sparkle that loops forever: Flags10 $0001 (depth override: drawn behind every other actor) while animation #15 plays once with the X ramp $2D and the Y ramp $2F of move_chain_table, then $0002 (drawn in front of every actor) with animation #15 and the ramps $2E / $30. The ramps are $2D positive X, $2E negative X, $2F negative-then-positive Y and $30 positive-then-negative Y, so the sparkle swings out and back around the player, passing behind and in front (inferred from the signs; not run). Spawned twice.

GameOverSparkleOrbitA {
    LDA #$0001
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2D, #2F ) ; Animation #15, X ramp $2D, Y ramp $2F
    COP [AnimOnce]
    LDA #$0001
    TRB $10
    LDA #$0002
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2E, #30 ) ; X ramp $2E, Y ramp $30
    COP [AnimOnce]
    LDA #$0002
    TRB $10
    BRA GameOverSparkleOrbitA
}

---------------------------------------------
; Mirror of GameOverSparkleOrbitA with the X ramps swapped ($2E behind, $2D in front) and the Y ramps $2F behind, $30 in front. Spawned once.

GameOverSparkleOrbitB {
    LDA #$0001
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2E, #2F ) ; X ramp $2E, Y ramp $2F
    COP [AnimOnce]
    LDA #$0001
    TRB $10
    LDA #$0002
    TSB $10
    COP [StageSpriteMoveXY] ( #15, #2D, #30 ) ; X ramp $2D, Y ramp $30
    COP [AnimOnce]
    LDA #$0002
    TRB $10
    BRA GameOverSparkleOrbitB

; Actor spawned by player_character at the start of the scene after a death (gameOverWakeupFlag set). Masks the joypad except Select and Start, clears the flag, waits 3 ticks (WaitByte #02), prints the line for characterForm (0 Will, 1 Freedan, 2 Shadow), unmasks and dies. The label sits inside the GameOverSparkleOrbitB block but is a separate entry.

  DeathWakeupMessage:
    LDA #$CFFC            ; Mask every button except Select and Start
    TSB $joypadMaskStd
    STZ $gameOverWakeupFlag ; Consume the flag set by GameOverSequence
    COP [WaitByte] ( #02 )
    LDA $characterForm    ; 0 Will, 1 Freedan, 2 Shadow selects the line
    BNE DeathWakeupNotWill
    COP [PrintDialogString] ( &dialogstring_00D7C2 )
    BRA DeathWakeupUnmask

; characterForm is not 0: decrement it; 1 prints the Freedan line, 2 the Shadow line (DeathWakeupShadowLine).

  DeathWakeupNotWill:
    DEC 
    BNE DeathWakeupShadowLine
    COP [PrintDialogString] ( &dialogstring_00D818 )
    BRA DeathWakeupUnmask

; characterForm 2: the Shadow line.

  DeathWakeupShadowLine:
    COP [PrintDialogString] ( &dialogstring_00D848 )

; Unmask the joypad ($CFFC) and die.

  DeathWakeupUnmask:
    LDA #$CFFC            ; Unmask
    TRB $joypadMaskStd
    COP [Die]
}

---------------------------------------------
; Wake-up line for Will (characterForm 0).

dialogstring_00D7C2 `[DEF]Will: I am sometimes [N]aware of having fallen [N]in a place I know. Must [N]have been a nightmare. [END]`

---------------------------------------------
; Wake-up line for Freedan (characterForm 1).

dialogstring_00D818 `[DEF]Freedan: When I think[N]about it, that place[N]seemed familiar...[END]`

---------------------------------------------
; Wake-up line for Shadow (characterForm 2); the same sentence as the Freedan line.

dialogstring_00D848 `[DEF]Shadow: When I think[N]about it, that place[N]seemed familiar...[END]`