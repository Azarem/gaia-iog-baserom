?INCLUDE 'hidden_red_jewel'

---------------------------------------------

eu95_ann [
  actor-def < #14, #00, #10, {

  code_07DF07:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07DF10 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07DF10 {
    COP [BranchIfFlagByte] ( #D6, #01, &code_07DF33 )
    COP [PrintDialogString] ( &dialogstring_07DF7A )
    COP [DialogueOptions] ( #02, #02, &code_list_07DF20 )
}

code_list_07DF20 [
  &code_07DF26   ;00
  &code_07DF2E   ;01
  &code_07DF26   ;02
]

code_07DF26 {
    COP [PrintDialogString] ( &dialogstring_07E092 )
    COP [SetFlagByte] ( #D6 )
    RTL 
}

code_07DF2E {
    COP [PrintDialogString] ( &dialogstring_07E03D )
    RTL 
}

code_07DF33 {
    COP [BranchIfFlagByte] ( #E5, #01, &code_07DF75 )
    COP [BranchIfNoItem] ( #28, &code_07DF43 )
    COP [PrintDialogString] ( &dialogstring_07E0DE )
    RTL 
}

code_07DF43 {
    COP [BranchIfFlagByte] ( #E3, #00, &code_07DF63 )
    COP [BranchIfFlagByte] ( #E4, #00, &code_07DF68 )
    COP [RemoveItem] ( #28 )
    COP [PrintDialogString] ( &dialogstring_07E10A )
    COP [GiveItem] ( #01, &code_07DF5F )
    COP [SetFlagByte] ( #E5 )
    RTL 
}

code_07DF5F {
    JML $@hidden_red_jewel.code_00C6A1
}

code_07DF63 {
    COP [SetFlagByte] ( #E3 )
    BRA loc_07DF6D
}

code_07DF68 {
    COP [SetFlagByte] ( #E4 )
    BRA loc_07DF6D

  loc_07DF6D:
    COP [RemoveItem] ( #28 )
    COP [PrintDialogString] ( &dialogstring_07E0E5 )
    RTL 
}

code_07DF75 {
    COP [PrintDialogString] ( &dialogstring_07E19D )
    RTL 
}

dialogstring_07DF7A `[TPL:B][TPL:1]Ann: A few days ago, a [N]man wearing a cloak [N]came around. [FIN]He asked if anyone named[N]Kara had come to town. [FIN]I shrank with fear when [N]I saw his cold eyes. [FIN]Should I tell Kara [N]about it? [N] If you must! [N] No, please don't! `

dialogstring_07E03D `[CLR]I don't like that Kara. [N]She acts like some kind [N]of princess. [FIN]You shouldn't be so[N]cruel, talking that way.[PAL:0][END]`

dialogstring_07E092 `[CLR]Heh heh.[N]I've found a weakness.[FIN][::]Aah.[N]I want an apple. Let's[N]go to the marketplace![PAL:0][END]`

dialogstring_07E0DE `[TPL:B][TPL:1][JMP:&eu95_ann.dialogstring_07E092+M]`

dialogstring_07E0E5 `[TPL:B][TPL:1]Ann: Thanks.[N]I can't eat any more.[PAL:0][END]`

dialogstring_07E10A `[TPL:B][TPL:1]Ann:[N]Why are you always going[N]to the market and coming[N]back with apples..?[FIN]For Kara...? [N]Or...? [FIN]Good. As a present I'll[N]give you this jewel.[FIN][PAL:0]Will gets a Red Jewel![END]`

dialogstring_07E19D `[TPL:B][TPL:1]Ann: I'll take [N]care of Kara...[PAL:0][END]`