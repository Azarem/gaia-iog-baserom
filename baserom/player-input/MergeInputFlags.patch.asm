
?INCLUDE 'GlobalInputHandler'

!remapR           0DA6

---------------------------------------------

;Merges all input remap flags that match at least one
;Clobbers X, Y, and $0000

MergeInputFlags {
    PHA
    STZ $0000
    LDY #$0008
    LDX #$0000
    
  mif_loop:
    DEY
    BMI mif_done
    LDA $remapR, X
    INX
    INX
    AND $01, S
    BEQ mif_loop
    LDA $remapR-2, X
    TSB $0000
    BRA mif_loop

  mif_done:
    PLA
    LDA $0000
    RTL
}


  loc_03803B!:
    LDA #$2000
    TSB $joypadHeld
    JSL $@vblank_joypad.VBlankWaitAndJoypad
    JSL $@inventory_overlay.OpenInventoryScreen
    JSL $@vblank_joypad.DisableNmiKeepJoypad
    LDA $joypadCurrent
    AND #$6000
    JSL $@MergeInputFlags
    TSB $joypadHeld
    PLP 
    RTL 


SaveGameState!:
    PHP 
    PHB 
    REP #$20
    LDA $joypadCurrent
    STZ $joypadCurrent
    STA $7E38AC
    LDA $joypadHeld
    STA $7E38AE
    LDA #$FFFF
    STA $joypadHeld
    LDA $joypadMaskStd
    STZ $joypadMaskStd
    STA $7E38B0
    LDA $activeActorCount
    STA $0DBE
    LDX #$0000

DialogCmd_WaitForButton! {
    LDA $joypadCurrent
    TSB $joypadHeld

  loc_03E6AA!:
    JSR $&WaitOneFrame
    LDA $joypadCurrent
    BIT #$C0CC
    BNE loc_03E6C1
    SEC
    JSR $&DrawDialogueCursor
    LDA #$0001
    TSB $displayModeFlags
    BRA loc_03E6AA

  loc_03E6C1!:
    TRB $joypadCurrent
    TSB $joypadHeld
    CLC 
    JSR $&DrawDialogueCursor
    LDA #$0001
    TSB $displayModeFlags
    JSR $&DialogCmd_ClearBox
    RTS 
}

DialogCmd_WaitForAnyInput! {
    LDA $joypadCurrent
    TSB $joypadHeld
    
  loc_03E6D8!:
    JSR $&WaitOneFrame
    LDA $joypadCurrent
    BIT #$C0CC
    BEQ loc_03E6D8
    TRB $joypadCurrent
    TSB $joypadHeld
    RTS 
}

AttackInit! {
    LDA $joypadCurrent
    AND #$CF88
    TSB $joypadHeld
    AND #$0F00
    STA $joypadCurrent
    LDA #$0100
    TRB $10
    LDA $characterForm
    BEQ loc_02CF0B
    COP [PlaySoundCh2] ( #02 )
    RTS 
}

GlobalAmbientOnDirectionPress! {
    LDA #$8000
    TSB $joypadHeld
    JSL $@GetPlayerFacingDirection
    BCC GlobalAmbientFacingInvalid
    PLD 
    RTL 
}
