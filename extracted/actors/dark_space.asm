; Dark Space portal (Bank 08, 579230-579495): the glowing portal object that leads to the Gaia hub (scene $E6, system/dark_space/sE6_gaia). The actor is only a trigger and an effect: the scene change itself is done by the warp rectangle of the room (a scene-warp row to scene $E6) once the actor has moved the player onto it.
; 
; === PLACEMENT ===
; 
; dark_space2 is spawned by 31 scene spawn rows, dark_space by one (Dao, scene_event_0CD3B2). pyCC_dark_space_portal, ec12_aqueduct_dark_space, gw88_tomb_dark_space and dm40_hidden_dark_space spawn DarkSpacePortalInit directly with $24 already set (1, or 3 in the pyramid when $0E is not $72). The scene spawn byte is odd in all 32 rows (12 x #01, 14 x #03, 6 x #05), so the engine leaves param >> 1 in $0E: variant 0, 1 or 2. The two init stubs move that into $24 and then replace $0E with the OAM attribute word: $3000 (sprite priority 3, Dao only) or $2000 (priority 2). The variant is the Gaia room layout: sE6_gaia accepts 0 to 3 (0 basic, 1 transformation statues, 2 ability, 3 special = layout 1 with the form-dependent logic).
; 
; === PORTAL ANIMATION ===
; 
; DarkSpacePortalInit sets up the sprite (spriteset_enemies frame #24 closed), makes the tile solid (MarkSolidHere), sets Flags12 $0004 (pause-filter immunity), Flags10 $0B00, extendedFlags $0200 (radar dot) and spawns the monitor child. The portal then loops: closed while the player is not near; when the player is within 5 tiles (|dx| and |dy| both < 81 pixels) it plays the opening animation #1F once and holds the open frame #20 while the player stays near; when he leaves, the closing animation #21 plays and it returns to the closed frame.
; 
; === ENTRY (monitor child) ===
; 
; DarkSpaceInteractionMonitor (hidden child, flags $2300, $24 = variant) runs every frame, but not while displayModeFlags bit $0080 (display-filter actor mode) is set. It tests BranchIfPlayerInRelTiles ( -1, 0, 1, 1 ): the player's tile offset from the portal must satisfy -1 < dx <= 1 and 0 < dy <= 1. Then BranchIfPressed $0801 (raw Up) leads to DarkSpaceMonitorStartWarp, which runs in the MONITOR's context (Y = $04 is the portal):
; 1. joypadMaskStd |= $CFFC (every button except Select and Start; the ROM has $CFF0 and db-us/transforms.json widens it, as in the other scripts) and the PLAYER's $10 |= $2000: the player becomes hidden (SortActorsByDepth skips actors with bit $2000; this answers part of OQ-I025-2).
; 2. The monitor's own X/Y := the player's X/Y, SFX $0C on both channels, the monitor's own $2000 cleared (it becomes visible) and animation #1C of spriteset_enemies plays once at the player's spot, then 29 more frames.
; 3. The player's X/Y := the portal's X/Y; playerXPos = X - 8, playerYPos = Y - 16 and the tile words playerXTile/YTile (>> 4). That puts the player one tile north of the portal, which is where the room's E6 warp rectangle lies, so the normal warp check fires.
; 4. gfxCacheIdxB := $0101 (exit and enter speed 1), gfxCacheIdxA := $0200 (exit effect 0 = fade, enter effect 2 = mosaic), layerPriorityFlag |= $0200 (camera frozen / chests off while the warp runs) and globalScriptIndex := the variant for sE6_gaia's layout switch. The monitor then idles (SetEntryHere + RTL).
; 
; === CORRECTIONS ===
; 
; The old header said the handler 'copies the player's position onto the portal' (it copies the portal's position onto the player), that the monitor 'triggers when the player is within 1 tile', that $3000 / $2000 are 'display mode bits' / 'display flags: variant 1 / 2' (they are the sprite priority bits of the OAM attribute word; the variant is the spawn parameter) and that $2000 on the player is a 'frozen flag' (it hides him). The $4000 test in DarkSpacePortalOpen is the off-screen flag and a no-op.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!layerPriorityFlag              06EE
!playerXPos                     09A2
!playerYPos                     09A4
!playerXTile                    09A6
!playerYTile                    09A8
!playerActor                    09AA
!displayModeFlags               09EC
!globalScriptIndex              0AAC

---------------------------------------------

; Dao variant of the portal (one spawn, scene_event_0CD3B2): saves the spawn variant and uses the OAM attribute word $3000 (sprite priority 3). The stub then branches into DarkSpacePortalInit.

dark_space [
  actor-def < #24, #00, #0B, {

; dark_space entry stub: $24 := $0E (spawn parameter >> 1 = Gaia room variant 0 to 2), $0E := $3000 (OAM attribute word, priority 3), then BRA DarkSpacePortalInit.

  DarkSpaceDaoEntry:
    LDA $0E               ; $0E = spawn parameter >> 1 (0, 1 or 2): the Gaia room variant
    STA $24
    LDA #$3000            ; OAM attribute word: sprite priority 3 (Dao)
    STA $0E
    BRA DarkSpacePortalInit
} >
]

