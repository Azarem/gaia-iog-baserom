; One-shot scene actor (Bank 00, 50791–50799) that SETS event flag #00 and dies.
; 
; Its only code is COP SetFlagByte ( #00 ) followed by COP Die. SetFlagByte takes a flag INDEX and sets it: flag #00 is the first bit of the eventFlags bitfield ($0A00); the operand names a bit, not a byte, and the call sets it. scene_lifecycle zeroes the first event-flag word (flags $00–$0F) whenever a scene is set up, so flag #00 starts every scene clear and this actor sets it again on its first tick.
; 
; Placed by tables/scene_actors.asm as actor-spawn < #00, #01, #00, @scene_flag_init > in 26 scene actor lists: slot #02 four times, #03 thirteen times, #04 six times and #14, #1A, #1C once each.
; 
; With the flag set, the player's idle poses use sprite indexes #10-#13 (animation $11 in PlayerIdleAnimLoop) instead of #00-#03 (animation $01), for Will and for Shadow alike, and shadow_shimmer stays in its Active state for the whole scene. Other users of flag #00: scripts that set it on a position or event trigger and, except the set-only btE1_light_elevator and av75_apprentice, clear it again around the event (sc01_fisherman: while playerYPos >= $0250; dm3D_breakable_wall, dm40_trapped_slave, eu9D_altar and av73_waterfall_sound: while the player is inside a tile box; ir1E_cliff_slide_trigger: while playerYPos < $0110, then permanently once $30 and $31 are set; av75_apprentice: when the player enters a tile box; btE1_light_elevator: once, #$00EF ticks into the ride), inventory_menu (sets it on Tab cancel) and inventory_overlay (loops until it is nonzero), and the player's idle / ladder / shimmy-detach sprite choice, player_transition_handlers and shadow_shimmer, all of which test it (measured for the idle poses and the shimmer; the ladder-idle and shimmy-detach variants are not traced). The flag does not follow the character form: Shadow with the flag clear takes the #00-#03 poses and Will with it set takes the #10-#13 ones. The three spritesets (spriteset_will, spriteset_freedan, spriteset_shadow) all carry animations at those indices, so no reader tests characterForm; what the alternate pose depicts is not established.
---------------------------------------------

---------------------------------------------

scene_flag_init [
  actor-def < #00, #00, #10, {

  code_00C66A:
    COP [SetFlagByte] ( #00 ) ; Set event flag index #00 (first bit of eventFlags $0A00); SetFlagByte sets a flag, it does not clear a byte
    COP [Die]             ; One tick only: the actor removes itself
} >
]