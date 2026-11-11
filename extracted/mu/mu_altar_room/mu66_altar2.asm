; Statue sprite of the second altar in the Mu altar room (scene $66).
; 
; Waits for flag $81 (Rama Statue placed on the second pedestal by UseItem_RamaStatue), then shows its statue frame #2D and idles. It sets no flag.
---------------------------------------------

---------------------------------------------

mu66_altar2 [
  actor-def < #2D, #00, #30, {

  code_069C70:
    COP [NudgePosition] ( #00, #F8 )
    COP [WaitOnFlagByte] ( #81, #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
} >
]