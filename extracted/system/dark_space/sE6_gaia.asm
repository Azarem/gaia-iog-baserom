; Dark Space / Gaia actor — scene $E6 master controller for save, heal, transform, and ability systems.
; 
; Implements the complete Dark Space experience: Gaia dialogue (location-specific hints), HP healing,
; game save via SRAM, character form transformation (Will ↔ Freedan ↔ Shadow), and ability acquisition
; (Psycho Dash, Psycho Slider, Spin Dash, Dark Friar, Aura Barrier, Earthquaker).
; 
; === ACTOR ARCHITECTURE ===
; 
; The main actor-def spawns three child actors:
; - FireflySpawnerLoop: Firefly particle spawner (ambient VFX loop)
; - GaiaNpcSprite: Gaia NPC sprite (single idle frame)
; - GaiaVoiceSparkle: Gaia voice sparkle reactor (responds to SFX activity)
; 
; After spawning, SwitchCase on $0AB2 (Dark Space layout variant, capped at 3) dispatches to
; one of four room layouts:
; - Case 0 (DS_LayoutBasic): Basic Dark Space — Gaia statue only
; - Case 1 (DS_LayoutTransform): Form-dependent — adds transformation statue(s)
; - Case 2 (DS_LayoutAbility): Ability acquisition — scene-based ability orb
; - Case 3 (DS_LayoutSpecial): Special — redirects to case 1 with $0AAC=1
; 
; === DARK SPACE EXIT ($0B08–$0B12) ===
; 
; On exit, DarkSpaceExit reads the stored return state:
; - $0B12 → sceneNext (destination scene)
; - $0B08 → camera X position (×16 for tile-to-pixel)
; - $0B0C → camera Y position (+2, ×16)
; - $0B10 → $0652 (transition auxiliary data)
; Uses mosaic transition (gfxCacheIdxA = $0002) with brightness fade ($0101).
; 
; === GAIA DIALOGUE FLOW ===
; 
; 1. First visit: intro lore (flag $DC tracks first encounter)
; 2. HP check: if hurt, Gaia heals via damageFlashTimer = $28
; 3. Location hint: GaiaHintSceneTable maps sceneIDs to a 34-entry hint dispatch table
; 4. Save prompt: yes/no → SaveGameState_Scene → continue/rest prompt
; 
; === TRANSFORMATION SYSTEM ===
; 
; Three character forms, each with dedicated animation routines:
; - Will → Freedan: Transform_WillToFreedan (standing) / Transform_WillToFreedanAlt (alternate)
; - Will → Shadow: Transform_WillToShadow
; - Freedan → Will: Transform_FreedanToWill
; - Freedan → Shadow: Transform_FreedanToShadow
; - Shadow → Will: Transform_ShadowToWill
; - Shadow → Freedan: Transform_ShadowToFreedan
; 
; All transformations use spriteset #05 (transformation frames), play SFX $2525,
; spawn PaletteResetAndKillThinker, and call DarkSpaceRestoreControl to restore player control.
; 
; === ABILITY SYSTEM ===
; 
; AbilitySceneTable maps scene IDs to ability/statue flags (2 bytes per entry):
; - Byte 0: scene ID
; - Byte 1 low nibble: ability index (0–5)
; - Byte 1 high nibble: statue type (0 = Will/Freedan statue, nonzero = Shadow statue)
; 
; AbilityOrbActor spawns the ability orb actor, which checks abilityBitmask to skip already-learned
; abilities. On interaction, the orb grants the ability via abilityBitmask OR, plays acquisition
; music (#18), and shows the ability description dialogue.
---------------------------------------------

?INCLUDE 'actor_pool'
?INCLUDE 'player_character'
?INCLUDE 'save_system'
?INCLUDE 'shadow_shimmer'
?INCLUDE 'spriteset_enemies'

!sceneNext                      0642
!gfxCacheIdxA                   0648
!gfxCacheIdxB                   064A
!joypadMaskStd                  065A
!sfxQueueCh1                    06F8
!playerActor                    09AA
!playerFlags                    09AE
!displayModeFlags               09EC
!abilityBitmask                 0AA2
!playerMaxHp                    0ACA
!playerHp                       0ACE
!characterForm                  0AD4
!damageFlashTimer               0B22
!APUIO1                         2141
!orbitAngle                     7F0010
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sE6_gaia [
  actor-def < #00, #00, #23, {

  DarkSpaceMainInit:
    COP [SpawnAfterFlags] ( @FireflySpawnerLoop, #$2800 ) ; Firefly particle spawner
    COP [SpawnAfterAbsFlags] ( @GaiaNpcSprite, #$0080, #$0040, #$1800 ) ; Gaia NPC sprite at (128,64)
    COP [SpawnAfterAbsFlags] ( @GaiaVoiceSparkle, #$0080, #$0058, #$1800 ) ; Voice sparkle reactor at (128,88)
    LDA $0AAC             ; Dark Space layout variant
    CMP #$0004            ; Cap at 3 (valid range 0–3)
    BCC loc_08D7D3
    LDA #$0000            ; Invalid → default to layout 0

  loc_08D7D3:
    STA $0AB2             ; Store validated layout
    STZ $0AAC             ; Reset selection state
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08D7E2 ) ; Dispatch to room layout handler
} >
]

code_list_08D7E2 [
  &DS_LayoutBasic   ;00
  &DS_LayoutTransform   ;01
  &DS_LayoutAbility   ;02
  &DS_LayoutSpecial   ;03
]
---------------------------------------------

; Dark Space exit — masks input, plays dissolve animation, loads return scene from $0B08–$0B12.
; Converts stored tile positions to pixel coordinates (×16) for camera placement.
; Uses mosaic transition (gfxCacheIdxA=$0002) with brightness fade ($0101).

DarkSpaceExit {
    LDA #$FFF0            ; Mask all joypad input
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
    COP [SetMetasprite] ( @spriteset_enemies ) ; Transformation spriteset
    COP [StageSpriteFrame] ( #1C ) ; Exit dissolve frame
    COP [AnimOnce]
    COP [WaitByte] ( #1D ) ; Wait 29 frames for dissolve
    LDA $0B12             ; Return scene ID
    STA $sceneNext
    LDA $0B08             ; Return camera X (tile coords)
    ASL                   ; ×16: tile → pixel
    ASL 
    ASL 
    ASL 
    STA $064C             ; Camera target X
    LDA $0B0C             ; Return camera Y (tile coords)
    INC                   ; +2 tile offset
    INC 
    ASL                   ; ×16: tile → pixel
    ASL 
    ASL 
    ASL 
    STA $064E             ; Camera target Y
    LDA #$0003            ; Transition flags
    STA $0650
    LDA $0B10             ; Transition auxiliary data
    STA $0652
    STZ $0AAC             ; Reset selection state
    LDA #$0101            ; Brightness fade speed 1/1
    STA $gfxCacheIdxB
    LDA #$0002            ; Mosaic dissolve transition
    STA $gfxCacheIdxA
    COP [SetEntryHere]
    RTL 
}

---------------------------------------------
; Layout 0: Basic Dark Space — Gaia statue only (no transformation statues).
; Checks two tile regions: center statue (7,8)-(9,9) for Gaia interaction,
; and exit zone (5,D)-(B,F) to leave Dark Space.

DS_LayoutBasic {
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_BasicWait ) ; At Gaia statue → wait
    BRA loc_08D863
}

DS_BasicWait {
    RTL 

  loc_08D863:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_BasicTalkGaia ) ; At statue → talk to Gaia
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit ) ; At exit → leave Dark Space
    RTL 
}

DS_BasicTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry )
    BRA DS_LayoutBasic
}

