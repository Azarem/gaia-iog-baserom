; Hotel clerk in Dao (scene $C3, tile (05,0C)). With $B8 set the handler prints 'This is a hotel for travelling merchants.'. With $B8 clear it asks 'Would you happen to be Will?': No prints 'Hmmm. I hope he arrives soon. Very distressing...'; Yes prints 'Good! A letter and some luggage have arrived from someone named Bill and Lola.', counts the empty slots of inventorySlots ($0AB4, 16 bytes) and, with at least two, gives items $25 and $26, sets $B8 and shows 'You get a letter and your father's journal!'; with fewer it prints 'Somehow, your inventory is full. Reduce your possessions somewhere.'.
---------------------------------------------

!displayModeFlags               09EC
!inventorySlots                 0AB4

---------------------------------------------

daC3_luggage_man [
  actor-def < #1F, #00, #10, {

  code_08B155:
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_08B167 )
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOnce]
    RTL 
} >
]

code_08B167 {
    COP [BranchOnFlagByte] ( #B8, #00, &code_08B172 )
    COP [PrintDialogString] ( &dialogstring_08B1CD )
    RTL 
}

code_08B172 {
    COP [PrintDialogString] ( &dialogstring_08B1EF )
    COP [DialogueOptions] ( #02, #02, &code_list_08B17C )
}

code_list_08B17C [
  &code_08B182   ;00
  &code_08B187   ;01
  &code_08B182   ;02
]

code_08B182 {
    COP [PrintDialogString] ( &dialogstring_08B27F )
    RTL 
}

code_08B187 {
    COP [PrintDialogString] ( &dialogstring_08B21A )
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
    COP [MusicAndText] ( #17, @dialogstring_08B25A )
}

code_08B1C7 {
    RTL 

  loc_08B1C8:
    COP [PrintDialogString] ( &dialogstring_08B2B2 )
    RTL 
}

dialogstring_08B1CD `[DEF]This is a hotel for[N]travelling merchants.[END]`

dialogstring_08B1EF `[DEF]Would you happen to [N]be Will? [N] Yes [N] No `

dialogstring_08B21A `[CLR]Good! A letter and some[N]luggage have arrived[N]from someone named[N]Bill and Lola.[FIN]`

dialogstring_08B25A `[CLR][SFX:0][DLY:9]You get a letter and [N]your father's journal![PAU:78][END]`

dialogstring_08B27F `[CLR]Hmmm. I hope he [N]arrives soon. [N]Very distressing... [END]`

dialogstring_08B2B2 `[DEF][CLR]Somehow, your inventory [N]is full. Reduce your [N]possessions somewhere. [END]`