---------------------------------------------
; Standard portal (31 spawns): same as dark_space with the OAM attribute word $2000 (sprite priority 2). It has no branch: execution falls through into DarkSpacePortalInit.

dark_space2 [
  actor-def < #24, #00, #0B, {

; dark_space2 entry stub: $24 := $0E (spawn parameter >> 1), $0E := $2000, then falls through into DarkSpacePortalInit.

  DarkSpaceStandardEntry:
    LDA $0E               ; $0E = spawn parameter >> 1 (0, 1 or 2)
    STA $24
    LDA #$2000            ; OAM attribute word: sprite priority 2
    STA $0E
} >
]

---------------------------------------------
; Common init of both variants and of the four direct spawners (which set $24 first). Sets Flags12 $0004, the metasprite and the closed frame #24, makes the tile solid, clears the hidden bit $2000, sets Flags10 $0B00 and extendedFlags $0200 (radar dot) and spawns DarkSpaceInteractionMonitor (flags $2300), giving it the variant in its $24. Then runs the closed-state loop.

DarkSpacePortalInit {
    LDA #$0004            ; Flags12 $0004: pause-filter immunity (RunActors_PauseFiltered tests $1004)
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSprAndHitbox] ( #24 ) ; Portal closed frame
    COP [MarkSolidHere]   ; Block player from walking through
    LDA #$2000            ; Clear $2000 (hidden) so the portal is drawn
    TRB $10
    LDA #$0B00            ; Flags10 $0B00 (bits $0800, $0200, $0100; meaning not traced)
    TSB $10
    COP [OrExtraFlags] ( #$0200 ) ; extendedFlags $0200: radar dot (OQ-63)
    COP [SpawnAfterFlags] ( @DarkSpaceInteractionMonitor, #$2300 ) ; Monitor child: flags $2300 = hidden ($2000) + $0300; Y = child
    LDA $24               ; Variant (0 to 3) for the monitor
    STA $0024, Y

; Closed state: stage the closed frame #24 (also the target when the portal has finished closing).

  DarkSpacePortalClosed:
    COP [StageSprAndHitbox] ( #24 ) ; Portal closed frame

; Closed loop: one frame per pass while the player is not within 5 tiles; BranchIfPlayerNear ( #05 ) leaves to DarkSpacePortalOpen.

  DarkSpacePortalClosedLoop:
    COP [BranchIfPlayerNear] ( #05, &DarkSpacePortalOpen ) ; |dx| and |dy| both < 81 px (5 tiles): open
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [SetEntryHereAndYield]
    BRA DarkSpacePortalClosedLoop
}

---------------------------------------------
; Player came near: play the opening animation #1F once (AnimOnce), then show the open frame #20 and enter the open loop. The first test (Flags10 bit $4000, the off-screen flag) branches to the very next instruction, so it has no effect.

DarkSpacePortalOpen {
    LDA $10
    BIT #$4000            ; Off-screen flag; the BNE goes to the next instruction, so this test is a no-op
    BNE DarkSpacePortalOpenAnim

; Opening animation #1F (AnimOnce), then the open frame #20; continues into the open loop at DarkSpacePortalOpenLoop.

  DarkSpacePortalOpenAnim:
    COP [StageSpriteFrame] ( #1F ) ; Opening animation
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #20 ) ; Portal open frame

; Open loop test: still within 5 tiles continues in DarkSpacePortalOpenIdle, otherwise falls through to the closing animation (DarkSpacePortalClose). The opening animation is not interrupted: the test runs only after AnimOnce has ended.

  DarkSpacePortalOpenLoop:
    COP [BranchIfPlayerNear] ( #05, &DarkSpacePortalOpenIdle ) ; Within 5 tiles: keep the portal open
    BRA DarkSpacePortalClose ; Player left — close
}

---------------------------------------------
; Open idle loop: one frame per pass, then back to the proximity test at DarkSpacePortalOpenLoop.

DarkSpacePortalOpenIdle {
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [SetEntryHereAndYield]
    BRA DarkSpacePortalOpenLoop

; Player left: closing animation #21 once, then back to the closed frame (DarkSpacePortalClosed).

  DarkSpacePortalClose:
    COP [StageSpriteFrame] ( #21 ) ; Closing animation
    COP [AnimOnce]
    BRA DarkSpacePortalClosed ; Return to closed state
}

---------------------------------------------
; Hidden child (flags $2300) that watches for the entry. SetEntryHere is placed before two NOPs, so every frame it restarts at the NOPs. Does nothing while displayModeFlags bit $0080 (display-filter actor mode) is set; otherwise tests the player's tile offset from the portal and calls DarkSpaceButtonCheck when he is on the entry tiles.

DarkSpaceInteractionMonitor {
    COP [SetEntryHere]
    NOP 
    NOP 
    LDA $displayModeFlags ; displayModeFlags $0080 = display-filter actor mode (dialogue, chest, reward): wait
    BIT #$0080
    BEQ DarkSpaceMonitorEntryTest
    RTL 

; Entry test: BranchIfPlayerInRelTiles ( minX -1, minY 0, maxX 1, maxY 1 ): the player is inside when -1 < dx <= 1 and 0 < dy <= 1 tiles relative to the portal; the branch goes to DarkSpaceButtonCheck.

  DarkSpaceMonitorEntryTest:
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #01, &DarkSpaceButtonCheck ) ; -1 < dx <= 1 and 0 < dy <= 1 tiles from the portal
    RTL 
}

---------------------------------------------
; Needs Up ($0800) in the raw joypad word (BranchIfPressed with mask bit 0 set reads joypadRaw) to start the warp.

DarkSpaceButtonCheck {
    COP [BranchIfPressed] ( #$0801, &DarkSpaceMonitorStartWarp ) ; Raw Up ($0800; mask bit 0 selects joypadRaw)
    RTL 
}

---------------------------------------------
; Entry sequence, run by the monitor (see the block note): mask the joypad, hide the player, play animation #1C (the warp effect) at the player's spot and wait 30 ticks (WaitByte #1D) after it ends, snap the player onto the portal (one tile north in the warp-test position), set the transition words, layerPriorityFlag $0200 and the variant in globalScriptIndex. The scene change itself comes from the E6 warp rectangle. It never restores the mask or the player's hidden bit: the scene change resets them.

DarkSpaceMonitorStartWarp {
    LDA #$CFFC            ; Mask every button except Select and Start
    TSB $joypadMaskStd
    PHX 
    LDX $playerActor
    LDA $0010, X          ; Player $10 |= $2000: hides the player sprite
    ORA #$2000
    STA $0010, X
    LDA $0014, X          ; Monitor X/Y := player X/Y: the warp effect plays on the player
    STA $14
    LDA $0016, X
    STA $16
    PLX 
    COP [PlaySoundBoth] ( #$0C0C ) ; Warp sound effect
    LDA #$2000            ; Monitor's own $10: clear hidden ($2000), the effect becomes visible
    TRB $10
    COP [StageSpriteFrame] ( #1C ) ; Animation #1C of spriteset_enemies (also played by GameOverSequence)
    COP [AnimOnce]
    COP [WaitByte] ( #1D ) ; WaitByte #1D = 30 ticks after the animation list has ended
    PHX 
    LDX $playerActor
    LDY $04               ; Y = the monitor's $04 prev-link = the portal
    LDA $0014, Y          ; Copy portal X → player X
    STA $0014, X
    SEC 
    SBC #$0008            ; playerXPos = pixel X - 8
    STA $playerXPos
    LSR                   ; Convert to tile coords (÷16)
    LSR 
    LSR 
    LSR 
    STA $playerXTile
    LDA $0016, Y          ; Copy portal Y → player Y
    STA $0016, X
    SEC 
    SBC #$0010            ; playerYPos = pixel Y - 16
    STA $playerYPos
    LSR                   ; Convert to tile coords (÷16)
    LSR 
    LSR 
    LSR 
    STA $playerYTile
    PLX 
    LDA #$0101            ; gfxCacheIdxB $0101: exit and enter speed 1
    STA $gfxCacheIdxB
    LDA #$0200            ; gfxCacheIdxA $0200: exit effect 0 (fade), enter effect 2 (mosaic)
    STA $gfxCacheIdxA
    LDA #$0200            ; layerPriorityFlag bit $0200: camera frozen / chests off during the warp
    TSB $layerPriorityFlag
    LDA $24               ; Variant (0 to 3) for the sE6_gaia layout switch
    STA $globalScriptIndex
    COP [SetEntryHere]    ; Idle for the rest of the scene visit; the warp rectangle takes over
    RTL 
}