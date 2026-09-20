; Kruk bird in Watermia — ambient animal.
; 
; Decorative NPC. Says: "Kyaah!! kyaah!!" — the Kruk call.
; Animated animal for town atmosphere. Referenced by several
; NPCs discussing Kruks as pets.
---------------------------------------------

---------------------------------------------

wa78_kruk [
  actor-def < #1A, #00, #10, {

  code_079AD6:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_079AEA )
    COP [SolidHighHere]
    COP [WaitWhileOffscreen] ( #0F )
    COP [StageSpriteFrame] ( #1C )
    COP [AnimOnce]
    RTL 
} >
]

code_079AEA {
    COP [PrintDialogString] ( &dialogstring_079AEF )
    RTL 
}

dialogstring_079AEF `[DEF]Kyaah!!... kyaah!!...[END]`