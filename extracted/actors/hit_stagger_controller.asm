; Hit knockback and recovery controller (Bank 00, 55415-55927). One short-lived actor is spawned per hit. It slides the victim along one axis for 16 frames by moving ITSELF (collision-checked movement) and copying its position to the victim every frame, then either hands control back (player) or resolves the hit (enemy: HP check, hit / death callback). It has no sprite and is never placed by a scene.
; 
; === SPAWN CONTRACT ===
; 
; Four spawn sites: ApplyPlayerHitstun and combat_collision.ApplyInteractionDamage (flags word $2400, victim = the player) and the two enemy-hit paths in combat_collision (flags $2000). The flags word becomes the child's $10: $2000 = script-driven run path (own wait counter; actor_execution moves such an actor only while $12 bit 3 is set), $0400 = 'the victim is the player': the controller tests it to choose HitStaggerReleasePlayer instead of HitStaggerResolveHit (the old note said $0400 marks an enemy and that the old label HitStaggerReturnAI 're-enables AI for enemies'; HitStaggerReleasePlayer only ever handles the player). CopyActorState gives the child the victim's position, anim index, $12 (without $1000) and, in $24, the victim's slot. The spawner then stores a direction code in the child's $28 and zeroes its $2C / $2E, and copies the victim's extendedFlags bit $0020 ('hitstun skip' in the WRAM map) into the child.
; Direction code in $28: 0 = south, 1 = north, 2 = west, 3 = east (CalcKnockbackDirection), 4 or more = no knockback. free101C ($7F101C) of the victim is a knockback TIER: 0 for ordinary actors, 1 for the player (player_character init) and mu5F_cyclops; the only writers in extracted/ are CopyActorState (zero), those three and this file (copy to the child).
; 
; === HitStaggerMain ===
; 
; $10 |= $0008 (collision-checked movement) unless the victim has extendedFlags $0020; $12 |= $0008 (movement request for a script-driven actor). If $12 bit $0010 is set (inherited from the victim: stagger-immune in combat_collision) or the direction code is 4 or more, there is no knockback: WaitByte #$0F (16 ticks), then HitStaggerReleasePlayer (player) or HitStaggerResolveHit. Otherwise the victim's pixel X / Y are saved in orbitAngle / orbitDiameter ($7F0010 / $7F0012: no orbit here, the words are reused as the START position), the tier is copied, and the direction code is decoded by chained DEC / BMI (the old note spoke of a '3-deep stack-encoded direction index'; there is no such stack): 0 = Y chain (carry set), 1 = Y chain with SetMoveNegateXY (negated), 2 = X chain with SetMoveNegateXY, 3 = X chain (carry clear). Each branch first clears the inherited ForceDir bits ($6000 of $12). The branches JSR HitStaggerApplyKnockbackDelta, which pushes HitStaggerStoreMovementDelta as a return address; that routine stores the movement chain head in $2E (carry set, $26 := 0, vertical) or $2C (carry clear, $26 := 1, horizontal; the old doc had the axis flag the other way round). The RTS chain ends in HitStaggerSlideLoop (pushed by Main).
; Curves (move_chain_table, one delta per frame, pixels): tier 0 uses entry $22 = 4 4 5 5 5 5 4 4 3 3 2 2 1 1 0 (sum 48 px = 3 tiles); tier 1 and above use entry $23 = 3 3 4 4 3 3 2 2 2 2 1 1 1 1 0 (sum 32 px = 2 tiles). The player is tier 1.
; 
; === HitStaggerSlideLoop (the 16-frame slide loop) ===
; 
; SetEntryHereAndYield, then LoopStart #$10: 16 frames in which the child's $14 / $16 are copied into the victim. After the loop: the player ($10 bit $0400) goes to HitStaggerReleasePlayer. An enemy without $10 bit $0008 goes straight to ResolveHit. Otherwise the distance travelled along the axis ($26 = 0: Y, else X) is d = |start - current|: d = 0 resolves at once; if d is a multiple of 16 HitStaggerCheckKnockbackDistance compares it with the tier threshold (tier 0 $30, tier 1 $20, tier 2 and above $40) and carry CLEAR (equal = the full slide happened) resolves; any other d is a CUT-SHORT slide (a wall stopped it): the victim's chain pointer and delta word on the knocked axis are zeroed ($2E and $7F002E for a vertical slide, $2C and $7F002C for a horizontal one) and its wait counter $08 is zeroed when it has no chain on the other axis, so its script resumes immediately (purpose inferred, OQ-I046-3). The thresholds equal the curve sums (48 and 32), which is why a full slide matches exactly; tiers 2 and 3 use the 32-px curve with a $40 threshold and could never match (no actor uses them).
; 
; === HitStaggerResolveHit (enemy) ===
; 
; HP ($7F0026) nonzero: if onHitCallback ($7F1000) is set it becomes the victim's entry address (low word only, the bank word is unchanged) and is cleared; the victim's iframe counter becomes $FFF4 (-12, recovery). HP zero: the victim's $10 gets $0040 (dead) unless it already has it, its entry becomes onDeathCallback / onDeathCallbackBank when set (and $08, $2C, $2E are zeroed) or StandardEnemyDefeatHandler in the same bank. Finally X := D (the child) and COP Die, because the COP needs X = the actor slot.
; 
; === HitStaggerReleasePlayer (player only) ===
; 
; Unless playerFlags has $0A00 (game over / script lock) the player's entry address becomes player_character.PlayerIdleEntry. The player's iframe counter is set to $FFE2 (-30) and the D-pad bits $0F00 of joypadMaskStd are cleared (shown again). Because a positive counter freezes the player controller, overwriting the $003C that ApplyPlayerHitstun wrote ends the stun after the 16-frame slide (about 17 ticks), not after 60; a heavy hit's -60 is likewise shortened to -30.
; 
; === Helpers ===
; 
; HitStaggerCheckKnockbackDistance stores d in the absolute scratch $0000 and pushes HitStaggerZeroToCarry - 1, so the CMP's RTS lands in HitStaggerZeroToCarry, which turns Z into carry (CLC when equal, SEC otherwise). All operands written with four hex digits ($0000, $002C, $002E, $0008 ...) are absolute addresses; $0000 is the global scratch word, the others are the slot fields indexed by X.
; 
; Everything here is UNVERIFIED-RUNTIME (no emulator trace); the arithmetic and flow are read from the code and the move_chain_table nodes.
---------------------------------------------

