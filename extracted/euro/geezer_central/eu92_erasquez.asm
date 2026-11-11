; Erasquez in the Euro geezer house (scene $92): the Teapot test and the hint that sets flag $9F.
; 
; Solid and interactable. The interact handler tests the inventory first (BranchIfHasItem #19). With the Teapot (item $19) he prints 'Erasquez: I feel the presence of evil from somewhere in town...' and changes nothing (the item stays, $9F is not touched). Without the Teapot and $9F clear he sets $9F and prints 'Hey, you! I feel a strange power coming from you...' ending with 'At the right time, go to Mt.Kress and take a look at the Teapot.' and 'Rofsky marked Mt.Kress on Will's map!'. Without the Teapot and $9F set he prints 'The spirits' tears in the teapot reflect your true form.'. $9F is read by the Euro world-map exit (scene $91), which then stages menu $10 (Quit / Mt.Temple / Watermia) instead of menu $0F; flag $AC takes precedence with menu $1A.
---------------------------------------------

---------------------------------------------

eu92_erasquez [
  actor-def < #2D, #00, #10, {

  code_07D7A1:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_07D7AA )
    COP [SetEntryHere]
    RTL 
} >
]

code_07D7AA {
    COP [BranchIfHasItem] ( #19, &code_07D7C2 )
    COP [BranchOnFlagByte] ( #9F, #01, &code_07D7BD )
    COP [SetFlagByte] ( #9F )
    COP [PrintDialogString] ( &dialogstring_07D7C7 )
    RTL 
}

code_07D7BD {
    COP [PrintDialogString] ( &dialogstring_07D892 )
    RTL 
}

code_07D7C2 {
    COP [PrintDialogString] ( &dialogstring_07D8D2 )
    RTL 
}

dialogstring_07D7C7 `[TPL:B][TPL:4]Erasquez: Hey, you![N]I feel a strange power[N]coming from you...[FIN]My intuition is so[N]developed, I can sense[N]things even if I can't[N]see them.[FIN]At the right time, go to[N]Mt.Kress and take [N]a look at the Teapot. [FIN][TPL:0]Rofsky marked Mt.Kress [N]on Will's map![PAL:0][END]`

dialogstring_07D892 `[TPL:B][TPL:4]Erasquez: The spirits' [N]tears in the teapot [N]reflect your true form.[PAL:0][END]`

dialogstring_07D8D2 `[TPL:A][TPL:4]Erasquez: I feel the [N]presence of evil from [N]somewhere in town... [FIN]Maybe the townspeople[N]have been changed[N]into demons.[FIN]It may be someone in the[N]town square, or one[N]of your friends.[FIN]Use the Teapot on anyone[N]you suspect.[PAL:0][END]`