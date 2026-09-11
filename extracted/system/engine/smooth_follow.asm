?BANK 00

?INCLUDE 'hardware_math'
?INCLUDE 'sprite_composition'

!chatPtr                        7F000A
!animScratch2                   7F000E
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!loopCounter                    7F0014
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

CopySiblingFollowState {
    TXY 
    LDX $0004, Y
    LDA $loopCounter, X
    STA $0000
    LDA $chatPtr, X
    STA $0002
    TYX 
    LDA $0000
    STA $loopCounter, X
    LDA $0002
    STA $chatPtr, X
    BRA code_00E6CE
}

InitFollowAndChase {
    TXY 
    LDX $0004, Y
    LDA $loopCounter, X
    STA $0000
    LDA $chatPtr, X
    STA $0002
    TYX 
    LDA $0000
    STA $loopCounter, X
    LDA $0002
    STA $chatPtr, X
    LDA #$FFFF
    STA $animScratch2, X

  code_00E6CE:
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $14
    BMI loc_00E703
    STA $0018
    LDA $0016, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI loc_00E6F5
    STA $001C
    CMP $0018
    BCC loc_00E6F2
    JMP $&code_00E7A5

  loc_00E6F2:
    JMP $&code_00E789

  loc_00E6F5:
    EOR #$FFFF
    INC 
    STA $001C
    CMP $0018
    BCS loc_00E736
    BRA loc_00E763

  loc_00E703:
    EOR #$FFFF
    INC 
    STA $0018
    LDA $0016, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI loc_00E724
    STA $001C
    CMP $0018
    BCC loc_00E721
    JMP $&code_00E7CE

  loc_00E721:
    JMP $&code_00E7FB

  loc_00E724:
    EOR #$FFFF
    INC 
    STA $001C
    CMP $0018
    BCC loc_00E733
    JMP $&code_00E850

  loc_00E733:
    JMP $&code_00E821

  loc_00E736:
    JSR $&ComputeFollowAngle
    LDA #$0000
    STA $0000
    JSR $&ResolveFollowDirection
    LDA $0000
    BMI code_00E74A
    JMP $&SelectFallbackDirection

  code_00E74A:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0000
    EOR #$FFFF
    INC 
    TAY 
    LDA $0002
    STA $0000
    STY $0002
    JMP $&ApplyFollowMovement

  loc_00E763:
    JSR $&ComputeFollowAngleAlt
    LDA #$0002
    STA $0000
    JSR $&ResolveFollowDirectionAlt
    LDA $0000
    BMI code_00E777
    JMP $&SelectFallbackDirection

  code_00E777:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0002
    JMP $&ApplyFollowMovement
}

code_00E789 {
    JSR $&ComputeFollowAngleAlt
    LDA #$0004
    STA $0000
    JSR $&ResolveFollowDirection
    LDA $0000
    BMI code_00E79D
    JMP $&SelectFallbackDirection

  code_00E79D:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    JMP $&ApplyFollowMovement
}

code_00E7A5 {
    JSR $&ComputeFollowAngle
    LDA #$0006
    STA $0000
    JSR $&ResolveFollowDirectionAlt
    LDA $0000
    BMI code_00E7B9
    JMP $&SelectFallbackDirection

  code_00E7B9:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0000
    TAY 
    LDA $0002
    STA $0000
    STY $0002
    JMP $&ApplyFollowMovement
}

code_00E7CE {
    JSR $&ComputeFollowAngle
    LDA #$0008
    STA $0000
    JSR $&ResolveFollowDirection
    LDA $0000
    BMI code_00E7E2
    JMP $&SelectFallbackDirection

  code_00E7E2:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0002
    EOR #$FFFF
    INC 
    TAY 
    LDA $0000
    STA $0002
    STY $0000
    JMP $&ApplyFollowMovement
}

code_00E7FB {
    JSR $&ComputeFollowAngleAlt
    LDA #$000A
    STA $0000
    JSR $&ResolveFollowDirectionAlt
    LDA $0000
    BMI code_00E80F
    JMP $&SelectFallbackDirection

  code_00E80F:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0000
    EOR #$FFFF
    INC 
    STA $0000
    JMP $&ApplyFollowMovement
}

