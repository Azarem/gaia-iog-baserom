; Crawlspace passage in the Angel Village river tunnel.
; 
; Interactive passageway with size check. Text: "The entrance
; is too small!" Blocks passage for Will's normal form —
; requires a smaller form (Shadow) to pass through.
---------------------------------------------

!sceneCurrent                   0644
!playerYPos                     09A4
!playerFlags                    09AE

---------------------------------------------

av70_crawlspace [
  actor-def < #00, #00, #30, {

  code_06D632:
    LDA $sceneCurrent
    CMP #$0070
    BEQ loc_06D64C
    COP [SetEntryHere]
    LDA $playerYPos
    CMP #$01D0
    BEQ loc_06D645
    RTL 

  loc_06D645:
    COP [BranchIfPressed] ( #$0400, &code_06D65E )
    RTL 

  loc_06D64C:
    COP [SetEntryHere]
    LDA $playerYPos
    CMP #$02D0
    BEQ loc_06D657
    RTL 

  loc_06D657:
    COP [BranchIfPressed] ( #$0400, &code_06D65E )
    RTL 
} >
]

code_06D65E {
    LDA $playerFlags
    BIT #$0002
    BEQ loc_06D667
    RTL 

  loc_06D667:
    COP [PrintDialogString] ( &dialogstring_06D66C )
    RTL 
}

dialogstring_06D66C `[TPL:A][TPL:0]The entrance is[N]too small![PAL:0][END]`