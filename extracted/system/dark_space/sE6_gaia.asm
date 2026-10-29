; Dark Space / Gaia hub (scene $E6, the room reached from the Dark Space portals and from the diary menu's load) plus a shared character-transformation library (Bank 08, 579499-587528; GaiaNpcSprite and GaiaVoiceSparkle in Bank 09, 630928-630997). The same spawn list is also used by scene $09, which has no scene-meta entry. scene_meta_00E6 loads spm_darkspace_sprites ($0579 bytes) and plays track $16 (bgm_space_beyond_time).
; 
; === STRUCTURE ===
; 
; DarkSpaceMainInit spawns three children with SpawnAfter: FireflySpawnerLoop, GaiaNpcSprite and GaiaVoiceSparkle. SpawnAfter inserts each new actor right after the parent, so the main actor's $06 link ends up on the LAST one spawned, the voice sparkle (the old notes called it the Gaia NPC link). Every 'LDY $06 / STA $0024, Y' below is therefore the voice sparkle's on / off switch ($FFFF = on, 0 = off), not an NPC interaction lock.
; It then validates globalScriptIndex ($0AAC: the room variant, written by the portal actor or restored by the diary load; 4 or more becomes 0), keeps it in $0AB2 (saved with the game, restored by the diary menu), clears $0AAC and switch-cases to a layout: 0 DS_LayoutBasic (Gaia only), 1 DS_LayoutTransform (statues chosen by characterForm), 2 DS_LayoutAbility (ability orb chosen by the scene), 3 DS_LayoutSpecial (sets $0AAC = 1 and runs layout 1; this is the pyramid's Dark Space, where GaiaHint_AuraItem tests $0AAC and gives the Aura item).
; Every room polls BranchIfPlayerInAbsTiles zones (x1, y1, x2, y2 in tiles): Gaia (7,8)-(9,9) = GaiaDialogueEntry, left statue (3,A)-(5,B), right statue (B,A)-(D,B), exit (5,D)-(B,F) = DarkSpaceExit. Each room has a wait state (the player is still standing in a zone: nothing happens, so a dialogue cannot retrigger) and an active state that dispatches the zones; the *Wait / *TileWait pairs and the loc_ labels after them are these two states.
; The called scripts (GaiaDialogueEntry, the *TransformDialogue routines) are entered with CallNear and end with RestoreSavedPtr, which returns to the room loop.
; 
; === EXIT ===
; 
; DarkSpaceExit masks the joypad, hides the player ($10 |= $2000), puts this actor on him, plays SFX $0C on both channels and the dissolve animation $1C of spriteset_pickups_effects once, waits 30 ticks (WaitByte #1D), then fills the warp words: sceneNext = $0B12 (the scene the player warped from, saved by ExecuteWarp), player spawn X = $0B08 x 16 and Y = ($0B0C + 2) x 16 (the source warp rectangle's tile position), facing 3 and the packed camera window $0B10 / $0B11 -> warpScrollParams. gfxCacheIdxB = $0101 is the transition speed (exit and enter 1), gfxCacheIdxA = $0002 is exit effect 2 = mosaic, enter effect 0 = fade. The old notes called the destination a camera position and $0101 a brightness fade.
; 
; === GAIA DIALOGUE ===
; 
; GaiaDialogueEntry: 6-tick pause (WaitByte #05), voice sparkle on, first visit (event flag $DC) the intro text, then GaiaHealAndHints. If HP < max it prints the 'hurt' text and writes hpToHeal = 40; UpdateHUD turns that request into +1 HP every 8 frames (SFX $0D) until HP = max (the loop yields until then). The hint is chosen by the position of the source scene in GaiaHintSceneTable (34 scenes, one GaiaHint_xx handler each; 21 of them have no text and go straight to the save prompt). GaiaSavePrompt: 'Record what's happened so far?' (DialogueOptions: entry 0 = cancel, 1 = first option, 2 = second option). Record = SaveGameState_Scene for the active slot ($0D8C), SFX $29, 60 ticks (WaitByte #3B), then 'Continue your journey?': Yes (entry 1) = GaiaThenGo, 'Then go.', returns to the room; No (entry 2) = GaiaThenRest, 'Then rest a while.', fades to track $0E (bgm_longing_for_the_past) and the actor yields forever. GaiaThenGo and GaiaThenRest are named after the answers 'Then go.' and 'Then rest a while.'; each is reached from two prompts (they were first called GaiaDontRecord and GaiaContinueJourney after the first prompt only, which made them look swapped for the second).
; 
; === FORMS AND ABILITIES ===
; 
; characterForm ($0AD4): 0 Will, 1 Freedan, 2 Shadow. A statue dialogue writes a Transform_* routine into the player actor's entry pointer ($0000 / $0002, $0008 = 0) and sets playerFlags $0800; the player then plays it (player body entry #05, the transformation frames), the routine sets characterForm and DarkSpaceRestoreControl clears $0800 and sends the player back to PlayerIdleEntry. The Shadow statue needs event flag $B4, whose only writer is daC8_neil (the Neil reunion in the Dao dormitory; the old header said it is unlocked at Ankor Wat); first Freedan visit flag $F7, first Shadow visit flag $DD.
; The Transform_* routines are a shared library: Transform_WillToShadow is entered from sE5_epilogue, pyDD_mummy_queen, gw8A_sand_fanger, mu67_vampires, sg55_viper, ir29_castoth and btE4_kara; Transform_ShadowToWill from pyDD_mummy_queen, gw8A_sand_fanger, mu67_vampires, sg55_viper, ir29_castoth and pyCD_jackal; Transform_FreedanToWill from sg55_mystic_statue, ir29_transform, ir1C_lily, ec13_lily, pyCD_jackal and mu67_bomb (13 files in all).
; AbilitySceneTable has 6 entries of (scene, abilityBitmask bit): $15 Psycho Dash $01, $62 Psycho Slider $02, $86 Spin Dash $04, $42 Dark Friar $10, $A7 Aura Barrier $20, $B8 Earthquaker $40, ended by $00. The low nibble holds the Will abilities, the high nibble the Freedan abilities; the old header called byte 1 'ability index + statue type'. The table position is the ability index used by table_08EB8F (names) and table_08EBD3 (descriptions) through globalScriptIndex. DS_LayoutAbility shows the orb for the current scene (BG change $86 and orb at (64,109) for a Will ability, $8B and (64,84) for a Freedan ability); AbilityOrbActor dies when the bit is already in abilityBitmask, otherwise waits for the player at the statue zone, turns him into the form that can use it (Will for the low nibble, Freedan for the high nibble) with LookupAbilityForm, ORs the bit in, plays the orb flight, fanfare (track $18) and the two texts.
; 
; === SPRITES (spm_darkspace_sprites) ===
; 
; Animation #00 (4 frames, hold $63 then $0C x 3) is GaiaNpcSprite; #01 to #03 are the three sparkle variants of GaiaVoiceSparkle; #0A (32 frames of hold 0, a 16 x 16 spark alternating with an 8 x 8 tile) is the ability orb. #04 to #09 are not selected by this file (#04 to #06 are 8 x 8 effect tiles, #07 to #09 a 32 x 32 figure of 16 x 16 parts); the spm_darkspace_sprites block note lists all eleven animations. FireflyParticle and DarkSpaceExit use spriteset_pickups_effects.
; 
; === NOT REFERENCED ===
; 
; No reference was found in extracted/ for: DS_AuraItemRoom and its handlers, AuraItemInteraction and its helpers (with dialogstring_08EFEF / 08F003 / 08F060), DarkSpaceAmbientParticle, the code at loc_08DA6B / loc_08DA77 (after an unconditional BRA), and the unused hint strings dialogstring_08DEC6, 08E066, 08E0C7, 08E109, 08E19C, 08E261, 08E2B9 and 08E615.
; 
; === CORRECTIONS ===
; 
; Replaced claims: byte 1 of AbilitySceneTable is an ability bit, not an index with a statue nibble; the continue prompt's Yes / No were described the other way round; $06 is the voice sparkle, not the Gaia NPC, and $24 is its voice switch; 'Unmask D-pad and face buttons' ($0F00) is the D-pad only; hpToHeal 40 is a heal request (not 'damage flash ticks'); warpDestX / warpDestY and the $0B08-$0B12 values are the player's spawn position and source scene, not a camera; GaiaNpcSprite loops an idle animation (it is not a single frame); the Shadow flag $B4 is set by Neil, not at Ankor Wat; 'spriteset #05 (transformation frames)' is player body entry #05 and the 'transformation spriteset' of the exit effect is spriteset_pickups_effects; Transform_ShadowToFreedan uses SetEntryHereAndYield, not SetEntryExit.
---------------------------------------------

?INCLUDE 'actor_pool'
?INCLUDE 'player_character'
?INCLUDE 'save_system'
?INCLUDE 'shadow_shimmer'
?INCLUDE 'spriteset_pickups_effects'

!sceneNext                      0642
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!warpDestX                      064C
!warpDestY                      064E
!warpFacing                     0650
!warpScrollParams               0652
!joypadMaskStd                  065A
!sfxQueueCh1                    06F8
!playerActor                    09AA
!playerFlags                    09AE
!displayModeFlags               09EC
!abilityBitmask                 0AA2
!globalScriptIndex              0AAC
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!sourceSceneId                  0B12
!hpToHeal                       0B22
!APUIO1                         2141
!orbitAngle                     7F0010
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sE6_gaia [
  actor-def < #00, #00, #23, {

; Entry. Spawns the firefly spawner, the Gaia sprite (128, 64) and the voice sparkle (128, 88), validates the room variant in $0AAC (0 to 3, else 0), keeps it in $0AB2, clears $0AAC and switch-cases to the layout.

  DarkSpaceMainInit:
    COP [SpawnAfterFlags] ( @FireflySpawnerLoop, #$2800 ) ; Firefly particle spawner
    COP [SpawnAfterAbsFlags] ( @GaiaNpcSprite, #$0080, #$0040, #$1800 ) ; Gaia NPC sprite at (128,64)
    COP [SpawnAfterAbsFlags] ( @GaiaVoiceSparkle, #$0080, #$0058, #$1800 ) ; Voice sparkle at (128, 88); its $24 switch starts at 0
    LDA $globalScriptIndex ; Dark Space layout variant
    CMP #$0004            ; Cap at 3 (valid range 0–3)
    BCC loc_08D7D3
    LDA #$0000            ; Invalid → default to layout 0

; The variant is valid or was forced to 0: store it in $0AB2 and clear $0AAC; the variant also goes to $0000 for the SwitchCase.

  loc_08D7D3:
    STA $0AB2             ; $0AB2 keeps the room variant (saved with the game, restored by the diary load)
    STZ $globalScriptIndex ; Clear $0AAC (GaiaHint_AuraItem tests it later; layout 3 sets it to 1)
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08D7E2 ) ; Dispatch to room layout handler
} >
]

---------------------------------------------
; Layout jump table by variant: 0 DS_LayoutBasic, 1 DS_LayoutTransform, 2 DS_LayoutAbility, 3 DS_LayoutSpecial.

code_list_08D7E2 [
  &DS_LayoutBasic   ;00
  &DS_LayoutTransform   ;01
  &DS_LayoutAbility   ;02
  &DS_LayoutSpecial   ;03
]
---------------------------------------------

; Leaves the Dark Space: masks input, hides the player, plays the dissolve at his spot, waits 30 ticks (WaitByte #1D) and fills the warp words from $0B12 / $0B08 / $0B0C / $0B10 (see the block note). The scene change itself is done by the warp words and the next frame's transition.

DarkSpaceExit {
    LDA #$FFFC            ; Mask all joypad input
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0010, Y          ; Hide player sprite (bit 13)
    ORA #$2000
    STA $0010, Y
    LDA $0014, Y          ; Copy player position to this actor
    STA $14
    LDA $0016, Y
    STA $16
    COP [PlaySoundBoth] ( #$0C0C ) ; Dissolve SFX on both channels
    LDA #$2000            ; Show this actor's sprite
    TRB $10
    COP [SetMetasprite] ( @spriteset_pickups_effects ) ; Enemy spriteset: animation $1C is the dissolve effect (the portal uses it too)
    COP [StageSpriteFrame] ( #1C ) ; Exit dissolve frame
    COP [AnimOnce]
    COP [WaitByte] ( #1D ) ; WaitByte #1D = 30 ticks for the dissolve
    LDA $sourceSceneId    ; Return scene ID
    STA $sceneNext
    LDA $0B08             ; Source warp rectangle X (tile), saved by ExecuteWarp
    ASL                   ; ×16: tile → pixel
    ASL 
    ASL 
    ASL 
    STA $warpDestX        ; Player spawn X in the return scene = tile X x 16
    LDA $0B0C             ; Source warp rectangle Y (tile), saved by ExecuteWarp
    INC                   ; +2 tile offset
    INC 
    ASL                   ; ×16: tile → pixel
    ASL 
    ASL 
    ASL 
    STA $warpDestY        ; Player spawn Y in the return scene
    LDA #$0003            ; Player facing 3 on arrival
    STA $warpFacing
    LDA $0B10             ; Packed camera window saved by ExecuteWarp ($0B10 / $0B11)
    STA $warpScrollParams
    STZ $globalScriptIndex ; Reset selection state
    LDA #$0101            ; Transition speed 1 for exit and enter
    STA $gfxCacheIdxB
    LDA #$0002            ; Exit effect 2 = mosaic, enter effect 0 = fade
    STA $gfxCacheIdxA
    COP [SetEntryHere]
    RTL 
}

---------------------------------------------
; Layout 0: Gaia statue only. Waits while the player stands on the Gaia zone, then handles the Gaia and exit zones.

DS_LayoutBasic {
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_BasicWait ) ; At Gaia statue → wait
    BRA loc_08D863
}

---------------------------------------------
; Wait state of layout 0 (RTL, re-run every frame) followed by loc_08D863, the active state: Gaia zone = DS_BasicTalkGaia, exit zone = DarkSpaceExit.

DS_BasicWait {
    RTL 

; Active state of layout 0 (SetEntryHere + zone tests).

  loc_08D863:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_BasicTalkGaia ) ; At statue → talk to Gaia
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit ) ; At exit → leave Dark Space
    RTL 
}

---------------------------------------------
; Calls GaiaDialogueEntry, then goes back to the wait state.

DS_BasicTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry )
    BRA DS_LayoutBasic
}

---------------------------------------------
; Layout 1 (and 3): switch-case on characterForm to the room of the current form.

DS_LayoutTransform {
    LDA $characterForm    ; Current character form
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08D888 ) ; Dispatch by form
}

---------------------------------------------
; Room jump table by characterForm: 0 DS_WillTransformRoom, 1 DS_FreedanTransformRoom, 2 DS_ShadowTransformRoom.

code_list_08D888 [
  &DS_WillTransformRoom   ;00
  &DS_FreedanTransformRoom   ;01
  &DS_ShadowTransformRoom   ;02
]

---------------------------------------------
; Room for Will: BG changes $88 and $8A, plus $8E and $8F when event flag $B4 is set (the Shadow statue). Zones: Gaia (7,8)-(9,9), left statue (3,A)-(5,B) = Freedan, right statue (B,A)-(D,B) = Shadow, exit (5,D)-(B,F). What the BG changes draw was not decoded (OQ-I056-3).

DS_WillTransformRoom {
    COP [StageBgChange] ( #88 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [BranchOnFlagByte] ( #B4, #00, &DS_WillInputWait )
    COP [StageBgChange] ( #8E )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]
}

---------------------------------------------
; Wait state of the Will room: nothing happens while the player stands in any of the three zones.

DS_WillInputWait {
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_WillTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_WillTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_WillTileWait )
    BRA loc_08D8C5
}

---------------------------------------------
; Yield (RTL) of the Will wait state, followed by loc_08D8C5 (active state).

DS_WillTileWait {
    RTL 

; Active state of the Will room: Gaia = DS_WillTalkGaia, left statue = DS_WillToFreedan, right statue = DS_WillToShadow, exit = DarkSpaceExit.

  loc_08D8C5:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_WillTalkGaia )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_WillToFreedan )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_WillToShadow )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit )
    RTL 
}

