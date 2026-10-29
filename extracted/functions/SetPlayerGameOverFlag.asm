; Helper actor body that ORs $0200 into the PLAYER ACTOR's flags word ($10) (Bank 0A, 697198–697211).
; 
; Y is the player actor's slot address (WRAM $09AA) and $0010,Y is the actor flags word. The name suggests 'game over', but game over is bit 9 of playerFlags ($09AE), a different word, which combat_collision sets when HP reaches zero (it also assigns GameOverSequence to the player). The bit set here is bit $0200 of the actor's own flags $10: the bit that the Psycho Slider, the lunge and PlayerStaticBodyPose set while the player must not be hit. combat_collision includes $0200 in the skip mask ($76E0) of its normal enemy-hits-player pass (the friendly pass uses $74E0, which allows it) and sends an actor with $0200 or $0080 to the friendly-only interaction pass. So the effect is most likely 'player cannot be hit during the boss-defeat sequence'; nothing here flashes.
; 
; Spawned with SpawnListAppend (flags $2000) by boss-defeat sequences: ir29_castoth, sg55_viper, gw8A_sand_fanger, pyDD_mummy_queen, mu67_vampires (both death callbacks, each after setting playerFlags $0020, the boss-defeat latch), sE8_dark_gaia (after the buttons are hidden) and unused_mode7_boss.
; 
; Like FlickerParentActor, the routine ends with RTL and never dies or changes its entry point, so the helper re-applies the bit every tick for as long as it exists; it is not a marked child.
---------------------------------------------

!playerActor                    09AA

---------------------------------------------

SetPlayerGameOverFlag {
    LDY $playerActor      ; Y = player actor slot address (WRAM $09AA; the slot address is also the actor's DP base)
    LDA $0010, Y          ; Actor flags word ($10) of the player actor
    ORA #$0200            ; Set actor-flag bit $0200 (not playerFlags bit 9, the real game-over bit)
    STA $0010, Y          ; Write the flags word back
    RTL                   ; RTL without Die or a new entry point: the helper runs again next tick and re-applies the bit
}