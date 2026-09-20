; Gold Ship deck crew member 5 — variant NPC with conditional placement.
; 
; Checks flags $4E and $F8 for placement — if both set, shifts
; position +$20 X. Reuses gs2C_crew4 dialog setup. Says: "Look,
; look! The King has returned! And he's much shorter!"
---------------------------------------------

?INCLUDE 'gs2C_crew4'

---------------------------------------------

gs2C_crew5 [
  actor-def < #12, #00, #10, {

  code_0583C9:
    COP [BranchOnFlagByte] ( #4E, #00, &code_0583D9 )
    COP [BranchOnFlagByte] ( #F8, #00, &code_0583D9 )
    COP [NudgePosition] ( #20, #00 )
} >
]

code_0583D9 {
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_0583E2 )
    COP [SetEntryHere]
    RTL 
}

code_0583E2 {
    COP [PrintDialogString] ( &dialogstring_0583E7 )
    RTL 
}

dialogstring_0583E7 `[DEF]Look, look! [N]The King has returned! [FIN]And he's much shorter![END]`

dialogstring_058421 `[JMP:&gs2C_crew4.dialogstring_058394+M]`