; Psycho Slider glide triggers (Bank 00): five trigger actor-defs (SliderGlideTriggerWest, East, North, South and NorthEntry; 29 actor-spawn records in scene_actors, one more through awB2_stair_climb, which JumpFar's to SliderGlideTriggerNorthMain) plus the helpers LockPlayerForClimb, UnlockPlayerAfterClimb and RestorePlayerControl (the last is also called by three ramp exits in ramps.asm).
; 
; === What a trigger detects ===
; A trigger runs every frame in its own slot (D = trigger: $14/$16 = its pixel position, $0E = glide length). Y = the player actor. It fires only while Will is Psycho Sliding (RunAttackNS/RunAttackEW in player_character) through its tile: the player's animation index ($28) must be one of the two looping frames of ONE slide direction, and IsPlayerSliderSpriteBank requires the player's sprite bank ($7F0008) to be $8F, the will_alt spriteset that SetPlayerSpriteDirect #04 selects at the start of every slide.
; Slide animation indices (will_alt spriteset): south $0C start / $0D loop / $0E finish, north $0F/$10/$11, west $12/$13/$14, east $15/$16/$17 (positive speed = south or east, negative = north or west). The old comments called these 'walk frames' and the bank check a 'walking state'; neither is true.
; Each trigger is named for the slide direction it reacts to: SliderGlideTriggerWest = WEST slide ($12/$13, glide X -4 per frame), SliderGlideTriggerEast = EAST slide ($15/$16, X +4), SliderGlideTriggerNorth = NORTH slide ($0F/$10, Y -4), SliderGlideTriggerSouth = SOUTH slide ($0C/$0D, Y +4). The SliderGlideWest/East/North/South routines move the player the same way the slide was already moving.
; 
; === Geometry ===
; Slide axis: exact pixel equality with the trigger (X for the West/East triggers, Y for the North/South triggers). Lateral axis: a 32-pixel window, trigger - 7 .. trigger + $18 inclusive (compare is trigger - 8 < player <= trigger - 8 + $20); the old '+/-$20' wording is wrong.
; 
; === The glide ===
; On a hit the trigger overwrites the player's entry pointer ($00/$02 of the player actor) with the matching SliderGlide routine and calls LockPlayerForClimb: $0E (the spawn record's type byte >> 1, InitActorFromSceneData mode 1) x 4 is stored as a frame countdown in the PLAYER's statsPtr ($7F0020), the player's velocity words are zeroed, D-pad input is masked (joypadMaskStd $0F00) and playerFlags $0800 is set. The player actor then runs that routine: once, $10 |= $2200 ($2000 = script-driven actor path, $0200 = slide-active flag that RunAttackFlagSetup also sets; its reader is unknown) and $10 bit $0008 (collision-aware movement) is cleared; then every frame the player's X or Y is changed by 4 px directly (no collision test) until the countdown reaches 0: 4 x $0E frames = 16 px per $0E unit (a $0E of 0 would run 65,536 frames). There is no animation during the glide; the slide's looping frame stays on screen.
; Landing: clear $2000, stage the FINISH frame of the same slide ($14 west, $17 east, $11 north, $0E south), AnimOnce, then UnlockPlayerAfterClimb. That routine does what RunAttackCleanup does (clear $0200, consume the attack bit in joypadHeld, clear playerFlags $0002) plus clearing climbStateData ($09E0, in fact the ability damage bonus that attack_ability_system sets for the slide), re-enabling collision-aware movement and un-masking joypadMaskStd, then RestorePlayerControl returns the player to PlayerIdleEntry.
; 
; db-us/transforms.json (slider_glide) rewrites two vanilla constants: the attack-bit immediate (the vanilla ROM has a different bit, $0080 here after the button remap) and the joypadMaskStd consumption mask (ends in $FC here instead of the vanilla $F0). Comments here describe the post-transform values. Block is marked non-movable because of the tight $& coupling between triggers and climb handlers.
---------------------------------------------

?BANK 00

?INCLUDE 'player_character'

!joypadHeld                     0658
!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!climbStateData                 09E0
!statsPtr                       7F0020

---------------------------------------------

; Glide trigger for a WEST-moving Psycho Slide (player animation $12/$13). Needs player X == trigger X exactly and player Y inside the 32-px window trigger Y - 7 .. trigger Y + $18, sprite bank $8F. On success the player is sent to SliderGlideWest (X -4 per frame) and locked by LockPlayerForClimb. 1 spawn site.

