; Invisible large-ramp speed booster (large_ramp_booster, actor-def <#00, #00, #20>). Placed in Incan Ruins room ir21 (1 booster at tile $10,$0B, in scene_event_0C8F57) and in the Diamond Mine minecart room dm41 (2 boosters at $16,$1C and $1B,$0B, in scene_event_0C9A95).
; 
; Control flow. BranchIfPlayerNear radius r is true when the player's |dX| and |dY| are both below r * 16 + 1 pixels, so #02 is a 32-px box and #03 a 48-px box.
; 1. loc_00C966 (also the spawn entry): both playerSpeedEw and playerSpeedNs zero -> RTL and test again next frame. Once either is nonzero: SetEntryHere, then BranchIfPlayerNear #02 -> LargeRampBoostEastWest, else RTL (the entry is now the near-test: the speed gate is not checked again until loc_00C966 is reached later).
; 2. LargeRampBoostEastWest: playerSpeedEw is incremented when it is zero or positive and decremented when negative (a zero EW speed becomes +1, east, even if only the NS speed was nonzero). Then SetEntryHere and BranchIfPlayerNear #03: within 48 px -> LargeRampIdleHold, which is just an RTL; outside -> BRA loc_00C966.
; 3. So the boost happens ONCE per approach: afterwards the entry is the radius-3 test and the actor idles (RTL each frame) until the player is more than 48 px away; only then do the speed gate and the radius-2 test run again. The older header ('increments playerSpeedEw or playerSpeedNs ... each frame') and docs/code/bank00/actors-infrastructure.md ('repeats while player remains near', NS also adjusted) do not match this control flow: playerSpeedNs is only read for the gate and never changed, and LargeRampIdleHold contains no boost (OQ-I040-1).
; 
; UNVERIFIED-RUNTIME: whether another path adds speed on these ramps, and whether a +/-1 step per approach is the intended feel, was not checked.
---------------------------------------------

?BANK 00

!playerSpeedEw                  09B2
!playerSpeedNs                  09B4

---------------------------------------------

; Speed gate at the spawn entry (loc_00C966): wait until the player is moving, then poll the 32-px box around this actor. The first box entry calls LargeRampBoostEastWest. See the block note.

large_ramp_booster [
  actor-def < #00, #00, #20, {

  loc_00C966:
    LDA $playerSpeedEw    ; Speed gate: both player speeds zero = idle (this is also the actor's start)
    ORA $playerSpeedNs
    BNE loc_00C96F
    RTL                   ; Not moving: yield, test again next frame

  loc_00C96F:
    COP [SetEntryHere]    ; From here the entry is the near-test below; the speed gate is not re-run until loc_00C966 is reached again
    COP [BranchIfPlayerNear] ( #02, &LargeRampBoostEastWest ) ; Player within 32 px (square box) -> boost; otherwise fall to the RTL
    RTL 
} >
]

---------------------------------------------
; playerSpeedEw += 1 (zero or positive) or -= 1 (negative), once per approach; then the actor polls the 48-px box (LargeRampIdleHold is an idle RTL) and returns to the speed gate when the player is farther away.

LargeRampBoostEastWest {
    LDA $playerSpeedEw    ; Sign of playerSpeedEw: zero or positive -> INC (east), negative -> DEC
    BMI loc_00C981
    INC $playerSpeedEw    ; +1 (also from 0)
    BRA loc_00C984

  loc_00C981:
    DEC $playerSpeedEw    ; -1

  loc_00C984:
    COP [SetEntryHere]    ; Entry is now the radius-3 test: the boost is not repeated while the player stays within 48 px
    COP [BranchIfPlayerNear] ( #03, &LargeRampIdleHold ) ; Within 48 px: LargeRampIdleHold (just an RTL, idle); outside: fall to the BRA
    BRA loc_00C966        ; More than 48 px away: back to the speed gate (loc_00C966)
}

---------------------------------------------
; One RTL: the idle yield used while the player stays within 48 px after a boost. There is no north-south boost here.

LargeRampIdleHold {
    RTL                   ; No code: idle yield. There is no north-south boost
}