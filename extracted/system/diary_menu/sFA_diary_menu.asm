?BANK 0B

?INCLUDE 'oam_digit_compose'
?INCLUDE 'save_system'
?INCLUDE 'strings_0BF706'
?INCLUDE 'system_strings'
?INCLUDE 'vblank_joypad'
?INCLUDE 'vram_buffer_clear'

!sceneNext                      0642
!worldReadyFlag                 0654
!joypadCurrent                  0656
!joypadHeld                     0658
!joypadMaskStd                  065A
!joypadMaskInv                  065C
!joypadRemapped                 065E
!joypadRaw                      0660
!joypadRepeatCounter            0662
!bg1ScrollH                     068A
!bg2ScrollH                     068E
!cameraTargetX                  06BE
!cameraTargetY                  06C2
!scrollModeFlags                06EF
!playerActor                    09AA
!joypadInject                   09AC
!playerFlags                    09AE
!displayModeFlags               09EC
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
!W34SEL                         2124
!WOBJSEL                        2125
!TM                             212C
!TS                             212D
!CGWSEL                         2130
!CGADSUB                        2131
!APUIO0                         2140
!JOY2L                          421A
!animScratch                    7F0000
!cgramPalette                   7F0A00
!scratch1010                    7F1010
!free101C                       7F101C
!L_RDNMI                        804210

---------------------------------------------

sFA_diary_menu [
  actor-def < #00, #00, #28, {

  code_0BE23A:
    LDA #$0000
    STA $cgramPalette
    SEP #$20
    STA $TM
    REP #$20
    LDA #$FFFF
    STA $0D92
    STA $0D96
    STA $0D98
    LDA #$4001
    TSB $displayModeFlags
    SEP #$20
    LDA #$88
    STA $W34SEL
    LDA #$22
    STA $WOBJSEL
    REP #$20
    LDA #$0000
    STA $cgramPalette
    STA $0B04
    LDA #$0001
    STA $00EE
    SEP #$20
    LDA #$01
    STA $TM
    LDA #$04
    STA $TS
    LDA #$82
    STA $CGWSEL
    LDA #$41
    STA $CGADSUB
    REP #$20
    LDA #$0080
    STA $bg1ScrollH
    STA $cameraTargetX
    LDA #$0300
    STA $bg2ScrollH
    STA $cameraTargetY
    LDA #$3000
    TSB $joypadMaskStd
    LDA #$2800
    TSB $playerFlags
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    COP [PrintWideStringAlt] ( &widestring_0BF3F4 )
    JSR $&sub_0BED64
    LDA #$0F00
    STA $joypadMaskInv
    STZ $18
    COP [SetEntryContinue]
    LDA $worldReadyFlag
    BNE loc_0BE2CA
    RTL 

  loc_0BE2CA:
    BRA loc_0BE2D0
} >
]
---------------------------------------------