SliderGlideTriggerWest [
  actor-def < #00, #00, #20, {

  code_00D0D4:
    LDY $playerActor      ; Y = player actor. Fires for a WEST-moving Psycho Slide (anim $12/$13): X must match exactly, Y inside a 32-px window
    LDA $16               ; Load trigger Y; check if player is within trigger's vertical band
    SEC                   ; Trigger Y − 8: start of vertical proximity zone
    SBC #$0008            ; Subtract 8px — start of proximity zone above trigger
    CMP $0016, Y          ; Passes only if trigger Y - 8 < player Y
    BCC loc_00D0E3
    RTL 

  loc_00D0E3:
    CLC 
    ADC #$0020            ; Trigger Y - 8 + $20 = trigger Y + $18: upper edge of the window
    CMP $0016, Y          ; Passes only if player Y <= trigger Y + $18 (window is 32 px wide, trigger Y - 7 .. + $18)
    BCS loc_00D0ED
    RTL 

  loc_00D0ED:
    LDA $0014, Y          ; Slide axis: player X must equal trigger X exactly (pixel compare, not a tile column)
    CMP $14               ; Exact pixel X match with the trigger
    BEQ loc_00D0F5
    RTL 

  loc_00D0F5:
    JSR $&IsPlayerSliderSpriteBank ; Player sprite bank must be $8F (will_alt spriteset used by the Psycho Slider); carry set rejects
    BCC loc_00D0FB
    RTL 

  loc_00D0FB:
    LDA $0028, Y          ; Player animation index: $12 = west slide start, $13 = west slide loop
    CMP #$0012
    BEQ loc_00D109
    CMP #$0013
    BEQ loc_00D109
    RTL 

  loc_00D109:
    LDA #$&SliderGlideWest ; All checks passed: redirect player entry to SliderGlideWest script
    STA $0000, Y
    LDA #$*SliderGlideWest
    STA $0002, Y
    JSR $&LockPlayerForClimb ; Store glide length ($0E x 4 frames) in the player's statsPtr, zero its velocity, mask the D-pad
    RTL 
} >
]

---------------------------------------------
; Glide trigger for an EAST-moving Psycho Slide (player animation $15/$16). Needs player X == trigger X and player Y in the window trigger Y - 7 .. trigger Y + $18. On success the player is sent to SliderGlideEast (X +4 per frame). 1 spawn site.

SliderGlideTriggerEast [
  actor-def < #00, #00, #20, {

  code_00D11C:
    LDY $playerActor
    LDA $16
    SEC 
    SBC #$0008            ; Fires for an EAST-moving Psycho Slide (anim $15/$16): X exact, Y inside the same 32-px window
    CMP $0016, Y
    BCC loc_00D12B
    RTL 

  loc_00D12B:
    CLC 
    ADC #$0020
    CMP $0016, Y
    BCS loc_00D135
    RTL 

  loc_00D135:
    LDA $0014, Y
    CMP $14
    BEQ loc_00D13D
    RTL 

  loc_00D13D:
    JSR $&IsPlayerSliderSpriteBank
    BCC loc_00D143
    RTL 

  loc_00D143:
    LDA $0028, Y          ; Player animation index: $15 = east slide start, $16 = east slide loop
    CMP #$0015            ; East slide frames: $15 or $16
    BEQ loc_00D151
    CMP #$0016
    BEQ loc_00D151
    RTL 

  loc_00D151:
    LDA #$&SliderGlideEast ; Redirect player to SliderGlideEast
    STA $0000, Y
    LDA #$*SliderGlideEast
    STA $0002, Y
    JSR $&LockPlayerForClimb ; Lock the player and arm the glide (SliderGlideEast: X +4 per frame)
    RTL 
} >
]

