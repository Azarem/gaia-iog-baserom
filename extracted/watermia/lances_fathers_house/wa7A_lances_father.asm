; Lance's father — expedition partner of Olman.
; 
; NPC: "I went on an expedition with Olman." Provides
; backstory about the Tower of Babel expedition that
; connects Lance and Will's fathers. Key lore NPC.
---------------------------------------------

---------------------------------------------

wa7A_lances_father [
  actor-def < #24, #00, #10, {

  code_07B39D:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_07B3AF )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_07B3AF {
    COP [BranchIfFlagByte] ( #A5, #01, &code_07B3BD )
    COP [PrintDialogString] ( &dialogstring_07B3C2 )
    COP [SetFlagByte] ( #01 )
    RTL 
}

code_07B3BD {
    COP [PrintDialogString] ( &dialogstring_07B412 )
    RTL 
}

dialogstring_07B3C2 `[TPL:B][TPL:3][SFX:10]Lance's father: [N]I went on an expedition [N]with Olman. [N]It was scary, but fun.[PAL:0][END]`

dialogstring_07B412 `[TPL:B][TPL:3][SFX:10]Lance's father: [N]Oh, Will. Sorry I [N]made you worry. [FIN]Lance and Lilly did their [N]best to nurse me back [N]to health. [FIN]I never wanted to be[N]controlled by my son,[N]but it's nice now to[N]have your own child.[PAL:0][END]`