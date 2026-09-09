!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!jewelsCollected                0AB0
!inventorySlots                 0AB4
!playerMaxHp                    0ACA
!playerDef                      0ADC
!playerStr                      0ADE
!damageFlashTimer               0B22

---------------------------------------------

jeweler_gem [
  actor-def < #02, #00, #10, {

  code_08CEA3:
    COP [BranchIfFlagByte] ( #E8, #01, &code_08D092 )
    LDA $0E
    ASL 
    ASL 
    ASL 
    CLC 
    ADC #$0002
    STA $28
    STZ $002A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA #$3000
    STA $0E
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08CEC9 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08CEC9 {
    COP [PrintWideString] ( &widestring_08D094 )
    LDA $jewelsCollected
    BEQ code_08CED6
    COP [PrintWideString] ( &widestring_08D0C8 )

  code_08CED6:
    COP [BranchIfFlagByte] ( #E9, #01, &code_08CEE7 )
    LDA $jewelsCollected
    CMP #$0003
    BCC code_08CEE7
    JMP $&code_08D017
}

code_08CEE7 {
    COP [BranchIfFlagByte] ( #EA, #01, &code_08CEF8 )
    LDA $jewelsCollected
    CMP #$0005
    BCC code_08CEF8
    JMP $&code_08D02A
}

code_08CEF8 {
    COP [BranchIfFlagByte] ( #EB, #01, &code_08CF09 )
    LDA $jewelsCollected
    CMP #$0008
    BCC code_08CF09
    JMP $&code_08D037
}

code_08CF09 {
    COP [BranchIfFlagByte] ( #EC, #01, &code_08CF1A )
    LDA $jewelsCollected
    CMP #$0012
    BCC code_08CF1A
    JMP $&code_08D04A
}

code_08CF1A {
    COP [BranchIfFlagByte] ( #ED, #01, &code_08CF2B )
    LDA $jewelsCollected
    CMP #$0020
    BCC code_08CF2B
    JMP $&code_08D057
}

code_08CF2B {
    COP [BranchIfFlagByte] ( #EE, #01, &code_08CF3C )
    LDA $jewelsCollected
    CMP #$0030
    BCC code_08CF3C
    JMP $&code_08D067
}

code_08CF3C {
    LDA $jewelsCollected
    CMP #$0050
    BCC loc_08CF47
    JMP $&code_08D077

  loc_08CF47:
    COP [PrintWideString] ( &widestring_08D0F1+M )

  code_08CF4B:
    COP [DialogueOptions] ( #03, #01, &code_list_08CF51 )
}

code_list_08CF51 [
  &code_08CF59   ;00
  &code_08CF59   ;01
  &code_08CF5E   ;02
  &code_08CFA6   ;03
]

code_08CF59 {
    COP [PrintWideString] ( &widestring_08D139 )
    RTL 
}

code_08CF5E {
    COP [BranchIfNoItem] ( #01, &code_08CF68 )
    COP [PrintWideString] ( &widestring_08D1E0 )
    RTL 
}

code_08CF68 {
    SED 
    STZ $0000
    LDA #$0001
    SEP #$20
    LDY #$0000

  loc_08CF74:
    CMP $inventorySlots, Y
    BNE loc_08CF84
    PHA 
    LDA $0000
    CLC 
    ADC #$01
    STA $0000
    PLA 

  loc_08CF84:
    INY 
    CPY #$0010
    BNE loc_08CF74
    REP #$20
    LDA $0000
    CLC 
    ADC $jewelsCollected
    STA $jewelsCollected
    CLD 

  code_08CF97:
    COP [RemoveItem] ( #01 )
    COP [BranchIfNoItem] ( #01, &code_08CF97 )
    COP [PrintWideString] ( &widestring_08D20F )
    JMP $&code_08CED6
}

code_08CFA6 {
    COP [PrintWideString] ( &widestring_08D267 )
    COP [PrintWideString] ( &widestring_08D617 )
    COP [BranchIfFlagByte] ( #E9, #00, &code_08CFB8 )
    COP [PrintWideString] ( &widestring_08D611 )
}

code_08CFB8 {
    COP [PrintWideString] ( &widestring_08D621 )
    COP [BranchIfFlagByte] ( #EA, #00, &code_08CFC6 )
    COP [PrintWideString] ( &widestring_08D611 )
}

code_08CFC6 {
    COP [PrintWideString] ( &widestring_08D636 )
    COP [BranchIfFlagByte] ( #EB, #00, &code_08CFD4 )
    COP [PrintWideString] ( &widestring_08D611 )
}

code_08CFD4 {
    COP [PrintWideString] ( &widestring_08D64A )
    COP [BranchIfFlagByte] ( #EC, #00, &code_08CFE2 )
    COP [PrintWideString] ( &widestring_08D611 )
}

code_08CFE2 {
    COP [PrintWideString] ( &widestring_08D65E )
    COP [BranchIfFlagByte] ( #ED, #00, &code_08CFF0 )
    COP [PrintWideString] ( &widestring_08D611 )
}

code_08CFF0 {
    COP [PrintWideString] ( &widestring_08D672 )
    COP [BranchIfFlagByte] ( #EE, #00, &code_08CFFE )
    COP [PrintWideString] ( &widestring_08D611 )
}

code_08CFFE {
    COP [PrintWideString] ( &widestring_08D67D )
    COP [PrintWideString] ( &widestring_08D68A )
    COP [PrintWideString] ( &widestring_08D0F1 )
    JMP $&code_08CF4B
}

code_08D00D {
    COP [PrintWideString] ( &widestring_08D292 )
    RTL 
}

code_08D012 {
    COP [PrintWideString] ( &widestring_08D2AA )
    RTL 
}

code_08D017 {
    COP [PrintWideString] ( &widestring_08D2D0 )
    COP [GiveItem] ( #06, &code_08D012 )
    COP [PrintWideString] ( &widestring_08D31A )
    COP [SetFlagByte] ( #E9 )
    JMP $&code_08CEE7
}

code_08D02A {
    INC $playerDef
    COP [SetFlagByte] ( #EA )
    COP [PrintWideString] ( &widestring_08D332 )
    JMP $&code_08CEF8
}

code_08D037 {
    INC $playerMaxHp
    LDA #$0001
    STA $damageFlashTimer
    COP [SetFlagByte] ( #EB )
    COP [PrintWideString] ( &widestring_08D395 )
    JMP $&code_08CF09
}

code_08D04A {
    INC $playerStr
    COP [SetFlagByte] ( #EC )
    COP [PrintWideString] ( &widestring_08D3F9 )
    JMP $&code_08CF1A
}

code_08D057 {
    LDA #$0001
    STA $0B16
    COP [SetFlagByte] ( #ED )
    COP [PrintWideString] ( &widestring_08D459 )
    JMP $&code_08CF2B
}

code_08D067 {
    LDA #$0002
    STA $0B1C
    COP [SetFlagByte] ( #EE )
    COP [PrintWideString] ( &widestring_08D4E3 )
    JMP $&code_08CF3C
}

code_08D077 {
    COP [PrintWideString] ( &widestring_08D5AE )
    LDA #$0202
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E9, #$0330, #$03D0, #80, #$4400 )
    RTL 
}

code_08D092 {
    COP [Die]
}

widestring_08D094 `[DEF]I am the Jeweler Gem. [N]I control the Seven[N]Seas. [FIN]`

widestring_08D0C8 `I'm holding [BCD:2,AB0] of the[N]Red Jewels for you.[FIN]`

widestring_08D0F1 `[DEF][PAL:0][::][CLR]What's your business?[N] Just wanted to see you[N] Give you Red Jewels[N] See your inventory`

widestring_08D139 `[CLR]Is that right.[N]How do you do.[FIN]Once you hold up the [N]Red Jewels, you'll [N]have to come running [N]to my place. [FIN]I am a famous master of [N]disguises. If you saw [N]me in another town, [N]you wouldn't know me. [END]`

widestring_08D1E0 `[CLR]But you don't have any[N]Jewels. Let me give[N]you some.[END]`

widestring_08D20F `[CLR]Mmm...This is a rare [N]jewel. Let me hold [N]it for you. [FIN]There are now[N][BCD:2,AB0]Jewels in the room.[FIN]`

widestring_08D267 `[CLR]I will give you goods[N]for your Jewels as[N]written on the list.[END]`

widestring_08D292 `[CLD][DEF][CLR]Well, see ya.[N]Somewhere.[END]`

widestring_08D2AA `[CLR]Your inventory seems[N]to be full....[N]Come back again!![END]`

widestring_08D2D0 `[CLR]You've collected more [N]than three Jewels![FIN]According to the list,[N]you get the herb![FIN]`

widestring_08D31A `You received the herb![FIN]`

widestring_08D332 `[CLR]You've collected over [N]five Jewels! According to[N]the list, your Defense [N]Power will be raised. [FIN]Your Defense Power is[N]raised by one.[FIN]`

widestring_08D395 `[CLR]You've collected over, [N]eight Jewels! According to[N]the list, your Life [N]Power will be raised. [FIN]Your Strength is[N]raised by one.[FIN]`

widestring_08D3F9 `[CLR]You've collected over [N]12 Jewels! According to [N]the list, your Strength [N]will be raised. [FIN]Your Attack Power is[N]raised by one.[FIN]`

widestring_08D459 `[CLR]You've collected over [N]20 Jewels! According to [N]the list, your Psycho [N]Power will be raised. [FIN]It's a mysterious power[N]given by the spirit.[FIN]Your Psycho Dash Power[N]is increased.[FIN]`

widestring_08D4E3 `[CLR]You've collected over [N]30 Jewels! According to [N]the list, your Dark [N]Power will be raised. [FIN]It's a mysterious power[N]given by the spirit.[FIN]The Dark Friar's power[N]is increased.[FIN]Try pushing the[N]Attack Button once more[N]when the Dark Friar[N]is flying.[FIN]`

widestring_08D5AE `[CLR]50... Suddenly[N]you've gathered[N]50 Red Jewels...[FIN]The time has come to[N]tell you some of[N]my secrets.[FIN]Follow me!![END]`

widestring_08D611 `[PAL:4]`

widestring_08D614 `[PAL:0]`

widestring_08D617 `[DLG:3,B][SIZ:8,7][CLR][SFX:0]`

widestring_08D621 `[CLR]Herb           3[N][PAL:0]`

widestring_08D636 `Defense Force  5[N][PAL:0]`

widestring_08D64A `Life Force     8[N][PAL:0]`

widestring_08D65E `Strength      12[N][PAL:0]`

widestring_08D672 `Psycho Power  20[N][PAL:0]`

widestring_08D67D `Dark Power    30[N][PAL:0]`

widestring_08D68A `My secrets    50[END]`