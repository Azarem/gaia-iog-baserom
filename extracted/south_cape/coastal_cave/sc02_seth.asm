; Seth in the coastal cave -- card game and statue puzzle.
; 
; Multi-state dialog covering the card game with Lance, reactions
; to Kara's escape news, and the cave statue puzzle sequence.
---------------------------------------------

?INCLUDE 'InitPlayerScriptVariant'
?INCLUDE 'interaction_handlers'

!joypadMaskStd                  065A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

sc02_seth [
  actor-def < #33, #00, #10, {

  code_04B458:
    COP [SpawnAfterAbsFlags] ( @e_sc02_actor_04B051, #$00E8, #$00C0, #$0300 )
    COP [BranchIfFlagByte] ( #4C, #01, &code_04B55D )
    COP [SetSpritePriority] ( #30 )
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #20, #01, &code_04B583 )
    COP [BranchIfFlagByte] ( #16, #01, &code_04B551 )
    COP [SetOnInteract] ( &code_04B58F )
    LDA #$0800
    TSB $10

  code_04B488:
    COP [StageSpriteFrame] ( #33 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #00, &code_04B488 )
    LDA #$0800
    TRB $10
    LDA #$0200
    TRB $12
    COP [WaitByte] ( #1D )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [SetOnInteract] ( &code_04B597 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfPlayerAt] ( #$0078, #$0090, &code_04B4BD )
    RTL 
} >
]

code_04B4BD {
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0000
    JSL $@InitPlayerScriptVariant
    COP [SetEntryExit]
    COP [PrintDialogString] ( &dialogstring_04B652 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #05 )
    COP [SetOnInteract] ( &code_04B5AC )
    LDY $06
    LDA $0014, Y
    STA $orbitAngle, X
    LDA $0016, Y
    STA $orbitDiameter, X
    COP [SetEntryContinue]
    LDY $06
    LDA $0014, Y
    CMP $orbitAngle, X
    BNE loc_04B504
    LDA $0016, Y
    CMP $orbitDiameter, X
    BNE loc_04B504
    RTL 

  loc_04B504:
    COP [WaitByte] ( #1F )
    COP [PrintDialogString] ( &dialogstring_04B75D )
    COP [SetFlagByte] ( #06 )
    COP [CallScript] ( &code_04B55F )
    COP [SetOnInteract] ( &code_04B5B1 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [SetOnInteract] ( #$0000 )
    COP [CallScript] ( &code_04B55F )
    COP [ExitIfFlagByte] ( #09, #01 )
    COP [StageSpriteMoveY] ( #16, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04B7DE )
    COP [SetFlagByte] ( #0A )
    LDA #$0800
    TSB $10
    LDA #$0200
    TSB $12
    COP [StageSpriteMoveY] ( #17, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #0B, #01 )
}

code_04B551 {
    COP [SetOnInteract] ( &code_04B592 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #33 )
    COP [AnimOnce]
    RTL 
}

code_04B55D {
    COP [Die]
}

code_04B55F {
    COP [StageSpriteLoopMoveY] ( #14, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #14, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #14, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #14, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #14, #04, #03 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_04B583 {
    COP [SetOnInteract] ( &code_04B59C )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #33 )
    COP [AnimOnce]
    RTL 
}

code_04B58F {
    COP [SetFlagByte] ( #02 )
}

code_04B592 {
    COP [PrintDialogString] ( &dialogstring_04B5B6 )
    RTL 
}

code_04B597 {
    COP [PrintDialogString] ( &dialogstring_04B612 )
    RTL 
}

code_04B59C {
    COP [BranchIfFlagByte] ( #25, #01, &code_04B5A7 )
    COP [PrintDialogString] ( &dialogstring_04B5B6 )
    RTL 
}

code_04B5A7 {
    COP [PrintDialogString] ( &dialogstring_04B5ED )
    RTL 
}

code_04B5AC {
    COP [PrintDialogString] ( &dialogstring_04B72B )
    RTL 
}

code_04B5B1 {
    COP [PrintDialogString] ( &dialogstring_04B77C )
    RTL 
}

dialogstring_04B5B6 `[TPL:A][TPL:5]Seth:[N]Ah ha ha. I'm going[N]to win again for sure.[PAL:0][END]`

dialogstring_04B5ED `[TPL:A][TPL:5]Seth:[N]Why do I keep losing...?[PAL:0][END]`

dialogstring_04B612 `[TPL:A][TPL:5]Seth: I'm not[N]interested in girls. I[N]like adventures better.[PAL:0][END]`

dialogstring_04B652 `[TPL:A][TPL:5]Seth:[N]Everyone's here.[N]What should we do today?[FIN][TPL:3]Erik: [N]I want to see Will's[N]mysterious power.[FIN]You haven't seen it? [N]He can move things [N]without touching them.[FIN][TPL:4]Lance: He moved [N]the statue that's in the[N]corner of the cave.[FIN]Will. [N]Show me again.[PAL:0][END]`

dialogstring_04B72B `[TPL:A][TPL:5]Seth: [N]Face the statue and[N]push the L/R Buttons.[PAL:0][END]`

dialogstring_04B75D `[TPL:A][TPL:4]Lance: Oh![N]It moved!![PAL:0][PAU:28][CLD]`

dialogstring_04B77C `[TPL:A][TPL:5]Seth: No matter how[N]many times I see it,[N]I'm still amazed.[FIN]But why can you move the[N]statue when you can't[N]move anything else...?[PAL:0][END]`

dialogstring_04B7DE `[TPL:A][TPL:5]Seth: Yeah, it must be[N]some kind of psychic[N]power thing.[FIN]If I didn't know better,[N]I'd think it was magic.[FIN]Most people have[N]five senses... [N]sight, [FIN]hearing, [FIN]taste, [FIN]smell, [FIN]and touch. [FIN]I think Will's psychic[N]power is some kind[N]of sixth sense.[PAL:0][END]`
---------------------------------------------

e_sc02_actor_04B051 {
    COP [SolidHighHere]
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_solid, #$2300 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #37 )
    COP [AnimOnce]
    RTL 
}