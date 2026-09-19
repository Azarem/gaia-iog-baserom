?INCLUDE 'hidden_red_jewel'

---------------------------------------------

gs2B_seth [
  actor-def < #14, #00, #10, {

  code_059641:
    COP [BranchIfFlagByte] ( #51, #01, &code_059650 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_059652 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_059650 {
    COP [Die]
}

code_059652 {
    COP [BranchIfFlagByte] ( #E0, #01, &code_059669 )
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