; Hub thinker spawned in nearly every field scene—~60 entries in scene_thinkers.asm, typically as the final slot in multi-thinker sets or the sole thinker in minimal scenes (Bank $00, ~545 bytes).
; 
; Dual responsibility: (1) ambient character palette dispatch via SwitchCase on $0AD4 (current form index)—selects PaletteStart bundles #0B, #0C, or #23 for Will/Freedan/Shadow color grading, then PaletteStep; (2) player-proximity NPC interaction when joypad bit $8000 is set.
; 
; Interaction path calls GetPlayerFacingDirection, then scans all active actors within 16×16 pixels of the player in the facing direction. If a qualifying actor has a linked script and the player presses a direction, it triggers sound and invokes the actor's talk/interact handler.
; 
; Present from early South Cape scenes through late-game areas; pairs with scene-specific thinkers (palette cyclers, HDMA waves, parallax) while providing universal character tinting and the field interaction system.
---------------------------------------------

?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'sprite_composition'

!joypadCurrent                  0656
!joypadHeld                     0658
!playerActor                    09AA
!chatPtr                        7F000A
!animScratch2                   7F000E

---------------------------------------------

global_ambient_dispatcher [
  thinker-def < #00, #08, {

  GlobalAmbientDispatchEntry:
    COP [SwitchCase] ( #$0AD4, &code_list_00BF91 ) ; SwitchCase on $0AD4 — dispatch Will/Freedan/Shadow/default ambient palette set
} >
]

code_list_00BF91 [
  &GlobalAmbientPaletteWill   ;00
  &GlobalAmbientPaletteFreedan   ;01
  &GlobalAmbientPaletteShadow   ;02
  &GlobalAmbientPaletteDefault   ;03
]

GlobalAmbientPaletteWill {
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    BRA GlobalAmbientInteractEntry
}

