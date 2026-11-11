; ==============================================================================
; Pyramid entrance portal - exit warp target from puzzle room
; ==============================================================================
; What it does: Portal dialog branch: from scene $CC warps to ($01F8,$0130)
;   instead of the default ($01F8,$0380) before scene change COP 26.
; Vanilla behavior: code_08B6C6 always uses the $0380 Y coordinate for scene CC.
; Hooks (overrides): pyCC_entrance_portal code_08B6C6.
; Depends on: pyCC_entrance_portal, py_actor_08B6F7 spawn, $0644 scene id.
; State: Sets player flag bit $2000 on $0010,Y; $0648/$064A transition words.
; Hazards/notes: COP 9C spawn; scene $CC check on $0644.
; ==============================================================================

!scene_current                  0644
!player_actor                   09AA

-------------------------------------------------
?INCLUDE 'pyCC_entrance_portal'
?INCLUDE 'py_actor_08B6F4'
-------------------------------------------------

pyCC_entrance_portal.code_08B6C6! {
    COP [BF] ( &dialogstring_08B74B )
    LDY $player_actor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [9C] ( @code_08B6F7, #$1800 )
    LDA #$0303
    STA $0648
    LDA #$0303
    STA $064A
    LDA $scene_current
    CMP #$00CC
    BEQ entrance_portal_top
    COP [26] ( #CC, #$01F8, #$0380, #03, #$4400 )
    RTL 

  entrance_portal_top:
    COP [26] ( #CC, #$01F8, #$0130, #03, #$4400 )
    RTL 
}