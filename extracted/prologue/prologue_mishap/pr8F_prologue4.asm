; Prologue 4: the mishap.
; 
; Brief narrative (~38 lines) about the Tower of Babel
; expedition's tragic outcome. Will's father Olman and
; the exploration party vanished during the expedition.
---------------------------------------------

?INCLUDE 'pr_text_placement_calc'
?INCLUDE 'pr_thinkers'

!gfxCacheIdxB                   064A
!displayModeFlags               09EC

---------------------------------------------

pr8F_prologue4 [
  actor-def < #00, #00, #30, {

  code_0BCE36:
    LDA #$4001
    TSB $displayModeFlags
    COP [CopyPalette] ( @pal_prologue_mishap, #00, #00, #20 )
    COP [SpawnAfterAbsFlags] ( @pr_text_placement_calc.code_0BCF8F, #$0020, #$0020, #$2000 )
    LDA #$&spritestring_0BD222
    STA $0026, Y
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD031 )
    COP [WaitWord] ( #$010D )
    COP [SpawnThinker] ( @pr_thinkers.e_pr_thinker_0BD039 )
    COP [WaitByte] ( #59 )
    LDA #$0804
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #8C, #$0000, #$0000, #00, #$1100 )
    COP [SetEntryContinue]
    RTL 
} >
]
---------------------------------------------

spritestring_0BD222 ~Some said there[N]were traps to[N]protect the[N]treasure, others[N]said it was a[N]curse.~