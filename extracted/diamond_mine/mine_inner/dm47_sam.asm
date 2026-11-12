; Sam — chained slave who teaches the Memory Melody after he is freed.
; 
; Spawns as a chain prop (dm_mine_static_prop) with solid collision and dies at spawn when flag $5E is set. Before the chain breaks (status bit $0040 of the prop) the interact handler says "Cut the chain!". After it breaks the handler tells Will about a song that restores lost memories. When $5E is still clear it then gives item #0D (Memory Melody) and sets $5E; with a full inventory it prints the inventory-full message and leaves $5E clear. A repeat talk after $5E is set says "I'll never forget you!".
; 
; Sam's main script waits on WaitOnFlagByte ( #5E, #01 ), locks the joypad, starts music #1E, waits 120 ticks (WaitByte #77) and polls APUIO1 for $FF (the track has finished). If Will holds the Wind Melody (#08), Sam asks for it and the Prison Key as souvenirs and removes #02 and #08; otherwise he asks for the Prison Key and removes #02. The joypad is then unlocked. Imas and Remus read $5E only once, at spawn.
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
    LDA #$FFFC
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
    COP [BranchIfHasItem] ( #08, &code_05D286 )
    COP [PrintDialogString] ( &dialogstring_05D40C )
    COP [RemoveItem] ( #02 )
    LDA #$FFFC
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
} >
]

code_05D286 {
    COP [PrintDialogString] ( &dialogstring_05D377 )
    COP [RemoveItem] ( #02 )
    COP [RemoveItem] ( #08 )
    LDA #$FFFC
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