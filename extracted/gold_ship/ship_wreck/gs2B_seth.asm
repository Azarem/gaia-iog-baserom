; Seth on the wrecked Gold Ship — gives a Red Jewel.
; 
; Before flag $51: solid NPC with interaction. On first talk
; (flag $E0 not set): Seth found a strange jewel on board and
; gives it to Will (hidden_red_jewel). After giving the jewel,
; dialog changes to: "It's the first time I've ever given you
; anything. Take care of it." Despawns after flag $51.
---------------------------------------------

?INCLUDE 'hidden_red_jewel'

---------------------------------------------

gs2B_seth [
  actor-def < #14, #00, #10, {

  code_059641:
    COP [BranchOnFlagByte] ( #51, #01, &code_059650 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_059652 )
    COP [SetEntryHere]
    RTL 
} >
]

code_059650 {
    COP [Die]
}

code_059652 {
    COP [BranchOnFlagByte] ( #E0, #01, &code_059669 )
    COP [PrintDialogString] ( &dialogstring_05966E )
    COP [GiveItem] ( #01, &code_059665 )
    COP [SetFlagByte] ( #E0 )
    RTL 
}

code_059665 {
    JML $@hidden_red_jewel.HiddenRedJewelInventoryFull
}

code_059669 {
    COP [PrintDialogString] ( &dialogstring_0596C1 )
    RTL 
}

dialogstring_05966E `[TPL:F][TPL:5]Seth: I found [N]a strange jewel [N]on board the ship. [N]I'll give it to you. [FIN][PAL:0]Will gets a Red Jewel![PAL:0][END]`

dialogstring_0596C1 `[TPL:F][TPL:5]It's the first time I've[N]ever given you anything.[N]Take care of it.[PAL:0][END]`