---------------------------------------------
; Gaia dialogue, then back to the wait state.

DS_WillTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry ) ; Gaia statue → dialogue
    BRA DS_WillInputWait
}

---------------------------------------------
; Left statue: FreedanTransformDialogue, then back to the wait state.

DS_WillToFreedan {
    COP [CallNear] ( &FreedanTransformDialogue ) ; Left statue → Freedan transform
    BRA DS_WillInputWait
}

---------------------------------------------
; Right statue: ShadowTransformDialogue, then back to the wait state.

DS_WillToShadow {
    COP [CallNear] ( &ShadowTransformDialogue ) ; Right statue → Shadow transform
    BRA DS_WillInputWait
}

---------------------------------------------
; Room for Freedan: BG changes $87 and $8A, plus $8E and $8F when event flag $B4 is set. Left statue = back to Will, right statue = Shadow.

DS_FreedanTransformRoom {
    COP [StageBgChange] ( #87 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [BranchOnFlagByte] ( #B4, #00, &DS_FreedanInputWait )
    COP [StageBgChange] ( #8E )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]
}

---------------------------------------------
; Wait state of the Freedan room.

DS_FreedanInputWait {
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_FreedanTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_FreedanTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_FreedanTileWait )
    BRA loc_08D931
}

---------------------------------------------
; Yield of the Freedan wait state, followed by loc_08D931 (active state).

DS_FreedanTileWait {
    RTL 

; Active state of the Freedan room: Gaia, left statue = WillRevertDialogue, right statue = ShadowTransformDialogue, exit.

  loc_08D931:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_FreedanTalkGaia )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_FreedanRevertWill )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_FreedanToShadow )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit )
    RTL 
}

---------------------------------------------
; Gaia dialogue, then back to the wait state.

DS_FreedanTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry ) ; Gaia statue → dialogue
    BRA DS_FreedanInputWait
}

---------------------------------------------
; Left statue: WillRevertDialogue, then back to the wait state.

DS_FreedanRevertWill {
    COP [CallNear] ( &WillRevertDialogue ) ; Left statue → revert to Will
    BRA DS_FreedanInputWait
}

---------------------------------------------
; Right statue: ShadowTransformDialogue, then back to the wait state.

DS_FreedanToShadow {
    COP [CallNear] ( &ShadowTransformDialogue ) ; Right statue → Shadow transform
    BRA DS_FreedanInputWait
}

---------------------------------------------
; Room for Shadow: BG changes $87, $8A, $8D and $8F unconditionally (flag $B4 is necessarily set). Left statue = back to Will, right statue = Freedan. The wait and active states are loc_08D97A and loc_08D997 (the room label itself is the set-up).

DS_ShadowTransformRoom {
    COP [StageBgChange] ( #87 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8D )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]

; Wait state of the Shadow room (the loop target of every Shadow handler).

  loc_08D97A:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_ShadowTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_ShadowTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_ShadowTileWait )
    BRA loc_08D997
}

---------------------------------------------
; Yield of the Shadow wait state, followed by loc_08D997 (active state).

DS_ShadowTileWait {
    RTL 

; Active state of the Shadow room: Gaia, left statue = WillRevertDialogue, right statue = FreedanTransformDialogue, exit.

  loc_08D997:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_ShadowTalkGaia )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_ShadowRevertWill )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_ShadowToFreedan )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit )
    RTL 
}

---------------------------------------------
; Gaia dialogue, then back to the wait state.

DS_ShadowTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry )
    BRA loc_08D97A
}

---------------------------------------------
; Left statue: WillRevertDialogue, then back to the wait state.

DS_ShadowRevertWill {
    COP [CallNear] ( &WillRevertDialogue )
    BRA loc_08D97A
}

