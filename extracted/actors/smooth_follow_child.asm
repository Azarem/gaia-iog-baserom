; Helper actor spawned by boss and puzzle scripts to make a child actor smoothly chase a reference actor.
; 
; Computes directional follow steps via smooth_follow.ComputeFollowAngle/ComputeFollowStep based on relative X/Y offsets, updating both actors' positions each frame. Used in Pyramid Blaster, Angkor wall walker, Mummy Queen, Sand Fanger, Edward Ribber, and other chase segments. Dies when the parent actor sets flag $4000 or on special actor ID $1FC0.
---------------------------------------------

?BANK 00

?INCLUDE 'smooth_follow'

!loopCounter                    7F0014

---------------------------------------------

smooth_follow_child {
    STZ $002A, X
    COP [SpawnMarkedAfter] ( @SmoothFollowChildTick, #$2000 )
    CPY #$1FC0
    BEQ loc_00E4FA
    LDA $24
    STA $0024, Y

  loc_00E4EF:
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_00E4EF

  loc_00E4FA:
    COP [Die]
}

SmoothFollowChildTick {
    TXY 
    LDX $0004, Y
    LDA $loopCounter, X
    TYX 
    STA $loopCounter, X
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $14
    BMI loc_00E53D
    STA $0018
    LDA $0016, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI loc_00E52F
    STA $001C
    CMP $0018
    BCC loc_00E52D
    JMP $&SmoothFollowApplyEastPrimary

  loc_00E52D:
    BRA loc_00E5A6

  loc_00E52F:
    EOR #$FFFF
    INC 
    STA $001C
    CMP $0018
    BCS loc_00E570
    BRA loc_00E58B

  loc_00E53D:
    EOR #$FFFF
    INC 
    STA $0018
    LDA $0016, Y
    SEC 
    SBC #$0008
    SEC 
    SBC $16
    BMI loc_00E55E
    STA $001C
    CMP $0018
    BCC loc_00E55B
    JMP $&SmoothFollowApplyEastSecondary

  loc_00E55B:
    JMP $&SmoothFollowApplyWestPrimary

  loc_00E55E:
    EOR #$FFFF
    INC 
    STA $001C
    CMP $0018
    BCC loc_00E56D
    JMP $&SmoothFollowApplySouthPrimary

  loc_00E56D:
    JMP $&SmoothFollowApplyWestSecondary

  loc_00E570:
    JSR $&smooth_follow.ComputeFollowAngle
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $16
    SEC 
    SBC $0000
    STA $16
    LDA $14
    CLC 
    ADC $0002
    STA $14
    JMP $&SmoothFollowWriteParentPos

  loc_00E58B:
    JSR $&smooth_follow.ComputeFollowAngleAlt
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $14
    CLC 
    ADC $0000
    STA $14
    LDA $16
    SEC 
    SBC $0002
    STA $16
    JMP $&SmoothFollowWriteParentPos

  loc_00E5A6:
    JSR $&smooth_follow.ComputeFollowAngleAlt
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $14
    CLC 
    ADC $0000
    STA $14
    LDA $16
    CLC 
    ADC $0002
    STA $16
    JMP $&SmoothFollowWriteParentPos
}

SmoothFollowApplyEastPrimary {
    JSR $&smooth_follow.ComputeFollowAngle
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $16
    CLC 
    ADC $0000
    STA $16
    LDA $14
    CLC 
    ADC $0002
    STA $14
    JMP $&SmoothFollowWriteParentPos
}

SmoothFollowApplyEastSecondary {
    JSR $&smooth_follow.ComputeFollowAngle
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $16
    CLC 
    ADC $0000
    STA $16
    LDA $14
    SEC 
    SBC $0002
    STA $14
    BRA SmoothFollowWriteParentPos
}

SmoothFollowApplyWestPrimary {
    JSR $&smooth_follow.ComputeFollowAngleAlt
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $14
    SEC 
    SBC $0000
    STA $14
    LDA $16
    CLC 
    ADC $0002
    STA $16
    BRA SmoothFollowWriteParentPos
}

SmoothFollowApplyWestSecondary {
    JSR $&smooth_follow.ComputeFollowAngleAlt
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $14
    SEC 
    SBC $0000
    STA $14
    LDA $16
    SEC 
    SBC $0002
    STA $16
    BRA SmoothFollowWriteParentPos
}

SmoothFollowApplySouthPrimary {
    JSR $&smooth_follow.ComputeFollowAngle
    COP [SetEntryContinue]
    JSR $&smooth_follow.ComputeFollowStep
    LDA $16
    SEC 
    SBC $0000
    STA $16
    LDA $14
    SEC 
    SBC $0002
    STA $14
    BRA SmoothFollowWriteParentPos
}

SmoothFollowWriteParentPos {
    LDA $0004, X
    TAY 
    LDA $0014, X
    STA $0014, Y
    LDA $0016, X
    STA $0016, Y
    RTL 
}