---------------------------------------------
; Layout 1: Transformation Dark Space — dispatches to form-specific room with statue(s).
; Sub-dispatches on characterForm: 0=Will, 1=Freedan, 2=Shadow.
; Each sub-case applies BG changes to show/hide the appropriate transformation statues.

DS_LayoutTransform {
    LDA $characterForm    ; Current character form
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_08D888 ) ; Dispatch by form
}

code_list_08D888 [
  &DS_WillTransformRoom   ;00
  &DS_FreedanTransformRoom   ;01
  &DS_ShadowTransformRoom   ;02
]

---------------------------------------------
; Will's transformation room — shows both Freedan and Shadow statues (if flag $B4 set).
; Three interaction zones: center Gaia (7,8)-(9,9), left statue (3,A)-(5,B), right statue (B,A)-(D,B).

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

DS_WillInputWait {
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_WillTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_WillTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_WillTileWait )
    BRA loc_08D8C5
}

DS_WillTileWait {
    RTL 

  loc_08D8C5:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_WillTalkGaia )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_WillToFreedan )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_WillToShadow )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit )
    RTL 
}

DS_WillTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry ) ; Gaia statue → dialogue
    BRA DS_WillInputWait
}

DS_WillToFreedan {
    COP [CallNear] ( &FreedanTransformDialogue ) ; Left statue → Freedan transform
    BRA DS_WillInputWait
}

DS_WillToShadow {
    COP [CallNear] ( &ShadowTransformDialogue ) ; Right statue → Shadow transform
    BRA DS_WillInputWait
}

---------------------------------------------
; Freedan's transformation room — shows Will revert and Shadow statues (if flag $B4 set).

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

DS_FreedanInputWait {
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_FreedanTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_FreedanTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_FreedanTileWait )
    BRA loc_08D931
}

DS_FreedanTileWait {
    RTL 

  loc_08D931:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_FreedanTalkGaia )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_FreedanRevertWill )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_FreedanToShadow )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit )
    RTL 
}

DS_FreedanTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry ) ; Gaia statue → dialogue
    BRA DS_FreedanInputWait
}

DS_FreedanRevertWill {
    COP [CallNear] ( &WillRevertDialogue ) ; Left statue → revert to Will
    BRA DS_FreedanInputWait
}

DS_FreedanToShadow {
    COP [CallNear] ( &ShadowTransformDialogue ) ; Right statue → Shadow transform
    BRA DS_FreedanInputWait
}

---------------------------------------------
; Shadow's transformation room — shows Will revert and Freedan statues.
; All BG changes applied unconditionally (Shadow always has access to both).

DS_ShadowTransformRoom {
    COP [StageBgChange] ( #87 )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8D )
    COP [ApplyBgChange]
    COP [StageBgChange] ( #8F )
    COP [ApplyBgChange]

  loc_08D97A:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_ShadowTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_ShadowTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_ShadowTileWait )
    BRA loc_08D997
}

DS_ShadowTileWait {
    RTL 

  loc_08D997:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_ShadowTalkGaia )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_ShadowRevertWill )
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &DS_ShadowToFreedan )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit )
    RTL 
}

DS_ShadowTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry )
    BRA loc_08D97A
}

DS_ShadowRevertWill {
    COP [CallNear] ( &WillRevertDialogue )
    BRA loc_08D97A
}

DS_ShadowToFreedan {
    COP [CallNear] ( &FreedanTransformDialogue )
    BRA loc_08D97A
}

