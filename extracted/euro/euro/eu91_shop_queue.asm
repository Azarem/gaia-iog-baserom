; Shop queue system in Euro (~386 lines).
; 
; Complex NPC queue management: "You can buy the best goods
; in this shop." Simulates a line of customers waiting.
; Player must wait their turn. Manages NPC positions,
; turn order, and customer dialog. One of the more
; elaborate town mechanics.
---------------------------------------------

?INCLUDE 'ActorDisplayModeSwap'

!playerXPos                     09A2
!playerYPos                     09A4

---------------------------------------------

eu91_shop_queue [
  actor-def < #00, #00, #30, {

  code_07D255:
    LDA #$0188
    TSB $12
    LDA $0E
    LSR 
    AND #$0038
    CLC 
    ADC #$0002
    STA $26
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@ActorDisplayModeSwap
    COP [SetOnInteract] ( &code_07D39A )
    TXY 
    LDA $24
    STA $0000
    BEQ loc_07D287

  loc_07D27E:
    LDA $0004, Y
    TAY 
    DEC $0000
    BNE loc_07D27E

  loc_07D287:
    TYA 
    STA $20
    COP [SolidHighHere]
    BRA loc_07D2F9

  code_07D28E:
    COP [SetTilePos] ( #2C, #40 )
    COP [WaitByte] ( #07 )
    LDA #$2000
    TRB $10
    LDA $26
    CLC 
    ADC #$0004
    STA $28
    STZ $2A
    COP [AnimOneFrame]

  loc_07D2A6:
    LDA $16
    CMP #$0420
    BEQ loc_07D2EB
    BRA loc_07D2B1

  code_07D2AF:
    COP [SetEntryExit]

  loc_07D2B1:
    JSR $&code_07D513
    BCS code_07D2AF
    COP [BranchIfSolidSouth] ( &code_07D2AF )
    JSR $&code_07D593
    BCC code_07D2AF
    COP [SolidHighOffset] ( #00, #01 )
    LDA $26
    CLC 
    ADC #$0004
    STA $28
    STZ $2A
    COP [StageForceMoveY] ( #11 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $26
    CLC 
    ADC #$0004
    STA $28
    STZ $2A
    COP [AnimOneFrame]
    JSR $&code_07D4FF
    BCS loc_07D2A6
    COP [ClearLowOffset] ( #00, #FF )
    BRA loc_07D2A6

  loc_07D2EB:
    LDA $26
    CLC 
    ADC #$0006
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]

  loc_07D2F9:
    LDA $14
    CMP #$0228
    BEQ loc_07D33E
    BRA loc_07D304

  code_07D302:
    COP [SetEntryExit]

  loc_07D304:
    JSR $&code_07D555
    BCS code_07D302
    COP [BranchIfSolidWest] ( &code_07D302 )
    JSR $&code_07D583
    BCC code_07D302
    COP [SolidHighOffset] ( #FF, #00 )
    LDA $26
    CLC 
    ADC #$0006
    STA $28
    STZ $2A
    COP [StageForceMoveX] ( #12 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $26
    CLC 
    ADC #$0006
    STA $28
    STZ $2A
    COP [AnimOneFrame]
    JSR $&code_07D541
    BCS loc_07D2F9
    COP [ClearLowOffset] ( #01, #00 )
    BRA loc_07D2F9

  loc_07D33E:
    LDA $16
    CMP #$0400
    BEQ loc_07D390
    BRA loc_07D349

  code_07D347:
    COP [SetEntryExit]

  loc_07D349:
    JSR $&code_07D4FF
    BCS code_07D347
    JSR $&code_07D59B
    BCC code_07D347
    COP [BranchIfSolidNorth] ( &code_07D347 )
    LDA $16
    CMP #$0410
    BNE loc_07D362
    COP [BranchIfSolidNorth] ( &code_07D347 )

  loc_07D362:
    LDA $26
    CLC 
    ADC #$0005
    STA $28
    STZ $2A
    COP [SolidHighOffset] ( #00, #FF )
    COP [StageForceMoveY] ( #12 )
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $26
    CLC 
    ADC #$0005
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSR $&code_07D513
    BCS loc_07D33E
    COP [ClearLowOffset] ( #00, #01 )
    BRA loc_07D33E

  loc_07D390:
    LDA #$2000
    TSB $10
    COP [SetEntryExitNow] ( @code_07D28E )
} >
]

code_07D39A {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07D3A5 )
}

code_list_07D3A5 [
  &code_07D3B1   ;00
  &code_07D3B6   ;01
  &code_07D3BB   ;02
  &code_07D3C0   ;03
  &code_07D3C5   ;04
  &code_07D3CA   ;05
]

code_07D3B1 {
    COP [PrintDialogString] ( &dialogstring_07D3CF )
    RTL 
}

code_07D3B6 {
    COP [PrintDialogString] ( &dialogstring_07D3F6 )
    RTL 
}

code_07D3BB {
    COP [PrintDialogString] ( &dialogstring_07D423 )
    RTL 
}

code_07D3C0 {
    COP [PrintDialogString] ( &dialogstring_07D43E )
    RTL 
}

code_07D3C5 {
    COP [PrintDialogString] ( &dialogstring_07D479 )
    RTL 
}

code_07D3CA {
    COP [PrintDialogString] ( &dialogstring_07D4A9 )
    RTL 
}

dialogstring_07D3CF `[DEF]You can buy the best[N]goods in this shop.[END]`

dialogstring_07D3F6 `[DEF]I saw the line and [N]wondered why people [N]were lining up...[END]`

dialogstring_07D423 `[DEF]We are always waiting[N]in line.[END]`

dialogstring_07D43E `[DEF]In times of trouble, [N]people are grateful for [N]whatever they can get.[END]`

dialogstring_07D479 `[DEF]I saw the line and[N]wondered why people[N]were lining up...[END]`

dialogstring_07D4A9 `[DEF]You can buy Life[N]Medicine in this shop.[FIN]I don't know if it[N]helps, but everyone[N]wants a long life.[END]`

code_07D4FF {
    LDA #$0005
    STA $0000
    LDA $20
    TAY 
    LDA $16
    SEC 
    SBC #$0010
    STA $001C
    BRA loc_07D525
}

code_07D513 {
    LDA #$0005
    STA $0000
    LDA $20
    TAY 
    LDA $16
    CLC 
    ADC #$0010
    STA $001C

  loc_07D525:
    LDA $001C
    CMP $0016, Y
    BNE loc_07D534
    LDA $14
    CMP $0014, Y
    BEQ loc_07D53F

  loc_07D534:
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_07D525
    CLC 
    RTS 

  loc_07D53F:
    SEC 
    RTS 
}

code_07D541 {
    LDA #$0005
    STA $0000
    LDA $20
    TAY 
    LDA $14
    CLC 
    ADC #$0010
    STA $0018
    BRA loc_07D567
}

code_07D555 {
    LDA #$0005
    STA $0000
    LDA $20
    TAY 
    LDA $14
    SEC 
    SBC #$0010
    STA $0018

  loc_07D567:
    LDA $0018
    CMP $0014, Y
    BNE loc_07D576
    LDA $16
    CMP $0016, Y
    BEQ loc_07D581

  loc_07D576:
    LDA $0006, Y
    TAY 
    DEC $0000
    BPL loc_07D567
    CLC 
    RTS 

  loc_07D581:
    SEC 
    RTS 
}

code_07D583 {
    LDA $14
    SEC 
    SBC #$0010
    STA $0018
    LDA $16
    STA $001C
    BRA loc_07D5A9
}

code_07D593 {
    LDA $16
    CLC 
    ADC #$0010
    BRA loc_07D5A1
}

code_07D59B {
    LDA $16
    SEC 
    SBC #$0010

  loc_07D5A1:
    STA $001C
    LDA $14
    STA $0018

  loc_07D5A9:
    LDA $playerXPos
    CLC 
    ADC #$0008
    SEC 
    SBC $0018
    BPL loc_07D5BA
    EOR #$FFFF
    INC 

  loc_07D5BA:
    CMP #$000D
    BCC loc_07D5C0
    RTS 

  loc_07D5C0:
    LDA $playerYPos
    CLC 
    ADC #$0010
    SEC 
    SBC $001C
    BPL loc_07D5D1
    EOR #$FFFF
    INC 

  loc_07D5D1:
    CMP #$000D
    RTS 
}