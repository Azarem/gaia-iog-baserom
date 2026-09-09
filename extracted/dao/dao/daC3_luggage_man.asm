!displayModeFlags               09EC
!inventorySlots                 0AB4

---------------------------------------------

daC3_luggage_man [
  actor-def < #1F, #00, #10, {

  code_08B155:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08B167 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08B167 {
    COP [BranchIfFlagByte] ( #B8, #00, &code_08B172 )
    COP [PrintWideString] ( &widestring_08B1CD )
    RTL 
}

code_08B172 {
    COP [PrintWideString] ( &widestring_08B1EF )
    COP [DialogueOptions] ( #02, #02, &code_list_08B17C )
}

code_list_08B17C [
  &code_08B182   ;00
  &code_08B187   ;01
  &code_08B182   ;02
]

code_08B182 {
    COP [PrintWideString] ( &widestring_08B27F )
    RTL 
}

code_08B187 {
    COP [PrintWideString] ( &widestring_08B21A )
    SEP #$20
    STZ $0000
    LDY #$0000

  loc_08B193:
    LDA $inventorySlots, Y
    BNE loc_08B19B
    INC $0000

  loc_08B19B:
    INY 
    CPY #$0010
    BNE loc_08B193
    REP #$20
    LDA $0000
    AND #$00FF
    CMP #$0002
    BCC loc_08B1C8
    COP [GiveItem] ( #25, &code_08B1C7 )
    COP [GiveItem] ( #26, &code_08B1C7 )
    COP [SetFlagByte] ( #B8 )
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @widestring_08B25A )
}

code_08B1C7 {
    RTL 

  loc_08B1C8:
    COP [PrintWideString] ( &widestring_08B2B2 )
    RTL 
}

widestring_08B1CD `[DEF]This is a hotel for[N]travelling merchants.[END]`

widestring_08B1EF `[DEF]Would you happen to [N]be Will? [N] Yes [N] No `

widestring_08B21A `[CLR]Good! A letter and some[N]luggage have arrived[N]from someone named[N]Bill and Lola.[FIN]`

widestring_08B25A `[CLR][SFX:0][DLY:9]You get a letter and [N]your father's journal![PAU:78][END]`

widestring_08B27F `[CLR]Hmmm. I hope he [N]arrives soon. [N]Very distressing... [END]`

widestring_08B2B2 `[DEF][CLR]Somehow, your inventory [N]is full. Reduce your [N]possessions somewhere. [END]`