---------------------------------------------
; Layout 2: Ability acquisition Dark Space — looks up current scene in AbilitySceneTable to determine
; which ability orb to spawn and which statue type (Will/Freedan vs Shadow) to display.
; High nibble of lookup byte selects statue BG (0 = Will/Freedan #86, else = Shadow #8B).

DS_LayoutAbility {
    COP [StageBgChange] ( #8A )
    COP [ApplyBgChange]
    PHX 
    LDX #$0000

  loc_08D9D5:
    LDA $@AbilitySceneTable, X ; Search scene→ability table
    BEQ loc_08DA44        ; End of table → no ability for this scene
    AND #$00FF
    CMP $0B12             ; Match current scene ID?
    BEQ loc_08D9E7
    INX 
    INX 
    BRA loc_08D9D5

  loc_08D9E7:
    LDA $@AbilitySceneTable+1, X ; Read ability/statue flags
    AND #$00FF
    PLX 
    AND #$000F            ; Low nibble: statue type
    BEQ loc_08DA1C        ; 0 → Will/Freedan statue
    COP [StageBgChange] ( #86 ) ; Show Freedan/Will statue BG
    COP [ApplyBgChange]
    LDA #$0000            ; orbitAngle=0: Will/Freedan ability
    STA $orbitAngle, X
    COP [SpawnListAppend] ( @AbilityOrbActor, #00, #00, #$3800 ) ; Spawn ability orb actor
    LDA #$0040            ; Orb X position (64px)
    STA $0014, Y
    LDA #$006D            ; Orb Y position (109px)
    STA $0016, Y
    LDA $06
    STA $0026, Y
    BRA loc_08DA45

  loc_08DA1C:
    COP [StageBgChange] ( #8B ) ; Show Shadow statue BG
    COP [ApplyBgChange]
    LDA #$0001            ; orbitAngle=1: Shadow ability
    STA $orbitAngle, X
    COP [SpawnListAppend] ( @AbilityOrbActor, #00, #00, #$3800 ) ; Spawn ability orb actor
    LDA #$0040            ; Orb X position (64px)
    STA $0014, Y
    LDA #$0054            ; Orb Y position (84px)
    STA $0016, Y
    LDA $06
    STA $0026, Y
    BRA loc_08DA45

  loc_08DA44:
    PLX 

  loc_08DA45:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_AbilityTileWait )
    BRA loc_08DA52
}

DS_AbilityTileWait {
    RTL 

  loc_08DA52:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_AbilityTalkGaia )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit )
    RTL 
}

DS_AbilityTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry )
    BRA loc_08DA45

  loc_08DA6B:
    LDA $orbitAngle, X
    BNE loc_08DA77
    COP [CallNear] ( &WillRevertDialogue )
    BRA loc_08DA45

  loc_08DA77:
    COP [CallNear] ( &FreedanTransformDialogue )
    BRA loc_08DA45
}

---------------------------------------------
; Layout 3: Special Dark Space — forces $0AAC=1 and redirects to layout 1 (transformation room).

DS_LayoutSpecial {
    LDA #$0001            ; Force selection state to 1
    STA $0AAC
    JMP $&DS_LayoutTransform ; Redirect to form-dependent layout
}

---------------------------------------------
; Alternate ability room layout — Shadow statue plus Aura item interaction actor.
; Spawns AuraItemInteraction (Aura item handler) at position ($C0, $78).

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

  loc_08DAB4:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_AuraTileWait )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_AuraTileWait )
    BRA loc_08DAC9
}

DS_AuraTileWait {
    RTL 

  loc_08DAC9:
    COP [SetEntryHere]
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #09, &DS_AuraTalkGaia )
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &DS_AuraToShadow )
    COP [BranchIfPlayerInAbsTiles] ( #05, #0D, #0B, #0F, &DarkSpaceExit )
    RTL 
}

DS_AuraTalkGaia {
    COP [CallNear] ( &GaiaDialogueEntry )
    BRA loc_08DAB4
}

DS_AuraToShadow {
    COP [CallNear] ( &ShadowTransformDialogue )
    BRA loc_08DAB4
}

---------------------------------------------
; Gaia dialogue entry — first-visit intro (flag $DC), HP healing, then location-specific hint.
; After the intro, heals player via damageFlashTimer loop, then looks up the current scene
; in GaiaHintSceneTable to dispatch to one of 34 hint entries (GaiaHint_00–GaiaHint_TempShape).