---------------------------------------------
; Entry variant of SliderGlideTriggerNorth: shifts the trigger itself by (-8, 0) pixels once (NudgePosition on the trigger's own slot), then continues into SliderGlideTriggerNorthMain. 1 spawn site.

SliderGlideTriggerNorthEntry [
  actor-def < #00, #00, #20, {

; Entry variant in SliderGlideTriggerNorthEntry: COP NudgePosition shifts the trigger actor by (-8, 0) once, then BRA into SliderGlideTriggerNorthMain for the normal north-slide gate.

  SliderGlideTriggerNorthOffset:
    COP [NudgePosition] ( #F8, #00 ) ; Shifts the trigger itself by (-8, 0) pixels once, then runs the normal North check
    BRA SliderGlideTriggerNorthMain
} >
]

---------------------------------------------
; Glide trigger for a NORTH-moving Psycho Slide (player animation $0F/$10). Needs player Y == trigger Y exactly and player X in the window trigger X - 7 .. trigger X + $18. Starts with SetEntryHere so the check repeats every frame. On success the player is sent to SliderGlideNorth (Y -4 per frame). 12 spawn sites (plus the awB2 JumpFar into SliderGlideTriggerNorthMain).

SliderGlideTriggerNorth [
  actor-def < #00, #00, #20, {

; Main per-frame entry of SliderGlideTriggerNorth after SetEntryHere: requires the player in a 32 px X window (trigger X minus 8 through plus $18), Y equal to trigger Y, Psycho Slide sprite bank, and animation $0F or $10, then redirects the player to SliderGlideNorth and calls LockPlayerForClimb; otherwise returns with RTL.

  SliderGlideTriggerNorthMain:
    COP [SetEntryHere]    ; Set entry for per-frame execution (re-check every frame)
    LDY $playerActor
    LDA $14
    SEC 
    SBC #$0008            ; Fires for a NORTH-moving Psycho Slide (anim $0F/$10): X inside a 32-px window (trigger X - 7 .. + $18), Y exact
    CMP $0014, Y
    BCC loc_00D17E
    RTL 

  loc_00D17E:
    CLC 
    ADC #$0020
    CMP $0014, Y
    BCS loc_00D188
    RTL 

  loc_00D188:
    LDA $0016, Y          ; Slide axis: player Y must equal trigger Y exactly
    SEC 
    SBC $16
    BEQ loc_00D191
    RTL 

  loc_00D191:
    JSR $&IsPlayerSliderSpriteBank
    BCC loc_00D197
    RTL 

  loc_00D197:
    LDA $0028, Y          ; Player animation index: $0F = north slide start, $10 = north slide loop
    CMP #$000F
    BEQ loc_00D1A5
    CMP #$0010
    BEQ loc_00D1A5
    RTL 

  loc_00D1A5:
    LDA #$&SliderGlideNorth ; Redirect player to SliderGlideNorth
    STA $0000, Y
    LDA #$*SliderGlideNorth
    STA $0002, Y
    JSR $&LockPlayerForClimb
    RTL 
} >
]

---------------------------------------------
; Glide trigger for a SOUTH-moving Psycho Slide (player animation $0C/$0D). Needs player Y == trigger Y exactly and player X in the window trigger X - 7 .. trigger X + $18. On success the player is sent to SliderGlideSouth (Y +4 per frame). 14 spawn sites, the most used trigger.

SliderGlideTriggerSouth [
  actor-def < #00, #00, #20, {

  code_00D1B8:
    LDY $playerActor
    LDA $14
    SEC 
    SBC #$0008            ; Fires for a SOUTH-moving Psycho Slide (anim $0C/$0D): X inside a 32-px window (trigger X - 7 .. + $18), Y exact
    CMP $0014, Y
    BCC loc_00D1C7
    RTL 

  loc_00D1C7:
    CLC 
    ADC #$0020
    CMP $0014, Y
    BCS loc_00D1D1
    RTL 

  loc_00D1D1:
    LDA $0016, Y          ; Slide axis: player Y must equal trigger Y exactly
    SEC                   ; South trigger: exact Y row match
    SBC $16
    BEQ loc_00D1DA
    RTL 

  loc_00D1DA:
    LDY $playerActor
    JSR $&IsPlayerSliderSpriteBank
    BCC loc_00D1E3
    RTL 

  loc_00D1E3:
    LDY $playerActor
    LDA $0028, Y          ; Player animation index: $0C = south slide start, $0D = south slide loop
    CMP #$000C
    BEQ loc_00D1F4
    CMP #$000D
    BEQ loc_00D1F4
    RTL 

  loc_00D1F4:
    LDA #$&SliderGlideSouth ; Redirect player to SliderGlideSouth
    STA $0000, Y
    LDA #$*SliderGlideSouth
    STA $0002, Y
    JSR $&LockPlayerForClimb
    RTL 
} >
]

