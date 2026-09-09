!playerActor                    09AA
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!characterForm                  0AD4

---------------------------------------------

DarkSpacePaletteInit {
    LDA $characterForm
    CMP #$0002
    BEQ loc_02B218
    COP [Die]

  loc_02B218:
    COP [SpawnMarkedAfter] ( @DarkSpacePaletteCycleA, #$2800 )

  DarkSpacePaletteIdle:
    LDY $06
    LDA #$&DarkSpacePaletteCycleA
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    COP [SetEntryContinue]
    JSR $&DarkSpaceCheckValidity
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BNE DarkSpacePaletteActive
    COP [BranchIfFlagByte] ( #00, #01, &DarkSpacePaletteActive )
    RTL 
}

DarkSpacePaletteActive {
    LDY $06
    LDA #$&DarkSpacePaletteCycleB
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    COP [SetEntryContinue]
    JSR $&DarkSpaceCheckValidity
    LDA $playerSpeedEw
    ORA $playerSpeedNs
    BEQ loc_02B25D
    RTL 

  loc_02B25D:
    COP [BranchIfFlagByte] ( #00, #00, &DarkSpacePaletteIdle )
    RTL 
}

DarkSpaceCheckValidity {
    LDA $characterForm
    CMP #$0002
    BNE loc_02B28A
    LDY $playerActor
    LDA $0010, Y
    BIT #$0040
    BNE loc_02B278
    RTS 

  loc_02B278:
    PLA 
    LDY $06
    LDA #$&DarkSpacePaletteNop
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    COP [SetEntryContinue]
    RTL 

  loc_02B28A:
    PLA 
    COP [Die]
}

DarkSpacePaletteCycleA {
    COP [PaletteStart] ( #23 )
    COP [PaletteStep]
    BRA DarkSpacePaletteCycleA

  DarkSpacePaletteCycleB:
    COP [PaletteStart] ( #24 )
    COP [PaletteStep]
    BRA DarkSpacePaletteCycleB

  DarkSpacePaletteNop:
    COP [SetEntryContinue]
    RTL 
}