GaiaDialogueEntry {
    LDA #$FFF0            ; Brief input mask
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 ) ; 5-frame delay
    LDA #$FFF0            ; Unmask input
    TRB $joypadMaskStd
    LDY $06               ; Get Gaia NPC actor link
    LDA #$FFFF            ; Disable NPC interaction
    STA $0024, Y
    COP [BranchOnFlagByte] ( #DC, #01, &GaiaHealAndHints ) ; Already met Gaia? → skip intro
    COP [SetFlagByte] ( #DC ) ; Mark first encounter
    COP [PrintDialogString] ( &dialogstring_08DD0B ) ; "I am Gaia..." intro
}

---------------------------------------------
; HP healing and location-specific hint dispatch.
; If HP < max, shows healing dialogue and loops damageFlashTimer until full.
; Then searches GaiaHintSceneTable for the current scene to dispatch a location hint.

GaiaHealAndHints {
    LDA $playerHp
    CMP $playerMaxHp      ; Already at full HP?
    BEQ loc_08DB37        ; Yes → skip healing
    COP [PrintDialogString] ( &dialogstring_08DE4D ) ; "It looks like you're hurt..."
    LDA #$FFF0            ; Mask input during heal
    TSB $joypadMaskStd
    LDA #$0028            ; 40 damage flash ticks = full heal
    STA $damageFlashTimer
    COP [SetEntryHere]    ; Loop each frame until healed
    LDA $playerHp
    CMP $playerMaxHp
    BEQ loc_08DB37        ; Healed → continue to hints
    RTL                   ; Not yet → re-enter next frame

  loc_08DB37:
    PHX 
    LDX #$0000

  loc_08DB3B:
    LDA $@GaiaHintSceneTable, X ; Scene→hint lookup table
    AND #$00FF
    BEQ loc_08DB9A        ; End of table → no hint for this scene
    CMP $0B12             ; Match current scene?
    BEQ loc_08DB4C
    INX 
    BRA loc_08DB3B

  loc_08DB4C:
    STX $0000             ; Store hint index
    PLX 
    COP [SwitchCase] ( #$0000, &code_list_08DB56 ) ; Dispatch to hint handler
}

code_list_08DB56 [
  &GaiaHint_00   ;00
  &GaiaHint_Jewels   ;01
  &GaiaHint_PsychoDash   ;02
  &GaiaHint_CastlianBoss   ;03
  &GaiaHint_04   ;04
  &GaiaHint_05   ;05
  &GaiaHint_06   ;06
  &GaiaHint_07   ;07
  &GaiaHint_08   ;08
  &GaiaHint_DarkFriar   ;09
  &GaiaHint_0A   ;0A
  &GaiaHint_0B   ;0B
  &GaiaHint_0C   ;0C
  &GaiaHint_0D   ;0D
  &GaiaHint_0E   ;0E
  &GaiaHint_MuContinent   ;0F
  &GaiaHint_PsychoSlider   ;10
  &GaiaHint_11   ;11
  &GaiaHint_12   ;12
  &GaiaHint_13   ;13
  &GaiaHint_SpinDash   ;14
  &GaiaHint_15   ;15
  &GaiaHint_16   ;16
  &GaiaHint_17   ;17
  &GaiaHint_AuraBarrier   ;18
  &GaiaHint_19   ;19
  &GaiaHint_1A   ;1A
  &GaiaHint_Earthquaker   ;1B
  &GaiaHint_AnkorWat   ;1C
  &GaiaHint_1D   ;1D
  &GaiaHint_AuraItem   ;1E
  &GaiaHint_1F   ;1F
  &GaiaHint_CometApproach   ;20
  &GaiaHint_TempShape   ;21
]
---------------------------------------------

; Save prompt — "Record what's happened so far?" with Record/Don't record options.
; Reached after Gaia's greeting + heal + optional hint dialogue.

loc_08DB9A {
    PLX 

  GaiaSavePrompt:
    LDA #$FFF0            ; Unmask input for menu navigation
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_08DDCB ) ; "Record what's happened so far?"
    COP [DialogueOptions] ( #02, #02, &code_list_08DBAB ) ; 2 options, cursor at 2nd
}

code_list_08DBAB [
  &GaiaDontRecord   ;00
  &GaiaSaveConfirm   ;01
  &GaiaDontRecord   ;02
]

---------------------------------------------
; "Record" option selected — save to SRAM and ask continue/rest.

GaiaSaveConfirm {
    LDA $0D8C             ; Current save slot number
    JSL $@save_system.SaveGameState_Scene ; Write event flags to SRAM
    COP [PlaySoundCh1] ( #29 ) ; Save confirmation jingle
    LDA #$FFF0            ; Mask input during jingle
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B ) ; Wait 59 frames for jingle
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_08DDFE ) ; "Continue your journey?"
    COP [DialogueOptions] ( #02, #01, &code_list_08DBD4 ) ; Yes/No
}

code_list_08DBD4 [
  &GaiaContinueJourney   ;00
  &GaiaDontRecord   ;01
  &GaiaContinueJourney   ;02
]

---------------------------------------------
; "Don't record" or "No" (stay) — "Then go." Re-enables NPC interaction and returns.

GaiaDontRecord {
    COP [PrintDialogString] ( &dialogstring_08DE43 ) ; "Then go."
    LDY $06
    LDA #$0000            ; Re-enable NPC interaction
    STA $0024, Y
    COP [RestoreSavedPtr]
}

---------------------------------------------
; "Yes" (continue journey) — plays rest dissolve animation and fades to Dark Space music.
; Re-enables NPC interaction, hides player, shows dissolve sprite, then loops with music fade.

GaiaContinueJourney {
    COP [PrintDialogString] ( &dialogstring_08DE32 ) ; "Then rest a while."
    LDY $06
    LDA #$0000            ; Re-enable NPC interaction
    STA $0024, Y
    LDA #$FFF0            ; Mask input during animation
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0010, Y          ; Hide player sprite
    ORA #$2000
    STA $0010, Y
    LDA $0014, Y          ; Copy player pos to this actor
    STA $14
    LDA $0016, Y
    STA $16
    COP [SetMetasprite] ( @spriteset_enemies ) ; Transformation spriteset
    LDA #$2000            ; Show this actor's sprite
    TRB $10
    COP [StageSpriteFrame] ( #1C ) ; Rest/dissolve frame
    COP [AnimOnce]
    COP [FadeThenStartMusic] ( #0E ) ; Fade to Dark Space ambient music
    COP [SetEntryHere]    ; Loop indefinitely (rest state)
    RTL 
}

GaiaHint_00 {
    JMP $&GaiaSavePrompt
}

GaiaHint_Jewels {
    COP [PrintDialogString] ( &dialogstring_08DED3 )
    JMP $&GaiaSavePrompt
}

GaiaHint_PsychoDash {
    COP [PrintDialogString] ( &dialogstring_08DF80 )
    JMP $&GaiaSavePrompt
}

GaiaHint_CastlianBoss {
    COP [PrintDialogString] ( &dialogstring_08DFEE )
    JMP $&GaiaSavePrompt
}

GaiaHint_04 {
    JMP $&GaiaSavePrompt
}

GaiaHint_05 {
    JMP $&GaiaSavePrompt
}

GaiaHint_06 {
    JMP $&GaiaSavePrompt
}

GaiaHint_07 {
    JMP $&GaiaSavePrompt
}

GaiaHint_08 {
    JMP $&GaiaSavePrompt
}

GaiaHint_DarkFriar {
    COP [PrintDialogString] ( &dialogstring_08E1EE )
    JMP $&GaiaSavePrompt
}

GaiaHint_0A {
    JMP $&GaiaSavePrompt
}

GaiaHint_0B {
    JMP $&GaiaSavePrompt
}

GaiaHint_0C {
    JMP $&GaiaSavePrompt
}

GaiaHint_0D {
    JMP $&GaiaSavePrompt
}

GaiaHint_0E {
    JMP $&GaiaSavePrompt
}

GaiaHint_MuContinent {
    COP [PrintDialogString] ( &dialogstring_08E2F8 )
    JMP $&GaiaSavePrompt
}

GaiaHint_PsychoSlider {
    COP [PrintDialogString] ( &dialogstring_08E3A7 )
    JMP $&GaiaSavePrompt
}

GaiaHint_11 {
    JMP $&GaiaSavePrompt
}

GaiaHint_12 {
    JMP $&GaiaSavePrompt
}

GaiaHint_13 {
    JMP $&GaiaSavePrompt
}

GaiaHint_SpinDash {
    COP [PrintDialogString] ( &dialogstring_08E428 )
    JMP $&GaiaSavePrompt
}

GaiaHint_15 {
    JMP $&GaiaSavePrompt
}

GaiaHint_16 {
    JMP $&GaiaSavePrompt
}

GaiaHint_17 {
    JMP $&GaiaSavePrompt
}

GaiaHint_AuraBarrier {
    COP [PrintDialogString] ( &dialogstring_08E4A4 )
    JMP $&GaiaSavePrompt
}

GaiaHint_19 {
    JMP $&GaiaSavePrompt
}

GaiaHint_1A {
    JMP $&GaiaSavePrompt
}

GaiaHint_Earthquaker {
    COP [PrintDialogString] ( &dialogstring_08E540 )
    JMP $&GaiaSavePrompt
}

GaiaHint_AnkorWat {
    COP [PrintDialogString] ( &dialogstring_08E58B )
    JMP $&GaiaSavePrompt
}

GaiaHint_1D {
    JMP $&GaiaSavePrompt
}

GaiaHint_AuraItem {
    LDA $0AAC
    BNE loc_08DCAF
    JMP $&GaiaSavePrompt

  loc_08DCAF:
    COP [BranchIfMissingItem] ( #24, &GaiaHint_AuraDesc )
    COP [GiveItem] ( #24, &GaiaHint_AuraFull )
    COP [PrintDialogString] ( &dialogstring_08E66C )
    LDA #$FFF0
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

  loc_08DCDF:
    COP [StartMusic] ( #16 )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_08E722 )
    JMP $&GaiaSavePrompt
}

GaiaHint_AuraDesc {
    COP [PrintDialogString] ( &dialogstring_08E722 )
    JMP $&GaiaSavePrompt
}

GaiaHint_AuraFull {
    COP [PrintDialogString] ( &dialogstring_08E800 )
    JMP $&GaiaSavePrompt
}

GaiaHint_1F {
    JMP $&GaiaSavePrompt
}

GaiaHint_CometApproach {
    COP [PrintDialogString] ( &dialogstring_08E853 )
    JMP $&GaiaSavePrompt
}

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

GaiaHintSceneTable #010B151E2628343D40424C5154565A60626C7C858699A1A3A7ACB6B8BBC3CCE0E3120000
---------------------------------------------

dialogstring_08DE96 `[DEF][CLR]I am Gaia, the source of[N]all life. I'll give you[N]some advice.[FIN]`

dialogstring_08DEC6 `[DEF][CLR]Hint Test[FIN]`

dialogstring_08DED3 `[PRT:@dialogstring_08DE96]When you defeat all the [N]enemies in an area, you [N]will get a jewel that [N]increases your abilities.[FIN]Push the Start Button[N]to see the locations of[N]your enemies.[FIN]Find the demons [N]and defeat them. [FIN]`

dialogstring_08DF80 `[PRT:@dialogstring_08DE96]Will's power - the [N]Psycho Dash. It can [N]destroy obstacles. [FIN]Always be alert. If you[N]find a suspicious place,[N]try to destroy it.[FIN]`

dialogstring_08DFEE `[PRT:@dialogstring_08DE96]Then you will fight[N]a huge enemy.[FIN]When he suffers damage, [N]rays of light will shoot [N]from his head. [FIN]If you suffer damage[N]hide behind him.[FIN]`

dialogstring_08E066 `[PRT:@dialogstring_08DE96]The door to the Gold[N]Ship is in a place paved[N]with gold tiles.[FIN]Listen to the melody [N]of the Incan spirit. [FIN]`

dialogstring_08E0C7 `[PRT:@dialogstring_08DE96]To defeat an enemy you[N]can't touch, think about[N]what happened under[N]Edward Castle.[FIN]`

dialogstring_08E109 `[PRT:@dialogstring_08DE96]The wall where the wind[N]blows...it's easy to[N]break through where[N]the stones are cracked.[FIN]If you can't find it, [N]listen for the only place [N]where the sound is[N]different. [FIN]`

dialogstring_08E19C `[PRT:@dialogstring_08DE96]The keys are on a grate[N]in the floor of the[N]mine. Find the laborer[N]who has them.[FIN]`

dialogstring_08E1EE `[PRT:@dialogstring_08DE96]Freedan's power - The[N]Dark Friar can defeat[N]enemies in places a[N]sword can't reach.[FIN]When you've defeated[N]all the enemies[N]the road will open up.[FIN]`

dialogstring_08E261 `[PRT:@dialogstring_08DE96]Take away the obstacle[N]in front, and the back[N]appears. Remove the[N]blocking pillar.[FIN]`

dialogstring_08E2B9 `[PRT:@dialogstring_08DE96]The switch on the floor [N]cannot be activated [N]by your weight. [FIN]`

dialogstring_08E2F8 `[PRT:@dialogstring_08DE96]When you started this [N]journey,  Mu began [N]to rise from the sea. [FIN]Sea water still covers [N]land in many places [N]on the continent. [FIN]When the water is gone [N]you will discover [N]the location of [N]Rama, King of Mu. [FIN]`

dialogstring_08E3A7 `[PRT:@dialogstring_08DE96]Will's power is the [N]Psycho Slider. Pass [N]through narrow corridors [N]using this power. [FIN]Be careful not to[N]overlook the cracks[N]in the cliff.[FIN]`

dialogstring_08E428 `[PRT:@dialogstring_08DE96]Will's power is the [N]Spin Dash. Use this to [N]climb hills and jump. [FIN]There are many hills at[N]the Great Wall of China.[N]Try everything.[FIN]`

dialogstring_08E4A4 `[PRT:@dialogstring_08DE96]Freedan's power is [N]the Aura Barrier. It [N]puts a layer of Aura [N]around his body. [FIN]Enemies at the mountain [N]temple are strong.If [N]you use this power, your [N]battles will be easier. [FIN]`

dialogstring_08E540 `[PRT:@dialogstring_08DE96]Freedan's Power is the [N]Earthquaker.[FIN]When he uses it,[N]his enemy can't move[N]for a long time.[FIN]`

dialogstring_08E58B `[DEF][CLR]This is the temple at[N]Ankor Wat.[FIN]It stands quietly in [N]the jungle and hides [N]its form when people [N]come near... [FIN]On this top floor you[N]will understand why you[N]made the journey.[FIN]`

dialogstring_08E615 `[PRT:@dialogstring_08DE96]The Pyramid is divided [N]into six blocks. [FIN]Use the Dark Power [N]previously obtained, in[N]each area. [FIN]`

dialogstring_08E66C `[DEF][CLR]I am Gaia, the source of[N]life. The Dark Power has[N]become strong in the[N]temple at Ankor Wat.[FIN]If you stand before the [N]right-hand statue, you [N]can change into Shadow, [N]the ultimate warrior.  [FIN]Then I think I will[N]grant you one item.[FIN]`

dialogstring_08E722 `[DEF][CLR]The Aura is Shadow's [N]mind. When he holds it [N]up, his body becomes [N]like water. [FIN]Only a small part of the[N]Pyramid is above ground.[N]Most of it is below[N]the surface.[FIN]You should change into[N]the Shadow and advance[N]into the underground.[FIN]`

dialogstring_08E7E7 `[DEF][CLR][DLY:9]You have the Aura![PAU:78][DLY:1][FIN]`

dialogstring_08E800 `[DEF][CLR]I am Gaia, the source of[N]life. I think I'll give[N]you one item.[FIN]Cut down on your[N]inventory and come back.[FIN]`

dialogstring_08E853 `[DEF][CLR]The comet draws near.[N]The time for your last[N]battle approaches.[FIN]This is the last time I[N]will talk to you like[N]this in this place.[FIN]With your rejuvenated [N]power, defeat the comet,[N]Dark Gaia and become [N]the Dark Knight. [FIN]Shadow's greatest power,[N]the Firebird, will arise[N]when you're one with [N]the Light Knight.[FIN]Only you can restore the [N]Earth to its original [N]condition. I'm putting [N]all my faith in you... [FIN]`

dialogstring_08E98A `[PRT:@dialogstring_08DE96]Your shape is only[N]temporary. Try standing[N]in front of the statue[N]next to you.[FIN]`
---------------------------------------------

; Ability orb actor — spawned near a transformation statue. Searches AbilitySceneTable for
; the current scene's ability. If already acquired (abilityBitmask match), dies immediately.
; Otherwise displays the orb sprite and waits for player to approach the statue.

AbilityOrbActor {
    PHX 
    LDX #$0000
    LDY #$0000            ; Y = entry index counter

  loc_08E9DB:
    LDA $@AbilitySceneTable, X ; Search for current scene
    BEQ loc_08E9EE        ; End of table → no ability here
    AND #$00FF
    CMP $0B12             ; Match scene ID?
    BEQ loc_08E9F1
    INX 
    INX 
    INY 
    BRA loc_08E9DB

  loc_08E9EE:
    PLX 
    COP [Die]             ; No ability for this scene → remove orb

  loc_08E9F1:
    LDA $@AbilitySceneTable+1, X ; Read ability flags byte
    AND #$00FF
    STA $24               ; Save for later abilityBitmask OR
    AND $abilityBitmask   ; Already have this ability?
    BNE loc_08E9EE        ; Yes → die
    TYA                   ; Store table index for dialogue lookup
    STA $0AAC
    PLX 
    COP [StageSprAndHitbox] ( #0A )
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #03, #0A, #05, #0B, &AbilityAcquisitionDispatch )
    RTL 
}

---------------------------------------------
; Ability acquisition — player reached the statue. Checks statue type and dispatches
; form-specific transformation. LookupStatueType returns 0 for Will/Freedan statue, 1 for Shadow.

AbilityAcquisitionDispatch {
    LDA #$FFF0            ; Mask input
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 ) ; Brief pause
    JSR $&LookupStatueType ; Check statue type for current scene
    CMP #$0000            ; 0 = Will/Freedan statue
    BEQ loc_08EA78        ; → revert to Will (if transformed)
    LDA $characterForm    ; Which form are we in?
    BEQ loc_08EA58        ; 0=Will → transform to Freedan
    CMP #$0002            ; 2=Shadow → transform to Freedan
    BEQ loc_08EA38
    BRA loc_08EA9B        ; 1=Freedan → already correct form

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
    LDA #$0800            ; Set ability-active flag
    TSB $playerFlags
    BRA loc_08EA9B

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
    LDA #$0800            ; Set ability-active flag
    TSB $playerFlags
    BRA loc_08EA9B

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
    LDA #$0800            ; Set ability-active flag
    TSB $playerFlags

  loc_08EA9B:
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $playerFlags
    BIT #$0800
    BEQ loc_08EAAA
    RTL 

  loc_08EAAA:
    COP [LoopStart] ( #08 ) ; 8-frame delay for transform
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [LoopEnd]
    LDA $24               ; Ability bit from table lookup
    ORA $abilityBitmask   ; Grant the new ability
    STA $abilityBitmask
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
    COP [StartMusic] ( #18 )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_08EB68 )
    COP [SetEntryHere]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_08EB0D
    RTL 

  loc_08EB0D:
    LDY $26
    LDA #$FFFF
    STA $0024, Y
    COP [PrintDialogString] ( &dialogstring_08EB85 )
    LDY $26
    LDA #$0000
    STA $0024, Y
    COP [StartMusic] ( #16 )
    COP [WaitByte] ( #3B )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [Die]
}
---------------------------------------------

; Scene→statue type lookup — searches AbilitySceneTable for current scene, returns high nibble
; of the flags byte. Returns 0 for Will/Freedan statue, nonzero for Shadow statue.
; Returns SEC if scene not found in table.

LookupStatueType {
    PHX 
    LDX #$0000

  loc_08EB33:
    LDA $@AbilitySceneTable, X
    BEQ loc_08EB57
    AND #$00FF
    CMP $0B12
    BEQ loc_08EB45
    INX 
    INX 
    BRA loc_08EB33

  loc_08EB45:
    LDA $@AbilitySceneTable+1, X
    AND #$00FF
    PLX 
    AND #$00F0
    BNE loc_08EB53
    RTS 

  loc_08EB53:
    LDA #$0001
    RTS 

  loc_08EB57:
    PLX 
    SEC 
    RTS 
}
---------------------------------------------

AbilitySceneTable #1501620286044210A720B8400000
---------------------------------------------

dialogstring_08EB68 `[DEF][DLY:9][ADR:&table_08EB8F,AAC][N]can now be used![PAU:78][FIN]`

dialogstring_08EB85 `[DEF][CLR][DLY:2][ADR:&table_08EBD3,AAC][END]`
---------------------------------------------

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

; Aura item interaction actor — spawned at the Shadow transformation statue.
; If player doesn't have Aura (item #24), offers it. If inventory full, shows error.
; After acquiring Aura, plays SFX music and shows description text.

AuraItemInteraction {
    COP [BranchIfMissingItem] ( #24, &AuraItemDie ) ; Already have Aura? → die
    COP [StageSprAndHitbox] ( #0A )
    LDA #$2000
    TRB $10

  AuraItemWaitLoop:
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &AuraItemGrant )
    RTL 
}

AuraItemGrant {
    LDA #$FFF0
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

  loc_08EFAD:
    LDY $26
    LDA #$FFFF
    STA $0024, Y
    COP [PrintDialogString] ( &dialogstring_08F003 )
    LDY $26
    LDA #$0000
    STA $0024, Y
    LDA #$FFF0
    TRB $joypadMaskStd
}

AuraItemDie {
    COP [Die]
}

AuraItemInventoryFull {
    LDA #$0800
    TRB $10
    COP [PrintDialogString] ( &dialogstring_08F060 )
    LDA #$0800
    TSB $10
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SetEntryHere]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    COP [BranchIfPlayerInAbsTiles] ( #0B, #0A, #0D, #0B, &AuraItemReturnToWait )
    JMP $&AuraItemWaitLoop
}

AuraItemReturnToWait {
    RTL 
}

dialogstring_08EFEF `[DEF][DLY:9]You have the Aura![FIN]`

dialogstring_08F003 `[DEF][CLR][DLY:2]Only Shadow can use[N]the Aura.[FIN]When you hold this up [N]Shadow's body will turn [N]to water and he can flow [N]underground. [END]`

dialogstring_08F060 `[DEF]Your inventory is full. [N]Store things somewhere [N]and return here. [END]`

---------------------------------------------
; Freedan transformation dialogue — checks form, shows first-visit lore (flag $F7),
; then sets player entry to the appropriate transformation handler.

FreedanTransformDialogue {
    LDA $characterForm
    CMP #$0001            ; Already Freedan?
    BEQ loc_08F0CA        ; Yes → skip (return to caller)
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
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

  loc_08F0CA:
    COP [RestoreSavedPtr]
}

FreedanTransformPrompt {
    COP [PrintDialogString] ( &dialogstring_08F12B )
    COP [DialogueOptions] ( #02, #02, &code_list_08F0D6 )
}

code_list_08F0D6 [
  &FreedanTransformDecline   ;00
  &FreedanTransformAccept   ;01
  &FreedanTransformDecline   ;02
]

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

FreedanTransformDecline {
    COP [PrintDialogString] ( &dialogstring_08F155 )
    COP [RestoreSavedPtr]
}

dialogstring_08F12B `[TPL:B]Change into the Dark [N]Knight, Freedan? [N] Yes [N] No `

dialogstring_08F155 `[CLD]`

dialogstring_08F157 `[TPL:B][CLR][TPL:0]Will hears a voice [N]in his head. [FIN][TPL:4]Will. [N]I've been waiting a long [N]time for you to come. [FIN]I am Freedan.[N]I am eternal.[FIN]Let me help you on [N]your journey. As time [N]goes by, you'll come to [N]understand my nature.... [FIN][PAL:0]Will gradually loses [N]consciousness... [N][END]`
---------------------------------------------

; Will → Freedan transformation (standing animation).
; Uses spriteset #05 (transformation frames). Spawns PaletteResetAndKillThinker for color transition.

Transform_WillToFreedan {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteLoop] ( #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #03, #02 )
    COP [AnimLoop]
    COP [SpawnThinkerParam] ( #0C, @actor_pool.PaletteResetAndKillThinker )
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

; Will → Freedan transformation (alternate animation — single-frame sequence).

Transform_WillToFreedanAlt {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #0C, @actor_pool.PaletteResetAndKillThinker )
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

; Shadow → Freedan transformation. Uses SetEntryExit to mark exit after palette reset.

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
    COP [SpawnThinkerParam] ( #0C, @actor_pool.PaletteResetAndKillThinker )
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

; Revert to Will dialogue — "Return to young Will?" yes/no prompt.
; If already Will (form 0), immediately returns via RestoreSavedPtr.

WillRevertDialogue {
    LDA $characterForm    ; Already Will?
    BNE loc_08F2E6        ; No → show transform prompt
    COP [RestoreSavedPtr] ; Already Will → nothing to do

  loc_08F2E6:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_08F357 )
    COP [DialogueOptions] ( #02, #01, &code_list_08F2FF )
}

code_list_08F2FF [
  &WillRevertDecline   ;00
  &WillRevertAccept   ;01
  &WillRevertDecline   ;02
]

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

WillRevertDecline {
    COP [PrintDialogString] ( &dialogstring_08F37B )
    COP [RestoreSavedPtr]
}

dialogstring_08F357 `[TPL:B]Return to young Will? [N] Yes [N] No `

dialogstring_08F37B `[CLD]`
---------------------------------------------

; Freedan → Will revert animation. Plays reverse of Will→Freedan sequence.

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
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker ) ; Reset palette
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

; Shadow → Will revert animation. Plays Shadow dissolve, then Freedan reverse, back to Will.

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
    COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker )
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

; Shadow transformation dialogue — requires flag $B4 (unlocked at Ankor Wat).
; First visit shows lore text (flag $DD). Subsequent visits offer yes/no prompt.
; If already Shadow (form 2), immediately returns.

ShadowTransformDialogue {
    COP [BranchOnFlagByte] ( #B4, #00, &ShadowTransformLocked ) ; Flag $B4 not set → Shadow locked
    LDA $characterForm
    CMP #$0002            ; Already Shadow?
    BEQ ShadowTransformLocked ; Yes → nothing to do
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #05 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [BranchOnFlagByte] ( #DD, #01, &ShadowTransformPrompt )
    COP [SetFlagByte] ( #DD )
    COP [PrintDialogString] ( &dialogstring_08F4B1 )
    LDA $characterForm
    BEQ loc_08F436
    BRA loc_08F456
}

ShadowTransformLocked {
    COP [RestoreSavedPtr]
}

ShadowTransformPrompt {
    COP [PrintDialogString] ( &dialogstring_08F47C )
    COP [DialogueOptions] ( #02, #02, &code_list_08F427 )
}

code_list_08F427 [
  &ShadowTransformDecline   ;00
  &ShadowTransformAccept   ;01
  &ShadowTransformDecline   ;02
]

ShadowTransformAccept {
    COP [PrintDialogString] ( &dialogstring_08F4AF )
    LDA $characterForm
    BNE loc_08F456

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

ShadowTransformDecline {
    COP [PrintDialogString] ( &dialogstring_08F4AF )
    COP [RestoreSavedPtr]
}

dialogstring_08F47C `[TPL:B]Change to the ultimate[N]Dark warrior, Shadow? [N] Yes [N] No `

dialogstring_08F4AF `[CLD]`

dialogstring_08F4B1 `[TPL:B]A voice echoes inside[N]his head.[FIN][TPL:4]I've been waiting for[N]you to come.[FIN]I am made from the light[N]of a comet. The ultimate[N]warrior, Shadow.[FIN]My body has no shape.[N]This body appears only[N]when the human[N]consciousness evolves.[FIN]The comet that now [N]approaches Earth is [N]also a consciousness [N]without form. [FIN]My body is the only[N]thing that can confront[N]the comet and[N]bring it to an end.[FIN]Well, close your eyes...[PAL:0][END]`
---------------------------------------------

; Will → Shadow transformation. Spawns ShadowShimmerInit for the visual shimmer effect.

Transform_WillToShadow {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #6C, @actor_pool.PaletteResetAndKillThinker )
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

; Freedan → Shadow transformation. Same shimmer effect as Will→Shadow.

Transform_FreedanToShadow {
    COP [SetPlayerSpriteDirect] ( #05 )
    COP [StageSpriteFrame] ( #07 )
    COP [AnimOnce]
    COP [PlaySoundBoth] ( #$2525 )
    COP [StageSpriteFrame] ( #09 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #08 )
    COP [AnimOnce]
    COP [SpawnThinkerParam] ( #6C, @actor_pool.PaletteResetAndKillThinker )
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

; Dark Space ambient particle — sets display-filtered flag for background rendering.

DarkSpaceAmbientParticle [
  actor-def < #02, #00, #28, {

  DS_AmbientParticleInit:
    LDA #$1000            ; Display-filtered flag
    TSB $12
} >
]

---------------------------------------------
; Firefly spawner loop — continuously spawns individual firefly particles with random timing.
; RNG byte × 8 → variable delay between spawns. Loops indefinitely.

FireflySpawnerLoop {
    COP [SetEntryHereAndYield]
    COP [RngByte]         ; Random 0–255
    AND #$000F            ; Mask to 0–15
    ASL                   ; ×8 → 0–120 frame delay
    ASL 
    ASL 
    STA $08               ; Set as frame timer
    COP [SpawnAfterFlags] ( @FireflyParticle, #$1B02 ) ; Spawn one firefly
    BRA FireflySpawnerLoop ; Loop forever
}

---------------------------------------------
; Individual firefly particle — random X position, drifts upward with slight horizontal movement.
; Dies when Y exceeds $FF (off screen top).

FireflyParticle {
    LDA #$1000            ; Display-filtered
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
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
    STA $moveXAlt, X      ; Horizontal drift speed
    DEC 
    STA $moveYAlt, X      ; Vertical rise speed (slightly less)

  loc_08F6C4:
    COP [ReloadMoveDurations]
    COP [SetEntryHere]
    COP [AnimOnce]
    LDA $16
    CMP #$00FF
    BCC loc_08F6C4
    COP [Die]
}
---------------------------------------------

; Restore player control after transformation — resets entry point to PlayerIdleEntry,
; clears movement overrides, restores grounded state, unmasks joypad, clears ability-active flag.

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
    AND #$FDFF            ; Clear bit 9 (game over flag)
    ORA #$0008            ; Set bit 3 (grounded/collision)
    STA $0010, X
    LDA #$0F00            ; Unmask D-pad and face buttons
    TRB $joypadMaskStd
    LDA #$0800            ; Clear ability-active flag
    TRB $playerFlags
    PLX 
    RTS 
}
---------------------------------------------

; Gaia NPC idle sprite — single animation frame, runs once and returns.

GaiaNpcSprite {
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    RTL 
}

---------------------------------------------
; Gaia voice sparkle reactor — monitors sfxQueueCh1 and plays random sprite frames
; when sound effects are active. Creates a visual "speaking" effect synced to audio.

GaiaVoiceSparkle {
    COP [StageSprAndHitbox] ( #01 ) ; Sparkle sprite
    LDA #$0000
    STA $24               ; Activation flag (set by Gaia dialogue)

  loc_09A09E:
    COP [SetEntryHere]
    LDA $24
    BNE loc_09A0A5
    RTL 

  loc_09A0A5:
    LDA $sfxQueueCh1
    BNE loc_09A0AB
    RTL 

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

  loc_09A0C1:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    BRA loc_09A09E

  loc_09A0CC:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryHere]
    COP [AnimOneFrame]
    BRA loc_09A09E
}