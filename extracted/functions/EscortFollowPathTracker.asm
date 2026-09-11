?INCLUDE 'GetPlayerFacingDirection'

!playerActor                    09AA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

EscortFollowPathTracker {
    PHX 
    LDA $orbitAngle, X
    BEQ loc_00C810
    DEC 
    BRA loc_00C814

  loc_00C810:
    JSL $@GetPlayerFacingDirection

  loc_00C814:
    ASL 
    ASL 
    ASL 
    TAX 
    LDY $04
    LDA $0014, Y
    STA $0000
    LDA $0016, Y
    STA $0002
    LDA $@word_00C943+4, X
    STA $001C
    LDY #$0000

  loc_00C830:
    LDA $@word_00C943, X
    CLC 
    ADC $0000
    STA $0000
    STA $0018
    LDA $@word_00C943+2, X
    CLC 
    ADC $0002
    STA $0002
    STA $001A
    TXA 
    TYX 
    TAY 
    LDA $0018
    STA $7EDF00, X
    LDA $001A
    STA $7EDF02, X
    LDA $001C
    STA $7EDF04, X
    TXA 
    TYX 
    TAY 
    TYA 
    CLC 
    ADC #$0008
    TAY 
    CPY #$0048
    BNE loc_00C830
    PLX 
    LDY $playerActor
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA $001C
    STA $0E
    LDA #$0000
    STA $orbitAngle, X
    COP [SetEntryExit]
    LDY $playerActor
    LDA $0014, Y
    CMP $14
    BNE loc_00C89F
    LDA $0016, Y
    CMP $16
    BEQ loc_00C8F7

  loc_00C89F:
    PHX 
    LDY $04
    LDA $orbitAngle, X
    AND #$003F
    TAX 
    LDA $7EDF00, X
    STA $0014, Y
    LDA $7EDF02, X
    STA $0016, Y
    LDY $playerActor
    LDA $0014, Y
    STA $14
    STA $7EDF00, X
    LDA $0016, Y
    STA $16
    STA $7EDF02, X
    LDA $7EDF04, X
    PLX 
    CMP $0E
    BEQ loc_00C924
    STA $0E
    CLC 
    ADC #$0004
    PHA 
    LDA $orbitDiameter, X
    CLC 
    ADC $01, S
    STA $01, S
    PLA 
    LDY $04
    STA $0028, Y
    LDA #$0000
    STA $002A, Y
    STA $0008, Y
    BRA loc_00C924

  loc_00C8F7:
    LDA $orbitAngle, X
    AND #$003F
    PHX 
    TAX 
    LDA $7EDF04, X
    PLX 
    PHA 
    LDA $orbitDiameter, X
    CLC 
    ADC $01, S
    STA $01, S
    PLA 
    LDY $04
    STA $0028, Y
    LDA #$0000
    STA $002A, Y
    STA $0008, Y
    LDA #$FFFF
    STA $0E
    RTL 

  loc_00C924:
    LDA $orbitAngle, X
    AND #$003F
    PHX 
    TAX 
    JSL $@GetPlayerFacingDirection
    STA $7EDF04, X
    PLX 
    LDA $orbitAngle, X
    CLC 
    ADC #$0008
    STA $orbitAngle, X
    RTL 
}

word_00C943 [
  #$0000   ;00
  #$FFFE   ;01
  #$0001   ;02
  #$0000   ;03
  #$0000   ;04
  #$0002   ;05
  #$0000   ;06
  #$0000   ;07
  #$0002   ;08
  #$0000   ;09
  #$0003   ;0A
  #$0000   ;0B
  #$FFFE   ;0C
  #$0000   ;0D
  #$0002   ;0E
  #$0000   ;0F
]