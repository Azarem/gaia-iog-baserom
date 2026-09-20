; Unused actor that sets up a smooth_follow follower chain.
; 
; Configures OrActorFlags, calls dm_follower_behavior setup, then
; tail-calls smooth_follow_child via JSL address push. Prototype
; follower mechanic that was replaced by the Diamond Mine escort system.
---------------------------------------------

?INCLUDE 'dm_follower_behavior'
?INCLUDE 'smooth_follow_child'

!playerActor                    09AA
!loopCounter                    7F0014

---------------------------------------------

unused_follow_chain {
    COP [OrExtraFlags] ( #$0010 )
    COP [CallNear] ( &dm_follower_behavior.code_0ADC25 )
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