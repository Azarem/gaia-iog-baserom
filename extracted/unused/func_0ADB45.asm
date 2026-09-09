?INCLUDE 'dm_func_0ADB6B'
?INCLUDE 'smooth_follow_child'

!playerActor                    09AA
!loopCounter                    7F0014

---------------------------------------------

func_0ADB45 {
    COP [OrActorFlags] ( #$0010 )
    COP [CallScript] ( &dm_func_0ADB6B.code_0ADC25 )
    LDA $playerActor
    STA $24
    LDA #$0008
    STA $0028, X
    LDA #$0002
    STA $loopCounter, X
    SEP #$20
    LDA #$^smooth_follow_child
    PHA 
    REP #$20
    LDA #$&smooth_follow_child-1
    PHA 
    RTL 
}