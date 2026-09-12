!joypadMaskStd                  065A
!playerXPos                     09A2
!playerYPos                     09A4
!playerXTile                    09A6

---------------------------------------------

av75_voice_rooms [
  actor-def < #00, #00, #30, {

  code_06D8BF:
    LDA $playerYPos
    CMP #$00F0
    BCC loc_06D8CA
    JMP $&code_06DA0C

  loc_06D8CA:
    COP [ClearFlagWord] ( #$0149 )
    COP [ClearFlagWord] ( #$014A )
    COP [ClearFlagWord] ( #$014B )
    COP [ClearFlagWord] ( #$014C )
    COP [ClearFlagWord] ( #$014D )
    COP [ClearFlagWord] ( #$014E )
    COP [ClearFlagWord] ( #$014F )
    COP [ClearFlagWord] ( #$0150 )
    LDA $playerXTile
    AND #$0010
    BNE loc_06D90B
    INC $0AA6
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06DA14 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 

  loc_06D90B:
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06DA6B )
    COP [WaitByte] ( #1D )
    COP [SpawnAfterFlags] ( @code_06DBF3, #$1002 )
    LDA $playerXPos
    STA $0014, Y
    LDA $playerYPos
    STA $0016, Y
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$8001, &code_06D937 )
    RTL 
} >
]

code_06D937 {
    LDY $06
    LDA $0014, Y
    STA $24
    LDA $0016, Y
    STA $26
    COP [KillNext]
    LDA $playerXTile
    LSR 
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06D956 )
}

code_list_06D956 [
  &code_06D95E   ;00
  &code_06D98A   ;01
  &code_06D9B4   ;02
  &code_06D9DE   ;03
]

code_06D95E {
    LDA $24
    CMP #$01B0
    BCC loc_06D980
    CMP #$01C0
    BCS loc_06D980
    LDA $26
    CMP #$0070
    BCC loc_06D980
    CMP #$0090
    BCS loc_06D980
    COP [PrintDialogString] ( &dialogstring_06DAF0 )
    INC $0AA6
    JMP $&code_06DA0C

  loc_06D980:
    COP [PrintDialogString] ( &dialogstring_06DAA0 )
    DEC $0AA6
    JMP $&code_06DA0C
}

code_06D98A {
    LDA $24
    CMP #$0330
    BCC loc_06D9AB
    CMP #$0350
    BCS loc_06D9AB
    LDA $26
    CMP #$00A0
    BCC loc_06D9AB
    CMP #$00C0
    BCS loc_06D9AB
    COP [PrintDialogString] ( &dialogstring_06DB2C )
    INC $0AA6
    BRA code_06DA0C

  loc_06D9AB:
    COP [PrintDialogString] ( &dialogstring_06DAA0 )
    DEC $0AA6
    BRA code_06DA0C
}

code_06D9B4 {
    LDA $24
    CMP #$0570
    BCC loc_06D9D5
    CMP #$0590
    BCS loc_06D9D5
    LDA $26
    CMP #$0070
    BCC loc_06D9D5
    CMP #$0090
    BCS loc_06D9D5
    COP [PrintDialogString] ( &dialogstring_06DB4F )
    INC $0AA6
    BRA code_06DA0C

  loc_06D9D5:
    COP [PrintDialogString] ( &dialogstring_06DAA0 )
    DEC $0AA6
    BRA code_06DA0C
}

code_06D9DE {
    LDA $24
    CMP #$0790
    BCC loc_06DA03
    CMP #$07B0
    BCS loc_06DA03
    LDA $26
    CMP #$00A0
    BCC loc_06DA03
    CMP #$00C0
    BCS loc_06DA03
    COP [PrintDialogString] ( &dialogstring_06DB9F )
    COP [SetFlagByte] ( #89 )
    COP [SetFlagWord] ( #$0151 )
    BRA code_06DA0C

  loc_06DA03:
    COP [PrintDialogString] ( &dialogstring_06DAA0 )
    DEC $0AA6
    BRA code_06DA0C
}

code_06DA0C {
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

dialogstring_06DA14 `[TPL:9]Istar's voice resounds.[FIN]Learn well the condition[N]of that room.[FIN]When you've learned it, [N]leave the room. [END]`

dialogstring_06DA6B `[TPL:9]Istar's voice resounds.[FIN]Show how it's different[N]from the room before.[END]`

dialogstring_06DAA0 `[TPL:A]How are your powers[N]of observation?[FIN]Now your trip will[N]get more difficult![FIN]Try again!![END]`

dialogstring_06DAF0 `[TPL:A]Right answer![N]The jar has[N]changed color![FIN]Good.[N]Go on to the next room.[END]`

dialogstring_06DB2C `[TPL:A]Right answer![FIN]Good. Go on[N]to the next room.[END]`

dialogstring_06DB4F `[TPL:A]Right answer![N]How have the contents of[N]the Jewel Box changed?[FIN]Good. Go on[N]to the next room.[END]`

dialogstring_06DB9F `[TPL:A]Right answer![N]The wind blew your[N]hair around.[FIN]You have passed my[N]test well.[N]You may return.[END]`

code_06DBF3 {
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteFrame] ( #19 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0801, &code_06DC16 )

  loc_06DC03:
    COP [BranchIfButton] ( #$0401, &code_06DC23 )

  loc_06DC09:
    COP [BranchIfButton] ( #$0201, &code_06DC30 )

  loc_06DC0F:
    COP [BranchIfButton] ( #$0101, &code_06DC40 )

  loc_06DC15:
    RTL 
}

code_06DC16 {
    LDA $16
    CMP #$0008
    BCC loc_06DC03
    DEC $16
    DEC $16
    BRA loc_06DC03
}

code_06DC23 {
    LDA $16
    CMP #$00D0
    BCS loc_06DC09
    INC $16
    INC $16
    BRA loc_06DC09
}

code_06DC30 {
    LDA $14
    AND #$00FF
    CMP #$0008
    BCC loc_06DC0F
    DEC $14
    DEC $14
    BRA loc_06DC0F
}

code_06DC40 {
    LDA $14
    AND #$00FF
    CMP #$00F8
    BCS loc_06DC15
    INC $14
    INC $14
    BRA loc_06DC15
}