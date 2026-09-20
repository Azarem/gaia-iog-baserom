; Fire Sprite enemy in the Mountain Temple (~429 lines).
; 
; Floating flame enemy with complex orbital movement patterns.
; Circles around fixed points and fires projectile attacks
; at the player. Uses math_lookup_tables for sine/cosine
; movement. Leaves fire trail hazards.
---------------------------------------------

?INCLUDE 'ApplyOrbitalOffsetFromRef'

!playerXPos                     09A2
!playerYPos                     09A4
!animScratch                    7F0000
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!parentId                       7F001C
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

mtA1_fire_sprite [
  actor-def < #00, #00, #00, {

  code_0B983E:
    LDA #$0011
    TSB $12
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X

  loc_0B984F:
    COP [WaitWhileOffscreen] ( #09 )

  code_0B9852:
    LDA $10
    BIT #$4000
    BNE loc_0B984F
    LDA #$000A
    STA $24
    COP [SetEntryHere]
    COP [BranchIfPlayerNear] ( #06, &code_0B9880 )
    DEC $24
    BMI loc_0B986A
    RTL 

  loc_0B986A:
    COP [CallNear] ( &code_0B9901 )
    BRA code_0B9852

  code_0B9870:
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    COP [SetEntryHereAndYield]
    BRA loc_0B9893
} >
]

code_0B9880 {
    COP [AndExtraFlags] ( #$FFFD )
    LDA #$0200
    TRB $12
    COP [SpawnAfterMarked] ( @code_0B992B, #$2200 )
    COP [LoopStart] ( #06 )

  loc_0B9893:
    LDA $14
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    JSR $&sub_0BA5D5
    CLC 
    ADC $playerXPos
    AND #$FFF0
    CLC 
    ADC #$0008
    STA $14
    JSR $&sub_0BA5D5
    CLC 
    ADC $playerYPos
    AND #$FFF0
    CLC 
    ADC #$0010
    STA $16
    COP [BranchIfSolidHere] ( &code_0B9870 )
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $moveXAlt, X
    STA $14
    LDA $moveYAlt, X
    STA $16
    PLA 
    STA $moveYAlt, X
    PLA 
    STA $moveXAlt, X
    COP [MoveToward] ( #00, #01 )
    COP [StageSpriteLoop] ( #00, #04 )
    COP [AnimLoop]
    COP [LoopEnd]
    COP [SetHitCallback] ( #$0000 )

  code_0B98EF:
    COP [AndExtraFlags] ( #$FFFD )
    LDA #$0200
    TSB $12
    COP [StageSpriteLoop] ( #00, #0C )
    COP [AnimLoop]
    JMP $&code_0B9852
}

code_0B9901 {
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $7F100C, X
    STA $moveXAlt, X
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$003F
    CLC 
    ADC $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #00, #01 )
    COP [RestoreSavedPtr]
}

code_0B992B {
    COP [LoopStart] ( #04 )
    COP [SpawnAfterFlags] ( @code_0B994D, #$0300 )
    LDA $24
    STA $0024, Y
    COP [WaitByte] ( #3F )
    COP [LoopEnd]
    PHX 
    PHD 
    LDA $24
    TCD 
    TAX 
    COP [SetHitCallback] ( &code_0B98EF )
    PLD 
    PLX 
    COP [Die]
}

code_0B994D {
    COP [PlaySoundCh1] ( #26 )
    LDA #$0080
    STA $orbitDiameter, X
    LDA #$0080
    STA $orbitAngle, X
    LDA #$0000
    STA $7F100C, X
    COP [StageSprAndHitbox] ( #1D )
    BRA loc_0B998D

  loc_0B996A:
    LDA $28
    CMP #$001F
    BCS loc_0B998D
    LDA $7F100C, X
    INC 
    STA $7F100C, X
    AND #$0001
    BNE loc_0B998D
    INC $28
    LDA $28
    CMP #$001F
    BCC loc_0B998D
    LDA #$0100
    TRB $10

  loc_0B998D:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B996A
    JSR $&code_0B9B9A
    COP [SetEntryHere]
    DEC $26
    BMI loc_0B998D
    LDY $24
    LDA $0012, Y
    BIT #$0200
    BNE loc_0B99D1
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B99B3
    JMP $&code_0B9A9D

  loc_0B99B3:
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    LDA $orbitAngle, X
    CLC 
    ADC #$0001
    STA $orbitAngle, X
    RTL 
}

code_0B99C6 {
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ code_0B99C6
    JSR $&code_0B9B9A

  loc_0B99D1:
    COP [SetEntryHere]
    DEC $26
    BMI code_0B99C6
    LDA $orbitDiameter, X
    BEQ loc_0B9A01
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    LDA $orbitDiameter, X
    SEC 
    SBC #$0002
    BPL loc_0B99F0
    LDA #$0000

  loc_0B99F0:
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC #$0001
    STA $orbitAngle, X
    RTL 

  loc_0B9A01:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9A01
    JSR $&code_0B9B9A
    COP [SetEntryHere]
    DEC $26
    BMI loc_0B9A01
    LDY $24
    JSL $@ApplyOrbitalOffsetFromRef
    LDA $orbitDiameter, X
    CLC 
    ADC #$0008
    CLC 
    ADC $0B02
    BIT #$FF00
    BNE loc_0B9A5C
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC #$0001
    STA $orbitAngle, X
    LDA $14
    SEC 
    SBC $7F100C, X
    STA $moveXAlt, X
    LDA $14
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $7F100E, X
    STA $moveYAlt, X
    LDA $16
    STA $7F100E, X
    RTL 

  loc_0B9A5C:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9A5C
    JSR $&code_0B9B9A
    COP [SetEntryHere]
    DEC $26
    BMI loc_0B9A5C
    LDA $moveXAlt, X
    STA $moveScratch1, X
    LDA $moveYAlt, X
    STA $moveScratch2, X
    LDA $10
    BIT #$4000
    BNE loc_0B9A85
    RTL 

  loc_0B9A85:
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #13 )
    LDA $parentId, X
    TAY 
    LDA $0012, Y
    AND #$FDFF
    STA $0012, Y
    COP [Die]
}

code_0B9A9D {
    LDY $24
    LDA $0014, Y
    STA $animScratch, X
    LDA $0016, Y
    STA $animScratch+2, X
    BRA loc_0B9ABA

  loc_0B9AAF:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9AAF
    JSR $&code_0B9B9A

  loc_0B9ABA:
    COP [SetEntryHere]
    DEC $26
    BMI loc_0B9AAF
    LDA $orbitDiameter, X
    BEQ loc_0B9AF4
    LDA $animScratch, X
    STA $14
    LDA $animScratch+2, X
    STA $16
    JSL $@ApplyOrbitalOffsetFromRef.code_00F3D3
    LDA $orbitDiameter, X
    SEC 
    SBC #$0002
    BPL loc_0B9AE3
    LDA #$0000

  loc_0B9AE3:
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC #$0001
    STA $orbitAngle, X
    RTL 

  loc_0B9AF4:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9AF4
    JSR $&code_0B9B9A
    COP [SetEntryHere]
    DEC $26
    BMI loc_0B9AF4
    LDA $animScratch, X
    STA $14
    LDA $animScratch+2, X
    STA $16
    JSL $@ApplyOrbitalOffsetFromRef.code_00F3D3
    LDA $orbitDiameter, X
    CLC 
    ADC #$0008
    CLC 
    ADC $0B02
    BIT #$FF00
    BNE loc_0B9B59
    STA $orbitDiameter, X
    LDA $orbitAngle, X
    CLC 
    ADC #$0001
    STA $orbitAngle, X
    LDA $14
    SEC 
    SBC $7F100C, X
    STA $moveXAlt, X
    LDA $14
    STA $7F100C, X
    LDA $16
    SEC 
    SBC $7F100E, X
    STA $moveYAlt, X
    LDA $16
    STA $7F100E, X
    RTL 

  loc_0B9B59:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0B9B59
    JSR $&code_0B9B9A
    COP [SetEntryHere]
    DEC $26
    BMI loc_0B9B59
    LDA $moveXAlt, X
    STA $moveScratch1, X
    LDA $moveYAlt, X
    STA $moveScratch2, X
    LDA $10
    BIT #$4000
    BNE loc_0B9B82
    RTL 

  loc_0B9B82:
    LDA #$2000
    TSB $10
    COP [WaitByte] ( #13 )
    LDA $parentId, X
    TAY 
    LDA $0012, Y
    AND #$FDFF
    STA $0012, Y
    COP [Die]
}

code_0B9B9A {
    LDA $08
    INC 
    STA $26
    STZ $08
    RTS 
}
---------------------------------------------

sub_0BA5D5 {
    COP [RngByte]
    AND #$003F
    SEC 
    SBC #$001F
    RTS 
}