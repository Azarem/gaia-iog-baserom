; Statue of Hope pedestal show in the Mu prayer room (scene $63).
; 
; A player standing inside tiles (10,00)-(20,10) when the actor spawns selects the east branch (flag $7E, pedestal at pixel (0180,0058)); otherwise the west branch runs (flag $7B, pedestal at (0080,0058)). With the branch's flag already set the actor only spawns the placed-statue sprite and dies. Otherwise it waits for UseItem_StatueOfHope to set the flag, spawns the sprite, locks the joypad ($CFFC), plays music #1B, fades the backdrop in and spawns ten helper sprites (six of code_069C14, four of code_069BDA). It then prints the single text "The Sun god... Rama... The ocean holds a power...", sets scratch $02 so that every helper sprite leaves, fades the backdrop out, unlocks the joypad and dies.
---------------------------------------------

?INCLUDE 'oneshot_backdrop_fade_in_1B'
?INCLUDE 'oneshot_backdrop_fade_out_1C'
?INCLUDE 'spriteset_npc_props'

!joypadMaskStd                  065A
!srcCacheMusic                  0687

---------------------------------------------

mu63_spirits [
  actor-def < #0E, #00, #30, {

  code_0699CA:
    COP [BranchIfPlayerInAbsTiles] ( #10, #00, #20, #10, &code_069AC1 )
    COP [BranchOnFlagByte] ( #7B, #01, &code_069AAE )
    COP [WaitOnFlagByte] ( #7B, #01 )
    COP [SpawnAfterAbsFlags] ( @code_069ABB, #$0080, #$0058, #$1000 )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #0F )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [SpawnThinker] ( @oneshot_backdrop_fade_in_1B.FadeBackdropIn1B )
    COP [WaitByte] ( #BF )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0020, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$00E0, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0040, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$00C0, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0070, #$0070, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0090, #$0070, #$1800 )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0050, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0070, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0090, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$00B0, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_069BAA )
    COP [PlaySoundBoth] ( #$2525 )
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #02 )
    COP [WaitByte] ( #77 )
    COP [SpawnThinker] ( @oneshot_backdrop_fade_out_1C.FadeBackdropOut1C )
    COP [WaitByte] ( #7F )
    STZ $srcCacheMusic+1
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [Die]
} >
]

code_069AAE {
    COP [SpawnAfterAbsFlags] ( @code_069ABB, #$0080, #$0058, #$1000 )
    COP [Die]
}

code_069ABB {
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    RTL 
}

code_069AC1 {
    COP [BranchOnFlagByte] ( #7E, #01, &code_069B9D )
    COP [WaitOnFlagByte] ( #7E, #01 )
    COP [SpawnAfterAbsFlags] ( @code_069ABB, #$0180, #$0058, #$1000 )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #0F )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [SpawnThinker] ( @oneshot_backdrop_fade_in_1B.FadeBackdropIn1B )
    COP [WaitByte] ( #BF )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0120, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$01E0, #$00C0, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0140, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$01C0, #$0090, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0170, #$0070, #$1800 )
    COP [WaitByte] ( #27 )
    COP [SpawnAfterAbsFlags] ( @code_069C14, #$0190, #$0070, #$1800 )
    COP [WaitByte] ( #3B )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0150, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0170, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$0190, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [SpawnAfterAbsFlags] ( @code_069BDA, #$01B0, #$00C8, #$1800 )
    COP [WaitByte] ( #77 )
    COP [PrintDialogString] ( &dialogstring_069BAA )
    COP [PlaySoundBoth] ( #$2525 )
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #02 )
    COP [WaitByte] ( #77 )
    COP [SpawnThinker] ( @oneshot_backdrop_fade_out_1C.FadeBackdropOut1C )
    COP [WaitByte] ( #7F )
    STZ $srcCacheMusic+1
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [Die]
}

code_069B9D {
    COP [SpawnAfterAbsFlags] ( @code_069ABB, #$0180, #$0058, #$1000 )
    COP [Die]
}

dialogstring_069BAA `[TPL:A]The Sun god...[N]Rama...[FIN]The ocean holds[N]a power...[END]`

code_069BDA {
    COP [SetSpritePriority] ( #30 )
    COP [StageSprAndHitbox] ( #0E )
    COP [PlaySoundBoth] ( #$2626 )
    COP [LoopStart] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryHereAndYield]
    LDA #$2000
    TRB $10
    COP [LoopEnd]

  code_069BF5:
    COP [SetEntryHereAndYield]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [BranchOnFlagByte] ( #02, #00, &code_069BF5 )
    COP [LoopStart] ( #1E )
    LDA #$2000
    TSB $10
    COP [SetEntryHereAndYield]
    LDA #$2000
    TRB $10
    COP [LoopEnd]
    COP [Die]
}

code_069C14 {
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [PlaySoundBoth] ( #$2525 )

  code_069C1D:
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [BranchOnFlagByte] ( #02, #00, &code_069C1D )
    COP [Die]
}