; Dao travel spirit in the Babel upper floors — point of no return.
; 
; Offers return travel: "If you proceed, you will not be able
; to turn back... If you want to go to Dao, I'll transport you."
; Last chance to return to Dao before the final boss. Serves
; as the point-of-no-return warning.
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A

---------------------------------------------

btE3_dao_travel_spirit [
  actor-def < #00, #00, #10, {

  code_098003:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #04 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_09801D )
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOnce]
    RTL 
} >
]

code_09801D {
    COP [PrintDialogString] ( &dialogstring_098053 )
    COP [DialogueOptions] ( #02, #02, &code_list_098027 )
}

code_list_098027 [
  &code_09802D   ;00
  &code_09802D   ;01
  &code_098032   ;02
]

code_09802D {
    COP [PrintDialogString] ( &dialogstring_0980C1 )
    RTL 
}

code_098032 {
    COP [PrintDialogString] ( &dialogstring_0980C1 )
    STZ $066D
    STZ $0670
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0202
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #C3, #$0210, #$0090, #03, #$2300 )
    RTL 
}

dialogstring_098053 `[TPL:B]If you proceed, you[N]will not be able to[N]turn back...[FIN]If you want to go to [N]Dao, I'll transport you. [N] Quit [N] Return to Dao village `

dialogstring_0980C1 `[CLD]`