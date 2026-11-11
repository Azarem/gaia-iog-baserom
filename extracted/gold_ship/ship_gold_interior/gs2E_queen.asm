; The Queen of the Gold Ship — key NPC of scene $2E.
; 
; Flag $4F clear: spawns a helper actor (code_058B07) that writes TM = $15 every frame and dies when $4F is set. Both paths then continue into code_058A0F: the Queen is nudged +8 in X and gets a talk handler. First talk (flag $4E clear): the long welcome dialog (the Mystic Statue of the Wind, the Incan royal family backstory) and sets $4E; later talks print dialogstring_058A30+M.
; 
; Central character in the Gold Ship's backstory about the Incan royal family.
---------------------------------------------

!TM                             212C

---------------------------------------------

gs2E_queen [
  actor-def < #1A, #00, #10, {

  code_058A02:
    COP [BranchOnFlagByte] ( #4F, #01, &code_058A0F )
    COP [SpawnAfterFlags] ( @code_058B07, #$2000 )
} >
]

code_058A0F {
    COP [NudgePosition] ( #08, #00 )
    COP [SetInteractHandler] ( &code_058A1D )
    COP [SetEntryHere]
    RTL 
}

code_058A1A {
    COP [SetEntryHere]
    RTL 
}

code_058A1D {
    COP [BranchOnFlagByte] ( #4E, #01, &code_058A2B )
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
    COP [SetEntryHere]
    SEP #$20
    LDA #$15
    STA $TM
    REP #$20
    COP [BranchOnFlagByte] ( #4F, #01, &code_058B19 )
    RTL 
}

code_058B19 {
    COP [Die]
}