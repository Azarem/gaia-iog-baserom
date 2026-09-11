?BANK 03

!playerActor                    09AA
!playerFlags                    09AE

---------------------------------------------

GetPlayerFacingDirection {
    PHP 
    REP #$20
    TXY 
    LDX $playerActor
    LDA $playerFlags
    BMI loc_03F0F1

  loc_03F0D6:
    LDA $0028, X
    TAX 
    LDA $@FacingDirectionLookup, X
    AND #$00FF
    CMP #$0004
    BPL loc_03F0EA
    TYX 
    PLP 
    CLC 
    RTL 

  loc_03F0EA:
    TYX 
    PLP 
    SEC 
    RTL 
}

GetPlayerFacing_AltEntry {
    PLY 
    BRA loc_03F0D6

  loc_03F0F1:
    PHY 
    TXY 
    LDA $0AC8
    AND #$00FF
    SEC 
    SBC #$0004
    BMI GetPlayerFacing_AltEntry
    ASL 
    TAX 
    LDA $@FacingFormOffsetTable, X
    SEC 
    SBC #$&FacingFormOffsetTable
    CLC 
    ADC $0028, Y
    TAX 
    PLY 
    LDA $@FacingFormOffsetTable, X
    AND #$00FF
    CMP #$0004
    BPL loc_03F0EA
    TYX 
    PLP 
    CLC 
    RTL 
}

FacingDirectionLookup #00010203000102030001020300010203000102030001020300000000000101010202020303030101000001000100010002030203020300010203000102030001020302030001020300010404040404040001020304040404

FacingFormOffsetTable [
  &FacingData_Will   ;00
  &FacingData_Freedan   ;01
  &FacingData_Shadow_A   ;02
  &FacingData_Shadow_B   ;03
]

FacingData_Will #000102030001020300010203000000010101020202030303040404

FacingData_Freedan #0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

FacingData_Shadow_A #00000000

FacingData_Shadow_B #000000000000