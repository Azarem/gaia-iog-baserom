; The Queen of the Gold Ship — key NPC with reunion scene.
; 
; Before flag $4F: spawns a child actor for the reunion cutscene
; setup. After flag $4F: solid NPC at (+8,0) with interaction
; dialog. Uses TM register writes for display layer control
; during the cutscene. Central character in the Gold Ship's
; backstory about the Incan royal family.
---------------------------------------------

!TM                             212C

---------------------------------------------

gs2E_queen [
  actor-def < #1A, #00, #10, {

  code_058A02:
    COP [BranchIfFlagByte] ( #4F, #01, &code_058A0F )
    COP [SpawnAfterFlags] ( @code_058B07, #$2000 )
} >
]

code_058A0F {
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_058A1D )
    COP [SetEntryContinue]
    RTL 
}

code_058A1A {
    COP [SetEntryContinue]
    RTL 
}

code_058A1D {
    COP [BranchIfFlagByte] ( #4E, #01, &code_058A2B )
    COP [PrintDialogString] ( &dialogstring_058A30 )
    COP [SetFlagByte] ( #4E )
    RTL 
}

code_058A2B {
    COP [PrintDialogString] ( &dialogstring_058A30+M )
    RTL 
}

dialogstring_058A30 `[TPL:B][TPL:3]Inca Queen:[N]Good. You have[N]returned safely.[FIN]As you were told, [N]until now I've been [N]guarding the Mystic [N]Statue of the Wind. [FIN]That's the statue you [N]were awarded [N]by the spirits. [FIN][::][TPL:B][TPL:3]It's in the jewel box in [N]the storehouse below, [N]Look for yourself.[PAL:0][END]`

code_058B07 {
    COP [SetEntryContinue]
    SEP #$20
    LDA #$15
    STA $TM
    REP #$20
    COP [BranchIfFlagByte] ( #4F, #01, &code_058B19 )
    RTL 
}

code_058B19 {
    COP [Die]
}