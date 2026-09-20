; Player damage and knockback entry function (Bank 00) called via JSL from enemy attack scripts such as Great Wall archer/asp and Incan stone guards.
; 
; Expects damage in Y and knockback metadata on the stack: it halves and subtracts the value from playerHp (clamped at zero), sets player stagger flag $0080 on $10, and writes an iframe counter to $7F0028. Unless playerFlags bit $0800 is already set, it spawns hit_stagger_controller.HitStaggerMain at priority $2400, stores knockback direction in the attacker's $0028 field, clears movement scratch $002C/$002E, and plays hit sound #$07.
; 
; It also masks joypad input ($0F00) for heavy hits or when the climbing flag is active. Control returns to the caller after spawning stagger; HitStaggerReturnAI eventually restores PlayerIdleEntry.
---------------------------------------------

?INCLUDE 'hit_stagger_controller'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!playerHp                       0ACE
!iframeCounter                  7F0028
!extendedFlags                  7F002A

---------------------------------------------

ApplyPlayerHitstun {
    PHX                   ; ApplyPlayerHitstun entry: damage in Y, knockback direction on stack
    PHD 
    STZ $0002
    STY $0000
    ASL 
    BCC loc_00C3AA
    PHA 
    LDA #$FFC4
    STA $0002
    PLA 

  loc_00C3AA:
    LSR                   ; Heavy hit (carry set): halve damage then subtract $3C iframe penalty
    EOR #$FFFF
    INC 
    CLC 
    ADC $playerHp
    BPL loc_00C3B8
    LDA #$0000

  loc_00C3B8:
    STA $playerHp
    LDA $playerActor
    TCD 
    TAX 
    LDA #$0080
    TSB $10
    LDA $0002
    BNE loc_00C3CD
    LDA #$003C

  loc_00C3CD:
    STA $iframeCounter, X ; Store iframe counter to $7F0028 (default $3C, or $FFC4 for heavy hits)
    LDA $playerFlags      ; Spawn HitStaggerMain at priority $2400 unless playerFlags $0800 already set
    BIT #$0800
    BNE loc_00C410
    COP [SpawnListAppend] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2400 )
    CPY #$1FC0
    BNE loc_00C3ED
    LDA #$0F00
    TRB $joypadMaskStd

  loc_00C3ED:
    LDA $extendedFlags, X
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    LDA $0000
    STA $0028, Y
    LDA #$0000
    STA $002C, Y
    STA $002E, Y

  loc_00C40A:
    COP [PlaySoundCh2] ( #07 )
    PLD 
    PLX 
    RTL 

  loc_00C410:
    LDA #$0F00
    TRB $joypadMaskStd
    BRA loc_00C40A
}