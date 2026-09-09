?BANK 02

!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRemapped                 065E
!joypadRaw                      0660
!joypadRepeatCounter            0662
!scrollModeFlags                06EF
!joypadInject                   09AC
!remapSelect                    0DA6
!remapX                         0DA8
!remapB                         0DAA
!remapA                         0DAC
!remapY                         0DAE
!remapStart                     0DB0
!remapL                         0DB2
!remapR                         0DB4
!M7A                            211B
!M7B                            211C
!M7C                            211D
!M7D                            211E
!M7X                            211F
!M7Y                            2120
!L_INIDISP                      802100
!L_NMITIMEN                     804200
!L_RDNMI                        804210

---------------------------------------------

VBlankPartial {
    PHP 
    REP #$20
    PHA 
    SEP #$20
    BRA loc_028057
}

VBlankWaitAndJoypad {
    PHP 
    REP #$20
    PHA 
    SEP #$20
    LDA $L_RDNMI

  loc_02804D:
    LDA $L_RDNMI
    BPL loc_02804D
    LDA $L_RDNMI

  loc_028057:
    LDA $scrollModeFlags
    BIT #$08
    BEQ loc_0280A6
    LDA $C2
    STA $M7A
    LDA $C3
    STA $M7A
    LDA $C4
    STA $M7B
    LDA $C5
    STA $M7B
    LDA $C6
    STA $M7C
    LDA $C7
    STA $M7C
    LDA $C8
    STA $M7D
    LDA $C9
    STA $M7D
    LDA $CA
    STA $M7X
    LDA $CB
    AND #$1F
    STA $M7X
    LDA $CC
    STA $M7Y
    LDA $CD
    AND #$1F
    STA $M7Y
    LDX $BE
    STX $CE
    LDX $C0
    STX $D0

  loc_0280A6:
    REP #$20
    LDA $joypadInject
    BEQ loc_0280B6
    STA $joypadCurrent
    STZ $joypadInject
    PLA 
    PLP 
    RTL 

  loc_0280B6:
    LDA $joypadRaw
    AND #$0F00
    STA $joypadRemapped
    LDA $remapL
    BEQ loc_0280D2
    LDA $joypadRaw
    BIT #$1000
    BEQ loc_0280D2
    LDA $remapL
    TSB $joypadRemapped

  loc_0280D2:
    LDA $remapR
    BEQ loc_0280E5
    LDA $joypadRaw
    BIT #$2000
    BEQ loc_0280E5
    LDA $remapR
    TSB $joypadRemapped

  loc_0280E5:
    LDA $remapB
    BEQ loc_0280F8
    LDA $joypadRaw
    BIT #$8000
    BEQ loc_0280F8
    LDA $remapB
    TSB $joypadRemapped

  loc_0280F8:
    LDA $remapY
    BEQ loc_02810B
    LDA $joypadRaw
    BIT #$4000
    BEQ loc_02810B
    LDA $remapY
    TSB $joypadRemapped

  loc_02810B:
    LDA $remapA
    BEQ loc_02811E
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_02811E
    LDA $remapA
    TSB $joypadRemapped

  loc_02811E:
    LDA $remapStart
    BEQ loc_028131
    LDA $joypadRaw
    BIT #$0040
    BEQ loc_028131
    LDA $remapStart
    TSB $joypadRemapped

  loc_028131:
    LDA $remapX
    BEQ loc_028144
    LDA $joypadRaw
    BIT #$0020
    BEQ loc_028144
    LDA $remapX
    TSB $joypadRemapped

  loc_028144:
    LDA $remapSelect
    BEQ loc_028157
    LDA $joypadRaw
    BIT #$0010
    BEQ loc_028157
    LDA $remapSelect
    TSB $joypadRemapped

  loc_028157:
    LDA $joypadRemapped
    STA $joypadCurrent
    STA $joypadRaw
    AND $joypadHeld
    STA $joypadHeld
    BEQ loc_02817F
    AND $joypadMaskInv
    BEQ loc_02817F
    LDA $joypadRepeatCounter
    INC 
    STA $joypadRepeatCounter
    CMP #$000C
    BNE loc_028182
    LDA $joypadMaskInv
    TRB $joypadHeld

  loc_02817F:
    STZ $joypadRepeatCounter

  loc_028182:
    LDA $joypadHeld
    TRB $joypadCurrent
    LDA $joypadMaskStd
    TRB $joypadCurrent
    PLA 
    PLP 
    RTL 
}

EnableNmiAndJoypad {
    PHP 
    SEP #$20
    PHA 
    LDA $L_RDNMI
    LDA #$81
    STA $L_NMITIMEN
    PLA 
    PLP 
    RTL 
}

EnableNmiOnly {
    PHP 
    SEP #$20
    PHA 
    LDA #$01
    STA $L_NMITIMEN
    PLA 
    PLP 
    RTL 
}

ForceBlank {
    PHP 
    SEP #$20
    PHA 
    LDA #$00
    STA $L_INIDISP
    PLA 
    PLP 
    RTL 
}

EnableDisplay {
    PHP 
    SEP #$20
    PHA 
    LDA #$80
    STA $L_INIDISP
    PLA 
    PLP 
    RTL 
}

WaitFrames {
    JSL $@VBlankWaitAndJoypad
    DEC 
    BNE WaitFrames
    RTL 
}