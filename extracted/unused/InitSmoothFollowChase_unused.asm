; Unreferenced smooth-follow initializer that spawns smooth_follow.InitFollowAndChase instead of the active smooth_follow_child path.
; 
; Waits for animScratch2 countdown and flag $4000 before dying. Alternative chase setup likely replaced by the active smooth_follow_child implementation in boss scripts.
---------------------------------------------

?INCLUDE 'smooth_follow'

!animScratch2                   7F000E

---------------------------------------------

InitSmoothFollowChase_unused {
    COP [SpawnMarkedAfter] ( @smooth_follow.InitFollowAndChase, #$2000 )
    CPY #$1FC0
    BEQ loc_00E681
    LDA $24
    STA $0024, Y
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $animScratch2, X
    DEC 
    STA $animScratch2, X
    BEQ loc_00E676
    RTL 

  loc_00E676:
    COP [SetEntryContinue]
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_00E676

  loc_00E681:
    COP [Die]
}