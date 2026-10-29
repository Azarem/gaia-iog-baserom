; Player damage and knockback entry (Bank 00, 50071-50198), called by JSL from enemy attack scripts. Registers: A = damage with bit 15 as a 'heavy hit' flag, Y = knockback direction code (0 south, 1 north, 2 west, 3 east, 4 or more = none).
; 
; === STEPS ===
; 
; 1. $0000 := Y (absolute scratch, kept for later) and $0002 := 0. ASL moves bit 15 of A into carry: when set, $0002 := $FFC4 (the heavy-hit counter). LSR restores the damage with bit 15 cleared; it is NOT halved (ASL then LSR cancel out).
; 2. playerHp := max(0, playerHp - damage). D and X become the player actor.
; 3. Player flags $10 |= $0080 (hit reaction); the iframe counter ($7F0028) := $0002 if nonzero, else $003C. A positive counter is hit-stun, a negative one is recovery / invincibility (see actor_execution).
; 4. If playerFlags bit $0800 (script / ability lock) is set, no stagger is spawned: only the D-pad bits $0F00 of joypadMaskStd are cleared. Otherwise HitStaggerMain is spawned with COP SpawnListAppend ( entry, 0, 0, #$2400 ): $2400 is the child's FLAGS word ($2000 script-driven, $0400 player victim). Y = the child slot afterwards.
; 5. Y = $1FC0 means the actor pool was full and the spawn failed: the D-pad bits $0F00 are cleared (some callers hide them first; the child that would have restored them does not exist). The code still falls through to the child-setup stores below with Y = $1FC0, unlike ApplyInteractionDamage, which skips them. The stores are indexed by that Y; what they hit at $1FC0 plus the field offset is not traced.
; 6. Child setup: extendedFlags bit $0020 of the player is copied to the child, the direction code from $0000 goes into the child's $28, and its $2C / $2E are zeroed. Hit sound: PlaySoundCh2 #07 (always the Will sound; combat_collision picks #08 for Freedan and Shadow).
; 
; The function never HIDES the D-pad: it only reveals it on the two no-stagger paths. Callers such as gw82_archer and ir1F_stone_guard hide it themselves (TSB #$0F00) before the JSL, and HitStaggerReleasePlayer reveals it when the stagger ends.
; 
; Because HitStaggerReleasePlayer overwrites the iframe counter with $FFE2 when the slide ends, the $003C written here only lasts until then (about 17 ticks).
; 
; === CALL SITES (9, in 3 files) ===
; 
; | File | A | Y |
; |------|---|---|
; | gw82_archer (2 sites) | 2, 2 | 3 (east), 2 (west) |
; | gw83_asp (3 sites) | 1, 1, $8001 (heavy) | 4, 4, 4 (no knockback) |
; | ir1F_stone_guard (4 sites) | $0B02 + 2, $0B02 + 2, 2, 2 | 0, 1, 3, 2 |
; 
; $0B02 is the difficulty level (ram_map.txt), so the stone guard's two strongest hits add it to a base of 2. Combat hits from the player's own attacks and from contact use combat_collision's inline code instead.
; 
; Everything here is UNVERIFIED-RUNTIME (no emulator trace); read from the code.
---------------------------------------------

?INCLUDE 'hit_stagger_controller'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!playerHp                       0ACE
!iframeCounter                  7F0028
!extendedFlags                  7F002A

---------------------------------------------

; Subtract the damage (A bit 15 = heavy), set the hit reaction and iframe counter on the player, and spawn HitStaggerMain with the direction code Y unless a script lock is active.

ApplyPlayerHitstun {
    PHX 
    PHD 
    STZ $0002             ; $0002 := 0 (absolute scratch: iframe override, 0 = default); $0000 := Y, the direction code, kept for later
    STY $0000
    ASL                   ; Carry := bit 15 of A, the heavy-hit flag; heavy sets $0002 := $FFC4 (-60 iframe counter)
    BCC loc_00C3AA
    PHA 
    LDA #$FFC4
    STA $0002
    PLA 

; Damage = A with bit 15 cleared (not halved); subtract it from playerHp, clamped at 0.

  loc_00C3AA:
    LSR                   ; Damage = A with bit 15 cleared (ASL then LSR cancel: not halved)
    EOR #$FFFF            ; Negate and add: playerHp - damage, clamped at 0
    INC 
    CLC 
    ADC $playerHp
    BPL loc_00C3B8
    LDA #$0000

; Store the HP, switch D / X to the player actor, flag the hit reaction and choose the iframe counter ($003C or $FFC4).

  loc_00C3B8:
    STA $playerHp
    LDA $playerActor      ; D := X := the player actor (COP needs X = D = slot)
    TCD 
    TAX 
    LDA #$0080            ; Player $10 |= $0080: hit reaction (also read by the blink code)
    TSB $10
    LDA $0002             ; Iframe counter: $FFC4 for a heavy hit, else the default $003C (+60 ticks of hit-stun)
    BNE loc_00C3CD
    LDA #$003C

; Store the iframe counter, then spawn the stagger controller unless playerFlags bit $0800 is set.

  loc_00C3CD:
    STA $iframeCounter, X ; Positive = stun, negative = recovery
    LDA $playerFlags      ; Bit $0800 (script / ability lock): no stagger
    BIT #$0800
    BNE loc_00C410
    COP [SpawnListAppend] ( @hit_stagger_controller.HitStaggerMain, #00, #00, #$2400 ) ; Spawn HitStaggerMain; flags $2400 = script-driven + player victim; Y = the child
    CPY #$1FC0            ; Y = $1FC0: the actor pool was full
    BNE loc_00C3ED
    LDA #$0F00            ; Spawn failed: reveal the D-pad (no child will do it)
    TRB $joypadMaskStd

; Configure the child: copy extendedFlags $0020, direction code to $28, zero $2C / $2E.

  loc_00C3ED:
    LDA $extendedFlags, X ; Child setup: the player's extendedFlags bit $0020 is copied into the child
    AND #$0020
    PHX 
    TYX 
    STA $extendedFlags, X
    PLX 
    LDA $0000             ; Direction code to the child's $28 (0 S, 1 N, 2 W, 3 E, 4+ none); zero its $2C / $2E
    STA $0028, Y
    LDA #$0000
    STA $002C, Y
    STA $002E, Y

; Hit sound #07, restore D and X, return.

  loc_00C40A:
    COP [PlaySoundCh2] ( #07 ) ; Hit sound #07
    PLD 
    PLX 
    RTL 

; Script lock active: no stagger; clear the D-pad bits of the hidden-button mask and finish with the sound.

  loc_00C410:
    LDA #$0F00            ; Script lock: reveal the D-pad (no stagger will do it)
    TRB $joypadMaskStd
    BRA loc_00C40A
}