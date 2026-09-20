; Kara's diary in Watermia — optional secret read.
; 
; Interactive object with choice: "Kara's diary is secret.
; Read it? Yes/No" — player can choose to read Kara's
; private thoughts. Character development item.
---------------------------------------------

---------------------------------------------

wa78_diary [
  actor-def < #00, #00, #30, {

  code_079BF8:
    COP [SetOnInteract] ( &code_079BFF )
    COP [SetEntryContinue]
    RTL 
} >
]

code_079BFF {
    COP [PrintDialogString] ( &dialogstring_079C19 )
    COP [DialogueOptions] ( #02, #02, &code_list_079C09 )
}

code_list_079C09 [
  &code_079C0F   ;00
  &code_079C14   ;01
  &code_079C0F   ;02
]

code_079C0F {
    COP [PrintDialogString] ( &dialogstring_079C4A )
    RTL 
}

code_079C14 {
    COP [PrintDialogString] ( &dialogstring_079C81 )
    RTL 
}

dialogstring_079C19 `[DEF][TPL:0]Kara's diary is secret. [N]Read it? [N] Yes [N] No `

dialogstring_079C4A `[CLR]OK. You'd feel guilty[N]reading it without[N]permission...[PAL:0][END]`

dialogstring_079C81 `[CLR][TPL:1]X Month X Day[N]After a long journey we[N]arrive in the Floating[N]City, Watermia.[FIN]I was parched after the[N]journey. Blisters on[N]my feet, but I wrapped[N]them in my handkerchief.[FIN]Before, I would have[N]complained, but I didn't[N]say anything. I think[N]I've changed a little.[FIN]I'm pleased that I can[N]be so concerned with[N]someone else.[FIN]I've heard this saying[N]from a villager.[FIN]"If you wish over a [N]lotus leaf on a full [N]moon night, your love [N]will notice you.ˮ [FIN]A good saying.[N]Maybe I'll try it...[PAL:0][END]`