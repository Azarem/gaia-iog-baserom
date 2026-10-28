; Per-scene hub thinker (Bank 00, 49035-49577, about 545 bytes), spawned in about 60 scene_thinkers lists, usually as the last slot. It has two jobs: it loads the player's sprite palette for the current form once at spawn, and it runs the shared 'talk to the thing in front of you' interaction every frame. It is not an ambient effect, and the trigger is the interact bit of joypadCurrent, not a direction press as the old header said.
; 
; === PALETTE (spawn only) ===
; 
; SwitchCase on characterForm ($0AD4: 0 Will, 1 Freedan, 2 Shadow; no range check, so the table's fourth entry is never reached) runs PaletteStart / PaletteStep on bundle #0B (Will), #0C (Freedan) or #23 (Shadow). All three write colours $81-$8F, which is OBJ palette 0 colours 1-15, the player's sprite palette. #0B and #0C are a single static strip; #23 is an animated set of strips (wait 2 each). PaletteStep plays the whole bundle before the script continues. The palette is chosen once when the thinker spawns, so a form change in the middle of a scene is not re-applied until the next scene setup.
; 
; === FILTER WORD ===
; 
; thinker-def <#00, #08> gives animScratch2 = $0800 (bit 11 set: also run in the Light runners). GlobalAmbientInteractEntry clears bit 11 in the thinker's own animScratch2, so from then on the dispatcher runs only in RunThinkers_General (the main loop) and is skipped by the lighter frame routines (dialogue, render, music upload): no new talk starts while a dialogue frame loop is running. The old comment called bit 11 an 'interaction ready flag'.
; 
; === TALK INTERACTION (every frame) ===
; 
; 1. PHD / TCD set D = 0 and joypadCurrent bit $8000 is tested: the interact bit. In the vanilla layout it is the B button (remapB); in this build transforms.json rewrites the system_init defaults to remapA = $8080 and remapB = $4008, so the A button feeds it (together with the attack bit $0080). The notes in this file name the logical bit, not a button. Not pressed: return.
; 2. GetPlayerFacingDirection: carry SET = no valid facing, return; carry CLEAR = valid (GlobalAmbientFacingValid; the old label said Invalid). A = 0 down, 1 up, 2 left, 3 right, saved in $09EE.
; 3. A probe point one pixel in front of the player ($18 / $1C = player X / Y plus (0,+1), (0,-1), (-1,0) or (+1,0)) is built. The four probe labels follow the facing code: GlobalAmbientProbeDown handles facing 0 (down), GlobalAmbientProbeUp facing 1 (up), GlobalAmbientProbeLeft facing 2 (left), GlobalAmbientProbeRight facing 3 (right); the old ScanEast / ScanWest / ScanNorth / ScanSouth labels were rotated against these.
; 4. GlobalAmbientFindActorInFront walks the actor list from actorListFirst and keeps the actor with the smallest |dx| + |dy| to the probe point whose |dx| and |dy| are both below $10 and whose sum is below $20. Only actors with Flags10 bit $1000 count (the third actor-def header byte of NPCs and objects carries it; the player has it clear and is skipped). X = 0 when none is found.
; 5. The target is 'in front' when its coordinate along the facing axis is beyond the probe (GlobalAmbientTargetInRange), otherwise it is at or behind the player (GlobalAmbientTargetAtOrBehind). Both need a non-zero chatPtr ($7F000A, set by SetInteractHandler). A target at or behind the player runs its chat routine directly; a target in front first sets the interact bit in joypadHeld.
; 6. In front and Flags12 ($12) bit $0200 clear: the turn-and-talk path (GlobalAmbientTalkWithSnapshot; it plays no sound, which the old label TalkSound suggested). The target's actor slot ($30 bytes, bank 0) and its extended $7F page ($30 bytes) are copied to $7E:3410-$346F through the RAM MVN stub at $0402 ($0404 = destination bank, $0405 = source bank, A = $2F is the byte count minus one, not a sound number; the old comments called it SFX $2F). The target is then turned to face the player (GlobalAmbientPickTalkAnimFrame), its animation is updated at once, its chat routine runs as a subroutine and, when it returns, both copies are written back (GlobalAmbientTalkRestoreActor). WRAM flags, dialogue and inventory changes made by the chat routine persist, but the NPC's own actor fields (position, animation, entry pointer, flags) are put back as they were; the next-link $06 is kept as it is now when the saved copy had none (it was the list tail).
; 7. Flags12 bit $0200 set (over 150 NPC, sign, book and door actor scripts set it) skips the snapshot, the turn and the animation: the chat routine runs directly (GlobalAmbientDeferToScript).
; 8. GlobalAmbientClearTalkInput then clears the interact bit in joypadCurrent and sets it in joypadHeld so the same press cannot trigger again.
; 
; GlobalAmbientPickTalkAnimFrame turns the target to face the player: it picks offset 0 down, 1 up, 2 left, 3 right of the target's 8-frame animation group, the OPPOSITE of the player's facing, and adds it to the group base ((index - 2) AND $FFF8) + 2. It overwrites $09EE with that offset; the label GlobalAmbientAnimFacingHorizontal is the left / right branch.
; 
; The interaction code uses the global direct page scratch $00-$04, $18 and $1C (D = 0); none of those is part of the persistent engine state.
---------------------------------------------

?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'sprite_composition'

!actorListFirst                 0056
!joypadCurrent                  0656
!joypadHeld                     0658
!playerActor                    09AA
!chatPtr                        7F000A
!animScratch2                   7F000E

---------------------------------------------

global_ambient_dispatcher [
  thinker-def < #00, #08, {

; Spawn entry: pick the player's sprite palette bundle by characterForm ($0AD4). Runs once per scene setup.

  GlobalAmbientDispatchEntry:
    COP [SwitchCase] ( #$0AD4, &code_list_00BF91 ) ; Case by characterForm ($0AD4): 0 Will, 1 Freedan, 2 Shadow; no range check. Runs once, at spawn
} >
]

---------------------------------------------
; SwitchCase table by characterForm: 0 Will, 1 Freedan, 2 Shadow; entry 3 is never reached (the form is 0-2).

code_list_00BF91 [
  &GlobalAmbientPaletteWill   ;00
  &GlobalAmbientPaletteFreedan   ;01
  &GlobalAmbientPaletteShadow   ;02
  &GlobalAmbientPaletteUnused   ;03
]

---------------------------------------------
; Will: bundle #0B, OBJ palette 0 colours $81-$8F (static), then the interaction loop.

GlobalAmbientPaletteWill {
    COP [PaletteStart] ( #0B ) ; Will: sprite palette bundle (OBJ palette 0 colours $81-$8F, static)
    COP [PaletteStep]
    BRA GlobalAmbientInteractEntry
}

---------------------------------------------
; Freedan: bundle #0C, OBJ palette 0 colours $81-$8F (static), then the interaction loop.

GlobalAmbientPaletteFreedan {
    COP [PaletteStart] ( #0C ) ; Freedan: sprite palette bundle (same colours, static)
    COP [PaletteStep]
    BRA GlobalAmbientInteractEntry
}

---------------------------------------------
; Shadow: bundle #23, an animated strip set on the same colours, then the interaction loop.

GlobalAmbientPaletteShadow {
    COP [PaletteStart] ( #23 ) ; Shadow: animated strip set on the same colours (wait 2 per strip)
    COP [PaletteStep]
    BRA GlobalAmbientInteractEntry
}

---------------------------------------------
; Index 3, never reached (characterForm is 0-2): the same bundle as Freedan.

GlobalAmbientPaletteUnused {
    COP [PaletteStart] ( #0C ) ; Index 3 is never used (characterForm is 0-2): same bundle as Freedan
    COP [PaletteStep]
    BRA GlobalAmbientInteractEntry

; Per-frame loop head. Clears bit 11 of animScratch2 so the thinker leaves the Light runners (no talk starts during dialogue / render / music-upload frames), yields, and tests the interact bit with D = 0.

  GlobalAmbientInteractEntry:
    LDA $animScratch2, X  ; Clear bit 11 of animScratch2: this thinker leaves the Light runners, so it does not run in dialogue, render and music-upload frames
    AND #$F7FF
    STA $animScratch2, X
    COP [SetEntryHereAndYield] ; Per-frame loop head: yield; the next frame resumes at the PHD below
    PHD                   ; Save the thinker's D; the interaction code runs with D = 0 (global direct page)
    LDA #$0000
    TCD 
    LDA $joypadCurrent
    BIT #$8000            ; Interact bit: the B button in the vanilla layout, the A button in this build (system_init remap, see the block note)
    BEQ GlobalAmbientNoInteractInput
    JMP $&GlobalAmbientOnInteractPress

  GlobalAmbientNoInteractInput:
    PLD 
    RTL 
}

---------------------------------------------
; Interact bit pressed (the old label said direction press). Read the player's facing, build the probe point in front of the player and find the interactable actor there.

GlobalAmbientOnInteractPress {
    JSL $@GetPlayerFacingDirection ; A = facing 0 down, 1 up, 2 left, 3 right; carry set = no valid facing
    BCC GlobalAmbientFacingValid ; Carry clear = valid facing: continue at GlobalAmbientFacingValid; carry set: leave
    PLD 
    RTL 

; Valid-facing path (BCC after GetPlayerFacingDirection: carry clear = valid; the old label said Invalid). Saves the facing in $09EE and splits into the four probe builders.

  GlobalAmbientFacingValid:
    STA $09EE             ; Save the facing in $09EE (PickTalkAnimFrame later overwrites it with an animation offset)
    LDY $playerActor
    PHP 
    REP #$20
    AND #$00FF
    BEQ GlobalAmbientProbeDown ; Facing 0 (down): probe below the player
    DEC 
    BEQ GlobalAmbientProbeUp ; Facing 1 (up): probe above the player
    DEC 
    BEQ GlobalAmbientProbeLeft ; Facing 2 (left): probe left of the player
    BRA GlobalAmbientProbeRight ; Facing 3 (right): probe right of the player

; Facing 0 = down (the old label said ScanEast): probe point = player X, player Y + 1.

  GlobalAmbientProbeDown:
    LDA $0014, Y
    STA $18
    LDA $0016, Y
    INC 
    STA $1C               ; Probe Y = player Y + 1 (one pixel below)
    JSR $&GlobalAmbientFindActorInFront ; X = nearest actor within 16 px on both axes of the probe point, or 0; Z set when none
    BEQ GlobalAmbientNoTargetFound
    LDA $0016, X
    SEC 
    SBC $1C
    BMI GlobalAmbientTargetAtOrBehind ; Target not beyond the probe: at or behind the player
    BRA GlobalAmbientTargetInRange

; Facing 1 = up (the old label said ScanWest): probe point = player X, player Y - 1.

  GlobalAmbientProbeUp:
    LDA $0014, Y
    STA $18
    LDA $0016, Y
    DEC 
    STA $1C               ; Probe Y = player Y - 1 (one pixel above)
    JSR $&GlobalAmbientFindActorInFront
    BEQ GlobalAmbientNoTargetFound
    LDA $1C
    SEC 
    SBC $0016, X
    BMI GlobalAmbientTargetAtOrBehind ; Target not beyond the probe: at or behind the player
    BRA GlobalAmbientTargetInRange

; Facing 2 = left (the old label said ScanNorth): probe point = player X - 1, player Y.

  GlobalAmbientProbeLeft:
    LDA $0014, Y
    DEC 
    STA $18               ; Probe X = player X - 1 (one pixel left)
    LDA $0016, Y
    STA $1C
    JSR $&GlobalAmbientFindActorInFront
    BEQ GlobalAmbientNoTargetFound
    LDA $18
    SEC 
    SBC $0014, X
    BMI GlobalAmbientTargetAtOrBehind ; Target not beyond the probe: at or behind the player
    BRA GlobalAmbientTargetInRange

; Facing 3 = right (the old label said ScanSouth): probe point = player X + 1, player Y.

  GlobalAmbientProbeRight:
    LDA $0014, Y
    INC 
    STA $18               ; Probe X = player X + 1 (one pixel right)
    LDA $0016, Y
    STA $1C
    JSR $&GlobalAmbientFindActorInFront
    BEQ GlobalAmbientNoTargetFound
    LDA $0014, X
    SEC 
    SBC $18
    BMI GlobalAmbientTargetAtOrBehind ; Target not beyond the probe: at or behind the player
    BRA GlobalAmbientTargetInRange

; No actor near the probe point: restore P and D and return; the press is left in joypadCurrent.

  GlobalAmbientNoTargetFound:
    PLP 
    PLD 
    RTL 

; Target at or behind the player along the facing axis (the signed difference to the probe went negative): needs a chatPtr, then runs it directly.

  GlobalAmbientTargetAtOrBehind:
    LDA $chatPtr, X       ; chatPtr: the target's interact routine (set by SetInteractHandler)
    BNE GlobalAmbientInvokeLinkedScript
    JMP $&GlobalAmbientClearTalkInput

; Make the target the current direct page (TXA / TCD) and run its chat routine through GlobalAmbientDeferToScript.

  GlobalAmbientInvokeLinkedScript:
    TXA                   ; Target at or behind the player with a chat routine: D = target, run it directly
    TCD 
    BRA GlobalAmbientDeferToScript

; Target beyond the probe (in front of the player): mark the interact bit as held, require a chatPtr, then either the direct call (Flags12 $0200 set) or the turn-and-talk snapshot path.

  GlobalAmbientTargetInRange:
    LDA #$8000
    TSB $joypadHeld       ; Mark the interact bit as held so this press does not trigger again
    LDA $chatPtr, X
    BEQ GlobalAmbientInteractExit ; No chat routine: nothing to run (the press is not consumed)
    TXA 
    TCD 
    LDA $12
    BIT #$0200            ; Flags12 bit $0200 set (signs, objects, scripted NPCs): skip the turn and the snapshot
    BEQ GlobalAmbientTalkWithSnapshot ; Bit clear: turn-and-talk path with the actor snapshot

; Direct call of the target's chat routine: push the return address (GlobalAmbientClearTalkInput), the actor's bank ($02) and chatPtr - 1, set the interact bit in joypadHeld and RTL into it.

  GlobalAmbientDeferToScript:
    SEP #$20              ; Direct call: push return (ClearTalkInput), the actor's bank ($02) and chatPtr - 1, then RTL into the chat routine
    PHK 
    PEA $&GlobalAmbientClearTalkInput-1
    LDA $02
    PHA 
    REP #$20
    LDA $chatPtr, X
    DEC 
    PHA 
    LDA #$8000
    TSB $joypadHeld
    RTL 

; Turn-and-talk path (no sound is played): snapshot the target's actor slot and $7F page to $7E:3410-$346F with the RAM MVN stub $0402, turn the target to face the player, then call its chat routine with GlobalAmbientTalkRestoreActor as the return address.

  GlobalAmbientTalkWithSnapshot:
    SEP #$20              ; Snapshot: $0404 = destination bank, $0405 = source bank, Y = dest; the MVN stub at $0402 copies A + 1 bytes
    LDA #$7E
    STA $0404
    LDY #$3410
    LDA #$00
    STA $0405
    REP #$20
    LDA #$002F            ; $2F = byte count minus one (48 bytes = one actor slot), not a sound number
    JSR $0402             ; RAM MVN stub: copy the target's actor slot (bank 0) to $7E:3410
    TDC 
    TAX 
    SEP #$20
    LDA #$7F
    STA $0405             ; Source bank $7F: the actor's extended page ($30 bytes) goes to $7E:3440
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAX 
    JSR $&GlobalAmbientPickTalkAnimFrame ; Face the player: A = the target's new animation index
    STA $28               ; Set the target's animation index; the frame counter $2A is cleared next
    STZ $2A
    JSL $@sprite_composition.UpdateActorAnimation ; Redraw the turned frame at once
    SEP #$20
    PHK 
    PEA $&GlobalAmbientTalkRestoreActor-1 ; Return address: GlobalAmbientTalkRestoreActor writes the snapshot back after the chat routine returns
    LDA $02
    PHA 
    REP #$20
    LDA $chatPtr, X
    DEC 
    PHA 
    RTL                   ; Call the chat routine (chatPtr - 1, bank $02) as a subroutine
}

---------------------------------------------
; Consume the press: clear the interact bit in joypadCurrent, set it in joypadHeld, restore P and D and return.

GlobalAmbientClearTalkInput {
    LDA #$8000
    TRB $joypadCurrent    ; Consume the press in joypadCurrent
    LDA #$8000
    TSB $joypadHeld       ; and flag it as held

  GlobalAmbientInteractExit:
    PLP 
    PLD 
    RTL 
}

---------------------------------------------
; Return point of the turn-and-talk path: write the snapshot back to the target's actor slot and $7F page (keeping the live next-link $06 when the saved one was 0), then consume the press.

GlobalAmbientTalkRestoreActor {
    TXY 
    LDA $06               ; Live next-link of the target (actors may have been appended during the talk)
    PHA 
    SEP #$20
    LDA #$7E
    STA $0405
    LDX #$3410            ; Restore: source $7E:3410, destination bank 0 (the actor slot)
    LDA #$00
    STA $0404
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAY 
    SEP #$20
    LDA #$7F
    STA $0404
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAX 
    LDA $06               ; Restored next-link; 0 means the snapshot was taken while the target was the list tail
    BNE GlobalAmbientTalkSoundCleanup ; Non-zero: keep the restored link
    LDA $01, S
    STA $06               ; Tail at snapshot time: keep the live link so actors appended during the talk stay reachable

  GlobalAmbientTalkSoundCleanup:
    PLA 
    LDA #$8000
    TRB $joypadCurrent
    LDA #$8000
    TSB $joypadHeld
    PLP 
    PLD 
    RTL 
}

---------------------------------------------
; Actor scan around the probe point ($18 / $1C): Flags10 bit $1000 required, |dx| and |dy| below $10, sum below $20; returns the nearest in X (0 = none) with Z set accordingly. Scratch: $00 = |dx|, $02 = best distance (starts at $20), $04 = best actor.

GlobalAmbientFindActorInFront {
    LDA #$0020            ; Actor scan: Flags10 bit $1000 required; |dx| and |dy| to the probe both below $10 and their sum below $20
    STA $02               ; $02 = best distance so far (limit $20)
    STZ $00
    STZ $04               ; $04 = best actor (0 = none)
    LDA $actorListFirst
    BRA GlobalAmbientScanLoop

  GlobalAmbientScanNextActor:
    LDA $0006, X

  GlobalAmbientScanLoop:
    TAX 
    BEQ GlobalAmbientScanDone
    LDA $0010, X
    BIT #$1000
    BEQ GlobalAmbientScanNextActor
    LDA $0014, X
    SEC 
    SBC $18
    BPL GlobalAmbientCheckDeltaX
    EOR #$FFFF
    INC 

  GlobalAmbientCheckDeltaX:
    CMP #$0010            ; |dx| must be below $10 (CMP / BCS); kept in $00
    BCS GlobalAmbientScanNextActor
    STA $00
    LDA $0016, X
    SEC 
    SBC $1C
    BPL GlobalAmbientCheckDeltaY
    EOR #$FFFF
    INC 

  GlobalAmbientCheckDeltaY:
    CMP #$0010            ; |dy| must be below $10
    BCS GlobalAmbientScanNextActor
    ADC $00               ; Distance = |dy| + |dx| (carry is clear after the CMP / BCS)
    CMP $02               ; Nearer than the best so far? Ties keep the earlier actor
    BCS GlobalAmbientScanNextActor
    STA $02
    STX $04
    BRA GlobalAmbientScanNextActor

  GlobalAmbientScanDone:
    LDX $04               ; X = nearest actor or 0 (Z flag set for the caller's BEQ)
    RTS 
}

---------------------------------------------
; Return in A the animation index that turns the target to face the player: the group base ((index - 2) AND $FFF8) + 2 plus the opposite-of-the-player's-facing offset (down 0, up 1, left 2, right 3). Overwrites $09EE with the offset.

GlobalAmbientPickTalkAnimFrame {
    LDA $09EE             ; Saved facing 0 down, 1 up, 2 left, 3 right -> offset of the frame that faces the player (the opposite way)
    AND #$00FF
    BIT #$0002            ; Bit 1 set = left / right (the label ...Horizontal is this branch)
    BNE GlobalAmbientAnimFacingHorizontal
    INC                   ; Down / up: 0 -> 1, 1 -> 0 (faces the player)
    AND #$0001
    BRA GlobalAmbientAnimFacingApply

; The LEFT / RIGHT branch (facing 2 or 3; the old label said Vertical): 2 -> offset 3, 3 -> offset 2.

  GlobalAmbientAnimFacingHorizontal:
    INC                   ; Left / right: after the AND and the two INCs below, 2 -> 3 and 3 -> 2
    AND #$0001
    INC 
    INC 

; Store the offset in $09EE and add it to the group base of the target's current animation index.

  GlobalAmbientAnimFacingApply:
    STA $09EE             ; $09EE now holds the animation offset (overwrites the saved facing)
    LDA $28
    DEC 
    DEC 
    AND #$FFF8
    INC 
    INC 
    CLC 
    ADC $09EE             ; Group base + offset = the target's new animation index
    RTS 
}