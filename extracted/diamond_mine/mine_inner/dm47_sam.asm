; Sam — chained slave who teaches the Memory Melody after rescue.
; 
; Before freed: "Cut the chain!" interaction. After freed: tells Will
; about a song that restores lost memories, then hums the Memory Melody.
; Waits for the SPC music track #1E to finish (polls APUIO1 for $FF),
; then checks inventory: if Will has the Prison Key (#08) and Wind
; Melody, Sam takes both as souvenirs and teaches the Memory Melody
; (item #0D, music+text display #17). If only the Prison Key, takes
; just that. Sets flag $5E when all three slaves are freed.
---------------------------------------------

?INCLUDE 'dm_mine_static_prop'
?INCLUDE 'f_inventory_full'

!joypadMaskStd                  065A
!APUIO1                         2141

---------------------------------------------

dm47_sam [
  actor-def < #28, #00, #10, {

  code_05D226:
    COP [BranchOnFlagByte] ( #5E, #01, &dm47_sam_destroy )
    COP [SpawnAfterFlags] ( @dm_mine_static_prop, #$0100 )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_05D299 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    LDY $06
    LDA $0010, Y
    BIT #$0040
    BNE loc_05D24B
    RTL 

  loc_05D24B:
    COP [SetInteractHandler] ( &code_05D29E )
    COP [WaitOnFlagByte] ( #5E, #01 )
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #1E )
    COP [WaitByte] ( #77 )
    COP [SetEntryHere]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_05D271
    RTL 

  loc_05D271:
    COP [BranchIfMissingItem] ( #08, &code_05D286 )
    COP [PrintDialogString] ( &dialogstring_05D40C )
    COP [RemoveItem] ( #02 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
} >
]

code_05D286 {
    COP [PrintDialogString] ( &dialogstring_05D377 )
    COP [RemoveItem] ( #02 )
    COP [RemoveItem] ( #08 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
}

code_05D299 {
    COP [PrintDialogString] ( &dialogstring_05D2C0 )
    RTL 
}

code_05D29E {
    COP [BranchOnFlagByte] ( #5E, #01, &code_05D2BB )
    COP [PrintDialogString] ( &dialogstring_05D2DA )
    COP [BranchOnFlagByte] ( #5E, #01, &code_05D2B6 )
    COP [GiveItem] ( #0D, &code_05D2B7 )
    COP [SetFlagByte] ( #5E )
}

code_05D2B6 {
    RTL 
}

code_05D2B7 {
    JML $@f_inventory_full.InventoryFullMessage
}

code_05D2BB {
    COP [PrintDialogString] ( &dialogstring_05D48E )
    RTL 
}

dialogstring_05D2C0 `[DEF][TPL:5]Sam: [N]Cut the chain![PAL:0][END]`

dialogstring_05D2DA `[DEF][TPL:5]Sam: [N]Thank you. [FIN]I heard from Erik that [N]your friend has lost [N]his memory. [FIN]Legend says that there[N]is a song that brings[N]back the past. Please[N]let him hear it.[FIN]Sam hums a [N]strange melody.[PAL:0][END]`

dialogstring_05D377 `[DEF]You've learned[N]the Memory Melody![FIN][TPL:5]Sam: [N]I need a favor... [FIN]May I have the prison[N]key and the Melody of[N]the Wind as a souvenir[N]of our meeting?[FIN]I'm sure I'll never[N]use it again.[END]`

dialogstring_05D40C `[DEF]You've learned[N]the Memory Melody![FIN][TPL:5]Sam: [N]I need a favor... [FIN]May I have the Prison[N]Key as a souvenir[N]of meeting you?[FIN]I'm sure I'll never[N]use it again.[END]`

dialogstring_05D48E `[DEF][TPL:5]I'll never forget you![PAL:0][END]`
---------------------------------------------

dm47_sam_destroy {
    COP [Die]
}