GlobalAmbientPaletteFreedan {
    COP [PaletteStart] ( #0C )
    COP [PaletteStep]
    BRA GlobalAmbientInteractEntry
}

GlobalAmbientPaletteShadow {
    COP [PaletteStart] ( #23 )
    COP [PaletteStep]
    BRA GlobalAmbientInteractEntry
}

GlobalAmbientPaletteDefault {
    COP [PaletteStart] ( #0C )
    COP [PaletteStep]
    BRA GlobalAmbientInteractEntry

  GlobalAmbientInteractEntry:
    LDA $animScratch2, X  ; Clear bit 11 of animScratch2 (interaction ready flag)
    AND #$F7FF
    STA $animScratch2, X
    COP [SetEntryExit]
    PHD 
    LDA #$0000
    TCD 
    LDA $joypadCurrent
    BIT #$8000
    BEQ GlobalAmbientNoInteractInput
    JMP $&GlobalAmbientOnDirectionPress

  GlobalAmbientNoInteractInput:
    PLD 
    RTL 
}

GlobalAmbientOnDirectionPress {
    JSL $@GetPlayerFacingDirection ; Direction press: save facing to $09EE, scan actors in 16px cone ahead of player
    BCC GlobalAmbientFacingInvalid
    PLD 
    RTL 

  GlobalAmbientFacingInvalid:
    STA $09EE
    LDY $playerActor
    PHP 
    REP #$20
    AND #$00FF
    BEQ GlobalAmbientScanEast
    DEC 
    BEQ GlobalAmbientScanWest
    DEC 
    BEQ GlobalAmbientScanNorth
    BRA GlobalAmbientScanSouth

  GlobalAmbientScanEast:
    LDA $0014, Y
    STA $18
    LDA $0016, Y
    INC 
    STA $1C
    JSR $&GlobalAmbientFindActorInFront
    BEQ GlobalAmbientNoTargetFound
    LDA $0016, X
    SEC 
    SBC $1C
    BMI GlobalAmbientTargetBehindPlayer
    BRA GlobalAmbientTargetInRange

  GlobalAmbientScanWest:
    LDA $0014, Y
    STA $18
    LDA $0016, Y
    DEC 
    STA $1C
    JSR $&GlobalAmbientFindActorInFront
    BEQ GlobalAmbientNoTargetFound
    LDA $1C
    SEC 
    SBC $0016, X
    BMI GlobalAmbientTargetBehindPlayer
    BRA GlobalAmbientTargetInRange

  GlobalAmbientScanNorth:
    LDA $0014, Y
    DEC 
    STA $18
    LDA $0016, Y
    STA $1C
    JSR $&GlobalAmbientFindActorInFront
    BEQ GlobalAmbientNoTargetFound
    LDA $18
    SEC 
    SBC $0014, X
    BMI GlobalAmbientTargetBehindPlayer
    BRA GlobalAmbientTargetInRange

  GlobalAmbientScanSouth:
    LDA $0014, Y
    INC 
    STA $18
    LDA $0016, Y
    STA $1C
    JSR $&GlobalAmbientFindActorInFront
    BEQ GlobalAmbientNoTargetFound
    LDA $0014, X
    SEC 
    SBC $18
    BMI GlobalAmbientTargetBehindPlayer
    BRA GlobalAmbientTargetInRange

  GlobalAmbientNoTargetFound:
    PLP 
    PLD 
    RTL 

  GlobalAmbientTargetBehindPlayer:
    LDA $chatPtr, X
    BNE GlobalAmbientInvokeLinkedScript
    JMP $&GlobalAmbientClearTalkInput

  GlobalAmbientInvokeLinkedScript:
    TXA                   ; Target behind player: TSB joypadHeld A and invoke linked chat script
    TCD 
    BRA GlobalAmbientDeferToScript

  GlobalAmbientTargetInRange:
    LDA #$8000
    TSB $joypadHeld
    LDA $chatPtr, X
    BEQ GlobalAmbientInteractExit
    TXA 
    TCD 
    LDA $12
    BIT #$0200
    BEQ GlobalAmbientPlayTalkSound

  GlobalAmbientDeferToScript:
    SEP #$20              ; Play SFX $2F via $0402 jump table before deferring to linked NPC script
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

  GlobalAmbientPlayTalkSound:
    SEP #$20
    LDA #$7E
    STA $0404
    LDY #$3410
    LDA #$00
    STA $0405
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAX 
    SEP #$20
    LDA #$7F
    STA $0405
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAX 
    JSR $&GlobalAmbientPickTalkAnimFrame
    STA $28
    STZ $2A
    JSL $@sprite_composition.UpdateActorAnimation
    SEP #$20
    PHK 
    PEA $&GlobalAmbientTalkSoundResume-1
    LDA $02
    PHA 
    REP #$20
    LDA $chatPtr, X
    DEC 
    PHA 
    RTL 
}

GlobalAmbientClearTalkInput {
    LDA #$8000
    TRB $joypadCurrent
    LDA #$8000
    TSB $joypadHeld

  GlobalAmbientInteractExit:
    PLP 
    PLD 
    RTL 
}

GlobalAmbientTalkSoundResume {
    TXY 
    LDA $06
    PHA 
    SEP #$20
    LDA #$7E
    STA $0405
    LDX #$3410
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
    LDA $06
    BNE GlobalAmbientTalkSoundCleanup
    LDA $01, S
    STA $06

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

GlobalAmbientFindActorInFront {
    LDA #$0020            ; Actor scan: require status bit $1000 and ≤$10 Manhattan distance from probe point
    STA $02
    STZ $00
    STZ $04
    LDA $0056
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
    CMP #$0010            ; Abs delta-X ≤$10 check; keep nearest actor index in running minimum at $04
    BCS GlobalAmbientScanNextActor
    STA $00
    LDA $0016, X
    SEC 
    SBC $1C
    BPL GlobalAmbientCheckDeltaY
    EOR #$FFFF
    INC 

  GlobalAmbientCheckDeltaY:
    CMP #$0010
    BCS GlobalAmbientScanNextActor
    ADC $00
    CMP $02
    BCS GlobalAmbientScanNextActor
    STA $02
    STX $04
    BRA GlobalAmbientScanNextActor

  GlobalAmbientScanDone:
    LDX $04
    RTS 
}

GlobalAmbientPickTalkAnimFrame {
    LDA $09EE             ; Map saved facing in $09EE to talk animation frame offset for sprite update
    AND #$00FF
    BIT #$0002
    BNE GlobalAmbientAnimFacingVertical
    INC 
    AND #$0001
    BRA GlobalAmbientAnimFacingApply

  GlobalAmbientAnimFacingVertical:
    INC 
    AND #$0001
    INC 
    INC 

  GlobalAmbientAnimFacingApply:
    STA $09EE
    LDA $28
    DEC 
    DEC 
    AND #$FFF8
    INC 
    INC 
    CLC 
    ADC $09EE
    RTS 
}