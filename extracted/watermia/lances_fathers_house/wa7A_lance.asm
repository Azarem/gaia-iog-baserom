; Lance in his father's house (scene $7A): the visit that sets flag $90.
; 
; $90 set: Lance dies at spawn. Otherwise he stands solid with the handler code_07AB6B, which sets scratch $02. The main script waits for scratch $02, locks the player ($EFFC), starts music #1B and prints 'Will, do you recognize this person? He's my father.'; from then on the handler is code_07AB6F: with scratch $01 clear (set by wa7A_lances_father when $A5 is clear) it repeats that line; with $01 set it prints 'He seems to have lost his memory. I finally met my lost father, but...' and sets $90. The main script waits for $90 and then, when the player stands in tiles (07,07)-(08,0A), locks the player ($CFFC), walks, prints 'Will, wait. I'll go, too. I'm preparing Lilly's birthday party. I want to finish by dark. Let's go to our room.' and dies.
---------------------------------------------

!joypadMaskStd                  065A
!srcCacheMusic                  0687

---------------------------------------------

wa7A_lance [
  actor-def < #15, #00, #10, {

  code_07AAF8:
    COP [BranchOnFlagByte] ( #90, #01, &code_07AB69 )
    COP [SetInteractHandler] ( &code_07AB6B )
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #02, #01 )
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [StartMusic] ( #1B )
    STZ $srcCacheMusic+1
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_07AB82 )
    LDA #$EFFC
    TRB $joypadMaskStd
    COP [SetInteractHandler] ( &code_07AB6F )
    COP [WaitOnFlagByte] ( #90, #01 )
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #07, #08, #0A, &code_07AB34 )
    RTL 
} >
]

code_07AB34 {
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [ClearSolidHere]
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #17, #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_07AC08 )
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #16, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #17, #11 )
    COP [AnimOnce]
    LDA #$CFFC
    TRB $joypadMaskStd
}

code_07AB69 {
    COP [Die]
}

code_07AB6B {
    COP [SetFlagByte] ( #02 )
    RTL 
}

code_07AB6F {
    COP [BranchOnFlagByte] ( #01, #01, &code_07AB7A )
    COP [PrintDialogString] ( &dialogstring_07AB82 )
    RTL 
}

code_07AB7A {
    COP [PrintDialogString] ( &dialogstring_07ABC4 )
    COP [SetFlagByte] ( #90 )
    RTL 
}

dialogstring_07AB82 `[TPL:A][TPL:4][SFX:1C]Lance: Will, do you [N]recognize this person? [FIN]He's my father.[PAL:0][END]`

dialogstring_07ABC4 `[TPL:A][TPL:4][SFX:1C]Lance: He seems to have [N]lost his memory.[FIN]I finally met my[N]lost father, but...[PAL:0][END]`

dialogstring_07AC08 `[TPL:A][TPL:4][SFX:1C]Lance: [N]Will, wait. [N]I'll go, too. [FIN]I'm preparing Lilly's[N]birthday party. I want[N]to finish by dark.[FIN]Let's go to our room.[PAL:0][END]`