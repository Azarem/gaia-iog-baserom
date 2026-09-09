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
    COP [PrintWideString] ( &widestring_058A30 )
    COP [SetFlagByte] ( #4E )
    RTL 
}

code_058A2B {
    COP [PrintWideString] ( &widestring_058A30+M )
    RTL 
}

widestring_058A30 `[TPL:B][TPL:3]Inca Queen:[N]Good. You have[N]returned safely.[FIN]As you were told, [N]until now I've been [N]guarding the Mystic [N]Statue of the Wind. [FIN]That's the statue you [N]were awarded [N]by the spirits. [FIN][::][TPL:B][TPL:3]It's in the jewel box in [N]the storehouse below, [N]Look for yourself.[PAL:0][END]`

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