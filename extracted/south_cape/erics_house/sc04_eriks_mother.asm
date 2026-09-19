; Erik's mother NPC with a humorous treatment dialog.
; 
; Explains she is using a heat treatment for sore muscles.
; Complains about cleaning the big house.
---------------------------------------------

---------------------------------------------

sc04_eriks_mother [
  actor-def < #14, #00, #10, {

  code_049055:
    COP [SpawnAfterRelFlags] ( @code_04906E, #$0009, #$FFF8, #$1002 )
    COP [SetOnInteract] ( &code_049076 )
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04906E {
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_049076 {
    COP [PrintDialogString] ( &dialogstring_04907B )
    RTL 
}

dialogstring_04907B `[DEF]Erik's mother: Don't[N]worry, I'm not on fire.[N]It's just a treatment[N]for my sore body.[FIN]Cleaning this big house[N]all day makes my[N]brain ache...[END]`