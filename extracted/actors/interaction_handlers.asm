?INCLUDE 'GetPlayerFacingDirection'

!playerActor                    09AA
!orbitAngle                     7F0010

---------------------------------------------

collect_handler_gem {
    COP [SetSavedPtr] ( &collect_handler_gem )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0031, &code_00E162 )

  code_00E161:
    RTL 
}

code_00E162 {
    COP [BranchIfPlayerNear] ( #0F, &code_00E168 )
    RTL 
}

code_00E168 {
    COP [BranchOnPlayerX] ( #$000F, &code_00E1DF, &code_00E172, &code_00E1DF )
}

code_00E172 {
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_00E1B1
    BPL loc_00E183
    EOR #$FFFF
    INC 

  loc_00E183:
    LSR 
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0000
    BNE loc_00E1AF
    COP [SetEntryContinue]
    LDY $04
    LDA $0016, Y
    SEC 
    SBC #$0002
    STA $0016, Y
    STA $16
    LDA $orbitAngle, X
    BEQ loc_00E1AF
    DEC 
    STA $orbitAngle, X
    BEQ loc_00E1AF
    RTL 

  loc_00E1AF:
    COP [RestoreSavedPtr]

  loc_00E1B1:
    LSR 
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE loc_00E1DD
    COP [SetEntryContinue]
    LDY $04
    LDA $0016, Y
    CLC 
    ADC #$0002
    STA $0016, Y
    STA $16
    LDA $orbitAngle, X
    BEQ loc_00E1DD
    DEC 
    STA $orbitAngle, X
    BEQ loc_00E1DD
    RTL 

  loc_00E1DD:
    COP [RestoreSavedPtr]
}

code_00E1DF {
    COP [BranchOnPlayerY] ( #$000F, &code_00E161, &code_00E1E9, &code_00E161 )
}

code_00E1E9 {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_00E228
    BPL loc_00E1FA
    EOR #$FFFF
    INC 

  loc_00E1FA:
    LSR 
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE loc_00E226
    COP [SetEntryContinue]
    LDY $04
    LDA $0014, Y
    SEC 
    SBC #$0002
    STA $0014, Y
    STA $14
    LDA $orbitAngle, X
    BEQ loc_00E226
    DEC 
    STA $orbitAngle, X
    BEQ loc_00E226
    RTL 

  loc_00E226:
    COP [RestoreSavedPtr]

  loc_00E228:
    LSR 
    STA $orbitAngle, X
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE loc_00E254
    COP [SetEntryContinue]
    LDY $04
    LDA $0014, Y
    CLC 
    ADC #$0002
    STA $0014, Y
    STA $14
    LDA $orbitAngle, X
    BEQ loc_00E254
    DEC 
    STA $orbitAngle, X
    BEQ loc_00E254
    RTL 

  loc_00E254:
    COP [RestoreSavedPtr]

  push_handler_solid:
    COP [SetSavedPtr] ( &push_handler_solid )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0031, &code_00E263 )

  code_00E262:
    RTL 
}

code_00E263 {
    COP [BranchIfPlayerNear] ( #0F, &code_00E269 )
    RTL 
}

code_00E269 {
    LDY $04
    LDA $0010, Y
    BIT #$0080
    BEQ loc_00E27F
    LDA $0012, Y
    BIT #$0010
    BNE loc_00E27F
    NOP 
    NOP 
    NOP 
    RTL 

  loc_00E27F:
    COP [BranchOnPlayerX] ( #$000F, &code_00E30C, &code_00E289, &code_00E30C )
}

code_00E289 {
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_00E2D3
    BPL loc_00E29A
    EOR #$FFFF
    INC 

  loc_00E29A:
    CMP #$0020
    BCC code_00E2D1
    JSL $@GetPlayerFacingDirection
    CMP #$0000
    BNE code_00E2D1
    COP [BranchIfSolidOffset] ( #00, #FF, &code_00E2D1 )
    COP [ClearLowHere]
    LDA $16
    SEC 
    SBC #$0010
    STA $16
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&code_00E399
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopNext]
    JSR $&code_00E3AC
}

code_00E2D1 {
    COP [RestoreSavedPtr]

  loc_00E2D3:
    CMP #$0020
    BCC code_00E30A
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE code_00E30A
    COP [BranchIfSolidOffset] ( #00, #01, &code_00E30A )
    COP [ClearLowHere]
    LDA $16
    CLC 
    ADC #$0010
    STA $16
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&code_00E399
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopNext]
    JSR $&code_00E3AC
}

code_00E30A {
    COP [RestoreSavedPtr]
}

code_00E30C {
    COP [BranchOnPlayerY] ( #$000F, &code_00E262, &code_00E316, &code_00E262 )
}

code_00E316 {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_00E360
    BPL loc_00E327
    EOR #$FFFF
    INC 

  loc_00E327:
    CMP #$0020
    BCC code_00E35E
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE code_00E35E
    COP [BranchIfSolidOffset] ( #FF, #00, &code_00E35E )
    COP [ClearLowHere]
    LDA $14
    SEC 
    SBC #$0010
    STA $14
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&code_00E399
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopNext]
    JSR $&code_00E3AC
}

code_00E35E {
    COP [RestoreSavedPtr]

  loc_00E360:
    CMP #$0020
    BCC code_00E397
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE code_00E397
    COP [BranchIfSolidOffset] ( #01, #00, &code_00E397 )
    COP [ClearLowHere]
    LDA $14
    CLC 
    ADC #$0010
    STA $14
    COP [SolidHighHere]
    COP [PlaySoundCh1] ( #2C )
    JSR $&code_00E399
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopNext]
    JSR $&code_00E3AC
}

code_00E397 {
    COP [RestoreSavedPtr]
}

code_00E399 {
    LDY $04
    LDA $0012, Y
    PHA 
    ORA #$0010
    STA $0012, Y
    PLA 
    AND #$0010
    STA $24
    RTS 
}

code_00E3AC {
    LDY $04
    LDA $0012, Y
    AND #$FFEF
    ORA $24
    STA $0012, Y
    RTS 
}

push_handler_forceball {
    COP [SetSavedPtr] ( &push_handler_forceball )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0031, &code_00E3D3 )
    LDY $04
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16

  code_00E3D2:
    RTL 
}

code_00E3D3 {
    COP [BranchIfPlayerNear] ( #0F, &code_00E3D9 )
    RTL 
}

code_00E3D9 {
    COP [BranchOnPlayerX] ( #$000F, &code_00E45A, &code_00E3E3, &code_00E45A )
}

code_00E3E3 {
    LDY $playerActor
    LDA $0016, Y
    SEC 
    SBC $16
    BPL loc_00E427
    BPL loc_00E3F4
    EOR #$FFFF
    INC 

  loc_00E3F4:
    CMP #$0020
    BCC code_00E425
    LDA $0028, Y
    CMP #$003A
    BNE code_00E425
    JSL $@GetPlayerFacingDirection
    CMP #$0000
    BNE code_00E425
    COP [BranchIfSolidOffset] ( #00, #FF, &code_00E425 )
    COP [AddPosition] ( #00, #F0 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    DEC 
    STA $0016, Y
    COP [LoopNext]
}

code_00E425 {
    COP [RestoreSavedPtr]

  loc_00E427:
    CMP #$0020
    BCC code_00E458
    LDA $0028, Y
    CMP #$003B
    BNE code_00E458
    JSL $@GetPlayerFacingDirection
    CMP #$0001
    BNE code_00E458
    COP [BranchIfSolidOffset] ( #00, #01, &code_00E458 )
    COP [AddPosition] ( #00, #10 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0016, Y
    INC 
    STA $0016, Y
    COP [LoopNext]
}

code_00E458 {
    COP [RestoreSavedPtr]
}

code_00E45A {
    COP [BranchOnPlayerY] ( #$000F, &code_00E3D2, &code_00E464, &code_00E3D2 )
}

code_00E464 {
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC $14
    BPL loc_00E4A8
    BPL loc_00E475
    EOR #$FFFF
    INC 

  loc_00E475:
    CMP #$0020
    BCC code_00E4A6
    LDA $0028, Y
    CMP #$003D
    BNE code_00E4A6
    JSL $@GetPlayerFacingDirection
    CMP #$0003
    BNE code_00E4A6
    COP [BranchIfSolidOffset] ( #FF, #00, &code_00E4A6 )
    COP [AddPosition] ( #F0, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    DEC 
    STA $0014, Y
    COP [LoopNext]
}

code_00E4A6 {
    COP [RestoreSavedPtr]

  loc_00E4A8:
    CMP #$0020
    BCC code_00E4D9
    LDA $0028, Y
    CMP #$003C
    BNE code_00E4D9
    JSL $@GetPlayerFacingDirection
    CMP #$0002
    BNE code_00E4D9
    COP [BranchIfSolidOffset] ( #01, #00, &code_00E4D9 )
    COP [AddPosition] ( #10, #00 )
    COP [PlaySoundCh1] ( #2C )
    COP [LoopInit] ( #10 )
    LDY $04
    LDA $0014, Y
    INC 
    STA $0014, Y
    COP [LoopNext]
}

code_00E4D9 {
    COP [RestoreSavedPtr]
}