?INCLUDE 'move_chain_table'
?INCLUDE 'player_character'
?INCLUDE 'StandardEnemyDefeatHandler'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!currentHp                      7F0026
!iframeCounter                  7F0028
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E
!onHitCallback                  7F1000
!onDeathCallback                7F1004
!onDeathCallbackBank            7F1006
!free101C                       7F101C

---------------------------------------------

; Entry of the child. Sets the movement flags, saves the victim's start position and tier, decodes the direction code (0 S, 1 N, 2 W, 3 E; 4+ or a stagger-immune victim = no knockback) and chains into the slide loop.

HitStaggerMain {
    LDA $extendedFlags, X ; Victim's extendedFlags: bit $0020 'hitstun skip' = no collision-checked movement; else $10 |= $0008 so the knockback stops at walls
    BIT #$0020
    BNE loc_00D885
    LDA #$0008
    TSB $10

; Request movement for this script-driven actor ($12 bit 3), then test for the no-knockback cases.

  loc_00D885:
    LDA #$0008
    TSB $12               ; $12 |= $0008: movement request, so the engine applies the chains although $2000 is set
    LDA $12
    BIT #$0010            ; Bit $0010 of $12 (inherited from the victim): stagger-immune, no knockback
    BNE loc_00D8C6
    PHX 
    LDY $24               ; Y := the victim (CopyActorState wrote its slot into $24)
    LDA $0014, Y
    STA $orbitAngle, X    ; Start X saved in orbitAngle (word reused, no orbit) and copied to the child's own X
    STA $14
    LDA $0016, Y
    STA $orbitDiameter, X ; Start Y saved in orbitDiameter (word reused) and copied to the child's own Y
    STA $16
    TYX 
    LDA $free101C, X      ; Victim's knockback tier (free101C), copied to the child: selects the curve and the distance threshold
    PLX 
    STA $free101C, X
    LDA $0028, X          ; Direction code stored by the spawner; 4 or more = no knockback
    CMP #$0004
    BCS loc_00D8C6
    PEA $&HitStaggerSlideLoop-1 ; Return address: the RTS chain ends in HitStaggerSlideLoop
    DEC                   ; Decode by chained DEC / BMI: 0 south, 1 north, 2 west, falling through to 3 east
    BMI loc_00D8D6
    DEC 
    BMI loc_00D8E0
    DEC 
    BMI loc_00D8ED
    BRA loc_00D8FA

; No knockback: wait 16 ticks, then HitStaggerReleasePlayer when the victim is the player ($10 bit $0400), else ResolveHit.

  loc_00D8C6:
    COP [WaitByte] ( #0F )
    LDA $10
    BIT #$0400
    BEQ loc_00D8D3
    JMP $&HitStaggerReleasePlayer

; Enemy, no knockback: resolve the hit.

  loc_00D8D3:
    JMP $&HitStaggerResolveHit

; Direction 0 (south): clear the ForceDir bits, SEC (vertical chain), JSR the delta setup; the RTS chain continues into HitStaggerSlideLoop.

  loc_00D8D6:
    LDA #$6000            ; Every direction first clears the ForceDir bits ($6000 of $12) inherited from the victim
    TRB $12
    SEC                   ; Carry set = vertical chain ($2E), carry clear = horizontal chain ($2C)
    JSR $&HitStaggerApplyKnockbackDelta ; The JSR pushes HitStaggerStoreMovementDelta as a return address; the RTS chain then continues into HitStaggerSlideLoop
    RTS 

; Direction 1 (north): negate both deltas with SetMoveNegateXY, SEC (vertical chain).

  loc_00D8E0:
    LDA #$6000
    TRB $12
    COP [SetMoveNegateXY] ( #01 ) ; SetMoveNegateXY negates both deltas: moves north
    SEC 
    JSR $&HitStaggerApplyKnockbackDelta
    RTS 

; Direction 2 (west): negate both deltas with SetMoveNegateXY, CLC (horizontal chain).

  loc_00D8ED:
    LDA #$6000
    TRB $12
    COP [SetMoveNegateXY] ( #01 ) ; SetMoveNegateXY negates both deltas: moves west
    CLC 
    JSR $&HitStaggerApplyKnockbackDelta
    RTS 

; Direction 3 (east): no negation, CLC (horizontal chain).

  loc_00D8FA:
    LDA #$6000
    TRB $12
    CLC                   ; Not negated: east
    JSR $&HitStaggerApplyKnockbackDelta
    RTS 
}

---------------------------------------------
; The 16-frame slide loop (not a direction picker): the child moves, the victim copies its position every frame. Afterwards: player to HitStaggerReleasePlayer, enemy to the distance check and ResolveHit.

HitStaggerSlideLoop {
    COP [SetEntryHereAndYield]
    COP [LoopStart] ( #10 ) ; 16 frames: the child (moved by the engine) copies its position into the victim every frame
    LDY $24
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [LoopEnd]
    LDA $10
    BIT #$0400            ; Bit $0400: the victim is the player
    BEQ loc_00D921
    JMP $&HitStaggerReleasePlayer

; Enemy with the movement flag: measure the vertical distance from the saved start Y when $26 is 0, else take the horizontal branch.

  loc_00D921:
    LDA $10
    BIT #$0008            ; Bit $0008: collision-checked knockback; clear means no distance check
    BEQ HitStaggerResolveHit
    LDA $26               ; Axis flag $26: 0 = vertical, nonzero = horizontal
    BNE loc_00D95B
    LDA $orbitDiameter, X ; d = |start Y - current Y|; d = 0 resolves at once
    SEC 
    SBC $16
    BEQ HitStaggerResolveHit
    BPL loc_00D93B
    EOR #$FFFF
    INC 

; Vertical distance d: a multiple of 16 goes to the threshold check (carry clear = full slide = resolve), anything else is a cut-short slide.

  loc_00D93B:
    BIT #$000F            ; d a multiple of 16: threshold check (carry clear = full slide = resolve); any other d is a cut-short slide
    BNE loc_00D945
    JSR $&HitStaggerCheckKnockbackDistance
    BCC HitStaggerResolveHit

; Cut-short vertical slide: wake the victim if it has no X chain, then clear its Y chain and Y delta.

  loc_00D945:
    LDX $24               ; Cut-short slide: wake the victim (zero its wait counter $08) when it has no chain on the other axis
    LDA $002C, X
    BNE loc_00D94F
    STZ $0008, X

; Clear the victim's Y chain pointer and Y delta word, then jump into the HP check.

  loc_00D94F:
    LDA #$0000
    STA $002E, X          ; Clear the victim's Y chain pointer and Y delta word
    STA $moveScratch2, X
    BRA loc_00D98A

; Horizontal branch: distance from the saved start X.

  loc_00D95B:
    LDA $orbitAngle, X    ; Same structure as the vertical branch on the X axis: d = |start X - current X|
    SEC 
    SBC $14
    BEQ HitStaggerResolveHit
    BPL loc_00D96A
    EOR #$FFFF
    INC 

; Horizontal distance d: a multiple of 16 goes to the threshold check, anything else is a cut-short slide.

  loc_00D96A:
    BIT #$000F
    BNE loc_00D974
    JSR $&HitStaggerCheckKnockbackDistance
    BCC HitStaggerResolveHit

; Cut-short horizontal slide: wake the victim if it has no Y chain, then clear its X chain and X delta.

  loc_00D974:
    LDX $24
    LDA $002E, X
    BNE loc_00D97E
    STZ $0008, X

; Clear the victim's X chain pointer and X delta word, then fall into HitStaggerResolveHit.

  loc_00D97E:
    LDA #$0000
    STA $002C, X          ; Clear the victim's X chain pointer and X delta word
    STA $moveScratch1, X
}

---------------------------------------------
; Enemy resolution: HP zero routes the victim to its death callback or StandardEnemyDefeatHandler; HP left runs the hit callback and sets a -12 recovery counter. Ends with Die on the child.

HitStaggerResolveHit {
    LDX $24

; HP check (X = victim): zero HP means the victim dies, otherwise the hit callback path.

  loc_00D98A:
    LDA $currentHp, X     ; HP zero: the victim dies; otherwise the hit callback path
    BNE loc_00D9D0
    LDA $0010, X
    BIT #$0040            ; Bit $0040 (dead) already set: only remove the child
    BNE loc_00D9E7
    ORA #$0040
    STA $0010, X
    LDA $onDeathCallback, X ; Death callback (address, then bank) becomes the victim's entry; 0 = none, use the standard defeat
    BEQ loc_00D9BC
    STA $0000, X
    LDA $onDeathCallbackBank, X
    STA $0002, X
    LDA #$0000            ; Run at once: zero the victim's wait counter and both movement chains
    STA $0008, X
    STA $002C, X
    STA $002E, X
    BRA loc_00D9E7

; No death callback: the victim's script becomes StandardEnemyDefeatHandler (same bank).

  loc_00D9BC:
    LDA #$*StandardEnemyDefeatHandler ; Entry := StandardEnemyDefeatHandler (same bank), wait counter zero: run at once
    STA $0002, X
    LDA #$&StandardEnemyDefeatHandler
    STA $0000, X
    LDA #$0000
    STA $0008, X
    BRA loc_00D9E7

; Victim survives: run onHitCallback (becomes the entry address, cleared) and set the iframe counter to $FFF4.

  loc_00D9D0:
    LDA $onHitCallback, X ; Hit callback (low word only) becomes the victim's entry address, then is cleared
    BEQ loc_00D9E0
    STA $0000, X
    LDA #$0000
    STA $onHitCallback, X

; Recovery: iframe counter $FFF4 (-12) on the victim.

  loc_00D9E0:
    LDA #$FFF4            ; Recovery: iframe counter $FFF4 (-12)
    STA $iframeCounter, X

; Remove the child: X := D, then COP Die.

  loc_00D9E7:
    TDC                   ; X := D (the child): COP Die needs X = the actor slot
    TAX 
    COP [Die]
}

---------------------------------------------
; Player only: PlayerIdleEntry as the entry address (unless game over or script lock), iframe counter $FFE2, D-pad shown again, Die. No AI is restored (the old label said HitStaggerReturnAI).

HitStaggerReleasePlayer {
    PHX 
    LDX $playerActor
    LDA $playerFlags
    BIT #$0A00            ; Game over ($0200) or script lock ($0800): leave the player's script alone
    BNE loc_00DA03
    LDA #$*player_character.PlayerIdleEntry ; Entry := PlayerIdleEntry (bank, then address)
    STA $0002, X
    LDA #$&player_character.PlayerIdleEntry
    STA $0000, X

; Set the player's iframe counter to $FFE2, restore the D-pad and remove the child.

  loc_00DA03:
    LDA #$FFE2            ; -30: recovery counter, replacing the positive stun counter
    STA $iframeCounter, X
    PLX 
    LDA #$0F00            ; Clear the D-pad bits in the hidden-button mask: usable again
    TRB $joypadMaskStd
    COP [Die]
}

---------------------------------------------
; A = distance travelled. Compares it with the threshold of the victim's tier (0: $30, 1: $20, 2 and above: $40); the RTS lands in CallbackPass, which returns carry CLEAR when equal.

HitStaggerCheckKnockbackDistance {
    STA $0000             ; Distance d in the absolute global scratch word $0000
    PEA $&HitStaggerZeroToCarry-1 ; Return through CallbackPass (turns Z into carry)
    LDA $free101C, X
    BNE loc_00DA26
    LDA $0000
    CMP #$0030            ; Tier 0 threshold $30 (48 px, the tier-0 curve sum)
    RTS 

; Tier 1: threshold $20.

  loc_00DA26:
    DEC 
    BNE loc_00DA30
    LDA $0000
    CMP #$0020            ; Tier 1 threshold $20 (32 px, the tier-1 curve sum)
    RTS 

; Tier 2: threshold $40.

  loc_00DA30:
    DEC 
    BNE loc_00DA3A
    LDA $0000
    CMP #$0040            ; Tier 2 and above: threshold $40 (no actor uses these tiers)
    RTS 

; Tier 3 and above: threshold $40.

  loc_00DA3A:
    LDA $0000
    CMP #$0040
    RTS 
}

---------------------------------------------
; Return trampoline of the distance check: carry CLEAR when the compare was equal, SET otherwise.

HitStaggerZeroToCarry {
    CLC 
    BNE loc_00DA45
    RTS 

; Not equal: carry SET.

  loc_00DA45:
    SEC 
    RTS 
}

---------------------------------------------
; Pushes HitStaggerStoreMovementDelta as the next return address and selects the table offset by tier: $44 (entry $22, 48 px curve) for tier 0, $46 (entry $23, 32 px curve) for every other tier. Carry (from the caller) is preserved for the store.

HitStaggerApplyKnockbackDelta {
    PEA $&HitStaggerStoreMovementDelta-1 ; Pushed return address: the RTS runs HitStaggerStoreMovementDelta
    LDA $free101C, X
    BNE loc_00DA54
    LDY #$0044            ; Tier 0: table offset $44 = entry $22 (48 px curve)
    RTS 

; Tier 1: offset $46.

  loc_00DA54:
    DEC 
    BNE loc_00DA5B
    LDY #$0046            ; Tier 1 and above: offset $46 = entry $23 (32 px curve)
    RTS 

; Tier 2: offset $46.

  loc_00DA5B:
    DEC 
    BNE loc_00DA62
    LDY #$0046
    RTS 

; Tier 3 and above: offset $46.

  loc_00DA62:
    LDY #$0046
    RTS 
}

---------------------------------------------
; Reads the chain head from move_chain_table + Y. Carry set: Y chain in $2E and $26 := 0 (vertical). Carry clear: X chain in $2C and $26 := 1 (horizontal).

HitStaggerStoreMovementDelta {
    LDA $&move_chain_table, Y ; Chain head from move_chain_table; the carry is still the caller's
    BCS loc_00DA73
    STA $2C               ; Carry clear: X chain in $2C, axis flag $26 := 1
    LDA #$0001
    STA $26
    RTS 

; Vertical: store the chain head in $2E and clear the axis flag $26.

  loc_00DA73:
    STA $2E               ; Carry set: Y chain in $2E, axis flag $26 := 0
    STZ $26
    RTS 
}