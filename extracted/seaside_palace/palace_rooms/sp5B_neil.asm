; Neil trapped in the palace rooms — unconscious groaning.
; 
; NPC: "Uhhhn. Uhhhn." Neil is barely conscious like Lance.
; The party members are all weakened by the palace.
---------------------------------------------

?INCLUDE 'ToggleActorVisibilityFlag'

---------------------------------------------

sp5B_neil [
  actor-def < #14, #00, #10, {

  code_06894F:
    COP [BranchIfFlagByte] ( #70, #01, &code_068985 )
    COP [SpawnAfterAbsFlags] ( @ToggleActorVisibilityFlag, #$0000, #$0000, #$2800 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_068987 )

  loc_068969:
    COP [StageSpriteLoopMoveX] ( #18, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #14, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #15, #78 )
    COP [AnimLoop]
    BRA loc_068969
} >
]

code_068985 {
    COP [Die]
}

code_068987 {
    COP [PrintDialogString] ( &dialogstring_06898C )
    RTL 
}

dialogstring_06898C `[TPL:A][TPL:6]Neil: [N]Uhhhn. Uhhhn.[PAL:0][END]`