---------------------------------------------
; Helper for the triggers: Y = player actor; carry clear when the player's sprite bank byte ($7F0008) is $8F, carry set otherwise. $8F is the bank of the will_alt spriteset (body_table entries 4 and 5), which the Psycho Slider selects with SetPlayerSpriteDirect #04; the normal Will spriteset is bank $95. It is not a 'move state'.

IsPlayerSliderSpriteBank {
    PHX                   ; Y = player actor (set by the trigger). Only the sprite BANK is tested, not a move state
    TYX 
    SEP #$20              ; Switch to 8-bit A for single-byte state comparison
    LDA $7F0008, X        ; $7F0008 = bank byte of the player's spriteset pointer ($7F0006)
    CMP #$8F              ; $8F = will_alt spriteset (body_table 4 = Psycho Slider poses, 5 = ability poses); normal Will is bank $95
    REP #$20
    BEQ loc_00D215
    PLX 
    SEC                   ; Carry set = reject (not in the will_alt spriteset)
    RTS 

  loc_00D215:
    PLX 
    CLC                   ; Carry clear = accept
    RTS 
}

---------------------------------------------
; Player-side glide for a west slide: entry flags once ($10 |= $2200, bit $0008 cleared), then X -4 per frame while the statsPtr countdown runs; at 0 it leaves script-driven mode, stages the west slide's finish frame $14 and calls UnlockPlayerAfterClimb.

SliderGlideWest {
    LDA #$2200            ; Once on entry: $2000 = script-driven actor path, $0200 = slide-active flag (also set by RunAttackFlagSetup; reader unknown)
    TSB $10
    LDA #$0008            ; Clear $10 bit $0008 (collision-aware movement) for the glide; UnlockPlayerAfterClimb sets it again
    TRB $10
    COP [SetEntryHere]
    LDA $14               ; West glide: player X -4 per frame, written directly (no collision test)
    SEC 
    SBC #$0004
    STA $14
    LDA $statsPtr, X      ; Frame countdown stored by LockPlayerForClimb (the player's statsPtr reused)
    DEC 
    BEQ loc_00D238        ; Counter reached zero → play landing sprite and unlock
    STA $statsPtr, X
    RTL 

  loc_00D238:
    LDA #$2000            ; Glide finished: leave script-driven mode, then pose the finish frame of the west slide
    TRB $10
    COP [StageSpriteFrame] ( #14 ) ; $14 = finish frame of the west Psycho Slide (will_alt spriteset)
    COP [AnimOnce]
    JSR $&UnlockPlayerAfterClimb
    RTL 
}

---------------------------------------------
; Player-side glide for an east slide: X +4 per frame; finish frame $17.

SliderGlideEast {
    LDA #$2200            ; Once on entry: script-driven path + slide-active flags (same as SliderGlideWest)
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryHere]
    LDA $14               ; East glide: player X +4 per frame, written directly
    CLC 
    ADC #$0004
    STA $14
    LDA $statsPtr, X      ; Frame countdown stored by LockPlayerForClimb
    DEC 
    BEQ loc_00D266
    STA $statsPtr, X
    RTL 

  loc_00D266:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #17 ) ; $17 = finish frame of the east Psycho Slide
    COP [AnimOnce]
    JSR $&UnlockPlayerAfterClimb
    RTL 
}

---------------------------------------------
; Player-side glide for a north slide: Y -4 per frame (up the screen); finish frame $11.

SliderGlideNorth {
    LDA #$2200            ; Once on entry: script-driven path + slide-active flags (same as SliderGlideWest)
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryHere]
    LDA $16               ; North glide: player Y -4 per frame (up the screen), written directly
    SEC 
    SBC #$0004
    STA $16
    LDA $statsPtr, X      ; Frame countdown stored by LockPlayerForClimb
    DEC 
    BEQ loc_00D294
    STA $statsPtr, X
    RTL 

  loc_00D294:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #11 ) ; $11 = finish frame of the north Psycho Slide
    COP [AnimOnce]
    JSR $&UnlockPlayerAfterClimb
    RTL 
}

---------------------------------------------
; Player-side glide for a south slide: Y +4 per frame (down the screen); finish frame $0E.

