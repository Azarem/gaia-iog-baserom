; Street performer/showman in Freejia — entertainment NPC.
; 
; NPC who boasts: "No one can put on a show like I can.
; Have a look!" Interactable with an animation sequence showing
; his performance. Town color/atmosphere character.
---------------------------------------------

?BANK 05

!joypadMaskStd                  065A

---------------------------------------------

fr32_showman [
  actor-def < #02, #00, #10, {

  code_05BD7E:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05BDB6 )
    COP [WaitOnFlagByte] ( #0F, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteLoop] ( #04, #3C )
    COP [AnimLoop]
    COP [SpawnAfterMarked] ( @code_05BDEB, #$1002 )
    COP [WaitByte] ( #B3 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #06, #02, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #08, #04, #04 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
} >
]

code_05BDB6 {
    COP [PrintDialogString] ( &dialogstring_05BDBE )
    COP [SetFlagByte] ( #0F )
    RTL 
}

dialogstring_05BDBE `[DEF]No one can put on a[N]show like I can.[N]Have a look![END]`

code_05BDEB {
    COP [PlaySoundCh1] ( #21 )
    COP [StageSpriteLoop] ( #32, #3C )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #0F )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #34 )
    COP [AnimOnce]
    COP [SetEntryHere]
    LDY $04
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    RTL 
}