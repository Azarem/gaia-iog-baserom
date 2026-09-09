!eventFlags                     0A00

---------------------------------------------

ir1F_actor_09C489 [
  actor-def < #00, #00, #23, {

  code_09C48C:
    COP [BranchIfFlagByte] ( #3C, #01, &code_09C4B0 )
    COP [SetEntryContinue]
    LDA $eventFlags
    AND #$001E
    CMP #$001E
    BEQ loc_09C4A0
    RTL 

  loc_09C4A0:
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #08 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0108 )
    COP [SetFlagByte] ( #3C )
} >
]

code_09C4B0 {
    COP [Die]
}