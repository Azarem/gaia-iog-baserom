?INCLUDE 'gs2C_crew4'

---------------------------------------------

gs2C_crew5 [
  actor-def < #12, #00, #10, {

  code_0583C9:
    COP [BranchIfFlagByte] ( #4E, #00, &code_0583D9 )
    COP [BranchIfFlagByte] ( #F8, #00, &code_0583D9 )
    COP [AddPosition] ( #20, #00 )
} >
]

code_0583D9 {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0583E2 )
    COP [SetEntryContinue]
    RTL 
}

code_0583E2 {
    COP [PrintWideString] ( &widestring_0583E7 )
    RTL 
}

widestring_0583E7 `[DEF]Look, look! [N]The King has returned! [FIN]And he's much shorter![END]`

widestring_058421 `[JMP:&gs2C_crew4.widestring_058394+M]`