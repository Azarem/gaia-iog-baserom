; Dark Friar fragment trail follower actors (179702–179826).
; 
; Provides two trail segment actor variants (TrailFollowerSprA sprite #05, TrailFollowerSprB sprite #06) that follow behind Dark Friar fragment projectiles to create a cascading afterimage effect. Both variants share the same loop logic — only their initial sprite/hitbox configuration differs.
; 
; The trail system works via a 3-stage position FIFO buffer stored in per-actor long-address scratch fields ($7F0000–$7F001A,X). Each frame, TrailPositionCascade shifts the parent actor's current position into stage 3 of the queue, while each older position advances one stage forward. The trail actor displays the position from stage 1 (the oldest buffered value), creating a 3-frame position delay.
; 
; X-position FIFO stages (per-actor, indexed by X):
;   Stage 1 (display): animScratch ($7F0000,X) → written to DP $14
;   Stage 2 (1 frame old): animScratch+2 ($7F0002,X) → shifts to stage 1
;   Stage 3 (newest): animScratch2 ($7F000E,X) → shifts to stage 2
;   Input: parent actor X ($0014,Y) → enters stage 3
; 
; Y-position FIFO stages (same structure):
;   Stage 1 (display): moveXAlt ($7F0018,X) → written to DP $16
;   Stage 2: moveYAlt ($7F001A,X) → shifts to stage 1
;   Stage 3: retPtr1 ($7F0004,X) → shifts to stage 2
;   Input: parent actor Y ($0016,Y) → enters stage 3
; 
; TrailPositionInit seeds all 3 stages with the current position so the trail starts co-located with its parent and gradually separates as the parent moves.
; 
; Spawned by DarkFriarFragmentInit in attack_ability_system via SpawnMarkedAfter. Two trail actors are spawned per fragment: SprB (directly behind) and SprA (furthest back).
---------------------------------------------

!animScratch                    7F0000
!retPtr1                        7F0004
!animScratch2                   7F000E
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

TrailFollowerSprA {
    COP [StageSprAndHitbox] ( #05 ) ; Stage sprite #05 with hitbox — smaller trail segment (spawned second, furthest behind parent)
    BRA loc_02BDFE        ; Jump to shared trail follower main loop
}

TrailFollowerSprB {
    COP [StageSprAndHitbox] ( #06 ) ; Stage sprite #06 with hitbox — larger trail segment (spawned first, directly behind parent)

  loc_02BDFE:
    JSR $&TrailPositionInit ; Initialize 3-stage position FIFO buffer with current position

  loc_02BE01:
    COP [AnimOneFrame]    ; Main loop: animate one frame and wait for collision/movement event ($2A)
    LDA $2A
    BEQ loc_02BE01
    LDA $08               ; Capture frame count from $08 — determines how many cascade updates to run this cycle
    STZ $08
    STA $26

  loc_02BE0D:
    COP [SetEntryExit]    ; Per-frame cascade: yield execution, then shift one position through the FIFO
    LDY $04               ; Load parent actor ID from $04 for position sampling
    JSR $&TrailPositionCascade ; Cascade parent position through the 3-stage FIFO buffer
    DEC $26               ; Decrement remaining cascade updates
    BPL loc_02BE0D
    BRA loc_02BE01        ; Loop back to animation wait for next event cycle
}

---------------------------------------------
; 3-stage position FIFO cascade for Dark Friar afterimage effect.
; 
; Each frame, shifts position data through three FIFO stages: stage 2 receives stage 1's position, stage 1 receives stage 0's position, stage 0 receives the current player position. This creates a trailing afterimage effect where follower sprites lag behind the player by 1, 2, and 3 frames respectively.

TrailPositionCascade {
    LDA $animScratch, X   ; Read stage 1 X (oldest buffered position) into display position $14
    STA $14
    LDA $animScratch+2, X ; Shift stage 2 X → stage 1 (advance X queue by one frame)
    STA $animScratch, X
    LDA $animScratch2, X  ; Shift stage 3 X → stage 2
    STA $animScratch+2, X
    LDA $0014, Y          ; Sample parent's current X position ($0014,Y) into stage 3 (newest X entry)
    STA $animScratch2, X
    LDA $moveXAlt, X      ; Read stage 1 Y (oldest buffered position) into display position $16
    STA $16
    LDA $moveYAlt, X      ; Shift stage 2 Y → stage 1 (advance Y queue by one frame)
    STA $moveXAlt, X
    LDA $retPtr1, X       ; Shift stage 3 Y → stage 2
    STA $moveYAlt, X
    LDA $0016, Y          ; Sample parent's current Y position ($0016,Y) into stage 3 (newest Y entry)
    STA $retPtr1, X
    RTS 
}

---------------------------------------------
; Initialize trail follower position FIFO.
; 
; Sets all three FIFO stages to the current player position, so trail followers start at the player's location rather than at (0,0). Called once when the Dark Friar attack begins.

TrailPositionInit {
    LDA $14               ; Seed all 3 X-position FIFO stages with current X ($14) — trail starts co-located
    STA $animScratch, X
    STA $animScratch+2, X
    STA $animScratch2, X
    LDA $16               ; Seed all 3 Y-position FIFO stages with current Y ($16)
    STA $moveXAlt, X
    STA $moveYAlt, X
    STA $retPtr1, X
    RTS 
}