code_00E821 {
    JSR $&ComputeFollowAngleAlt
    LDA #$000C
    STA $0000
    JSR $&ResolveFollowDirection
    LDA $0000
    BMI code_00E835
    JMP $&SelectFallbackDirection

  code_00E835:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0000
    EOR #$FFFF
    INC 
    STA $0000
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0002
    BRA ApplyFollowMovement
}

code_00E850 {
    JSR $&ComputeFollowAngle
    LDA #$000E
    STA $0000
    JSR $&ResolveFollowDirectionAlt
    LDA $0000
    BMI code_00E864
    JMP $&SelectFallbackDirection

  code_00E864:
    COP [SetEntryContinue]
    JSR $&ComputeFollowStep
    LDA $0000
    EOR #$FFFF
    INC 
    TAY 
    LDA $0002
    EOR #$FFFF
    INC 
    STA $0000
    STY $0002
}

ApplyFollowMovement {
    LDY $04
    LDA $14
    CLC 
    ADC $0000
    STA $14
    STA $0014, Y
    LDA $0000
    STA $moveScratch1, X
    LDA $16
    CLC 
    ADC $0002
    STA $16
    STA $0016, Y
    LDA $0002
    STA $moveScratch2, X
    LDA $orbitDiameter, X
    CMP #$0008
    BPL loc_00E8AE
    RTL 

  loc_00E8AE:
    LDA #$0000
    STA $orbitDiameter, X
    COP [SetEntryExitNow] ( @code_00E6CE )
}

