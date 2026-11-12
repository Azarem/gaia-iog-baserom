; Mansion entrance (scene $E9): the awakening narration and the exit trigger.
; 
; Flag $29 clear (first visit): writes CGADSUB = $21, sets $29, locks the joypad ($EFFC), waits 30 ticks (WaitByte #1D), prints 'When I awoke, I was standing in the entrance to a strange mansion.', unlocks and continues into the per-frame loop (code_08FC92). Flag $29 set: goes straight to the loop. The loop writes CGADSUB = $21 every frame and, when Will is inside the relative tile rectangle (32,3E)-(34,3F), queues scene $E3 at ($0280,$01A0) and dies (the same destination as the Solid Arm defeat). The warp to the Solid Arm lair (scene $EA) is in scene_warps (warp_def_E6). Reached from actors/jeweler_gem (50 Red Jewels).
---------------------------------------------

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!CGADSUB                        2131

---------------------------------------------

sE9_mansion_intro [
  actor-def < #00, #00, #30, {

  code_08FC6D:
    COP [BranchOnFlagByte] ( #29, #01, &code_08FC92 )
    SEP #$20
    LDA #$21
    STA $CGADSUB
    REP #$20
    COP [SetFlagByte] ( #29 )
    LDA #$EFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_08FCBE )
    LDA #$EFFC
    TRB $joypadMaskStd
} >
]

code_08FC92 {
    COP [SetEntryHere]
    COP [BranchIfPlayerInRelTiles] ( #32, #3E, #34, #3F, &code_08FCA6 )
    SEP #$20
    LDA #$21
    STA $CGADSUB
    REP #$20
    RTL 
}

code_08FCA6 {
    LDA #$0202
    STA $gfxCacheIdxA
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #E3, #$0280, #$01A0, #80, #$2310 )
    COP [Die]
}

dialogstring_08FCBE `[TPL:A][TPL:0]When I awoke, I was [N]standing in the entrance[N]to a strange mansion.[PAL:0][END]`