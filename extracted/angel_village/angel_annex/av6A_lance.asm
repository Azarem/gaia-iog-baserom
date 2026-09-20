; Lance in the Angel Village annex — confides something important.
; 
; Extended NPC (~104 lines). Says: "Will. I want to talk to you
; about something. It's hard to say..." Part of the emotional
; subplot about Lance's growing feelings and his necklace.
---------------------------------------------

---------------------------------------------

av6A_lance [
  actor-def < #04, #00, #10, {

  code_06BBF2:
    COP [BranchOnFlagByte] ( #8D, #01, &av6A_lance_destroy )
    COP [BranchOnFlagByte] ( #8C, #01, &code_06BC07 )
    COP [SetInteractHandler] ( &code_06BC19 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_06BC07 {
    COP [SetTilePos] ( #1C, #0C )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_06BC14 )
    COP [SetEntryHere]
    RTL 
}

code_06BC14 {
    COP [PrintDialogString] ( &dialogstring_06BFBE )
    RTL 
}

code_06BC19 {
    COP [BranchOnFlagByte] ( #74, #01, &code_06BC57 )
    COP [SetFlagByte] ( #74 )
    COP [PrintDialogString] ( &dialogstring_06BC5C )
    COP [DialogueOptions] ( #02, #01, &code_list_06BC2C )
}

code_list_06BC2C [
  &code_06BC36   ;00
  &code_06BC32   ;01
  &code_06BC36   ;02
]

code_06BC32 {
    COP [PrintDialogString] ( &dialogstring_06BD1A )
}

code_06BC36 {
    COP [PrintDialogString] ( &dialogstring_06BD4A )

  code_06BC3A:
    COP [DialogueOptions] ( #03, #00, &code_list_06BC40 )
}

code_list_06BC40 [
  &code_06BC3A   ;00
  &code_06BC48   ;01
  &code_06BC4D   ;02
  &code_06BC52   ;03
]

code_06BC48 {
    COP [PrintDialogString] ( &dialogstring_06BE1F )
    RTL 
}

code_06BC4D {
    COP [PrintDialogString] ( &dialogstring_06BE85 )
    RTL 
}

code_06BC52 {
    COP [PrintDialogString] ( &dialogstring_06BF0A )
    RTL 
}

code_06BC57 {
    COP [PrintDialogString] ( &dialogstring_06BF7C )
    RTL 
}

dialogstring_06BC5C `[TPL:A][TPL:4]Lance: [N]Will. I want to talk to [N]you about something. [FIN][TPL:4]It's hard to talk about,[N]but I seem to have fallen [N]in love with Lilly...[FIN]I dream only of her...[N]I want her to[N]notice me.[FIN]It's not like me, is it?[N][PAL:0] Right[N] Not true`

dialogstring_06BD1A `[CLR][TPL:0]Will: I didn't think  [N]I'd ever hear you [N]say a thing like that. [FIN]`

dialogstring_06BD4A `[CLR][TPL:0]Will: But you've spent [N]a lot of time together. [N]It seems only natural. [FIN][CLR][TPL:4]Lance: Soon it will be [N]Lilly's 15th birthday. [FIN]I want to give her a[N]present and tell her[N]how I feel.[FIN]What would[N]you give her?[FIN] A bouquet of flowers[N] A pretty necklace[N] A sweet kiss`

dialogstring_06BE1F `[CLR][TPL:0]Will: [N]Any woman would like a [N]bouquet of flowers. [FIN][TPL:4]Lance: I know. I'll send [N]a bouquet of rose buds [N]to show my love. [FIN][JMP:&dialogstring_06BF7C]`

dialogstring_06BE85 `[CLR][TPL:0]Will: Of course, [N]something she'd wear [N]would be nice. [FIN]When she sees it, she'll [N]think of you. [FIN][TPL:4]Lance: Of course. [N]I'll find stones and [N]make a necklace. [FIN][JMP:&dialogstring_06BF7C]`

dialogstring_06BF0A `[CLR][TPL:0]Will: [N]That's the only thing [N]she'd like, right? [FIN][TPL:4]Lance: It might be too [N]sudden, but if you think [N]it's OK, I'll try it. [FIN][JMP:&dialogstring_06BF7C]`

dialogstring_06BF7C `[TPL:A][TPL:4]Lance: Thanks for [N]the advice. [FIN]I'll think about it.[N]It's good to[N]have friends.[PAL:0][END]`

dialogstring_06BFBE `[TPL:B][TPL:4]Lance: [N]Lilly will have her [N]birthday while we're in [N]the Floating City...[PAL:0][END]`
---------------------------------------------

av6A_lance_destroy {
    COP [Die]
}