SelectFallbackDirection {
    DEC 
    AND #$0007
    STA $0004
    COP [SwitchCase] ( #$0004, &follow_fallback_table )
}

follow_fallback_table [
  &code_00E74A   ;00
  &code_00E777   ;01
  &code_00E79D   ;02
  &code_00E7B9   ;03
  &code_00E7E2   ;04
  &code_00E80F   ;05
  &code_00E835   ;06
  &code_00E864   ;07
]
---------------------------------------------

ComputeFollowAngle {
    LDA $0018
    CMP $001C
    BNE loc_00EDB5
    LDA #$0000
    BRA loc_00EE10

  loc_00EDB5:
    LDY $0018
    LDA $001C
    LSR 
    LSR 
    LSR 
    LSR 
    BNE loc_00EDDD
    BRA loc_00EDDC
}

ComputeFollowAngleAlt {
    LDA $001C
    CMP $0018
    BNE loc_00EDD0
    LDA #$0000
    BRA loc_00EE10

  loc_00EDD0:
    LDY $001C
    LDA $0018
    LSR 
    LSR 
    LSR 
    LSR 
    BNE loc_00EDDD

  loc_00EDDC:
    INC 

  loc_00EDDD:
    SEP #$20
    JSL $@hardware_math.UnsignedDivide
    REP #$20
    AND #$00FF
    CMP #$0018
    BPL loc_00EDF4
    CMP #$0011
    BPL loc_00EE02
    BRA loc_00EE08

  loc_00EDF4:
    SEC 
    SBC #$0010
    EOR #$FFFF
    INC 
    CLC 
    ADC #$0010
    BRA loc_00EE10

  loc_00EE02:
    SEC 
    SBC #$0010
    BRA loc_00EE10

  loc_00EE08:
    EOR #$FFFF
    INC 
    CLC 
    ADC #$0010

  loc_00EE10:
    STA $orbitAngle, X
    LDA #$0000
    STA $orbitDiameter, X
    RTS 
}

ComputeFollowStep {
    LDA $orbitAngle, X
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    TAY 
    LDA $orbitDiameter, X
    STA $0004
    ASL 
    STA $0006
    TYA 
    CLC 
    ADC $0006
    TAY 
    LDA $loopCounter, X
    STA $0000
    CLC 
    ADC $0004
    AND #$000F
    STA $0008
    STA $orbitDiameter, X
    PHX 
    TYX 
    STZ $0002

  loc_00EE51:
    LDA $@SmoothFollowLookup, X
    CLC 
    ADC $0002
    STA $0002
    INX 
    INX 
    INC $0004
    LDA $0004
    BIT #$FFF0
    BEQ loc_00EE75
    TXA 
    SEC 
    SBC #$0020
    TAX 
    LDA #$0000
    STA $0004

  loc_00EE75:
    CMP $0008
    BNE loc_00EE51
    PLX 
    RTS 
}

ResolveFollowDirection {
    LDA $orbitAngle, X
    CMP #$000D
    BPL loc_00EE9A
    CMP #$0005
    BPL loc_00EEA2
    BRA loc_00EEAA
}

ResolveFollowDirectionAlt {
    LDA $orbitAngle, X
    CMP #$000D
    BPL loc_00EEAA
    CMP #$0005
    BPL loc_00EEA2

  loc_00EE9A:
    LDA #$0000
    STA $0002
    BRA loc_00EEB0

  loc_00EEA2:
    LDA #$0001
    STA $0002
    BRA loc_00EEB0

  loc_00EEAA:
    LDA #$0002
    STA $0002

  loc_00EEB0:
    LDA $0000
    CLC 
    ADC $0002
    AND #$000F
    STA $0004
    LDA $chatPtr, X
    LDA $animScratch2, X
    BMI loc_00EF1C
    SEC 
    SBC $0004
    BMI loc_00EEE0
    BEQ loc_00EF1C
    CMP #$0001
    BEQ loc_00EF1C
    CMP #$000F
    BEQ loc_00EF1C
    CMP #$0009
    BPL loc_00EF0B
    BRA loc_00EEF1

  loc_00EEE0:
    CMP #$FFFF
    BEQ loc_00EF1C
    CMP #$FFF1
    BEQ loc_00EF1C
    CMP #$FFF9
    BPL loc_00EF0B
    BRA loc_00EEF1

  loc_00EEF1:
    LDA $animScratch2, X
    DEC 
    STA $animScratch2, X
    STA $0004
    BPL loc_00EF29
    LDA #$000F
    STA $animScratch2, X
    STA $0004
    BRA loc_00EF29

  loc_00EF0B:
    LDA $animScratch2, X
    INC 
    AND #$000F
    STA $animScratch2, X
    STA $0004
    BRA loc_00EF29

  loc_00EF1C:
    LDA $0004
    STA $animScratch2, X
    LDA #$FFFF
    STA $0000

  loc_00EF29:
    LDA $0004, X
    TAY 
    LDA $chatPtr, X
    BMI loc_00EF40
    CLC 
    ADC $0004
    STA $0028, Y
    LDA #$0000
    STA $002A, Y

  loc_00EF40:
    LDA $chatPtr, X
    BMI loc_00EF52
    PHX 
    TYX 
    TYA 
    TCD 
    JSL $@sprite_composition.UpdateActorAnimation
    PLA 
    TXY 
    TAX 
    TCD 

  loc_00EF52:
    LDA $chatPtr, X
    STA $0006
    LDA $animScratch2, X
    AND #$000F
    PHX 
    ASL 
    TAX 
    CLC 
    LDA $0006
    BPL loc_00EF6A
    SEC 

  loc_00EF6A:
    LDA $@FollowDirectionTable, X
    DEC 
    PLX 
    PHA 
    RTS 
}

FollowDirectionTable [
  &code_00EF92   ;00
  &code_00EFB0   ;01
  &code_00EFCE   ;02
  &code_00EFEC   ;03
  &code_00F00A   ;04
  &code_00F028   ;05
  &code_00F049   ;06
  &code_00F06A   ;07
  &code_00F08B   ;08
  &code_00F0AC   ;09
  &code_00F0CD   ;0A
  &code_00F0EE   ;0B
  &code_00F10F   ;0C
  &code_00F130   ;0D
  &code_00F151   ;0E
  &code_00F172   ;0F
]

code_00EF92 {
    BCS loc_00EF9D
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  loc_00EF9D:
    LDA $0000
    BMI loc_00EFAF
    LDA #$0001
    STA $0000
    LDA #$0010
    STA $orbitAngle, X

  loc_00EFAF:
    RTS 
}

code_00EFB0 {
    BCS loc_00EFBB
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  loc_00EFBB:
    LDA $0000
    BMI loc_00EFCD
    LDA #$0001
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00EFCD:
    RTS 
}

code_00EFCE {
    BCS loc_00EFD9
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  loc_00EFD9:
    LDA $0000
    BMI loc_00EFEB
    LDA #$0002
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  loc_00EFEB:
    RTS 
}

code_00EFEC {
    BCS loc_00EFF7
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  loc_00EFF7:
    LDA $0000
    BMI loc_00F009
    LDA #$0002
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F009:
    RTS 
}

code_00F00A {
    BCS loc_00F015
    LDA $000E, Y
    AND #$3FFF
    STA $000E, Y

  loc_00F015:
    LDA $0000
    BMI loc_00F027
    LDA #$0003
    STA $0000
    LDA #$0010
    STA $orbitAngle, X

  loc_00F027:
    RTS 
}

code_00F028 {
    BCS loc_00F036
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  loc_00F036:
    LDA $0000
    BMI loc_00F048
    LDA #$0003
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F048:
    RTS 
}

code_00F049 {
    BCS loc_00F057
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  loc_00F057:
    LDA $0000
    BMI loc_00F069
    LDA #$0004
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  loc_00F069:
    RTS 
}

code_00F06A {
    BCS loc_00F078
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  loc_00F078:
    LDA $0000
    BMI loc_00F08A
    LDA #$0004
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F08A:
    RTS 
}

code_00F08B {
    BCS loc_00F099
    LDA $000E, Y
    AND #$3FFF
    ORA #$8000
    STA $000E, Y

  loc_00F099:
    LDA $0000
    BMI loc_00F0AB
    LDA #$0005
    STA $0000
    LDA #$0010
    STA $orbitAngle, X

  loc_00F0AB:
    RTS 
}

code_00F0AC {
    BCS loc_00F0BA
    LDA $000E, Y
    AND #$3FFF
    ORA #$C000
    STA $000E, Y

  loc_00F0BA:
    LDA $0000
    BMI loc_00F0CC
    LDA #$0005
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F0CC:
    RTS 
}

code_00F0CD {
    BCS loc_00F0DB
    LDA $000E, Y
    AND #$3FFF
    ORA #$C000
    STA $000E, Y

  loc_00F0DB:
    LDA $0000
    BMI loc_00F0ED
    LDA #$0006
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  loc_00F0ED:
    RTS 
}

code_00F0EE {
    BCS loc_00F0FC
    LDA $000E, Y
    AND #$3FFF
    ORA #$C000
    STA $000E, Y

  loc_00F0FC:
    LDA $0000
    BMI loc_00F10E
    LDA #$0006
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F10E:
    RTS 
}

code_00F10F {
    BCS loc_00F11D
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  loc_00F11D:
    LDA $0000
    BMI loc_00F12F
    LDA #$0007
    STA $0000
    LDA #$0010
    STA $orbitAngle, X

  loc_00F12F:
    RTS 
}

code_00F130 {
    BCS loc_00F13E
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  loc_00F13E:
    LDA $0000
    BMI loc_00F150
    LDA #$0007
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F150:
    RTS 
}

code_00F151 {
    BCS loc_00F15F
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  loc_00F15F:
    LDA $0000
    BMI loc_00F171
    LDA #$0008
    STA $0000
    LDA #$0000
    STA $orbitAngle, X

  loc_00F171:
    RTS 
}

code_00F172 {
    BCS loc_00F180
    LDA $000E, Y
    AND #$3FFF
    ORA #$4000
    STA $000E, Y

  loc_00F180:
    LDA $0000
    BMI loc_00F192
    LDA #$0008
    STA $0000
    LDA #$0008
    STA $orbitAngle, X

  loc_00F192:
    RTS 
}

SmoothFollowLookup #01000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100000001000100010001000100010001000100010001000100010000000100010001000100010001000100000001000100010001000100000001000100010001000000010001000100010001000000010001000100010000000100010001000000010001000100000001000100010000000100010000000100010001000000010000000100010001000000010001000000010001000000010001000000010000000100010000000100010000000100000001000100000001000000010000000100000001000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000000000100000001000000010000000000010000000000010000000100000000000100000000000100000001000000000001000000000000000100000001000000000000000100000000000100000000000000010000000000000001000000000000000100000000000000010000000000000001000000000000000000010000000000000000000000010000000000000000000000000001000000000000000000000000000000010000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000