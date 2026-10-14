; Full-screen statue-collection reward ceremony actor on scene $FD (52569–53033, Bank 00).
; 
; Reconfigures BG mode/registers for the inventory display, validates statue flags and inventory count ($0AAC), plays music wait and sound, spawns orbital particle effects, and sets scene transition parameters for return to gameplay. Awards mystic statues #00–#05 with animated reveal. Counterpart to inventory_statue_slot for the initial collection moment.
; 
; === STATUE REWARD TABLE (statue_reward_00CE97) ===
; 
; 6 entries × 4 bytes (statue-reward struct: 3 data + 1 tail), shared with inventory_statue_slot:
; 
; | Index | Flag | Sprite | Match | Boss / Event | Location |
; |-------|------|--------|-------|--------------|----------|
; | 0 | $F8 | $3A | $00 | Gold Ship event | gs2E_crew2.asm |
; | 1 | $F9 | $3B | $01 | Viper boss | sg55_mystic_statue.asm |
; | 2 | $FA | $3C | $02 | Vampires/Rama | mu66_rama_spirits.asm |
; | 3 | $FB | $3D | $03 | Sand Fanger | gw8A_sand_fanger.asm |
; | 4 | $FC | $3E | $04 | Mummy Queen | pyDD_mystic_statue.asm |
; | 5 | $FD | $3F | $05 | Olman/Babel | btDE_olman.asm |
; 
; Flag = event flag index in the $0A00 eventFlags bitfield (raw, no base offset).
; Sprite = inventory_spritemap frame index for the statue icon.
; Match = globalScriptIndex ($0AAC) value that must match for this entry to be the one currently being awarded.
; 
; === COLLECTION FLOW ===
; 
; 1. TRIGGER: A boss/event actor (e.g., sg55_mystic_statue, gw8A_sand_fanger) sets globalScriptIndex ($0AAC) to 0–5, stores sourceSceneId ($0B12) and return position ($0B08–$0B10), then COP QueueMapChange to scene $FD.
; 
; 2. SCENE $FD LOAD: All 6 statue_inventory_reward actors spawn (same positions as scene $FF inventory pedestals). Each uses the same $0E parameter encoding as inventory_statue_slot.
; 
; 3. FLAG CHECK: Each actor indexes statue_reward_00CE97 by its low nibble, loads the flag byte, and calls TestFlagRaw. Already-collected statues enter StatueRewardAlreadyClaimed (display only, no ceremony). Uncollected statues check the match byte against globalScriptIndex — mismatches enter StatueRewardWrongTab (hidden, idle loop).
; 
; 4. AWARD: The one matching actor calls SetFlagRaw to permanently set the event flag ($F8–$FD) in the eventFlags array at $0A00. This is the moment the statue becomes 'collected' — from this point on, inventory_statue_slot will display it.
; 
; 5. CEREMONY: Sets sprite frame, spawns 8 StatueRewardOrbitalSparkle actors in a ring (orbitAngle spaced by $20, orbitDiameter starting at $FC, spiraling inward at -2/frame). Uses globalScriptIndex as a 180-frame countdown timer ($00B4), waiting for IsMusicPlaying to return false.
; 
; 6. CONFETTI: After sparkles converge (orbitDiameter reaches 0), clears hidden flag, spawns 60 ($3C) StatueRewardConfettiBurst actors (random ±8 pixel scatter, one per 4 frames via frameCounter AND 3).
; 
; 7. RETURN: Copies sourceSceneId → sceneNext, restores player position from $0B08–$0B10 (tile×16 → pixel), sets gfxCacheIdxB = $0303 and gfxCacheIdxA = $0002 (mosaic dissolve transition). Enters final SetEntryHere loop.
; 
; === EVENT FLAG STORAGE ===
; 
; Flags $F8–$FD are raw event flags (no base offset) stored at byte offsets $1F–$1F in the eventFlags ($0A00) array:
;   $F8 = byte 31 ($0A1F), bit 0
;   $F9 = byte 31 ($0A1F), bit 1
;   $FA = byte 31 ($0A1F), bit 2
;   $FB = byte 31 ($0A1F), bit 3
;   $FC = byte 31 ($0A1F), bit 4
;   $FD = byte 31 ($0A1F), bit 5
; 
; All six flags pack into a single byte at $0A1F. These persist in save data and survive scene transitions.
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

  code_00CD5C:
    LDA #$FFFC            ; Reward entry: mask joypad $FFFC, NudgePosition(8,8), SetMetasprite(@inventory_spritemap)
    TSB $joypadMaskStd
    COP [NudgePosition] ( #08, #08 )
    COP [SetMetasprite] ( @inventory_spritemap )
    SEP #$20
    LDA #$08
    STA $BG1SC
    LDA #$0C
    STA $BG2SC
    LDA #$13              ; Load $0E into $24; test bit 4 — if set, NudgePosition(0,$F8) for top-row vertical offset
    STA $TM
    LDA #$11
    STA $TS
    LDA #$82
    STA $CGWSEL
    LDA #$02
    STA $CGADSUB
    REP #$20              ; LDA #$2000 → STA $0E; PHX; extract statue index from $24 AND $000F × 4
    STZ $0676
    LDA $0E
    STA $24
    BIT #$0010
    BEQ loc_00CD9D
    COP [NudgePosition] ( #00, #F8 )

  loc_00CD9D:
    LDA #$2000            ; Index statue_reward_00CE97: load flag byte, TestFlagRaw — already collected?
    STA $0E
    PHX 
    LDA $24
    AND #$000F
    ASL 
    ASL 
    TAX                   ; If flag set → JMP StatueRewardAlreadyClaimed (display only, skip ceremony)
    LDA $@statue_reward_00CE97, X
    AND #$00FF
    JSL $@flag_helpers.TestFlagRaw
    BCC loc_00CDBB
    JMP $&StatueRewardAlreadyClaimed

  loc_00CDBB:
    LDA $@statue_reward_00CE97+2, X ; If not collected: load match byte from table, CMP globalScriptIndex ($0AAC)
    AND #$00FF
    CMP $globalScriptIndex
    BEQ loc_00CDCA
    JMP $&StatueRewardWrongTab

  loc_00CDCA:
    LDA $@statue_reward_00CE97, X ; *** SetFlagRaw — permanently marks the statue as collected (event flags $F8–$FD) ***
    AND #$00FF
    JSL $@flag_helpers.SetFlagRaw
    LDA $@statue_reward_00CE97+1, X
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@sprite_composition.UpdateActorAnimation
    LDA #$0001
    STA $26

  loc_00CDEA:
    COP [SpawnAfterFlags] ( @StatueRewardOrbitalSparkle, #$1802 ) ; Spawn 8 StatueRewardOrbitalSparkle actors in a ring (orbitAngle += $20 per spawn)
    LDA $26
    CLC 
    ADC #$0020
    STA $26
    STA $0026, Y
    CMP #$0101
    BNE loc_00CDEA
    TYA 
    STA $26
    LDA #$00B4
    STA $globalScriptIndex
    COP [SetEntryHere]
    DEC $globalScriptIndex
    BEQ loc_00CE46
    JSL $@music_actors.IsMusicPlaying
    BCC loc_00CE18
    RTL 

  loc_00CE18:
    LDA #$0000            ; Music done: zero globalScriptIndex, WaitByte($0F), PlaySoundBoth($2525)
    STA $globalScriptIndex
    COP [WaitByte] ( #0F )
    COP [PlaySoundBoth] ( #$2525 )
    COP [SetEntryHereAndYield]
    PHX 
    LDX $26
    LDA $orbitDiameter, X
    PLX 
    CMP #$0000
    BEQ loc_00CE35
    RTL 

  loc_00CE35:
    LDA #$2000            ; Poll orbitDiameter of sparkle chain head — wait for convergence to zero
    TRB $10
    COP [LoopStart] ( #3C )
    COP [SpawnAfterFlags] ( @StatueRewardConfettiBurst, #$1802 ) ; Sparkle converged: clear hidden, spawn $3C (60) confetti burst actors
    COP [LoopEnd]

  loc_00CE46:
    LDA $sourceSceneId    ; Exit: copy sourceSceneId→sceneNext, restore warp position from $0B08–$0B10
    STA $sceneNext
    LDA $0B08
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
    LDA #$0003
    STA $warpFacing
    LDA $0B10
    STA $warpScrollParams ; Set gfxCacheIdxB=$0303, gfxCacheIdxA=$0002 (mosaic dissolve transition); final loop
    LDA #$0303
    STA $gfxCacheIdxB
    LDA #$0002
    STA $gfxCacheIdxA
    COP [SetEntryHere]
    RTL                   ; StatueRewardAlreadyClaimed: load sprite, UpdateActorAnimation, clear hidden, idle loop
} >
]

StatueRewardAlreadyClaimed {
    LDA $@statue_reward_00CE97+1, X
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@sprite_composition.UpdateActorAnimation
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    RTL 
}

StatueRewardWrongTab {
    PLX 
    COP [SetEntryHere]
    RTL 
}

statue_reward_00CE97 [
  statue-reward < #F8, #3A, #00 >   ;00
  statue-reward < #F9, #3B, #01 >   ;01
  statue-reward < #FA, #3C, #02 >   ;02
  statue-reward < #FB, #3D, #03 >   ;03
  statue-reward < #FC, #3E, #04 >   ;04
  statue-reward < #FD, #3F, #05 >   ;05
]

StatueRewardOrbitalSparkle {
    COP [SetSpritePriority] ( #30 ) ; StatueRewardOrbitalSparkle: sparkle actor orbiting the awarded statue
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSprAndHitbox] ( #02 )
    LDA #$00FC
    STA $orbitDiameter, X
    LDA $26
    STA $orbitAngle, X

  loc_00CEC7:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_00CEC7
    LDA $08
    INC 
    STA $26
    STZ $08
    COP [SetEntryHere]
    DEC $26
    BMI loc_00CEC7
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    LDA $orbitAngle, X
    CLC 
    ADC #$0004            ; StatueRewardConfettiBurst: random ±8 scatter, one per 4 frames; Die after AnimOnce
    STA $orbitAngle, X
    LDA $orbitDiameter, X
    BEQ loc_00CEFD
    SEC 
    SBC #$0002
    STA $orbitDiameter, X
    RTL 

  loc_00CEFD:
    COP [Die]
}

StatueRewardConfettiBurst {
    LDA $frameCounter
    AND #$0003
    BNE loc_00CF27
    COP [RngByte]
    AND #$000F
    SEC 
    SBC #$0008
    CLC 
    ADC $14
    STA $14
    LDA $16
    SEC 
    SBC #$0008
    STA $16
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]

  loc_00CF27:
    COP [Die]
}