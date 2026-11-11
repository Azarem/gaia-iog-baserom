; Travel spirit of Dao (scene $C3, tile (21,08)). The actor dies at spawn while $D2 is clear (set by the Tower of Babel entrance monologue). With $D2 set it stands solid and asks 'Go to Tower of Babel?' with two rows (labelled 'Quit' and 'Return'); rows 0 and 1 of the handler table only clear the dialog; row 2 clears the dialog, zeroes $066D and $0670, sets gfxCacheIdxA and gfxCacheIdxB and queues scene $E3 at (0280,01B0).
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!srcCacheBgB                    066F

---------------------------------------------

daC3_babel_travel_spirit [
  actor-def < #00, #00, #10, {

  code_0980C6:
    LDA #$0200
    TSB $12
    COP [BranchOnFlagByte] ( #D2, #00, &code_0980E6 )
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #04 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_0980E8 )
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOnce]
    RTL 
} >
]

code_0980E6 {
    COP [Die]
}

code_0980E8 {
    COP [PrintDialogString] ( &dialogstring_09811E )
    COP [DialogueOptions] ( #02, #01, &code_list_0980F2 )
}

code_list_0980F2 [
  &code_0980F8   ;00
  &code_0980F8   ;01
  &code_0980FD   ;02
]

code_0980F8 {
    COP [PrintDialogString] ( &dialogstring_098144 )
    RTL 
}

code_0980FD {
    COP [PrintDialogString] ( &dialogstring_098144 )
    STZ $066D
    STZ $srcCacheBgB+1
    LDA #$0404
    STA $gfxCacheIdxB
    LDA #$0202
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #E3, #$0280, #$01B0, #00, #$2310 )
    RTL 
}

dialogstring_09811E `[TPL:A]Go to Tower of Babel?[N] Quit[N] Return`

dialogstring_098144 `[CLD]`