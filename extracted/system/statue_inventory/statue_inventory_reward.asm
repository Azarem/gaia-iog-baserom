; Mystic-statue reward ceremony (scene $FD, Bank 00, 52569-53033). Six copies of this actor spawn in scene $FD, one per pedestal; only the copy whose table index equals globalScriptIndex ($0AAC) runs the ceremony, the others stay hidden or show a statue that was collected before. Scene $FD lists nothing but these six actors (no player, no camera).
; 
; === TRIGGER ===
; Six scripts queue scene $FD with COP QueueMapChange: index 0 gs2E_crew2 (Gold Ship), 1 sg55_mystic_statue (Viper), 2 mu66_rama_spirits (Mu), 3 gw8A_sand_fanger (Great Wall), 4 pyDD_mystic_statue (Mummy Queen), 5 btDE_olman (Babel). Each first writes globalScriptIndex = its index, sourceSceneId ($0B12) = its own scene ($2E, $55, $66, $8A, $CD, $DE) and the return position in $0B08-$0B10 (tile X, tile Y, scroll parameters).
; 
; === TABLE statue_reward_table ===
; 6 entries of 4 bytes (3 fields + 1 tail byte, never read by the two actors):
; | Index | Flag | Sprite | Match | Boss / event | Trigger script |
; |-------|------|--------|-------|--------------|----------------|
; | 0 | $F8 | $3A | $00 | Gold Ship event | gs2E_crew2.asm |
; | 1 | $F9 | $3B | $01 | Viper | sg55_mystic_statue.asm |
; | 2 | $FA | $3C | $02 | Mu (Rama's spirits) | mu66_rama_spirits.asm |
; | 3 | $FB | $3D | $03 | Sand Fanger | gw8A_sand_fanger.asm |
; | 4 | $FC | $3E | $04 | Mummy Queen | pyDD_mystic_statue.asm |
; | 5 | $FD | $3F | $05 | Olman (Babel) | btDE_olman.asm |
; Flag = event flag index: flag N is bit (N AND 7) of byte $0A00 + N / 8, so $F8-$FD are bits 0-5 of the single byte $0A1F. Sprite = animation index ($28) in inventory_spritemap. Match = the globalScriptIndex value for which this entry is the statue being awarded (it equals the row number).
; 
; === ACTOR FLOW ===
; 1. Entry: joypadMaskStd |= $FFFC (every button hidden; this build's value, the vanilla $FFF0 is rewritten by transforms.json, probably to cover the remapped X bit $0004), NudgePosition(8, 8) plus (0, -8) when bit 4 of the spawn parameter is set (same record encoding and positions as inventory_statue_slot), metasprite inventory_spritemap. Initial flags $3000: hidden, and running in the display-filtered pass.
; 2. Screen setup by direct register writes: BG1 tilemap at VRAM word $0800 (BG1SC $08), BG2 tilemap at $0C00 (BG2SC $0C), main screen BG1 + BG2 + OBJ (TM $13), sub screen BG1 + OBJ (TS $11), colour math with the sub screen as the source (CGWSEL $82) added onto BG2 only (CGADSUB $02). There is no BGMODE write. srcCacheBgD+1 ($0676-$0677) is cleared to invalidate graphics cache slot D.
; 3. Every copy: index = low nibble of the parameter. TestFlagRaw(flag): set -> StatueRewardAlreadyClaimed (statue shown, idle). Otherwise match against globalScriptIndex: different -> StatueRewardNotThisStatue (stays hidden, idle).
; 4. The matching copy: SetFlagRaw (statue collected for good; inventory_statue_slot shows it from now on), animation frame set (still hidden), then 8 StatueRewardOrbitalSparkle actors with start angles $21, $41, ... $E1, $0101 (the loop ends when the angle word reaches $0101; only the low byte is an angle, so they are $20 apart).
; 5. Waiting: globalScriptIndex becomes a 180-frame countdown. Each frame it is decremented; at zero the ceremony jumps straight to step 7 (no confetti). While IsMusicPlaying (SPC transfer pending or the display-filter bit set) it waits. When that ends the counter is zeroed, WaitByte $0F, sound $2525 on both channels, then the orbitDiameter of the LAST sparkle spawned is polled each frame until it is 0.
; 6. Reveal: the hidden bit is cleared and 60 StatueRewardConfettiBurst actors are spawned, one per frame (LoopEnd yields every iteration). Each burst tests frameCounter AND 3 on its first tick and dies at once unless that is 0, so only about one burst in four is visible.
; 7. Exit: sceneNext = sourceSceneId (a nonzero sceneNext starts the scene change), warpDestX / warpDestY = $0B08 / $0B0C x 16, warpFacing = 3, warpScrollParams = $0B10, gfxCacheIdxA = $0002 (exit effect 2 = mosaic, enter effect 0 = fade) and gfxCacheIdxB = $0303 (speed 3 for both).
---------------------------------------------

?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'flag_helpers'
?INCLUDE 'inventory_spritemap'
?INCLUDE 'music_actors'
?INCLUDE 'sprite_composition'
?INCLUDE 'spriteset_enemies'

!frameCounter                   0036
!sceneNext                      0642
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!warpDestX                      064C
!warpDestY                      064E
!warpFacing                     0650
!warpScrollParams               0652
!joypadMaskStd                  065A
!srcCacheBgD                    0675
!globalScriptIndex              0AAC
!sourceSceneId                  0B12
!BG1SC                          2107
!BG2SC                          2108
!TM                             212C
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

statue_inventory_reward [
  actor-def < #00, #00, #30, {

; Actor entry (flow steps 1 and 2 of the block note): joypadMaskStd |= $FFFC (every button hidden), NudgePosition (8, 8), metasprite and flags setup, then the direct screen register writes.

  StatueRewardEntry:
    LDA #$FFFC            ; Hide every button (build value $FFFC; transforms.json rewrites the vanilla $FFF0); the ceremony takes no input
    TSB $joypadMaskStd
    COP [NudgePosition] ( #08, #08 )
    COP [SetMetasprite] ( @inventory_spritemap )
    SEP #$20
    LDA #$08
    STA $BG1SC            ; BG1SC $08 / BG2SC $0C: BG1 tilemap at VRAM word $0800, BG2 at $0C00 (32x32)
    LDA #$0C
    STA $BG2SC
    LDA #$13
    STA $TM               ; TM $13: main screen BG1 + BG2 + OBJ; TS $11: sub screen BG1 + OBJ
    LDA #$11
    STA $TS
    LDA #$82
    STA $CGWSEL           ; CGWSEL $82: colour math from the sub screen; CGADSUB $02: add onto BG2 only
    LDA #$02
    STA $CGADSUB
    REP #$20
    STZ $srcCacheBgD+1    ; Clear $0676-$0677 (address high byte and bank of graphics cache slot D): that slot reloads
    LDA $0E               ; Spawn parameter (spawn byte 2 >> 1) kept in $24; bit 4 marks a top-row pedestal, moved 8 px up
    STA $24
    BIT #$0010
    BEQ loc_00CD9D
    COP [NudgePosition] ( #00, #F8 )

  loc_00CD9D:
    LDA #$2000            ; $0E = $2000: the OAM attribute word, replacing the spawn parameter
    STA $0E
    PHX                   ; Save the actor slot; X becomes the table offset (low nibble x 4)
    LDA $24
    AND #$000F
    ASL 
    ASL 
    TAX 
    LDA $@statue_reward_table, X ; Entry +0: event flag index; TestFlagRaw returns carry set when this statue is already collected
    AND #$00FF
    JSL $@flag_helpers.TestFlagRaw
    BCC loc_00CDBB
    JMP $&StatueRewardAlreadyClaimed ; Already collected: show only

  loc_00CDBB:
    LDA $@statue_reward_table+2, X ; Entry +2: match value, compared with globalScriptIndex (set by the trigger script): equal runs the ceremony, otherwise stay hidden
    AND #$00FF
    CMP $globalScriptIndex
    BEQ loc_00CDCA
    JMP $&StatueRewardNotThisStatue

  loc_00CDCA:
    LDA $@statue_reward_table, X
    AND #$00FF
    JSL $@flag_helpers.SetFlagRaw ; SetFlagRaw: statue collected for good (bits 0-5 of $0A1F); inventory_statue_slot shows it from now on
    LDA $@statue_reward_table+1, X ; Entry +1: sprite (animation index $3A-$3F), frame counter $2A = 0; stage the frame, which stays hidden until the sparkles converge
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@sprite_composition.UpdateActorAnimation
    LDA #$0001
    STA $26               ; $26 = angle counter for the sparkles, starting at 1

  loc_00CDEA:
    COP [SpawnAfterFlags] ( @StatueRewardOrbitalSparkle, #$1802 ) ; Spawn one sparkle (flags $1802)
    LDA $26
    CLC 
    ADC #$0020            ; Next sparkle $20 further round (256 = one turn)
    STA $26
    STA $0026, Y          ; Hand the new sparkle its start angle in its $26
    CMP #$0101            ; The angle word reaches $0101 after 8 sparkles
    BNE loc_00CDEA
    TYA                   ; Remember the last sparkle's slot in $26: its orbitDiameter is polled below
    STA $26
    LDA #$00B4            ; globalScriptIndex is reused as a 180-frame countdown
    STA $globalScriptIndex
    COP [SetEntryHere]    ; Per-frame wait loop A: count down, wait for the jingle
    DEC $globalScriptIndex
    BEQ loc_00CE46        ; Timeout: leave without the confetti
    JSL $@music_actors.IsMusicPlaying ; Carry set = a jingle or music transfer is still active
    BCC loc_00CE18
    RTL 

  loc_00CE18:
    LDA #$0000            ; Jingle over: zero the counter, short pause, sound $25 on both channels
    STA $globalScriptIndex
    COP [WaitByte] ( #0F )
    COP [PlaySoundBoth] ( #$2525 )
    COP [SetEntryHereAndYield] ; Resume point: the next lines run once per frame
    PHX 
    LDX $26               ; Poll the orbitDiameter of the last sparkle (slot in $26): 0 means the sparkles have converged
    LDA $orbitDiameter, X
    PLX 
    CMP #$0000
    BEQ loc_00CE35
    RTL 

  loc_00CE35:
    LDA #$2000            ; Converged: reveal the statue (clear the hidden bit)
    TRB $10
    COP [LoopStart] ( #3C ) ; 60 iterations; LoopEnd yields each time, so one burst per frame
    COP [SpawnAfterFlags] ( @StatueRewardConfettiBurst, #$1802 ) ; Spawn one confetti burst at the statue (flags $1802)
    COP [LoopEnd]

  loc_00CE46:
    LDA $sourceSceneId    ; Return to the scene that started the ceremony: a nonzero sceneNext starts the scene change
    STA $sceneNext
    LDA $0B08             ; $0B08 / $0B0C = return tile X / Y saved by the trigger script; x 16 gives the warp destination in pixels
    ASL 
    ASL 
    ASL 
    ASL 
    STA $warpDestX
    LDA $0B0C
    ASL 
    ASL 
    ASL 
    ASL 
    STA $warpDestY
    LDA #$0003            ; warpFacing = 3; warpScrollParams = $0B10 (saved by the trigger script)
    STA $warpFacing
    LDA $0B10
    STA $warpScrollParams
    LDA #$0303            ; gfxCacheIdxB $0303: speed 3 for exit and enter; gfxCacheIdxA $0002: exit effect 2 (mosaic), enter effect 0 (fade)
    STA $gfxCacheIdxB
    LDA #$0002
    STA $gfxCacheIdxA
    COP [SetEntryHere]    ; Re-entry point; nothing more to do until the scene changes
    RTL 
} >
]

---------------------------------------------
; This statue was collected before the ceremony started: reached by JMP with X = table byte offset and the actor slot on the stack. Sets the frame, shows the statue and idles.

StatueRewardAlreadyClaimed {
    LDA $@statue_reward_table+1, X ; Entry +1: sprite (animation index), frame counter 0; stage the statue frame
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@sprite_composition.UpdateActorAnimation
    LDA #$2000            ; Show the statue: clear the hidden bit
    TRB $10
    COP [SetEntryHere]    ; Idle for the rest of the scene
    RTL 
}

---------------------------------------------
; A statue that is not the one being awarded (match byte differs from globalScriptIndex, and its own flag is still clear): restores X and idles hidden. (The old label StatueRewardWrongTab borrowed 'tab' from the inventory slot logic; there is no tab in scene $FD.)

StatueRewardNotThisStatue {
    PLX 
    COP [SetEntryHere]
    RTL 
}

---------------------------------------------
; Statue table: flag index, sprite (animation index), match value and one tail byte per entry. Read by this actor and inventory_statue_slot (index x 4).

statue_reward_table [
  statue-reward < #F8, #3A, #00 >   ;00
  statue-reward < #F9, #3B, #01 >   ;01
  statue-reward < #FA, #3C, #02 >   ;02
  statue-reward < #FB, #3D, #03 >   ;03
  statue-reward < #FC, #3E, #04 >   ;04
  statue-reward < #FD, #3F, #05 >   ;05
]

---------------------------------------------
; Sparkle that spirals in toward the statue. Start diameter $FC, start angle = the value the ceremony wrote into its $26. Each tick: position = the ceremony actor + orbit(angle, diameter) (ApplyOrbitalOffsetFromRef), angle + 4, diameter - 2; the actor dies once the diameter is 0 (about 126 ticks).

StatueRewardOrbitalSparkle {
    COP [SetSpritePriority] ( #30 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSprAndHitbox] ( #02 )
    LDA #$00FC            ; Start diameter $FC; start angle = the value the ceremony wrote into this actor's $26
    STA $orbitDiameter, X
    LDA $26
    STA $orbitAngle, X

  loc_00CEC7:
    COP [SetEntryHere]
    COP [AnimOneFrame]    ; AnimOneFrame stages the next frame without yielding; its hold time goes to $08, and frame counter 0 means stage another
    LDA $2A
    BEQ loc_00CEC7
    LDA $08               ; Hold time + 1 = ticks to spend on this frame, counted down in $26; $08 is cleared because this script paces itself
    INC 
    STA $26
    STZ $08
    COP [SetEntryHere]
    DEC $26               ; Count the tick; hold over: stage the next frame
    BMI loc_00CEC7
    LDY $24               ; Y = $24 = the ceremony actor (CopyActorState stores the spawner's slot there)
    JSL $@ApplyOrbitalOffsetFromRef ; Position = ceremony actor + orbit(angle, diameter)
    LDA $orbitAngle, X
    CLC 
    ADC #$0004            ; Angle + 4 per tick
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    BEQ loc_00CEFD
    SEC 
    SBC #$0002            ; Diameter - 2 per tick; a diameter of 0 means finished (Die below)
    STA $orbitDiameter, X
    RTL 

  loc_00CEFD:
    COP [Die]
}

---------------------------------------------
; One short effect at the statue: X within -8..+7 px, Y 8 px up, frame #02 played once. It runs only when frameCounter AND 3 = 0 on its first tick; otherwise it dies immediately.

StatueRewardConfettiBurst {
    LDA $frameCounter     ; Only one frame in four may show a burst (frameCounter AND 3); the others die at once
    AND #$0003
    BNE loc_00CF27
    COP [RngByte]         ; X = ceremony X + (RNG AND $0F) - 8: -8..+7 px
    AND #$000F
    SEC 
    SBC #$0008
    CLC 
    ADC $14
    STA $14
    LDA $16               ; Y = 8 px above the statue
    SEC 
    SBC #$0008
    STA $16
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #02 ) ; Frame #02
    COP [AnimOnce]

  loc_00CF27:
    COP [Die]
}