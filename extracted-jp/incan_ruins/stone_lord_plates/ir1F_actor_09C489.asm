!eventFlags                     0A00

---------------------------------------------

h_ir1F_actor_09C489 [
  actor-def < #00, #00, #23, {

  code_0580A6:
    COP [BranchIfFlagByte] ( #3C, #01, &code_0580CA )
    COP [SetEntryContinue]
    LDA $eventFlags
    AND #$001E
    CMP #$001E
    BEQ loc_0580BA
    RTL 

  loc_0580BA:
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #08 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0108 )
    COP [SetFlagByte] ( #3C )
} >
]

code_0580CA {
    COP [Die]
}