func_0BE2CC {
    COP [PrintWideStringAlt] ( &widestring_0BF3F4 )

  loc_0BE2D0:
    LDA #$FFFF
    STA $0D92
    LDA #$0000
    STA $0D98

  code_0BE2DC:
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0800, &code_0BE2F6 )
    COP [BranchIfButton] ( #$0400, &code_0BE30F )
    COP [BranchIfButton] ( #$0080, &code_0BE32B )
    RTL 
}

code_0BE2F6 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D98
    DEC 
    BPL loc_0BE302
    LDA #$0003

  loc_0BE302:
    STA $0D98
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

code_0BE30F {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D98
    INC 
    CMP #$0004
    BCC loc_0BE31E
    LDA #$0000

  loc_0BE31E:
    STA $0D98
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

code_0BE32B {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D98
    AND #$0003
    STA $0000
    LDA #$FFFF
    STA $0D98
    COP [SwitchCase] ( #$0000, &code_list_0BE34C )
}

code_list_0BE34C [
  &code_0BE354   ;00
  &code_0BEA55   ;01
  &func_0BE8A8   ;02
  &func_0BE6BA   ;03
]

code_0BE354 {
    JSR $&sub_0BEBF9
    COP [PrintWideStringAlt] ( &widestring_0BF437 )
    COP [CallScript] ( &code_0BEB8B )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA $0D8C
    AND #$0003
    STA $0D92

  code_0BE36D:
    COP [SetEntryExit]
    LDA #$000C
    STA $free101C, X
    COP [CallScript] ( &code_0BE527 )
    COP [SetEntryContinueDeferred] ( @code_0BE36D )
    COP [BranchIfButton] ( #$0800, &code_0BE398 )
    COP [BranchIfButton] ( #$0400, &code_0BE3B1 )
    COP [BranchIfButton] ( #$0080, &code_0BE3DF )
    COP [BranchIfButton] ( #$8000, &code_0BE3CD )
    RTL 
}

code_0BE398 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BE3A4
    LDA #$0002

  loc_0BE3A4:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

code_0BE3B1 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BE3C0
    LDA #$0000

  loc_0BE3C0:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

code_0BE3CD {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&sub_0BEBF9
    JMP $&func_0BE2CC
}

code_0BE3DF {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D92
    STA $0D8C
    LDA #$FFFF
    STA $0D92
    LDA $0D8C
    STA $306000
    JSL $@save_system.LoadGameState_Scene
    BCS loc_0BE433
    JSR $&sub_0BE673
    LDA $0AB2
    STA $0AAC
    LDA #$00E6
    STA $sceneNext
    LDA #$0078
    STA $064C
    LDA #$0090
    STA $064E
    LDA #$0003
    STA $0650
    LDA #$1100
    STA $0652
    LDA #$2800
    TRB $playerFlags
    COP [Die]

  loc_0BE433:
    LDA $0D92
    STA $0D94
    LDA #$FFFF
    STA $0D92
    LDA #$0000
    STA $0D8E
    STA $0D90
    JSR $&sub_0BEBF9
    COP [PrintWideStringAlt] ( &widestring_0BF5AD )
    COP [PrintWideStringAlt] ( &widestring_0BF625 )
    COP [PrintWideStringAlt] ( &widestring_0BF630 )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA #$0000
    STA $0D98

  code_0BE462:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0380, &code_0BE498 )
    COP [BranchIfButton] ( #$0800, &code_0BE75B )
    COP [BranchIfButton] ( #$0400, &code_0BE774 )
    COP [BranchIfButton] ( #$8000, &code_0BE47D )
    RTL 
}

code_0BE47D {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    LDA $0D94
    STA $0D92
    JMP $&code_0BE354
}

code_0BE498 {
    LDA #$0380
    TSB $joypadHeld
    LDA $0D98
    BEQ loc_0BE4E7
    DEC 
    BNE loc_0BE4C5
    COP [PlaySoundCh2] ( #0D )
    LDA $0D90
    INC 
    AND #$0001
    STA $0D90
    COP [PrintWideStringAlt] ( &widestring_0BF625 )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA #$0380
    TSB $joypadHeld
    JMP $&code_0BE462

  loc_0BE4C5:
    DEC 
    BNE loc_0BE4E7
    COP [PlaySoundCh2] ( #0D )
    LDA $0D8E
    INC 
    AND #$0001
    STA $0D8E
    COP [PrintWideStringAlt] ( &widestring_0BF630 )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA #$0380
    TSB $joypadHeld
    JMP $&code_0BE462

  loc_0BE4E7:
    COP [BranchIfButton] ( #$0080, &code_0BE4EE )
    RTL 
}

code_0BE4EE {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    LDA $0D90
    STA $0B24
    LDA $0D8E
    STA $0B26
    JSR $&sub_0BE673
    LDA #$0008
    STA $sceneNext
    COP [QueueMapChange] ( #08, #$0050, #$00A0, #00, #$1200 )
    LDA #$2800
    TRB $playerFlags
    COP [Die]
}

code_0BE527 {
    PHX 
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    ASL 
    TAX 
    LDA $@strings_0BF706, X
    SEC 
    SBC #$&strings_0BF706
    TAX 
    SEP #$20

  loc_0BE53D:
    LDA $@strings_0BF706, X
    INX 
    CMP #$CA
    BNE loc_0BE53D
    REP #$20
    LDA $@strings_0BF706, X
    TAY 
    LDA $@strings_0BF706+2, X
    PLX 
    STA $7F100E, X
    TYA 
    STA $7F100C, X
    SEC 
    SBC $cameraTargetX
    BMI loc_0BE56E
    STA $7F100C, X
    LDA #$0001
    STA $animScratch, X
    BRA loc_0BE57D

  loc_0BE56E:
    EOR #$FFFF
    INC 
    STA $7F100C, X
    LDA #$FFFF
    STA $animScratch, X

  loc_0BE57D:
    LDA $7F100E, X
    SEC 
    SBC $cameraTargetY
    BMI loc_0BE596
    STA $7F100E, X
    BEQ loc_0BE590
    LDA #$0001

  loc_0BE590:
    STA $animScratch+2, X
    BRA loc_0BE5A7

  loc_0BE596:
    EOR #$FFFF
    INC 
    STA $7F100E, X
    BEQ loc_0BE5A3
    LDA #$FFFF

  loc_0BE5A3:
    STA $animScratch+2, X

  loc_0BE5A7:
    LDA $7F100C, X
    CMP $7F100E, X
    BCC loc_0BE612
    LDA $7F100C, X
    BEQ loc_0BE610
    STA $scratch1010+4, X
    LSR 
    STA $scratch1010, X
    LDA $7F100E, X
    STA $scratch1010+2, X
    COP [SetEntryContinue]
    LDA $free101C, X
    STA $0000

  loc_0BE5D1:
    LDA $animScratch, X
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX
    LDA $scratch1010, X
    SEC 
    SBC $scratch1010+2, X
    STA $scratch1010, X
    BPL loc_0BE5FF
    CLC 
    ADC $7F100C, X
    STA $scratch1010, X
    LDA $animScratch+2, X
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY

  loc_0BE5FF:
    LDA $scratch1010+4, X
    DEC 
    STA $scratch1010+4, X
    BEQ loc_0BE610
    DEC $0000
    BNE loc_0BE5D1
    RTL 

  loc_0BE610:
    COP [RestoreSavedPtr]

  loc_0BE612:
    LDA $7F100E, X
    BEQ loc_0BE671
    STA $scratch1010+4, X
    LSR 
    STA $scratch1010+2, X
    LDA $7F100C, X
    STA $scratch1010, X
    COP [SetEntryContinue]
    LDA $free101C, X
    STA $0000

  loc_0BE632:
    LDA $animScratch+2, X
    CLC 
    ADC $cameraTargetY
    STA $cameraTargetY
    LDA $scratch1010+2, X
    SEC 
    SBC $scratch1010, X
    STA $scratch1010+2, X
    BPL loc_0BE660
    CLC 
    ADC $7F100E, X
    STA $scratch1010+2, X
    LDA $animScratch, X
    CLC 
    ADC $cameraTargetX
    STA $cameraTargetX

  loc_0BE660:
    LDA $scratch1010+4, X
    DEC 
    STA $scratch1010+4, X
    BEQ loc_0BE671
    DEC $0000
    BNE loc_0BE632
    RTL 

  loc_0BE671:
    COP [RestoreSavedPtr]
}
---------------------------------------------

sub_0BE673 {
    LDA #$0000
    STA $0B04
    STZ $00EE
    LDA $0B24
    BNE loc_0BE68C
    SEP #$20
    LDA #$91
    STA $APUIO0
    REP #$20
    BRA loc_0BE695

  loc_0BE68C:
    SEP #$20
    LDA #$90
    STA $APUIO0
    REP #$20

  loc_0BE695:
    LDA $0B26
    BNE loc_0BE6B3
    LDA #$8000
    STA $remapA
    LDA #$4000
    STA $remapB
    LDA #$0000
    STA $remapStart
    LDA #$0040
    STA $remapY
    RTS 

  loc_0BE6B3:
    LDA #$0000
    STA $remapStart
    RTS 
}
---------------------------------------------

func_0BE6BA {
    JSR $&sub_0BEBF9
    COP [PrintWideStringAlt] ( &widestring_0BF476 )
    COP [CallScript] ( &code_0BEB8B )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA #$0000
    STA $0D92

  code_0BE6D0:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &code_0BEA86 )
    COP [BranchIfButton] ( #$0400, &code_0BEA9F )
    COP [BranchIfButton] ( #$0080, &code_0BE6FD )
    COP [BranchIfButton] ( #$8000, &code_0BE6EB )
    RTL 
}

code_0BE6EB {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&sub_0BEBF9
    JMP $&func_0BE2CC
}

code_0BE6FD {
    COP [PlaySoundCh2] ( #12 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    BNE loc_0BE714
    RTL 

  loc_0BE714:
    COP [PlaySoundCh2] ( #11 )
    LDA $0D92
    STA $0D94
    JSR $&sub_0BE840
    LDA #$FFFF
    STA $0D92
    JSR $&sub_0BEBF9
    COP [PrintWideStringAlt] ( &widestring_0BF538 )
    COP [PrintWideStringAlt] ( &widestring_0BF625 )
    COP [PrintWideStringAlt] ( &widestring_0BF630 )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA #$0000
    STA $0D98

  code_0BE740:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0380, &code_0BE7A5 )
    COP [BranchIfButton] ( #$0800, &code_0BE75B )
    COP [BranchIfButton] ( #$0400, &code_0BE774 )
    COP [BranchIfButton] ( #$8000, &code_0BE790 )
    RTL 
}

code_0BE75B {
    COP [PlaySoundCh2] ( #10 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D98
    DEC 
    BPL loc_0BE770
    LDA #$0002

  loc_0BE770:
    STA $0D98
    RTL 
}

code_0BE774 {
    COP [PlaySoundCh2] ( #10 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D98
    INC 
    CMP #$0003
    BCC loc_0BE78C
    LDA #$0000

  loc_0BE78C:
    STA $0D98
    RTL 
}

code_0BE790 {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    JMP $&func_0BE6BA
}

code_0BE7A5 {
    LDA $0D98
    BEQ loc_0BE7EE
    DEC 
    BNE loc_0BE7CC
    COP [PlaySoundCh2] ( #10 )
    LDA $0D90
    INC 
    AND #$0001
    STA $0D90
    COP [PrintWideStringAlt] ( &widestring_0BF625 )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA #$0380
    TSB $joypadHeld
    JMP $&code_0BE740

  loc_0BE7CC:
    DEC 
    BNE loc_0BE7EE
    COP [PlaySoundCh2] ( #10 )
    LDA $0D8E
    INC 
    AND #$0001
    STA $0D8E
    COP [PrintWideStringAlt] ( &widestring_0BF630 )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA #$0380
    TSB $joypadHeld
    JMP $&code_0BE740

  loc_0BE7EE:
    COP [BranchIfButton] ( #$0080, &code_0BE7F5 )
    RTL 
}

code_0BE7F5 {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA #$FFFF
    STA $0D98
    LDA $0D94
    JSR $&sub_0BE87C
    PHX 
    LDA $0D94
    XBA 
    ASL 
    TAX 
    JSL $@save_system.ComputeSaveChecksum
    LDA $0018
    STA $3063FC, X
    LDA $001C
    STA $3063FE, X
    PLX 
    JSR $&sub_0BEBF9
    COP [PrintWideStringAlt] ( &widestring_0BF476 )
    COP [CallScript] ( &code_0BEB8B )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA $0D94
    STA $0D92
    JMP $&code_0BE6D0
}
---------------------------------------------

sub_0BE840 {
    PHX 
    XBA 
    ASL 
    TAX 
    PHX 
    LDA $01, S
    CLC 
    ADC #$0B24
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    CMP #$0002
    BCC loc_0BE85C
    LDA #$0000

  loc_0BE85C:
    STA $0D90
    LDA $01, S
    CLC 
    ADC #$0B26
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    CMP #$0002
    BCC loc_0BE876
    LDA #$0000

  loc_0BE876:
    STA $0D8E
    PLX 
    PLX 
    RTS 
}
---------------------------------------------

sub_0BE87C {
    PHX 
    XBA 
    ASL 
    TAX 
    PHX 
    LDA $01, S
    CLC 
    ADC #$0B24
    SEC 
    SBC #$0A00
    TAX 
    LDA $0D90
    STA $306200, X
    LDA $01, S
    CLC 
    ADC #$0B26
    SEC 
    SBC #$0A00
    TAX 
    LDA $0D8E
    STA $306200, X
    PLX 
    PLX 
    RTS 
}
---------------------------------------------

func_0BE8A8 {
    LDA $0D74
    BEQ loc_0BE8D4
    LDA $0D76
    BEQ loc_0BE8D4
    LDA $0D78
    BEQ loc_0BE8D4
    LDA #$0002
    STA $0D98
    STZ $00EE
    COP [PrintWideStringAlt] ( &widestring_0BF679 )
    LDA #$0001
    STA $00EE
    JSR $&sub_0BEBF9
    COP [PrintWideStringAlt] ( &widestring_0BF3F4 )
    JMP $&code_0BE2DC

  loc_0BE8D4:
    JSR $&sub_0BEBF9
    LDA #$0000
    STA $0D92

  code_0BE8DD:
    COP [PrintWideStringAlt] ( &widestring_0BF48C )
    COP [CallScript] ( &code_0BEB8B )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &code_0BE905 )
    COP [BranchIfButton] ( #$0400, &code_0BE91E )
    COP [BranchIfButton] ( #$0080, &code_0BE949 )
    COP [BranchIfButton] ( #$8000, &code_0BE93A )
    RTL 
}

code_0BE905 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BE911
    LDA #$0002

  loc_0BE911:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

code_0BE91E {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BE92D
    LDA #$0000

  loc_0BE92D:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

code_0BE93A {
    COP [PlaySoundCh2] ( #0D )
    LDA #$8000
    TSB $joypadHeld
    JSR $&sub_0BEBF9
    JMP $&func_0BE2CC
}

code_0BE949 {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    BNE loc_0BE960
    RTL 

  loc_0BE960:
    LDY #$0000

  loc_0BE963:
    LDA $0D74, Y
    BEQ loc_0BE972
    INY 
    INY 
    CPY #$0006
    BCC loc_0BE963
    BNE loc_0BE972
    RTL 

  loc_0BE972:
    TYA 
    LSR 
    STA $0D96
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &code_0BE992 )
    COP [BranchIfButton] ( #$0400, &code_0BE9B7 )
    COP [BranchIfButton] ( #$0080, &code_0BE9F7 )
    COP [BranchIfButton] ( #$8000, &code_0BE9DF )
    RTL 
}

code_0BE992 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D96

  loc_0BE998:
    DEC 
    BPL loc_0BE99E
    LDA #$0002

  loc_0BE99E:
    STA $0D96
    CMP $0D92
    BEQ loc_0BE998
    ASL 
    TAY 
    LDA $0D74, Y
    BNE code_0BE992
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

code_0BE9B7 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D96

  loc_0BE9BD:
    INC 
    CMP #$0003
    BCC loc_0BE9C6
    LDA #$0000

  loc_0BE9C6:
    STA $0D96
    CMP $0D92
    BEQ loc_0BE9BD
    ASL 
    TAY 
    LDA $0D74, Y
    BNE code_0BE9B7
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

code_0BE9DF {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&sub_0BEBF9
    LDA #$FFFF
    STA $0D96
    JMP $&code_0BE8DD
}

code_0BE9F7 {
    LDA $0D96
    ASL 
    TAY 
    LDA $0D74, Y
    BEQ loc_0BEA04
    JMP $&code_0BE949

  loc_0BEA04:
    COP [PlaySoundCh2] ( #29 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    PHX 
    LDA $0D92
    AND #$0003
    XBA 
    ASL 
    CLC 
    ADC #$6200
    TAX 
    LDA $0D96
    AND #$0003
    XBA 
    ASL 
    CLC 
    ADC #$6200
    TAY 
    SEP #$20
    LDA #$30
    STA $0405
    LDA #$30
    STA $0404
    REP #$20
    LDA #$01FF
    JSR $0402
    PLX 
    LDA $0D96
    STA $0D92
    LDA #$FFFF
    STA $0D96
    JSR $&sub_0BED64
    JSR $&sub_0BEBF9
    JMP $&code_0BE8DD
}

code_0BEA55 {
    JSR $&sub_0BEBF9

  code_0BEA58:
    COP [PrintWideStringAlt] ( &widestring_0BF4A7 )
    COP [CallScript] ( &code_0BEB8B )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA #$0000
    STA $0D92

  code_0BEA6B:
    COP [SetEntryExit]
    COP [BranchIfButton] ( #$0800, &code_0BEA86 )
    COP [BranchIfButton] ( #$0400, &code_0BEA9F )
    COP [BranchIfButton] ( #$0080, &code_0BEACD )
    COP [BranchIfButton] ( #$8000, &code_0BEABB )
    RTL 
}

code_0BEA86 {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    DEC 
    BPL loc_0BEA92
    LDA #$0002

  loc_0BEA92:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

code_0BEA9F {
    COP [PlaySoundCh2] ( #10 )
    LDA $0D92
    INC 
    CMP #$0003
    BCC loc_0BEAAE
    LDA #$0000

  loc_0BEAAE:
    STA $0D92
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    RTL 
}

code_0BEABB {
    COP [PlaySoundCh2] ( #0D )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    JSR $&sub_0BEBF9
    JMP $&func_0BE2CC
}

code_0BEACD {
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    LDA $0D92
    ASL 
    TAY 
    LDA $0D74, Y
    BNE loc_0BEAF0
    COP [PlaySoundCh2] ( #12 )
    LDA $0D92
    JSL $@save_system.ClearSaveSlot
    JMP $&code_0BEA6B

  loc_0BEAF0:
    LDA $0D92
    STA $0D94
    LDA #$FFFF
    STA $0D92
    JSR $&sub_0BEBF9
    COP [PrintWideStringAlt] ( &widestring_0BF6B3 )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA $0D94
    ASL 
    TAY 
    LDA $0D7A, Y
    PHY 
    JSR $&sub_0BF1DB
    PLY 
    STA $0D9A
    LDA $0D80, Y
    PHY 
    JSR $&sub_0BF1DB
    PLY 
    STA $0D9E
    LDA $0D86, Y
    PHY 
    JSR $&sub_0BF1DB
    PLY 
    STA $0D9C
    COP [PrintWideStringAlt] ( &widestring_0BF6A4 )
    COP [RunBg3Script] ( @system_strings.asciistring_01EADC )
    LDA #$4000
    STA $remapB
    STZ $remapY
    COP [DialogueOptions] ( #02, #03, &code_list_0BEB46 )
}

code_list_0BEB46 [
  &code_0BEB4C   ;00
  &code_0BEB4C   ;01
  &code_0BEB61   ;02
]

code_0BEB4C {
    LDA #$8000
    TSB $joypadHeld
    LDA #$8000
    STA $remapB
    LDA #$4000
    STA $remapY
    JMP $&code_0BEA55
}

code_0BEB61 {
    LDA #$8000
    STA $remapB
    LDA #$4000
    STA $remapY
    COP [PlaySoundCh2] ( #13 )
    COP [SetEntryContinue]
    LDA $0D94
    JSL $@save_system.ClearSaveSlot
    COP [WaitByte] ( #1D )
    LDA $1C
    STA $1A
    STZ $1C
    JSR $&sub_0BEBF9
    JSR $&sub_0BED64
    JMP $&code_0BEA58
}

code_0BEB8B {
    LDA $0D74
    BEQ loc_0BEBAF
    LDA $0D7A
    JSR $&sub_0BF1DB
    STA $0D9A
    LDA $0D80
    JSR $&sub_0BF1DB
    STA $0D9E
    LDA $0D86
    JSR $&sub_0BF1DB
    STA $0D9C
    COP [PrintWideStringAlt] ( &widestring_0BF4C3 )

  loc_0BEBAF:
    LDA $0D76
    BEQ loc_0BEBD3
    LDA $0D7C
    JSR $&sub_0BF1DB
    STA $0D9A
    LDA $0D82
    JSR $&sub_0BF1DB
    STA $0D9E
    LDA $0D88
    JSR $&sub_0BF1DB
    STA $0D9C
    COP [PrintWideStringAlt] ( &widestring_0BF4EA )

  loc_0BEBD3:
    LDA $0D78
    BEQ loc_0BEBF7
    LDA $0D7E
    JSR $&sub_0BF1DB
    STA $0D9A
    LDA $0D84
    JSR $&sub_0BF1DB
    STA $0D9E
    LDA $0D8A
    JSR $&sub_0BF1DB
    STA $0D9C
    COP [PrintWideStringAlt] ( &widestring_0BF511 )

  loc_0BEBF7:
    COP [RestoreSavedPtr]
}
---------------------------------------------

sub_0BEBF9 {
    PHP 
    PHX 
    PHD 
    SEP #$20
    JSL $@vram_buffer_clear.ClearVramBufferFull
    PLX 
    PLD 
    PLP 
    RTS 
}
---------------------------------------------

func_0BEC06_noref {
    COP [BranchIfButton] ( #$8000, &code_0BEC8C )
    COP [BranchIfButton] ( #$6040, &code_0BECA1 )
    COP [BranchIfButton] ( #$0800, &code_0BEC6C )
    COP [BranchIfButton] ( #$0400, &code_0BEC74 )
    LDA $14
    CMP #$0002
    BCS loc_0BEC31
    COP [BranchIfButton] ( #$0200, &code_0BEC7C )
    COP [BranchIfButton] ( #$0100, &code_0BEC84 )

  loc_0BEC31:
    LDA $18
    INC $18
    BIT #$000F
    BEQ loc_0BEC53
    LDA $1A
    CLC 
    RTS 
}
---------------------------------------------

func_0BEC3E {
    STA $1A
    JSR $&sub_0BECFB
    STZ $18
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    COP [PlaySoundCh2] ( #10 )
    LDA $18

  loc_0BEC53:
    BIT #$0010
    BNE loc_0BEC5F
    JSR $&sub_0BECB1
    LDA $1A
    CLC 
    RTS 

  loc_0BEC5F:
    JSR $&sub_0BECD9
    LDA #$0001
    TSB $displayModeFlags
    LDA $1A
    CLC 
    RTS 
}

code_0BEC6C {
    LDA $1A
    SEC 
    SBC #$0001
    BRA func_0BEC3E
}

code_0BEC74 {
    LDA $1A
    CLC 
    ADC #$0001
    BRA func_0BEC3E
}

code_0BEC7C {
    LDA $1A
    SEC 
    SBC #$0002
    BRA func_0BEC3E
}

code_0BEC84 {
    LDA $1A
    CLC 
    ADC #$0002
    BRA func_0BEC3E
}

code_0BEC8C {
    JSR $&sub_0BECB1
    COP [PlaySoundCh2] ( #11 )
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    STZ $18
    LDA $1A
    SEC 
    RTS 
}

code_0BECA1 {
    LDA $joypadCurrent
    ORA $joypadHeld
    STA $joypadHeld
    STZ $18
    LDA #$FFFF
    SEC 
    RTS 
}
---------------------------------------------

sub_0BECB1 {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@table_0BED3C, X
    SEC 
    SBC #$&table_0BED3C
    CLC 
    ADC $1A
    CLC 
    ADC $1A
    TAX 
    LDA $@table_0BED3C+2, X
    TAX 
    LDA #$202B
    STA $7F0200, X
    PLX 
    LDA #$0001
    TSB $displayModeFlags
    RTS 
}
---------------------------------------------

sub_0BECD9 {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@table_0BED3C, X
    SEC 
    SBC #$&table_0BED3C
    CLC 
    ADC $1A
    CLC 
    ADC $1A
    TAX 
    LDA $@table_0BED3C+2, X
    TAX 
    LDA #$2040
    STA $7F0200, X
    PLX 
    RTS 
}
---------------------------------------------

sub_0BECFB {
    PHX 
    LDA $14
    ASL 
    TAX 
    LDA $@table_0BED3C, X
    SEC 
    SBC #$&table_0BED3C
    TAX 
    LDA $1A
    BPL loc_0BED12
    CLC 
    ADC $@table_0BED3C, X

  loc_0BED12:
    CMP $@table_0BED3C, X
    BCC loc_0BED1D
    SEC 
    SBC $@table_0BED3C, X

  loc_0BED1D:
    STA $1A
    LDA $@table_0BED3C, X
    TAY 
    DEY 
    INX 
    INX 

  loc_0BED27:
    LDA $@table_0BED3C, X
    PHX 
    TAX 
    LDA #$2040
    STA $7F0200, X
    PLX 
    INX 
    INX 
    DEY 
    BPL loc_0BED27
    PLX 
    RTS 
}
---------------------------------------------

table_0BED3C [
  &word_0BED44   ;00
  &word_0BED4E   ;01
  &word_0BED54   ;02
  &word_0BED5C   ;03
]

word_0BED44 [
  #$0004   ;00
  #$014A   ;01
  #$01CA   ;02
  #$0160   ;03
  #$01E0   ;04
]

word_0BED4E [
  #$0002   ;00
  #$01CE   ;01
  #$01D8   ;02
]

word_0BED54 [
  #$0003   ;00
  #$02CA   ;01
  #$044A   ;02
  #$05CA   ;03
]

word_0BED5C [
  #$0003   ;00
  #$034A   ;01
  #$03CA   ;02
  #$044A   ;03
]
---------------------------------------------

sub_0BED64 {
    PHX 
    LDA #$0000
    STA $0D74
    STA $0D76
    STA $0D78
    STA $0D7A
    STA $0D7C
    STA $0D7E
    STA $0D80
    STA $0D82
    STA $0D84
    STA $0D80
    STA $0D82
    STA $0D84
    LDA #$0002
    STA $24
    STZ $26
    LDA $306000
    CMP #$0003
    BCC loc_0BEDA3
    LDA #$0000
    STA $306000

  loc_0BEDA3:
    STA $0D8C

  code_0BEDA6:
    LDA $24
    XBA 
    ASL 
    TAX 
    JSL $@save_system.ComputeSaveChecksum
    LDA $0018
    CMP $3063FC, X
    BNE loc_0BEE11
    LDA $001C
    CMP $3063FE, X
    BNE loc_0BEE11
    PHX 
    LDA $24
    ASL 
    TAY 
    TXA 
    CLC 
    ADC #$0B12
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D74, Y
    LDA $01, S
    CLC 
    ADC #$0ACA
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D7A, Y
    LDA $01, S
    CLC 
    ADC #$0ADC
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D80, Y
    LDA $01, S
    CLC 
    ADC #$0ADE
    SEC 
    SBC #$0A00
    TAX 
    LDA $306200, X
    STA $0D86, Y
    PLA 
    SEC 
    BRA loc_0BEE12

  loc_0BEE11:
    CLC 

  loc_0BEE12:
    ROL $26
    LDA $24
    DEC 
    STA $24
    BMI loc_0BEE1E
    JMP $&code_0BEDA6

  loc_0BEE1E:
    PLX 
    RTS 
}
---------------------------------------------

func_0BF178_noref {
    LDA $00E0
    AND $00E2
    STA $00E2
    LDA $00E2
    TRB $00E0
    LDA $00E0
    BIT #$0040
    BEQ loc_0BF1A1
    LDY $playerActor
    LDA $0010, Y
    EOR #$0008
    STA $0010, Y
    LDA #$0040
    TSB $00E2

  loc_0BF1A1:
    RTL 
}
---------------------------------------------

func_0BF1A2_noref {
    STZ $00DE
    RTL 
}
---------------------------------------------

func_0BF1A6_noref {
    INC $00DE
    RTL 
}
---------------------------------------------

func_0BF1AA_noref {
    LDA $00E0
    BIT #$8000
    BNE loc_0BF1B3
    RTL 

  loc_0BF1B3:
    LDA $00DE
    JSR $&sub_0BF1DB
    STA $0000
    LDA $bg1ScrollH
    CLC 
    ADC #$0010
    STA $0018
    LDA $bg2ScrollH
    CLC 
    ADC #$0070
    STA $001C
    LDA #$3200
    STA $0002
    JSL $@oam_digit_compose.ComposeDigits_Continuation
    RTL 
}
---------------------------------------------

sub_0BF1DB {
    PHA 
    LDY $0000
    STZ $0000
    CMP #$03E8
    BCS loc_0BF245
    CMP #$01F4
    BCC loc_0BF1F8
    SEC 
    SBC #$01F4
    PHA 
    LDA #$0005
    STA $0000
    PLA 

  loc_0BF1F8:
    CMP #$0064
    BCC loc_0BF206
    SEC 
    SBC #$0064
    INC $0000
    BRA loc_0BF1F8

  loc_0BF206:
    PHA 
    LDA $0000
    XBA 
    AND #$FF00
    STA $0000
    PLA 
    SEP #$20
    CMP #$32
    BCC loc_0BF222
    SEC 
    SBC #$32
    PHA 
    LDA #$05
    STA $0000
    PLA 

  loc_0BF222:
    CMP #$0A
    BCC loc_0BF22E
    SEC 
    SBC #$0A
    INC $0000
    BRA loc_0BF222

  loc_0BF22E:
    PHA 
    LDA $0000
    ASL 
    ASL 
    ASL 
    ASL 
    ORA $01, S
    STA $01, S
    PLA 
    REP #$20
    STA $01, S
    STY $0000
    PLA 
    CLC 
    RTS 

  loc_0BF245:
    STY $0000
    PLA 
    SEC 
    RTS 
}
---------------------------------------------

func_0BF24B_noref {
    LDA $00E1
    BIT #$F040
    ASL $A9
    TSB $22
    CMP #$8281
    RTL 
}
---------------------------------------------

func_0BF259_noref {
    LDA $JOY2L
    STA $00E0
    RTL 
}
---------------------------------------------

func_0BF260_noref {
    RTL 
}
---------------------------------------------

func_0BF261_noref {
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_0BF2A5

  loc_0BF269:
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@func_0BF2A6
    JSL $@vblank_joypad.EnableNmiOnly
    LDA $joypadRaw
    BIT #$0080
    BNE loc_0BF269

  loc_0BF27D:
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@func_0BF2A6
    JSL $@vblank_joypad.EnableNmiOnly
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_0BF27D

  loc_0BF291:
    JSL $@vblank_joypad.EnableNmiAndJoypad
    JSL $@func_0BF2A6
    JSL $@vblank_joypad.EnableNmiOnly
    LDA $joypadRaw
    BIT #$0080
    BNE loc_0BF291

  loc_0BF2A5:
    RTL 
}
---------------------------------------------

func_0BF2A6 {
    PHP 
    REP #$20
    PHA 
    SEP #$20
    LDA $L_RDNMI

  loc_0BF2B0:
    LDA $L_RDNMI
    BPL loc_0BF2B0
    LDA $L_RDNMI
    LDA $scrollModeFlags
    BIT #$08
    BEQ loc_0BF309
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

  loc_0BF309:
    REP #$20
    LDA $joypadInject
    BEQ loc_0BF319
    STA $joypadCurrent
    STZ $joypadInject
    PLA 
    PLP 
    RTL 

  loc_0BF319:
    LDA $joypadRaw
    AND #$0F00
    STA $joypadRemapped
    LDA $remapL
    BEQ loc_0BF335
    LDA $joypadRaw
    BIT #$1000
    BEQ loc_0BF335
    LDA $remapL
    TSB $joypadRemapped

  loc_0BF335:
    LDA $remapR
    BEQ loc_0BF348
    LDA $joypadRaw
    BIT #$2000
    BEQ loc_0BF348
    LDA $remapR
    TSB $joypadRemapped

  loc_0BF348:
    LDA $remapB
    BEQ loc_0BF35B
    LDA $joypadRaw
    BIT #$8000
    BEQ loc_0BF35B
    LDA $remapB
    TSB $joypadRemapped

  loc_0BF35B:
    LDA $remapY
    BEQ loc_0BF36E
    LDA $joypadRaw
    BIT #$4000
    BEQ loc_0BF36E
    LDA $remapY
    TSB $joypadRemapped

  loc_0BF36E:
    LDA $remapA
    BEQ loc_0BF381
    LDA $joypadRaw
    BIT #$0080
    BEQ loc_0BF381
    LDA $remapA
    TSB $joypadRemapped

  loc_0BF381:
    LDA $remapStart
    BEQ loc_0BF394
    LDA $joypadRaw
    BIT #$0040
    BEQ loc_0BF394
    LDA $remapStart
    TSB $joypadRemapped

  loc_0BF394:
    LDA $remapX
    BEQ loc_0BF3A7
    LDA $joypadRaw
    BIT #$0020
    BEQ loc_0BF3A7
    LDA $remapX
    TSB $joypadRemapped

  loc_0BF3A7:
    LDA $remapSelect
    BEQ loc_0BF3BA
    LDA $joypadRaw
    BIT #$0010
    BEQ loc_0BF3BA
    LDA $remapSelect
    TSB $joypadRemapped

  loc_0BF3BA:
    LDA $joypadRemapped
    STA $joypadCurrent
    STA $joypadRaw
    AND $joypadHeld
    STA $joypadHeld
    BEQ loc_0BF3E2
    AND $joypadMaskInv
    BEQ loc_0BF3E2
    LDA $joypadRepeatCounter
    INC 
    STA $joypadRepeatCounter
    CMP #$000C
    BNE loc_0BF3E5
    LDA $joypadMaskInv
    TRB $joypadHeld

  loc_0BF3E2:
    STZ $joypadRepeatCounter

  loc_0BF3E5:
    LDA $joypadHeld
    TRB $joypadCurrent
    LDA $joypadMaskStd
    TRB $joypadCurrent
    PLA 
    PLP 
    RTL 
}
---------------------------------------------

table_0BF6AD [
  &widestring_0BF4C3+M   ;00
  &widestring_0BF4EA+M   ;01
  &widestring_0BF511+M   ;02
]
---------------------------------------------

widestring_0BF3F4 `[DLG:6,A][SIZ:A,4]Start Journey[N]Erase Trip Diary[N]Copy Trip Diary[N]Change Snd/Buttons`

widestring_0BF437 `[DLG:2,8][SIZ:E,7]Which Diary?[N][::] Diary1 [ADR:&strings_0BF706,D74][N][N] Diary2 [ADR:&strings_0BF706,D76][N][N] Diary3 [ADR:&strings_0BF706,D78]`

widestring_0BF476 `[DLG:2,8][SIZ:E,7]Change Snd/Button[N][JMP:&sFA_diary_menu.widestring_0BF437+M]`

widestring_0BF48C `[DLG:2,8][SIZ:E,7]Move which Diary?[N][JMP:&sFA_diary_menu.widestring_0BF437+M]`

widestring_0BF4A7 `[DLG:2,8][SIZ:E,7]Erase which Diary?[N][JMP:&sFA_diary_menu.widestring_0BF437+M]`

widestring_0BF4C3 `[DLG:2,C][::][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

widestring_0BF4EA `[DLG:2,10][::][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

widestring_0BF511 `[DLG:2,14][::][SKP:2]HP[SKP:1][BCD:2,D9A][SKP:2]STR[SKP:1][BCD:2,D9C][SKP:2]DEF[SKP:1][BCD:2,D9E]`

widestring_0BF538 `[DLG:6,8][SIZ:A,8][SKP:2]Change Snd/Buttons[N]End Changes[N]Sound[N]Button Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item palette[N][SKP:5]   :Not used`

widestring_0BF5AD `[DLG:6,8][SIZ:A,8]Arrangement  OK?[N]Start Journey[N]Sound[N]Button Type[N][SKP:5]   :Attack/Talk[N][SKP:5]   :Item/Cancel[N][SKP:5]   :Item palette[N][SKP:5]   :Not used`

widestring_0BF625 `[DLG:D,C][SFX:0][ADR:&sFA_diary_menu.table_0BF667,D90]`

widestring_0BF630 `[DLG:11,E][SFX:0][ADR:&sFA_diary_menu.table_0BF63B,D8E]`
---------------------------------------------

table_0BF63B [
  &widestring_0BF63F   ;00
  &widestring_0BF653   ;01
]

widestring_0BF63F `1[DLG:8,10]A[DLG:8,12]B[DLG:8,14]SEL[DLG:8,16]Y`

widestring_0BF653 `2[DLG:8,10]B[DLG:8,12]Y[DLG:8,14]SEL[DLG:8,16]A`
---------------------------------------------

table_0BF667 [
  &widestring_0BF66B   ;00
  &widestring_0BF672   ;01
]

widestring_0BF66B `Stereo`

widestring_0BF672 `Mono  `
---------------------------------------------

widestring_0BF679 `[DLG:4,15][SIZ:C,2][DLY:FF]Diary not empty[N]Erase and select[FIN][CLD]`
---------------------------------------------

widestring_0BF6A4 `[DLG:4,A][ADR:&sFA_diary_menu.table_0BF6AD,D94]`
---------------------------------------------

widestring_0BF6B3 `[DLG:4,8][SIZ:D,5][ADR:&sFA_diary_menu.table_0BF6D9,D94][N][N]Erase diary? [N] No [N] Yes `
---------------------------------------------

table_0BF6D9 [
  &widestring_0BF6DF   ;00
  &widestring_0BF6EC   ;01
  &widestring_0BF6F9   ;02
]

widestring_0BF6DF `Diary1 [ADR:&strings_0BF706,D74]`

widestring_0BF6EC `Diary2 [ADR:&strings_0BF706,D76]`

widestring_0BF6F9 `Diary3 [ADR:&strings_0BF706,D78]`