---------------------------------------------
; Right statue: FreedanTransformDialogue, then back to the wait state.

DS_ShadowToFreedan {
    COP [CallNear] ( &FreedanTransformDialogue )
    BRA loc_08D97A
}

---------------------------------------------
; Layout 2: BG change $8A, then a search of AbilitySceneTable for $0B12. Found: a Will ability (low nibble) shows BG $86 and spawns AbilityOrbActor at (64,109) with orbitAngle = 0; a Freedan ability shows BG $8B and the orb at (64,84) with orbitAngle = 1. Not found: no orb. Then the Gaia and exit zones.

DS_LayoutAbility {
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    PHX 
    LDX #$0000

; Table search loop: 2-byte entries, X steps by 2, a zero scene byte ends the table.

  loc_08D9D5:
    LDA $@AbilitySceneTable, X ; Search scene→ability table
    BEQ loc_08DA44        ; End of table → no ability for this scene
    AND #$00FF
    CMP $sourceSceneId    ; Match current scene ID?
    BEQ loc_08D9E7
    INX 
    INX 
    BRA loc_08D9D5

; Scene found: read the ability bit, restore X (PLX) and branch on the low nibble.

  loc_08D9E7:
    LDA $@AbilitySceneTable+1, X ; Read ability/statue flags
    AND #$00FF
    PLX 
    AND #$000F            ; Low nibble = Will ability bits ($01 / $02 / $04)
    BEQ loc_08DA1C        ; No Will bit = Freedan ability: the other room set-up
    COP [StageBgChange] ( #86 ) ; Will ability room: BG change $86
    COP [ApplyBgChange]
    LDA #$0000            ; orbitAngle = 0: Will ability (read only by the unreachable loc_08DA6B)
    STA $orbitAngle, X
    COP [SpawnListAppend] ( @AbilityOrbActor, #00, #00, #$3800 ) ; Spawn ability orb actor
    LDA #$0040            ; Orb X position (64px)
    STA $0014, Y
    LDA #$006D            ; Orb Y position (109px)
    STA $0016, Y
    LDA $06               ; Orb $26 = the voice sparkle (this actor's $06 = the last child spawned)
    STA $0026, Y
    BRA loc_08DA45

; Freedan-ability branch: BG $8B, orb at (64,84), orbitAngle = 1.

  loc_08DA1C:
    COP [StageBgChange] ( #8B ) ; Freedan ability room: BG change $8B
    COP [ApplyBgChange]
    LDA #$0001            ; orbitAngle = 1: Freedan ability
    STA $orbitAngle, X
    COP [SpawnListAppend] ( @AbilityOrbActor, #00, #00, #$3800 ) ; Spawn ability orb actor
    LDA #$0040            ; Orb X position (64px)
    STA $0014, Y
    LDA #$0054            ; Orb Y position (84px)
    STA $0016, Y
    LDA $06               ; Orb $26 = the voice sparkle (this actor's $06 = the last child spawned)
    STA $0026, Y
    BRA loc_08DA45

; Scene not in the table: restore X and continue without an orb.

  loc_08DA44:
    PLX 

; Wait state of the ability room (SetEntryHere, zone test).

  loc_08DA45:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_AbilityTileWait )
    BRA loc_08DA52
}

---------------------------------------------
; Yield of the ability wait state, followed by loc_08DA52 (active state).

DS_AbilityTileWait {
    RTL 

; Active state of the ability room: Gaia = DS_AbilityTalkGaia, exit = DarkSpaceExit. The statue zone belongs to the orb actor.

  loc_08DA52:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_AbilityTalkGaia )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit )
    RTL 
}

---------------------------------------------
; Gaia dialogue and back to the wait state. The code after its BRA (loc_08DA6B, loc_08DA77) is not reachable.

DS_AbilityTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry )
    BRA loc_08DA45

; Not referenced: would call WillRevertDialogue or FreedanTransformDialogue by orbitAngle (a statue interaction that moved into AbilityOrbActor).

  loc_08DA6B:
    LDA $orbitAngle, X
    BNE loc_08DA77
    COP [CallNear] ( &WillRevertDialogue )
    BRA loc_08DA45

; Not referenced: the FreedanTransformDialogue half of loc_08DA6B.

  loc_08DA77:
    COP [CallNear] ( &FreedanTransformDialogue )
    BRA loc_08DA45
}

---------------------------------------------
; Layout 3: sets $0AAC = 1 and jumps to layout 1. The flag survives (the init cleared it before the dispatch), so GaiaHint_AuraItem later sees a non-zero value.

DS_LayoutSpecial {
    LDA #$0001            ; Force selection state to 1
    STA $globalScriptIndex
    JMP $&DS_LayoutTransform ; Redirect to form-dependent layout
}

---------------------------------------------
; Not referenced: alternate room with BG changes $8B, $8F, $89, $8A and an AuraItemInteraction actor at ($C0, $78); zones Gaia, left statue (to Shadow) and exit. Layout 3 reaches the Aura item through GaiaHint_AuraItem instead.

DS_AuraItemRoom {
    COP [StageBgChange] ( #8B )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #89 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [SpawnListAppend] ( @AuraItemInteraction, #00, #00, #$3800 )
    LDA #$00C0
    STA $0014, Y
    LDA #$0078
    STA $0016, Y
    LDA $06
    STA $0026, Y

; Wait state of the unreferenced Aura room.

  loc_08DAB4:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_AuraTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_AuraTileWait )
    BRA loc_08DAC9
}

---------------------------------------------
; Yield of the Aura wait state, followed by loc_08DAC9.

DS_AuraTileWait {
    RTL 

; Active state of the unreferenced Aura room.

  loc_08DAC9:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_AuraTalkGaia )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_AuraToShadow )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit )
    RTL 
}

---------------------------------------------
; Gaia dialogue (unreferenced room).

DS_AuraTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry )
    BRA loc_08DAB4
}

---------------------------------------------
; ShadowTransformDialogue (unreferenced room).

DS_AuraToShadow {
    COP [CallNear] ( &ShadowTransformDialogue )
    BRA loc_08DAB4
}