SliderGlideSouth {
    LDA #$2200            ; Once on entry: script-driven path + slide-active flags (same as SliderGlideWest)
    TSB $10
    LDA #$0008
    TRB $10
    COP [SetEntryHere]
    LDA $16               ; South glide: player Y +4 per frame (down the screen), written directly
    CLC 
    ADC #$0004
    STA $16
    LDA $statsPtr, X      ; Frame countdown stored by LockPlayerForClimb
    DEC 
    BEQ loc_00D2C2
    STA $statsPtr, X
    RTL 

  loc_00D2C2:
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #0E ) ; $0E = finish frame of the south Psycho Slide
    COP [AnimOnce]
    JSR $&UnlockPlayerAfterClimb
    RTL 
}
---------------------------------------------

; Runs in the TRIGGER's context (D = trigger) right after a hit. Stores $0E x 4 (the glide length in frames; 4 px per frame, so 16 px per unit of $0E) in the PLAYER's statsPtr ($7F0020) as a countdown, zeroes the player's $2C/$2E/$08, masks the D-pad ($0F00 into joypadMaskStd) and sets playerFlags $0800 (script/ability lock). The countdown is left at 1 when the glide ends (the zero is never stored back).

LockPlayerForClimb {
    LDA $0E               ; D = trigger: $0E = glide length in units of 16 px (spawn type byte >> 1 for odd type bytes)
    ASL                   ; ASL ×2: step count = param × 4 (4px/frame × 4 = 16px per unit)
    ASL 
    PHX 
    LDX $playerActor
    STA $statsPtr, X      ; The PLAYER's statsPtr ($7F0020) is reused as the glide frame countdown
    LDA #$0000            ; Zero all velocity fields while player is locked
    STA $002C, X
    STA $002E, X
    STA $0008, X
    PLX 
    LDA #$0F00            ; Mask D-pad buttons ($0F00) in joypadMaskStd — no input during climb
    TSB $joypadMaskStd
    LDA #$0800
    TSB $playerFlags      ; Set playerFlags $0800 (script/ability lock — climb active)
    RTS 
}

---------------------------------------------
; End of a glide, standing in for RunAttackCleanup (which the interrupted slide never reaches): zeroes climbStateData ($09E0, the ability damage bonus), clears the consumption bits from joypadMaskStd, sets $10 bit $0008 and clears $0200, consumes the attack press in joypadHeld, clears playerFlags $0002, then RestorePlayerControl.

UnlockPlayerAfterClimb {
    STZ $climbStateData   ; $09E0 is the ability damage bonus set for the slide (named climbStateData); zero it because the slide's own cleanup is skipped
    LDA #$CFFC            ; Clear the consumed-button bits from joypadMaskStd (the mask differs from the vanilla ROM after the button remap)
    TRB $joypadMaskStd
    LDA #$0008            ; $10 bit $0008 = collision-aware movement back on
    TSB $10
    LDA #$0200            ; Clear $0200 (the slide-active flag set by RunAttackFlagSetup)
    TRB $10
    LDA #$0080            ; Consume the attack press in joypadHeld (the bit differs from the vanilla ROM after the button remap) so no new attack starts on exit
    TSB $joypadHeld
    LDA #$0002            ; Clear playerFlags $0002 (body slam/charge attack flag)
    TRB $playerFlags
    JSR $&RestorePlayerControl ; Restore normal player entry point and movement state
    RTS 
}
---------------------------------------------

; Returns the player to normal locomotion: entry pointer = PlayerIdleEntry, $2C/$2E/$08 zeroed, $10 = ($10 and $FDFF) or $0008, D-pad un-masked ($0F00 from joypadMaskStd), playerFlags $0800 cleared. Called from UnlockPlayerAfterClimb and from three ramp exits in ramps.asm.

RestorePlayerControl {
    PHX 
    LDX $playerActor
    LDA #$*player_character.PlayerIdleEntry ; Reset player entry to PlayerIdleEntry (bank byte)
    STA $0002, X
    LDA #$&player_character.PlayerIdleEntry ; Reset player entry to PlayerIdleEntry (offset)
    STA $0000, X
    LDA #$0000            ; Zero all velocity scratch fields ($002C/$002E/$0008)
    STA $002C, X
    STA $002E, X
    STA $0008, X
    LDA $0010, X
    AND #$FDFF            ; Clear $0200 (slide-active flag) from the player's status word
    ORA #$0008            ; Set $0008 (collision-aware movement) in the status word
    STA $0010, X
    LDA #$0F00            ; Unmask D-pad ($0F00) in joypadMaskStd
    TRB $joypadMaskStd
    LDA #$0800            ; Clear playerFlags $0800 (script/ability lock released)
    TRB $playerFlags
    PLX 
    RTS 
}