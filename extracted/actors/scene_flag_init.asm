; One-shot scene actor (Bank 00, 50791–50799) that SETS event flag #00 and dies.
; 
; Its only code is COP SetFlagByte ( #00 ) followed by COP Die. SetFlagByte takes a flag INDEX and sets it: flag #00 is the first bit of the eventFlags bitfield ($0A00); the earlier note's 'clear event flag byte zero' is wrong on both counts (it sets, and it names a bit, not a byte). scene_lifecycle zeroes the first event-flag word (flags $00–$0F) whenever a scene is set up, so flag #00 starts every scene clear and this actor sets it again on its first tick.
; 
; Placed by tables/scene_actors.asm as actor-spawn < #00, #01, #00, @scene_flag_init > in 26 scene actor lists: slot #02 four times, #03 thirteen times, #04 six times and #14, #1A, #1C once each (the earlier note said slot #03 or #04 only).
; 
; What the set flag means is open (OQ-I030-1). Other users of flag #00: scripts that set and clear it around events (dm3D_breakable_wall, ir1E_cliff_slide_trigger, eu9D_altar, dm40_trapped_slave, av73_waterfall_sound, sc01_fisherman, and set-only in btE1_light_elevator and av75_apprentice), inventory_menu (sets it on Tab cancel) and inventory_overlay (loops until it is nonzero), and the player's idle / ladder / shimmy-detach sprite choice, player_transition_handlers and shadow_shimmer, whose comments call it the Shadow flag. The unconditional set in these 26 scenes does not fit a Shadow-form flag.
---------------------------------------------

---------------------------------------------

scene_flag_init [
  actor-def < #00, #00, #10, {

  code_00C66A:
    COP [SetFlagByte] ( #00 ) ; Set event flag index #00 (first bit of eventFlags $0A00); SetFlagByte sets a flag, it does not clear a byte
    COP [Die]             ; One tick only: the actor removes itself
} >
]