---------------------------------------------
; Gaia talk: 6-tick pause (WaitByte #05) with input masked, voice sparkle on, intro text on the first visit (event flag $DC), then GaiaHealAndHints.

GaiaDialogueEntry {
    LDA #$FFFC            ; Brief input mask
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 ) ; WaitByte #05 = 6 ticks
    LDA #$FFFC            ; Unmask input
    TRB $joypadMaskStd
    LDY $06               ; $06 = the last child spawned = GaiaVoiceSparkle
    LDA #$FFFF            ; Voice sparkle on ($24 = $FFFF)
    STA $0024, Y
    COP [BranchOnFlagByte] ( #DC, #01, &GaiaHealAndHints ) ; Already met Gaia? → skip intro
    COP [SetFlagByte] ( #DC ) ; Mark first encounter
    COP [PrintDialogString] ( &dialogstring_08DD0B ) ; "I am Gaia..." intro
}

---------------------------------------------
; HP check and heal (hpToHeal = 40, one HP per 8 frames until full), then the hint lookup by source scene; falls to the save prompt when the scene has no entry.

GaiaHealAndHints {
    LDA $playerHp
    CMP $playerMaxHp      ; Already at full HP?
    BEQ loc_08DB37        ; Yes → skip healing
    COP [PrintDialogString] ( &dialogstring_08DE4D ) ; "It looks like you're hurt..."
    LDA #$FFFC            ; Mask input during heal
    TSB $joypadMaskStd
    LDA #$0028            ; Heal request 40: UpdateHUD adds 1 HP per 8 frames (SFX $0D) until HP = max
    STA $hpToHeal
    COP [SetEntryHere]    ; Loop each frame until healed
    LDA $playerHp
    CMP $playerMaxHp
    BEQ loc_08DB37        ; Healed → continue to hints
    RTL                   ; Not yet → re-enter next frame

; HP is full or healed: start the hint table search (X is saved with PHX).

  loc_08DB37:
    PHX 
    LDX #$0000

; Hint table search loop: 1-byte entries, a zero ends the table.

  loc_08DB3B:
    LDA $@GaiaHintSceneTable, X ; Scene→hint lookup table
    AND #$00FF
    BEQ loc_08DB9A        ; End of table → no hint for this scene
    CMP $sourceSceneId    ; Match current scene?
    BEQ loc_08DB4C
    INX 
    BRA loc_08DB3B

; Scene found: X = hint index, restore X and switch-case to the GaiaHint_xx handler.

  loc_08DB4C:
    STX $0000             ; Hint index = position in GaiaHintSceneTable
    PLX 
    COP [SwitchCase] ( #$0000, &code_list_08DB56 ) ; Dispatch to hint handler
}

---------------------------------------------
; Hint handlers by position in GaiaHintSceneTable (34 entries, $00-$21).

code_list_08DB56 [
  &GaiaHint_SouthCape01   ;00
  &GaiaHint_Jewels   ;01
  &GaiaHint_PsychoDash   ;02
  &GaiaHint_CastlianBoss   ;03
  &GaiaHint_IncanRuins26   ;04
  &GaiaHint_IncanRuins28   ;05
  &GaiaHint_Freejia34   ;06
  &GaiaHint_DiamondMine3D   ;07
  &GaiaHint_DiamondMine40   ;08
  &GaiaHint_DarkFriar   ;09
  &GaiaHint_SkyGarden4C   ;0A
  &GaiaHint_SkyGarden51   ;0B
  &GaiaHint_SkyGarden54   ;0C
  &GaiaHint_SkyGarden56   ;0D
  &GaiaHint_SeasidePalace5A   ;0E
  &GaiaHint_MuContinent   ;0F
  &GaiaHint_PsychoSlider   ;10
  &GaiaHint_AngelVillage6C   ;11
  &GaiaHint_Watermia7C   ;12
  &GaiaHint_GreatWall85   ;13
  &GaiaHint_SpinDash   ;14
  &GaiaHint_Euro99   ;15
  &GaiaHint_MtTempleA1   ;16
  &GaiaHint_MtTempleA3   ;17
  &GaiaHint_AuraBarrier   ;18
  &GaiaHint_NativesVillageAC   ;19
  &GaiaHint_GardenB6   ;1A
  &GaiaHint_Earthquaker   ;1B
  &GaiaHint_AnkorWat   ;1C
  &GaiaHint_DaoVillageC3   ;1D
  &GaiaHint_AuraItem   ;1E
  &GaiaHint_BabelTowerE0   ;1F
  &GaiaHint_CometApproach   ;20
  &GaiaHint_TempShape   ;21
]
---------------------------------------------

; Scene not in the hint table: restore X and fall into the save prompt.

loc_08DB9A {
    PLX 

; Save prompt, shared end of every hint handler: unmask input, 'Record what's happened so far?' with Record / Don't record.

  GaiaSavePrompt:
    LDA #$FFFC            ; Unmask input for menu navigation
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_08DDCB ) ; "Record what's happened so far?"
    COP [DialogueOptions] ( #02, #02, &code_list_08DBAB ) ; 2 options, cursor at 2nd
}

---------------------------------------------
; Save prompt table: 0 cancel and 2 = GaiaThenGo, 1 = GaiaSaveConfirm.

code_list_08DBAB [
  &GaiaThenGo   ;00
  &GaiaSaveConfirm   ;01
  &GaiaThenGo   ;02
]

---------------------------------------------
; Record: SaveGameState_Scene for slot $0D8C, SFX $29, 60 ticks (WaitByte #3B), then 'Continue your journey?' (Yes = entry 1).

GaiaSaveConfirm {
    LDA $0D8C             ; Current save slot number
    JSL $@save_system.SaveGameState_Scene ; Write event flags to SRAM
    COP [PlaySoundCh1] ( #29 ) ; Save confirmation jingle
    LDA #$FFFC            ; Mask input during jingle
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B ) ; WaitByte #3B = 60 ticks for the jingle
    LDA #$FFFC
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_08DDFE ) ; "Continue your journey?"
    COP [DialogueOptions] ( #02, #01, &code_list_08DBD4 ) ; Yes/No
}

---------------------------------------------
; Continue prompt table: 1 (Yes) = GaiaThenGo ('Then go.'), 2 (No) and 0 (cancel) = GaiaThenRest ('Then rest a while.').

code_list_08DBD4 [
  &GaiaThenRest   ;00
  &GaiaThenGo   ;01
  &GaiaThenRest   ;02
]

---------------------------------------------
; 'Then go.': voice sparkle off and return to the room loop. Reached by 'Don't record', by cancelling the save prompt and by 'Yes' to 'Continue your journey?'.

GaiaThenGo {
    COP [PrintDialogString] ( &dialogstring_08DE43 ) ; "Then go."
    LDY $06
    LDA #$0000            ; Voice sparkle off ($24 = 0)
    STA $0024, Y
    COP [RestoreSavedPtr]
}

---------------------------------------------
; 'Then rest a while.' (No to 'Continue your journey?'): voice sparkle off, input masked, the player hidden, dissolve animation $1C at his spot, fade to track $0E and yield forever.

GaiaThenRest {
    COP [PrintDialogString] ( &dialogstring_08DE32 ) ; "Then rest a while."
    LDY $06
    LDA #$0000            ; Voice sparkle off ($24 = 0)
    STA $0024, Y
    LDA #$FFFC            ; Mask input during animation
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0010, Y          ; Hide player sprite
    ORA #$2000
    STA $0010, Y
    LDA $0014, Y          ; Copy player pos to this actor
    STA $14
    LDA $0016, Y
    STA $16
    COP [SetMetasprite] ( @spriteset_pickups_effects ) ; Enemy spriteset (animation $1C = dissolve effect)
    LDA #$2000            ; Show this actor's sprite
    TRB $10
    COP [StageSpriteFrame] ( #1C ) ; Rest/dissolve frame
    COP [AnimOnce]
    COP [FadeThenStartMusic] ( #0E ) ; Fade out, then start track $0E (bgm_longing_for_the_past)
    COP [SetEntryHere]    ; Rest state: yields forever (the player is hidden and masked)
    RTL 
}

---------------------------------------------
; Scene $01 (South Cape): no hint text, save prompt only.

GaiaHint_SouthCape01 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $0B (Edward Prison): jewel and Start-map hint.

GaiaHint_Jewels {
    COP [PrintDialogString] ( &dialogstring_08DED3 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $15 (Itory Village): Psycho Dash hint.

GaiaHint_PsychoDash {
    COP [PrintDialogString] ( &dialogstring_08DF80 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $1E (Larai Cliff): warning about a huge enemy whose head shoots rays of light when hurt.

GaiaHint_CastlianBoss {
    COP [PrintDialogString] ( &dialogstring_08DFEE )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $26 (Incan Ruins): no text.

GaiaHint_IncanRuins26 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $28 (Incan Ruins): no text.

GaiaHint_IncanRuins28 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $34 (Freejia): no text.

GaiaHint_Freejia34 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $3D (Diamond Mine): no text.

GaiaHint_DiamondMine3D {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $40 (Diamond Mine): no text.

GaiaHint_DiamondMine40 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $42 (Diamond Mine): Dark Friar hint.

GaiaHint_DarkFriar {
    COP [PrintDialogString] ( &dialogstring_08E1EE )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $4C (Sky Garden): no text.

GaiaHint_SkyGarden4C {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $51 (Sky Garden): no text.

GaiaHint_SkyGarden51 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $54 (Sky Garden): no text.

GaiaHint_SkyGarden54 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $56 (Sky Garden): no text.

GaiaHint_SkyGarden56 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $5A (Seaside Palace): no text.

GaiaHint_SeasidePalace5A {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $60 (Mu): Mu rising from the sea.

GaiaHint_MuContinent {
    COP [PrintDialogString] ( &dialogstring_08E2F8 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $62 (Mu): Psycho Slider hint.

GaiaHint_PsychoSlider {
    COP [PrintDialogString] ( &dialogstring_08E3A7 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $6C (Angel Village): no text.

GaiaHint_AngelVillage6C {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $7C (Watermia): no text.

GaiaHint_Watermia7C {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $85 (Great Wall): no text.

GaiaHint_GreatWall85 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $86 (Great Wall): Spin Dash hint.

GaiaHint_SpinDash {
    COP [PrintDialogString] ( &dialogstring_08E428 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $99 (City of Euro): no text.

GaiaHint_Euro99 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $A1 (Mt. Temple): no text.

GaiaHint_MtTempleA1 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $A3 (Mt. Temple): no text.

GaiaHint_MtTempleA3 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $A7 (Mt. Temple): Aura Barrier hint.

GaiaHint_AuraBarrier {
    COP [PrintDialogString] ( &dialogstring_08E4A4 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $AC (Natives' Village): no text.

GaiaHint_NativesVillageAC {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $B6 (Garden): no text.

GaiaHint_GardenB6 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $B8 (Ankor Wat): Earthquaker hint.

GaiaHint_Earthquaker {
    COP [PrintDialogString] ( &dialogstring_08E540 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $BB (Ankor Wat top floor): the temple text.

GaiaHint_AnkorWat {
    COP [PrintDialogString] ( &dialogstring_08E58B )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $C3 (Dao Village): no text.

GaiaHint_DaoVillageC3 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $CC (Pyramid): when $0AAC is non-zero (layout 3): gives item $24 (the Aura) unless the player has it (GaiaHint_AuraDesc) or the inventory is full (GaiaHint_AuraFull): text, fanfare (track $18, then 90 ticks: WaitByte #59), 'You have the Aura!', waits for the SPC reply $FF, back to track $16, the Aura description, then the save prompt. With $0AAC = 0 it is just the save prompt.

GaiaHint_AuraItem {
    LDA $globalScriptIndex
    BNE loc_08DCAF
    JMP $&GaiaSavePrompt

; $0AAC is non-zero: the Aura gift sequence.

  loc_08DCAF:
    COP [BranchIfHasItem] ( #24, &GaiaHint_AuraDesc )
    COP [GiveItem] ( #24, &GaiaHint_AuraFull )
    COP [PrintDialogString] ( &dialogstring_08E66C )
    LDA #$FFFC
    TSB $joypadMaskStd
    COP [StartMusic] ( #18 )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_08E7E7 )
    COP [SetEntryHere]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_08DCDF
    RTL 

; The fanfare has finished (APUIO1 = $FF): restart the room music (track $16), print the Aura description and go to the save prompt.

  loc_08DCDF:
    COP [StartMusic] ( #16 )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_08E722 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; The player already has the Aura: description text only.

GaiaHint_AuraDesc {
    COP [PrintDialogString] ( &dialogstring_08E722 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Inventory full: 'Cut down on your inventory and come back.'

GaiaHint_AuraFull {
    COP [PrintDialogString] ( &dialogstring_08E800 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $E0 (Babel Tower): no text.

GaiaHint_BabelTowerE0 {
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $E3 (Babel Tower): the last talk with Gaia.

GaiaHint_CometApproach {
    COP [PrintDialogString] ( &dialogstring_08E853 )
    JMP $&GaiaSavePrompt
}

---------------------------------------------
; Scene $12 (Underground Tunnel): the temporary-shape text.

GaiaHint_TempShape {
    COP [PrintDialogString] ( &dialogstring_08E98A )
    JMP $&GaiaSavePrompt
}
---------------------------------------------

dialogstring_08DD0B `[DEF]I am Gaia, the source of[N]all life. I will help[N]you on your journey.[FIN]Only one with the Dark[N]Power can see this[N]space. You are the[N]chosen one.[FIN]In the dark space you[N]can record a travel[N]journal. Stop there[N]before you depart.[FIN]`

dialogstring_08DDCB `[DEF][CLR]Record what's happened[N]so far?[N] Record[N] Don't record`

dialogstring_08DDFE `[CLR]Finished recording...[FIN]Continue your journey?[N] Yes[N] No`

dialogstring_08DE32 `[CLR]Then rest a while.[END]`

dialogstring_08DE43 `[CLR]Then go.[END]`

dialogstring_08DE4D `[DEF][CLR]It looks like you're[N]hurt. Close your eyes.[FIN]`
---------------------------------------------

; 34 source scene IDs ($01, $0B, $15, $1E, $26, $28, $34, $3D, $40, $42, $4C, $51, $54, $56, $5A, $60, $62, $6C, $7C, $85, $86, $99, $A1, $A3, $A7, $AC, $B6, $B8, $BB, $C3, $CC, $E0, $E3, $12) then two $00 bytes (the end marker the search stops at, and one more); the position is the GaiaHint_xx index.

GaiaHintSceneTable #010B151E2628343D40424C5154565A60626C7C858699A1A3A7ACB6B8BBC3CCE0E3120000
---------------------------------------------

; Shared prefix of most hints ('I am Gaia, the source of all life. I'll give you some advice.'), pulled in with [PRT:].

dialogstring_08DE96 `[DEF][CLR]I am Gaia, the source of[N]all life. I'll give you[N]some advice.[FIN]`

---------------------------------------------
; Not referenced: 'Hint Test'.

dialogstring_08DEC6 `[DEF][CLR]Hint Test[FIN]`

dialogstring_08DED3 `[PRT:@dialogstring_08DE96]When you defeat all the [N]enemies in an area, you [N]will get a jewel that [N]increases your abilities.[FIN]Push the Start Button[N]to see the locations of[N]your enemies.[FIN]Find the demons [N]and defeat them. [FIN]`

dialogstring_08DF80 `[PRT:@dialogstring_08DE96]Will's power - the [N]Psycho Dash. It can [N]destroy obstacles. [FIN]Always be alert. If you[N]find a suspicious place,[N]try to destroy it.[FIN]`

dialogstring_08DFEE `[PRT:@dialogstring_08DE96]Then you will fight[N]a huge enemy.[FIN]When he suffers damage, [N]rays of light will shoot [N]from his head. [FIN]If you suffer damage[N]hide behind him.[FIN]`

---------------------------------------------
; Not referenced: Gold Ship door hint (gold tiles, melody of the Incan spirit).

dialogstring_08E066 `[PRT:@dialogstring_08DE96]The door to the Gold[N]Ship is in a place paved[N]with gold tiles.[FIN]Listen to the melody [N]of the Incan spirit. [FIN]`

---------------------------------------------
; Not referenced: hint about an untouchable enemy and Edward Castle.

dialogstring_08E0C7 `[PRT:@dialogstring_08DE96]To defeat an enemy you[N]can't touch, think about[N]what happened under[N]Edward Castle.[FIN]`

---------------------------------------------
; Not referenced: hint about the wall where the wind blows.

dialogstring_08E109 `[PRT:@dialogstring_08DE96]The wall where the wind[N]blows...it's easy to[N]break through where[N]the stones are cracked.[FIN]If you can't find it, [N]listen for the only place [N]where the sound is[N]different. [FIN]`

---------------------------------------------
; Not referenced: Diamond Mine keys hint.

dialogstring_08E19C `[PRT:@dialogstring_08DE96]The keys are on a grate[N]in the floor of the[N]mine. Find the laborer[N]who has them.[FIN]`

dialogstring_08E1EE `[PRT:@dialogstring_08DE96]Freedan's power - The[N]Dark Friar can defeat[N]enemies in places a[N]sword can't reach.[FIN]When you've defeated[N]all the enemies[N]the road will open up.[FIN]`

---------------------------------------------
; Not referenced: remove-the-pillar hint.

dialogstring_08E261 `[PRT:@dialogstring_08DE96]Take away the obstacle[N]in front, and the back[N]appears. Remove the[N]blocking pillar.[FIN]`

---------------------------------------------
; Not referenced: floor switch hint.

dialogstring_08E2B9 `[PRT:@dialogstring_08DE96]The switch on the floor [N]cannot be activated [N]by your weight. [FIN]`

dialogstring_08E2F8 `[PRT:@dialogstring_08DE96]When you started this [N]journey,  Mu began [N]to rise from the sea. [FIN]Sea water still covers [N]land in many places [N]on the continent. [FIN]When the water is gone [N]you will discover [N]the location of [N]Rama, King of Mu. [FIN]`

dialogstring_08E3A7 `[PRT:@dialogstring_08DE96]Will's power is the [N]Psycho Slider. Pass [N]through narrow corridors [N]using this power. [FIN]Be careful not to[N]overlook the cracks[N]in the cliff.[FIN]`

dialogstring_08E428 `[PRT:@dialogstring_08DE96]Will's power is the [N]Spin Dash. Use this to [N]climb hills and jump. [FIN]There are many hills at[N]the Great Wall of China.[N]Try everything.[FIN]`

dialogstring_08E4A4 `[PRT:@dialogstring_08DE96]Freedan's power is [N]the Aura Barrier. It [N]puts a layer of Aura [N]around his body. [FIN]Enemies at the mountain [N]temple are strong.If [N]you use this power, your [N]battles will be easier. [FIN]`

dialogstring_08E540 `[PRT:@dialogstring_08DE96]Freedan's Power is the [N]Earthquaker.[FIN]When he uses it,[N]his enemy can't move[N]for a long time.[FIN]`

dialogstring_08E58B `[DEF][CLR]This is the temple at[N]Ankor Wat.[FIN]It stands quietly in [N]the jungle and hides [N]its form when people [N]come near... [FIN]On this top floor you[N]will understand why you[N]made the journey.[FIN]`

---------------------------------------------
; Not referenced: Pyramid six blocks hint.

dialogstring_08E615 `[PRT:@dialogstring_08DE96]The Pyramid is divided [N]into six blocks. [FIN]Use the Dark Power [N]previously obtained, in[N]each area. [FIN]`

dialogstring_08E66C `[DEF][CLR]I am Gaia, the source of[N]life. The Dark Power has[N]become strong in the[N]temple at Ankor Wat.[FIN]If you stand before the [N]right-hand statue, you [N]can change into Shadow, [N]the ultimate warrior.  [FIN]Then I think I will[N]grant you one item.[FIN]`

dialogstring_08E722 `[DEF][CLR]The Aura is Shadow's [N]mind. When he holds it [N]up, his body becomes [N]like water. [FIN]Only a small part of the[N]Pyramid is above ground.[N]Most of it is below[N]the surface.[FIN]You should change into[N]the Shadow and advance[N]into the underground.[FIN]`

dialogstring_08E7E7 `[DEF][CLR][DLY:9]You have the Aura![PAU:78][DLY:1][FIN]`

dialogstring_08E800 `[DEF][CLR]I am Gaia, the source of[N]life. I think I'll give[N]you one item.[FIN]Cut down on your[N]inventory and come back.[FIN]`

dialogstring_08E853 `[DEF][CLR]The comet draws near.[N]The time for your last[N]battle approaches.[FIN]This is the last time I[N]will talk to you like[N]this in this place.[FIN]With your rejuvenated [N]power, defeat the comet,[N]Dark Gaia and become [N]the Dark Knight. [FIN]Shadow's greatest power,[N]the Firebird, will arise[N]when you're one with [N]the Light Knight.[FIN]Only you can restore the [N]Earth to its original [N]condition. I'm putting [N]all my faith in you... [FIN]`

dialogstring_08E98A `[PRT:@dialogstring_08DE96]Your shape is only[N]temporary. Try standing[N]in front of the statue[N]next to you.[FIN]`
---------------------------------------------

; Ability orb: finds the ability bit for $0B12 in AbilitySceneTable (table position = ability index in globalScriptIndex), dies if the bit is already in abilityBitmask, otherwise shows the orb (animation #0A) and waits for the player at the statue zone (3,A)-(5,B).

AbilityOrbActor {
    PHX 
    LDX #$0000
    LDY #$0000            ; Y = entry index counter

; Table search loop (Y counts the entries).

  loc_08E9DB:
    LDA $@AbilitySceneTable, X ; Search for current scene
    BEQ loc_08E9EE        ; End of table → no ability here
    AND #$00FF
    CMP $sourceSceneId    ; Match scene ID?
    BEQ loc_08E9F1
    INX 
    INX 
    INY 
    BRA loc_08E9DB

; Scene not found or ability already known: restore X and Die.

  loc_08E9EE:
    PLX 
    COP [Die]             ; No ability for this scene → remove orb

; Scene found: keep the ability bit in $24, die if it is already in abilityBitmask, store the entry index in $0AAC.

  loc_08E9F1:
    LDA $@AbilitySceneTable+1, X ; Ability bit for this scene ($01 to $40)
    AND #$00FF
    STA $24               ; Save for later abilityBitmask OR
    AND $abilityBitmask   ; Already have this ability?
    BNE loc_08E9EE        ; Yes → die
    TYA                   ; Store table index for dialogue lookup
    STA $globalScriptIndex
    PLX 
    COP [StageSprAndHitbox] ( #0A ) ; Orb sprite: animation #0A of spm_darkspace_sprites
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &AbilityAcquisitionDispatch ) ; Player at the statue zone (3,A)-(5,B)
    RTL 
}

---------------------------------------------
; The player stands at the statue: input masked, 6 ticks (WaitByte #05), LookupAbilityForm decides the form. Will ability: Freedan / Shadow -> Transform_FreedanToWill. Freedan ability: Will -> Transform_WillToFreedanAlt, Shadow -> Transform_ShadowToFreedan, Freedan -> nothing. Then it waits for playerFlags $0800 to clear, grants the ability, flies the orb to the player, plays the fanfare and the two texts, restores the music and unmasks.

AbilityAcquisitionDispatch {
    LDA #$FFFC            ; Mask input
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 ) ; Brief pause
    JSR $&LookupAbilityForm ; A = 0: Will ability (low nibble), 1: Freedan ability (high nibble)
    CMP #$0000            ; 0 = Will ability
    BEQ loc_08EA78        ; Will ability: go back to Will (if transformed)
    LDA $characterForm    ; Which form are we in?
    BEQ loc_08EA58        ; 0=Will → transform to Freedan
    CMP #$0002            ; 2=Shadow → transform to Freedan
    BEQ loc_08EA38
    BRA loc_08EA9B        ; 1=Freedan → already correct form

; Shadow -> Freedan: write Transform_ShadowToFreedan into the player entry and set $0800.

  loc_08EA38:
    LDY $playerActor      ; Shadow → Freedan: override player entry point
    SEP #$20
    LDA #$^Transform_ShadowToFreedan ; Bank byte of Shadow→Freedan handler
    STA $0002, Y
    REP #$20
    LDA #$&Transform_ShadowToFreedan ; Address of Shadow→Freedan handler
    STA $0000, Y
    LDA #$0000            ; Clear frame timer
    STA $0008, Y
    LDA #$0800            ; playerFlags $0800: script lock until DarkSpaceRestoreControl
    TSB $playerFlags
    BRA loc_08EA9B

; Will -> Freedan: write Transform_WillToFreedanAlt into the player entry and set $0800.

  loc_08EA58:
    LDY $playerActor      ; Will → Freedan: override player entry point
    SEP #$20
    LDA #$^Transform_WillToFreedanAlt ; Bank byte of Will→Freedan handler
    STA $0002, Y
    REP #$20
    LDA #$&Transform_WillToFreedanAlt ; Address of Will→Freedan handler
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800            ; playerFlags $0800: script lock until DarkSpaceRestoreControl
    TSB $playerFlags
    BRA loc_08EA9B

; Will ability: if the player is not Will, write Transform_FreedanToWill (also used from the Shadow form) and set $0800.

  loc_08EA78:
    LDA $characterForm    ; Will/Freedan statue: revert to Will
    BEQ loc_08EA9B        ; Already Will → no transform needed
    LDY $playerActor      ; Freedan → Will: override player entry point
    SEP #$20
    LDA #$^Transform_FreedanToWill ; Bank byte of Freedan→Will handler
    STA $0002, Y
    REP #$20
    LDA #$&Transform_FreedanToWill ; Address of Freedan→Will handler
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800            ; playerFlags $0800: script lock until DarkSpaceRestoreControl
    TSB $playerFlags

; Wait for the transformation to finish (playerFlags $0800 clear).

  loc_08EA9B:
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_08EAAA
    RTL 

; Ability grant sequence: 8-frame pause, abilityBitmask |= $24, orb animation, orb flies to (player X, Y - 16), fanfare, 'X can now be used!', wait for the SPC, description text, music back to track $16, unmask, Die.

  loc_08EAAA:
    COP [LoopStart] ( #08 ) ; 8-frame pause with input masked
    LDA #$FFFC
    TSB $joypadMaskStd
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [LoopEnd]
    LDA $24               ; Ability bit from table lookup
    ORA $abilityBitmask   ; Grant the new ability
    STA $abilityBitmask
    COP [StageSpriteLoopMoveY] ( #0A, #03, #14 ) ; Orb animation #0A, 3 passes, with a Y move (parameter $14)
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #03 )
    COP [AnimLoop]
    LDY $playerActor      ; Fly-to target = player X, Y - 16
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #0A, #01 ) ; Orb flies to the player
    LDA #$2000
    TSB $10
    LDA #$0800
    TRB $10
    COP [StartMusic] ( #18 ) ; Fanfare: track $18 (bgm_important_item)
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_08EB68 )
    COP [SetEntryHere]    ; Wait until the SPC reports $FF (fanfare finished)
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_08EB0D
    RTL 

; The fanfare has finished: voice sparkle on, description text (table_08EBD3 by $0AAC), voice sparkle off.

  loc_08EB0D:
    LDY $26               ; $26 = the voice sparkle (copied from the main actor's $06)
    LDA #$FFFF            ; Voice sparkle on
    STA $0024, Y
    COP [PrintDialogString] ( &dialogstring_08EB85 )
    LDY $26
    LDA #$0000            ; Voice sparkle off
    STA $0024, Y
    COP [StartMusic] ( #16 ) ; Back to the room music: track $16 (bgm_space_beyond_time)
    COP [WaitByte] ( #3B )
    LDA #$FFFC
    TRB $joypadMaskStd
    COP [Die]
}
---------------------------------------------

; Searches AbilitySceneTable for $0B12 and returns A = 0 when the ability bit is in the low nibble (Will), 1 when it is in the high nibble (Freedan); carry set if the scene is missing (the only caller ignores it). It was first called LookupStatueType after the old 'statue type' reading (there is no statue type).

LookupAbilityForm {
    PHX 
    LDX #$0000

; Table search loop.

  loc_08EB33:
    LDA $@AbilitySceneTable, X
    BEQ loc_08EB57
    AND #$00FF
    CMP $sourceSceneId
    BEQ loc_08EB45
    INX 
    INX 
    BRA loc_08EB33

; Scene found: test the high nibble ($F0).

  loc_08EB45:
    LDA $@AbilitySceneTable+1, X
    AND #$00FF
    PLX 
    AND #$00F0
    BNE loc_08EB53
    RTS 

; High nibble set: return 1.

  loc_08EB53:
    LDA #$0001
    RTS 

; Scene not found: restore X and return with carry set.

  loc_08EB57:
    PLX 
    SEC 
    RTS 
}
---------------------------------------------

; 6 entries (scene, abilityBitmask bit): $15 -> $01 Psycho Dash, $62 -> $02 Psycho Slider, $86 -> $04 Spin Dash, $42 -> $10 Dark Friar, $A7 -> $20 Aura Barrier, $B8 -> $40 Earthquaker, then two $00 bytes (the end marker and one more). Low nibble = Will, high nibble = Freedan. Bit $08 is not used.

AbilitySceneTable #1501620286044210A720B8400000
---------------------------------------------

; '[ability name] can now be used!' (name from table_08EB8F by $0AAC through [ADR:]).

dialogstring_08EB68 `[DEF][DLY:9][ADR:&table_08EB8F,AAC][N]can now be used![PAU:78][FIN]`

---------------------------------------------
; Description of the ability (table_08EBD3 by $0AAC through [ADR:]).

dialogstring_08EB85 `[DEF][CLR][DLY:2][ADR:&table_08EBD3,AAC][END]`
---------------------------------------------

; Ability names by ability index (table position in AbilitySceneTable).

table_08EB8F [
  &dialogstring_08EB9B   ;00
  &dialogstring_08EBA2   ;01
  &dialogstring_08EBAB   ;02
  &dialogstring_08EBB2   ;03
  &dialogstring_08EBBA   ;04
  &dialogstring_08EBC7   ;05
]

dialogstring_08EB9B `Psycho Dash`

dialogstring_08EBA2 `Psycho Slider`

dialogstring_08EBAB `Spin Dash`

dialogstring_08EBB2 `Dark Friar`

dialogstring_08EBBA `Aura Barrier`

dialogstring_08EBC7 `Earthquaker`
---------------------------------------------

; Ability descriptions by ability index.

table_08EBD3 [
  &dialogstring_08EBDF   ;00
  &dialogstring_08EC66   ;01
  &dialogstring_08ECEA   ;02
  &dialogstring_08ED6D   ;03
  &dialogstring_08EDF2   ;04
  &dialogstring_08EE8B   ;05
]

dialogstring_08EBDF `Only young Will can use [N]the Psycho Dash. [FIN]You can smash walls[N]and obstacles by hurling[N]yourself against them.[FIN]Use the Attack Button [N]to save energy. `

dialogstring_08EC66 `Only young Will can use [N]the Psycho Slider. [FIN]You can now use the[N]Sliding Attack to pass[N]through small[N]passageways.[FIN]Push the Attack Button [N]when running. `

dialogstring_08ECEA `Only young Will can use [N]the Spin Dash. [FIN]Spin your body to[N]send enemies flying,[N]and use the recoil[N]to climb hills.[FIN]Use the Attack and LR [N]Buttons for power. `

dialogstring_08ED6D `The Dark Friar is a dark[N]power that only the Dark[N]Knight, Freedan,[N]can use.[FIN]Use the Aura Power to [N]scorch a distant enemy. [N]Use the Attack Button [N]to save energy. `

dialogstring_08EDF2 `The Aura Barrier is a [N]Dark Power that can only [N]be used by the Dark  [N]Knight, Freedan. [FIN]Use the power of[N]the Aura to put a[N]barrier around you.[FIN]Use the Attack and LR [N]Buttons for power. `

dialogstring_08EE8B `The Earthquaker is a[N]Dark Power that can only[N]be used by Freedan,[N]the Dark Knight.[FIN]This causes earthquakes.[N]The enemy won't be able[N]to move for a long time.[FIN]Push the Attack Button [N]when jumping down. `
---------------------------------------------

; Not referenced (only spawned by DS_AuraItemRoom): an Aura item pickup at the Shadow statue. Dies if the player has item $24, otherwise waits at zone (B,A)-(D,B).

AuraItemInteraction {
    COP [BranchIfHasItem] ( #24, &AuraItemDie ) ; Already have Aura? → die
    COP [StageSprAndHitbox] ( #0A )
    LDA #$2000
    TRB $10

; Wait loop of the unreferenced Aura pickup.

  AuraItemWaitLoop:
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &AuraItemGrant )
    RTL 
}

---------------------------------------------
; Not referenced: gives item $24 (or AuraItemInventoryFull), flies the item to the player, music track $17 and the 'You have the Aura!' text.

AuraItemGrant {
    LDA #$FFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    COP [GiveItem] ( #24, &AuraItemInventoryFull )
    COP [StageSpriteLoopMoveY] ( #0A, #03, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #03 )
    COP [AnimLoop]
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #0A, #01 )
    LDA #$2000
    TSB $10
    LDA #$0800
    TRB $10
    LDA #$0080
    TSB $displayModeFlags
    COP [MusicAndText] ( #17, @dialogstring_08EFEF )
    COP [WaitByte] ( #03 )
    COP [SetEntryHere]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_08EFAD
    RTL 

; Unreferenced pickup: voice sparkle on, description, voice sparkle off, unmask.

  loc_08EFAD:
    LDY $26
    LDA #$FFFF
    STA $0024, Y
    COP [PrintDialogString] ( &dialogstring_08F003 )
    LDY $26
    LDA #$0000
    STA $0024, Y
    LDA #$FFFC
    TRB $joypadMaskStd
}

---------------------------------------------
; Not referenced: Die.

AuraItemDie {
    COP [Die]
}

---------------------------------------------
; Not referenced: 'Your inventory is full' text.

AuraItemInventoryFull {
    LDA #$0800
    TRB $10
    COP [PrintDialogString] ( &dialogstring_08F060 )
    LDA #$0800
    TSB $10
    LDA #$FFFC
    TRB $joypadMaskStd
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &AuraItemReturnToWait )
    JMP $&AuraItemWaitLoop
}

---------------------------------------------
; Not referenced: yield.

AuraItemReturnToWait {
    RTL 
}

dialogstring_08EFEF `[DEF][DLY:9]You have the Aura![FIN]`

dialogstring_08F003 `[DEF][CLR][DLY:2]Only Shadow can use[N]the Aura.[FIN]When you hold this up [N]Shadow's body will turn [N]to water and he can flow [N]underground. [END]`

dialogstring_08F060 `[DEF]Your inventory is full. [N]Store things somewhere [N]and return here. [END]`

---------------------------------------------
; Left statue of Will / Shadow rooms. Already Freedan = return. First visit (flag $F7): lore text, then Transform_WillToFreedan (the standing version; it assumes the player is Will). Later visits: 'Change into the Dark Knight, Freedan?' (FreedanTransformPrompt).

FreedanTransformDialogue {
    LDA $characterForm
    CMP #$0001            ; Already Freedan?
    BEQ loc_08F0CA        ; Yes → skip (return to caller)
    LDA #$FFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFFC
    TRB $joypadMaskStd
    COP [BranchOnFlagByte] ( #F7, #01, &FreedanTransformPrompt )
    COP [SetFlagByte] ( #F7 )
    COP [PrintDialogString] ( &dialogstring_08F157 )
    LDY $playerActor
    SEP #$20
    LDA #$^Transform_WillToFreedan
    STA $0002, Y
    REP #$20
    LDA #$&Transform_WillToFreedan
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags

; Return to the room loop (RestoreSavedPtr).

  loc_08F0CA:
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Yes / No prompt, cursor on No.

FreedanTransformPrompt {
    COP [PrintDialogString] ( &dialogstring_08F12B )
    COP [DialogueOptions] ( #02, #02, &code_list_08F0D6 )
}

---------------------------------------------
; 0 cancel and 2 = FreedanTransformDecline, 1 = FreedanTransformAccept.

code_list_08F0D6 [
  &FreedanTransformDecline   ;00
  &FreedanTransformAccept   ;01
  &FreedanTransformDecline   ;02
]

---------------------------------------------
; Will -> Transform_WillToFreedanAlt, Shadow -> Transform_ShadowToFreedan (loc_08F105); sets $0800 and returns to the room.

FreedanTransformAccept {
    COP [PrintDialogString] ( &dialogstring_08F155 )
    LDA $characterForm
    BNE loc_08F105
    LDY $playerActor
    SEP #$20
    LDA #$^Transform_WillToFreedanAlt
    STA $0002, Y
    REP #$20
    LDA #$&Transform_WillToFreedanAlt
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]

; Shadow -> Freedan branch.

  loc_08F105:
    LDY $playerActor
    SEP #$20
    LDA #$^Transform_ShadowToFreedan
    STA $0002, Y
    REP #$20
    LDA #$&Transform_ShadowToFreedan
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Clears the dialogue box and returns.

FreedanTransformDecline {
    COP [PrintDialogString] ( &dialogstring_08F155 )
    COP [RestoreSavedPtr]
}

dialogstring_08F12B `[TPL:B]Change into the Dark [N]Knight, Freedan? [N] Yes [N] No `

dialogstring_08F155 `[CLD]`

dialogstring_08F157 `[TPL:B][CLR][TPL:0]Will hears a voice [N]in his head. [FIN][TPL:4]Will. [N]I've been waiting a long [N]time for you to come. [FIN]I am Freedan.[N]I am eternal.[FIN]Let me help you on [N]your journey. As time [N]goes by, you'll come to [N]understand my nature.... [FIN][PAL:0]Will gradually loses [N]consciousness... [N][END]`
---------------------------------------------

; Will -> Freedan, standing version (first-visit lore): player body #05 frame 0, SFX $25 on both channels, animation 2 x 2 passes, 3 x 2 passes, palette thinker (bundle ID $0C), animations 8 and 9 x 2 passes, frame $0A, characterForm = 1, DarkSpaceRestoreControl.

Transform_WillToFreedan {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteLoop] ( #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #03, #02 )
    COP [AnimLoop]
    COP [SpawnThinkerParam] ( #0C, @actor_pool.PaletteResetAndKillThinker ) ; Palette thinker with bundle ID $0C
    COP [StageSpriteLoop] ( #08, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #09, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    LDA #$0001            ; Set form to Freedan
    STA $characterForm
    JSR $&DarkSpaceRestoreControl ; Restore player control
    RTL 
}
---------------------------------------------

; Will -> Freedan, frame version: frames 1, 2, 3, palette thinker (bundle ID $0C), frames 8, 9, $0B, characterForm = 1, DarkSpaceRestoreControl. Entered from the prompt and from the ability orb.

Transform_WillToFreedanAlt {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #0C, @actor_pool.PaletteResetAndKillThinker ) ; Palette thinker with bundle ID $0C
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    LDA #$0001
    STA $characterForm
    JSR $&DarkSpaceRestoreControl
    RTL 
}
---------------------------------------------

; Shadow -> Freedan: frames $0D, $10, $0F, $0E, characterForm = 1, one-frame yield, palette thinker (bundle ID $0C), frames 8, 9, $0B, DarkSpaceRestoreControl.

Transform_ShadowToFreedan {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    LDA #$0001
    STA $characterForm
    COP [SetEntryHereAndYield]
    COP [SpawnThinkerParam] ( #0C, @actor_pool.PaletteResetAndKillThinker ) ; Palette thinker with bundle ID $0C
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    JSR $&DarkSpaceRestoreControl
    RTL 
}
---------------------------------------------

; Left statue of Freedan / Shadow rooms. Already Will = return. Otherwise 'Return to young Will?' (cursor on Yes).

WillRevertDialogue {
    LDA $characterForm    ; Already Will?
    BNE loc_08F2E6        ; No → show transform prompt
    COP [RestoreSavedPtr] ; Already Will → nothing to do

; The player is not Will: pause 6 ticks (WaitByte #05), show the prompt.

  loc_08F2E6:
    LDA #$FFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFFC
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_08F357 )
    COP [DialogueOptions] ( #02, #01, &code_list_08F2FF )
}

---------------------------------------------
; 0 cancel and 2 = WillRevertDecline, 1 = WillRevertAccept.

code_list_08F2FF [
  &WillRevertDecline   ;00
  &WillRevertAccept   ;01
  &WillRevertDecline   ;02
]

---------------------------------------------
; Freedan -> Transform_FreedanToWill, Shadow -> Transform_ShadowToWill (loc_08F331); sets $0800 and returns.

WillRevertAccept {
    COP [PrintDialogString] ( &dialogstring_08F37B )
    LDA $characterForm
    CMP #$0001
    BNE loc_08F331
    LDY $playerActor
    SEP #$20
    LDA #$^Transform_FreedanToWill
    STA $0002, Y
    REP #$20
    LDA #$&Transform_FreedanToWill
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]

; Shadow -> Will branch.

  loc_08F331:
    LDY $playerActor
    SEP #$20
    LDA #$^Transform_ShadowToWill
    STA $0002, Y
    REP #$20
    LDA #$&Transform_ShadowToWill
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Clears the dialogue box and returns.

WillRevertDecline {
    COP [PrintDialogString] ( &dialogstring_08F37B )
    COP [RestoreSavedPtr]
}

dialogstring_08F357 `[TPL:B]Return to young Will? [N] Yes [N] No `

dialogstring_08F37B `[CLD]`
---------------------------------------------

; Freedan -> Will: frames 6, 9, 8 (SFX $25 after the first), characterForm = 0, one-frame yield, palette thinker (bundle ID $0B), frames 3, 2, 5, DarkSpaceRestoreControl. Entered from 6 other files.

Transform_FreedanToWill {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    STZ $characterForm    ; Set form back to Will
    COP [SetEntryHereAndYield]
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker ) ; Palette thinker with bundle ID $0B
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    JSR $&DarkSpaceRestoreControl
    RTL 
}
---------------------------------------------

; Shadow -> Will: frames $0D, $10, $0F, $0E, characterForm = 0, one-frame yield, palette thinker (bundle ID $0B), frames 3, 2, 5, DarkSpaceRestoreControl. Entered from 6 other files.

Transform_ShadowToWill {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    STZ $characterForm
    COP [SetEntryHereAndYield]
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker ) ; Palette thinker with bundle ID $0B
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    JSR $&DarkSpaceRestoreControl
    RTL 
}
---------------------------------------------

; Right statue. Locked (return) when event flag $B4 is clear or the player is already Shadow. First visit (flag $DD): lore text, then the transformation without a prompt (Will: WillToShadow at loc_08F436, Freedan: FreedanToShadow at loc_08F456). Later: 'Change to the ultimate Dark warrior, Shadow?'.

ShadowTransformDialogue {
    COP [BranchOnFlagByte] ( #B4, #00, &ShadowTransformLocked ) ; Flag $B4 not set → Shadow locked
    LDA $characterForm
    CMP #$0002            ; Already Shadow?
    BEQ ShadowTransformLocked ; Yes → nothing to do
    LDA #$FFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFFC
    TRB $joypadMaskStd
    COP [BranchOnFlagByte] ( #DD, #01, &ShadowTransformPrompt )
    COP [SetFlagByte] ( #DD )
    COP [PrintDialogString] ( &dialogstring_08F4B1 )
    LDA $characterForm
    BEQ loc_08F436
    BRA loc_08F456
}

---------------------------------------------
; Return to the room loop.

ShadowTransformLocked {
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Yes / No prompt, cursor on No.

ShadowTransformPrompt {
    COP [PrintDialogString] ( &dialogstring_08F47C )
    COP [DialogueOptions] ( #02, #02, &code_list_08F427 )
}

---------------------------------------------
; 0 cancel and 2 = ShadowTransformDecline, 1 = ShadowTransformAccept.

code_list_08F427 [
  &ShadowTransformDecline   ;00
  &ShadowTransformAccept   ;01
  &ShadowTransformDecline   ;02
]

---------------------------------------------
; Will -> Transform_WillToShadow (loc_08F436), otherwise Transform_FreedanToShadow (loc_08F456).

ShadowTransformAccept {
    COP [PrintDialogString] ( &dialogstring_08F4AF )
    LDA $characterForm
    BNE loc_08F456

; Write Transform_WillToShadow into the player entry, set $0800, return.

  loc_08F436:
    LDY $playerActor
    SEP #$20
    LDA #$^Transform_WillToShadow
    STA $0002, Y
    REP #$20
    LDA #$&Transform_WillToShadow
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]

; Write Transform_FreedanToShadow into the player entry, set $0800, return.

  loc_08F456:
    LDY $playerActor
    SEP #$20
    LDA #$^Transform_FreedanToShadow
    STA $0002, Y
    REP #$20
    LDA #$&Transform_FreedanToShadow
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [RestoreSavedPtr]
}

---------------------------------------------
; Clears the dialogue box and returns.

ShadowTransformDecline {
    COP [PrintDialogString] ( &dialogstring_08F4AF )
    COP [RestoreSavedPtr]
}

dialogstring_08F47C `[TPL:B]Change to the ultimate[N]Dark warrior, Shadow? [N] Yes [N] No `

dialogstring_08F4AF `[CLD]`

dialogstring_08F4B1 `[TPL:B]A voice echoes inside[N]his head.[FIN][TPL:4]I've been waiting for[N]you to come.[FIN]I am made from the light[N]of a comet. The ultimate[N]warrior, Shadow.[FIN]My body has no shape.[N]This body appears only[N]when the human[N]consciousness evolves.[FIN]The comet that now [N]approaches Earth is [N]also a consciousness [N]without form. [FIN]My body is the only[N]thing that can confront[N]the comet and[N]bring it to an end.[FIN]Well, close your eyes...[PAL:0][END]`
---------------------------------------------

; Will -> Shadow: frames 0, 2, 3 (SFX $25), palette thinker (bundle ID $6C), frames $0E, $0F, spawns ShadowShimmerInit, characterForm = 2, frames $10, $12, DarkSpaceRestoreControl. Entered from 7 other files (boss and ending scripts).

Transform_WillToShadow {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #6C, @actor_pool.PaletteResetAndKillThinker ) ; Palette thinker with bundle ID $6C
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnListAppend] ( @shadow_shimmer.ShadowShimmerInit, #00, #00, #$2800 )
    LDA #$0002            ; Set form to Shadow
    STA $characterForm
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    JSR $&DarkSpaceRestoreControl
    RTL 
}
---------------------------------------------

; Freedan -> Shadow: frames 7, 9, 8 (SFX $25), palette thinker (bundle ID $6C), frames $0E, $0F, spawns ShadowShimmerInit, characterForm = 2, frames $10, $12, DarkSpaceRestoreControl.

Transform_FreedanToShadow {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #6C, @actor_pool.PaletteResetAndKillThinker ) ; Palette thinker with bundle ID $6C
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0F )
    COP [AnimOnce]
    COP [SpawnListAppend] ( @shadow_shimmer.ShadowShimmerInit, #00, #00, #$2800 )
    LDA #$0002
    STA $characterForm
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    JSR $&DarkSpaceRestoreControl
    RTL 
}
---------------------------------------------

; Not referenced: an actor that only sets the display-filter bit ($1000 in $12). FireflyParticle does the same itself.

DarkSpaceAmbientParticle [
  actor-def < #02, #00, #28, {

  DS_AmbientParticleInit:
    LDA #$1000            ; Display-filtered flag
    TSB $12
} >
]

---------------------------------------------
; Ambient loop: sets the $08 timer to a random 0 to 120 (RNG & $0F, x 8; the wait lasts timer + 1 ticks), spawns one FireflyParticle, then yields until the timer is done; repeats forever.

FireflySpawnerLoop {
    COP [SetEntryHereAndYield]
    COP [RngByte]         ; Random 0–255
    AND #$000F            ; Mask to 0–15
    ASL                   ; x8 -> timer 0-120 (the wait lasts timer + 1 ticks)
    ASL 
    ASL 
    STA $08               ; Set as frame timer
    COP [SpawnAfterFlags] ( @FireflyParticle, #$1B02 ) ; Spawn one firefly
    BRA FireflySpawnerLoop ; Loop forever
}

---------------------------------------------
; One firefly: display-filtered, spriteset_pickups_effects animation #02, starts at Y = 0 and a random X (RNG x 2), movement chains 4 / 6 / 8 / 10 on X and one less on Y, removed when Y reaches $FF. The loop would end at once for a negative Y step, so it must move down; the old note said it rises (OQ-I056-2).

FireflyParticle {
    LDA #$1000            ; Display-filtered
    TSB $12
    COP [SetMetasprite] ( @spriteset_pickups_effects )
    COP [StageSprAndHitbox] ( #02 ) ; Firefly sprite
    LDA #$0000            ; Start at Y=0
    STA $16
    COP [RngByte]         ; Random X position
    ASL                   ; ×2 → 0–510 px range
    STA $14
    AND #$0003            ; Low 2 bits → speed variant (0–3)
    ASL                   ; ×2 → 0–6
    CLC 
    ADC #$0004            ; Base speed 4 → range 4–10
    STA $moveXAlt, X      ; X movement chain index 4, 6, 8 or 10 (from the random low bits)
    DEC 
    STA $moveYAlt, X      ; Y movement chain index = X index - 1

; Per-frame loop: reload the move chains, animate, repeat while Y < $FF.

  loc_08F6C4:
    COP [ReloadMoveChains]
    COP [SetEntryHere]
    COP [AnimOnce]
    LDA $16
    CMP #$00FF
    BCC loc_08F6C4
    COP [Die]
}
---------------------------------------------

; Called at the end of every transformation (JSR, X = player): player entry back to PlayerIdleEntry, movement chains and $08 cleared, $10 bit 9 cleared and bit 3 set, D-pad unmasked ($0F00), playerFlags $0800 cleared.

DarkSpaceRestoreControl {
    PHX 
    LDX $playerActor
    LDA #$*player_character.PlayerIdleEntry ; Bank byte
    STA $0002, X
    LDA #$&player_character.PlayerIdleEntry ; Code address
    STA $0000, X
    LDA #$0000            ; Clear all movement
    STA $002C, X          ; Override chain X
    STA $002E, X          ; Override chain Y
    STA $0008, X          ; Frame timer
    LDA $0010, X
    AND #$FDFF            ; Clear bit 9 ($0200, the scripted-motion marker of the player's $10; not the game-over flag, which is playerFlags $0200)
    ORA #$0008            ; Set bit 3: collision-checked movement (vine, ladder and shimmy states clear it)
    STA $0010, X
    LDA #$0F00            ; D-pad bits only ($0F00); the face buttons keep their mask state
    TRB $joypadMaskStd
    LDA #$0800            ; Clear ability-active flag
    TRB $playerFlags
    PLX 
    RTS 
}
---------------------------------------------

; Gaia: animation #00 of spm_darkspace_sprites (frames 100, 13, 13 and 13 ticks) played once per run; the script has no SetEntryHere, so it re-enters from the start and the animation repeats.

GaiaNpcSprite {
    COP [StageSpriteFrame] ( #00 ) ; Idle animation #00: 4 frames (100, 13, 13, 13 ticks); the script re-enters and repeats it
    COP [AnimOnce]
    RTL 
}

---------------------------------------------
; Voice effect: $24 is the switch (set to $FFFF by the dialogue routines, 0 otherwise). While on and an SFX is queued on channel 1 it shows a random sparkle frame: #01 (RNG 0 or 3), #02 (1) or #03 (2).

GaiaVoiceSparkle {
    COP [StageSprAndHitbox] ( #01 ) ; Sparkle sprite
    LDA #$0000
    STA $24               ; Activation flag (set by Gaia dialogue)

; Wait / test loop: yield, return unless $24 is set and sfxQueueCh1 is non-zero.

  loc_09A09E:
    COP [SetEntryHere]
    LDA $24
    BNE loc_09A0A5
    RTL 

  loc_09A0A5:
    LDA $sfxQueueCh1      ; SFX queued on channel 1
    BNE loc_09A0AB
    RTL 

; Pick a sparkle: RNG & 3 (1 -> #02, 2 -> #03, else #01).

  loc_09A0AB:
    COP [RngByte]         ; Random 0–3 to pick sparkle variant
    AND #$0003
    DEC                   ; 1 → frame #02
    BEQ loc_09A0C1
    DEC                   ; 2 → frame #03
    BEQ loc_09A0CC        ; 0 or 3 → frame #01 (default)
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    BRA loc_09A09E

; Sparkle variant #02: show one frame and return to the test loop.

  loc_09A0C1:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    BRA loc_09A09E

; Sparkle variant #03: show one frame and return to the test loop.

  loc_09A0CC:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    BRA loc_09A09E
}