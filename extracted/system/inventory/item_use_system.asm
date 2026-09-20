; Item use dispatch and handler system (230416–237738, Bank 03).
; 
; Contains the complete inventory item usage pipeline. When the player activates an equipped item, ItemUseDispatch reads the slot index, extracts the 6-bit item ID ($00–$3F), and dispatches through a 64-entry jump table to the appropriate handler. Each handler returns via RTS into ItemUseEpilogue, which runs a dialogue frame update and suppresses Start button re-entry.
; 
; === HANDLER PATTERNS ===
; 
; 1. Display-only: Print a description and return. No gameplay effect. Used for story items (Lance Letter, Lilly Necklace, Will, Crystal Ring, Prize Money, Black Glasses, Bill & Lola Letter, Father's Journal).
; 
; 2. Scene-gated key items: Check sceneCurrent for the target location, verify the player's tile position via BranchIfPlayerInAbsTiles, then activate (remove item, set event flag, optionally modify tilemap). Prints failure message if location doesn't match. Used for keys (Prison, Elevator, Mine A/B, Seaside Palace), placement items (Diamond Block, Inca Statues A/B, Crystal Ball, Purification Stone, Statue of Hope, Rama Statue, Magic Powder, Teapot), and consumable quest items (Smoked Meat, Mushroom Water, Gorgon Flower).
; 
; 3. Melody items: Wind Melody, Lola's Melody, and Memory Melody share FluteMusicActorController for music playback. Requires Will (form 0). Each melody handler verifies the target scene, spawns the music actor with a melody index ($20 = 0/1/2), and the controller manages the full SPC upload → playback → poll → effect → restore cycle.
; 
; 4. Dialogue option items: Herb (yes/no heal), Journal (3 topics), Hieroglyph Plates (6-slot puzzle with swap logic).
; 
; === SHARED HELPERS ===
; 
; RemoveEquippedItem: Clears the equipped slot byte, resets inventoryEquippedType to 0, and sets inventoryEquippedIndex to $FFFF (no selection).
; 
; FluteMusicActorController: Multi-phase actor orchestrating melody playback — suppresses input, spawns SPC transfer actors, overrides the player to a static pose, polls for music completion, dispatches to the melody-specific *_Effect handler via SwitchCase, then restores background music.
; 
; SetPlayerTransition: Sets the player actor's function pointer and clears its frame timer. Used by melody handlers and UseItem_Aura to override player behavior.
; 
; === SPECIAL MECHANICS ===
; 
; Red Jewel: BCD arithmetic (SED/CLD) for decimal jewel counter. Spawns an orbit visual effect that expands from diameter 1 to 255 via ApplyOrbitalOffsetFromRef.
; 
; Hieroglyph Plates: Items $1E–$23 share one handler. Plate ID = item − $1E. Six slots stored at $0B28 (word each, $FFFF = empty). Placing a plate in an occupied slot swaps the old plate back to inventory via GiveItemToPlayer.
; 
; Aura: Shadow-only (form 2), requires stationary player with no active dialogue/cutscene flags. Triggers transformation via player actor function pointer override to PlayerAuraTransformEntry.
; 
; Gorgon Flower: Three independent petal flags ($BF/$C0/$C1). Item is only removed when all three are set — partial placement persists across visits.
; 
; === WRAM VARIABLES ===
; 
; $0AA6: Current hieroglyph plate ID (item index − $1E)
; $0AAC: Hieroglyph slot selection (0–5)
; $0B28: Hieroglyph slot table (6 words; $FFFF = empty, else plate ID)
---------------------------------------------

?BANK 03

?INCLUDE 'actor_pool'
?INCLUDE 'ambient_palette_cycler'
?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'hdma_dma_spc'
?INCLUDE 'inventory_mgmt'
?INCLUDE 'music_actors'
?INCLUDE 'player_transition_handlers'
?INCLUDE 'spriteset_enemies'
?INCLUDE 'system_core'

!sceneCurrent                   0644
!joypadHeld                     0658
!joypadMaskStd                  065A
!musicParentActor               06F2
!musicTransitionState           06FA
!playerXTile                    09A6
!playerYTile                    09A8
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!displayModeFlags               09EC
!jewelsCollected                0AB0
!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!inventoryEquippedType          0AC6
!characterForm                  0AD4
!damageFlashTimer               0B22
!APUIO1                         2141
!chatPtr                        7F000A
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

; Entry point for inventory item usage.
; 
; Pushes ItemUseEpilogue−1 as an RTS-trick return address so each handler can simply RTS to reach the cleanup code. Reads the equipped slot index from inventoryEquippedIndex — if negative ($FFFF = nothing equipped), jumps to UseItem_None. Otherwise reads the item byte from inventorySlots, masks to a 6-bit item ID ($00–$3F), doubles it for a word-sized jump table index, suppresses the Start button ($4000 in joypadHeld) to prevent menu re-entry, and dispatches through ItemHandlerJumpTable via indirect JMP.

ItemUseDispatch {
    PEA $&ItemUseEpilogue-1 ; Push epilogue return — each handler returns via RTS into ItemUseEpilogue
    LDY $inventoryEquippedIndex ; Equipped slot index; $FFFF (negative) = nothing equipped → UseItem_None
    BPL loc_03841B
    JMP $&UseItem_None

  loc_03841B:
    LDA $inventorySlots, Y ; Read item byte, mask to 6-bit ID ($00–$3F), double for word table index
    AND #$00FF
    AND #$003F
    ASL 
    TAX 
    LDA #$4000            ; Suppress Start ($4000) to prevent menu re-open during item use
    TSB $joypadHeld
    JMP ($&ItemHandlerJumpTable, X) ; Dispatch to item handler via indirect JMP through the 64-entry table
}

---------------------------------------------
; Post-handler cleanup for item use. Calls UpdateFrameDialogue to process one frame of dialogue/UI, re-suppresses the Start button ($4000), restores processor flags, and returns to the caller via RTL.

ItemUseEpilogue {
    SEP #$20
    JSL $@system_core.UpdateFrameDialogue ; Run one dialogue/UI frame between item handler and menu return
    REP #$20
    LDA #$4000            ; Re-suppress Start in case dialogue processing cleared the flag
    TSB $joypadHeld
    PLP 
    RTL 
}

---------------------------------------------
; 64-entry word table mapping item IDs $00–$3F to handler addresses.
; 
; Entries $00–$28 point to individual item handlers. Entries $29–$3F are unused and all point to UseItem_Unused (a single RTS). Items $1E–$23 (Hieroglyph Plates) all share UseItem_HieroglyphPlate.

ItemHandlerJumpTable [
  &UseItem_None   ;00
  &UseItem_RedJewel   ;01
  &UseItem_PrisonKey   ;02
  &UseItem_IncaStatueA   ;03
  &UseItem_IncaStatueB   ;04
  &UseItem_IncanMelody   ;05
  &UseItem_Herb   ;06
  &UseItem_DiamondBlock   ;07
  &UseItem_WindFlute   ;08
  &UseItem_LolaMelody   ;09
  &UseItem_SmokedMeat   ;0A
  &UseItem_MineKeyA   ;0B
  &UseItem_MineKeyB   ;0C
  &UseItem_MemoryMelody   ;0D
  &UseItem_CrystalBall   ;0E
  &UseItem_ElevatorKey   ;0F
  &UseItem_SeasidePalaceKey   ;10
  &UseItem_PurificationStone   ;11
  &UseItem_StatueOfHope   ;12
  &UseItem_RamaStatue   ;13
  &UseItem_MagicPowder   ;14
  &UseItem_Journal   ;15
  &UseItem_LanceLetter   ;16
  &UseItem_LillyNecklace   ;17
  &UseItem_Will   ;18
  &UseItem_Teapot   ;19
  &UseItem_MushroomWater   ;1A
  &UseItem_PrizeMoney   ;1B
  &UseItem_BlackGlasses   ;1C
  &UseItem_GorgonFlower   ;1D
  &UseItem_HieroglyphPlate   ;1E
  &UseItem_HieroglyphPlate   ;1F
  &UseItem_HieroglyphPlate   ;20
  &UseItem_HieroglyphPlate   ;21
  &UseItem_HieroglyphPlate   ;22
  &UseItem_HieroglyphPlate   ;23
  &UseItem_Aura   ;24
  &UseItem_BillLolaLetter   ;25
  &UseItem_FatherJournal   ;26
  &UseItem_CrystalRing   ;27
  &UseItem_Apple   ;28
  &UseItem_Unused   ;29
  &UseItem_Unused   ;2A
  &UseItem_Unused   ;2B
  &UseItem_Unused   ;2C
  &UseItem_Unused   ;2D
  &UseItem_Unused   ;2E
  &UseItem_Unused   ;2F
  &UseItem_Unused   ;30
  &UseItem_Unused   ;31
  &UseItem_Unused   ;32
  &UseItem_Unused   ;33
  &UseItem_Unused   ;34
  &UseItem_Unused   ;35
  &UseItem_Unused   ;36
  &UseItem_Unused   ;37
  &UseItem_Unused   ;38
  &UseItem_Unused   ;39
  &UseItem_Unused   ;3A
  &UseItem_Unused   ;3B
  &UseItem_Unused   ;3C
  &UseItem_Unused   ;3D
  &UseItem_Unused   ;3E
  &UseItem_Unused   ;3F
]

---------------------------------------------
; No item equipped — prints a generic message and returns.

UseItem_None {
    COP [PrintDialogString] ( &dialogstring_0384C4 )
    RTS 
}

dialogstring_0384C4 `[DEF]You're not equipped.[END]`

---------------------------------------------
; Red Jewel handler — increments the jewel counter and spawns a visual orbit effect.
; 
; Removes the jewel from inventory, then uses BCD arithmetic (SED/CLD-bracketed addition) to increment the packed-decimal counter at jewelsCollected ($0AB0). Switches DP to the player actor slot and spawns a child actor (code_038566) at the player's position with display-filter flags ($2000). The child sets up a second actor (code_038576) that performs the orbiting jewel animation. Copies the player's XY position to the spawned actor and sets its OAM priority to $3000.

UseItem_RedJewel {
    COP [PrintDialogString] ( &dialogstring_038517 )
    JSR $&RemoveEquippedItem
    SED                   ; BCD mode: jewelsCollected is packed decimal, not binary — SED/CLD bracket
    LDA $jewelsCollected
    CLC 
    ADC #$0001
    STA $jewelsCollected
    CLD 
    PHX 
    PHD 
    LDA $playerActor      ; Switch DP to player actor slot for SpawnLastRel relative base position
    TCD 
    TAX 
    COP [SpawnLastRel] ( @code_038566, #00, #00, #$2000 ) ; Spawn orbit visual effect at player position; $2000 = display-filtered actor
    TYX 
    LDA #$0000            ; Clear spawned actor flags ($0012), set OAM priority $3000 ($000E)
    STA $0012, X
    LDA #$3000
    STA $000E, X
    LDY $playerActor      ; Copy player X/Y position to spawned orbit actor
    LDA $0014, Y
    STA $0014, X
    LDA $0016, Y
    STA $0016, X
    PLD 
    PLX 
    RTS 
}

dialogstring_038517 `[DEF]He raised the Red Jewel![FIN]Red Jewels[N]fly to Jeweler Gem's in[N]a single ray of light![END]`

code_038566 {
    COP [SpawnMarkedAfter] ( @code_038576, #$1002 )
    COP [LoopInit] ( #FF )
    DEC $16
    COP [LoopNext]
    COP [Die]
}

code_038576 {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSprAndHitbox] ( #02 )
    LDA #$0001            ; Initialize orbit parameters: angle = 1, diameter = 1
    STA $orbitAngle, X
    STA $orbitDiameter, X
    COP [PlaySoundCh2] ( #25 )

  loc_03858C:
    COP [AnimOneFrame]    ; Wait for sprite animation to produce a frame before starting orbital motion
    LDA $2A
    BEQ loc_03858C
    LDA $08               ; Save frame wait counter as orbit expansion duration
    STZ $08
    STA $26

  loc_038598:
    LDY $24               ; Orbital motion loop: load parent ref, apply circular offset each frame
    JSL $@ApplyOrbitalOffsetFromRef
    COP [SetEntryExit]
    LDA $orbitAngle, X    ; Advance orbit angle by 2 per frame for rotation speed
    CLC 
    ADC #$0002
    STA $orbitAngle, X
    LDA $orbitDiameter, X ; Expand orbit diameter +1 each frame; at max 255 → actor dies
    CMP #$00FF
    BEQ loc_0385C0
    INC 
    STA $orbitDiameter, X
    DEC $26               ; Repeat expansion for saved frame count, then re-animate and expand more
    BPL loc_038598
    BRA loc_03858C

  loc_0385C0:
    COP [Die]
}

---------------------------------------------
; Prison Key — unlocks doors in Edward's Castle underground (scene $0B).
; 
; Checks two tile regions: Door A at tiles ($0E,$10)–($10,$11) and Door B at ($0A,$17)–($0C,$18). Each door has an independent flag ($24 and $42 respectively). If used at the wrong location or the door is already open, prints a failure message. This is the first instance of the scene-gated key item pattern used by many handlers in this file.

UseItem_PrisonKey {
    LDA $sceneCurrent     ; Scene $0B = Edward's Castle underground prison
    CMP #$000B
    BNE loc_03861A
    COP [BranchIfPlayerInAbsTiles] ( #0E, #10, #10, #11, &code_0385DC ) ; Door A: tiles ($0E,$10)–($10,$11)
    COP [BranchIfPlayerInAbsTiles] ( #0A, #17, #0C, #18, &code_0385FF ) ; Door B: tiles ($0A,$17)–($0C,$18)
    BRA loc_03861A
}

code_0385DC {
    COP [BranchIfFlagByte] ( #24, #01, &code_038615 )
    COP [PrintDialogString] ( &dialogstring_03861F )
    COP [StageBgChange] ( #06 ) ; BG change #06 removes the prison door tiles from the tilemap
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0106 ) ; Flag word $0106 and flag byte $24 track first door unlock
    COP [SetFlagByte] ( #24 )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [ClearLowAbs] ( #0E, #11 ) ; Clear collision tiles for both door columns at Y=$11
    COP [ClearLowAbs] ( #0F, #11 )
    RTS 
}

code_0385FF {
    COP [BranchIfFlagByte] ( #42, #01, &code_038615 )
    COP [PrintDialogString] ( &dialogstring_03861F )
    COP [SetFlagByte] ( #42 )
    COP [PlaySoundBoth] ( #$0E0E )
    COP [ClearHighAbs] ( #09, #17 )
    RTS 
}

code_038615 {
    COP [PrintDialogString] ( &dialogstring_038680 )
    RTS 

  loc_03861A:
    COP [PrintDialogString] ( &dialogstring_03865D )
    RTS 
}

dialogstring_03861F `[DEF]As he turns the [N]prison key, the steel [N]door opens with a [N]dull sound. [END]`

dialogstring_03865D `[DEF]There's no keyhole for[N]the prison key.[END]`

dialogstring_038680 `[DEF]The door is open. [END]`

---------------------------------------------
; Inca Statue A — place on the mantel in Inca Ruins (scene $1E).
; 
; Checks primary mantel position at tiles ($37–$38, $12–$13). If correct, places the statue (removes item, sets flag $30). Falls through to UseItem_IncaStatueA_CheckAlt for the alternate mantel position.

UseItem_IncaStatueA {
    LDA $sceneCurrent
    CMP #$001E
    BNE loc_0386FA
    LDA $playerYTile
    CMP #$0012
    BEQ loc_0386A6
    CMP #$0013
    BNE loc_0386EA

  loc_0386A6:
    LDA $playerXTile
    CMP #$0037
    BEQ loc_0386B3
    CMP #$0038
    BNE loc_0386EA

  loc_0386B3:
    COP [PrintDialogString] ( &dialogstring_0386BE )
    COP [RemoveItem] ( #03 )
    COP [SetFlagByte] ( #30 )
    RTS 
}

dialogstring_0386BE `[DEF]He set Inca Statue [N]A on the mantel. [END]`

---------------------------------------------
; Alternate position check for Inca Statue A.
; 
; Checks tiles ($26–$27, $15–$16). If this is where Statue B belongs, prints a shape mismatch message (code_03876D). If neither mantel matches and flag $44 is set, prints the spirits hint; otherwise prints a generic query about the Inca secret.

UseItem_IncaStatueA_CheckAlt {
    LDA $playerYTile
    CMP #$0015
    BEQ loc_0386EA
    CMP #$0016
    BNE loc_0386FA

  loc_0386EA:
    LDA $playerXTile
    CMP #$0026
    BNE loc_0386F5
    JMP $&code_03876D

  loc_0386F5:
    CMP #$0027
    BNE loc_0386FA

  loc_0386FA:
    COP [BranchIfFlagByte] ( #44, #00, &code_038705 )
    COP [PrintDialogString] ( &dialogstring_03870A )
    RTS 
}

code_038705 {
    COP [PrintDialogString] ( &dialogstring_038746 )
    RTS 
}

dialogstring_03870A `[DEF]He said to dedicate the [N]statues where the [N]breath of the spirits [N]can't reach. [END]`

dialogstring_038746 `[DEF]Is the Inca secret[N]hidden in the statue?[END]`

code_03876D {
    COP [PrintDialogString] ( &dialogstring_038772 )
    RTS 
}

dialogstring_038772 `[DEF]The shape of the mantel [N]doesn't match the [N]shape of the statue. [END]`

---------------------------------------------
; Inca Statue B — place on the alternate mantel in Inca Ruins (scene $1E).
; 
; Mirror structure of UseItem_IncaStatueA but checks the alternate mantel position first ($26–$27, $15–$16). If correct, places the statue (removes item, sets flag $31). Falls through to UseItem_IncaStatueB_CheckAlt.

UseItem_IncaStatueB {
    LDA $sceneCurrent
    CMP #$001E
    BNE loc_03880D
    LDA $playerYTile
    CMP #$0015
    BEQ loc_0387BC
    CMP #$0016
    BNE loc_038800

  loc_0387BC:
    LDA $playerXTile
    CMP #$0026
    BEQ loc_0387C9
    CMP #$0027
    BNE loc_038800

  loc_0387C9:
    COP [PrintDialogString] ( &dialogstring_0387D4 )
    COP [RemoveItem] ( #04 )
    COP [SetFlagByte] ( #31 )
    RTS 
}

dialogstring_0387D4 `[DEF]He set Inca Statue [N]B on the mantel. [END]`

---------------------------------------------
; Alternate position check for Inca Statue B. Same logic as UseItem_IncaStatueA_CheckAlt but with swapped mantel positions.

UseItem_IncaStatueB_CheckAlt {
    LDA $playerYTile
    CMP #$0012
    BEQ loc_038800
    CMP #$0013
    BNE loc_03880D

  loc_038800:
    LDA $playerXTile
    CMP #$0037
    BEQ loc_038818
    CMP #$0038
    BNE loc_03880D

  loc_03880D:
    COP [BranchIfFlagByte] ( #44, #00, &code_038705 )
    COP [PrintDialogString] ( &dialogstring_03870A )
    RTS 

  loc_038818:
    COP [PrintDialogString] ( &dialogstring_038772 )
    RTS 
}

---------------------------------------------
; Incan Melody — play for the mayor in Itory Village (scene $18).
; 
; Prints the performance message. In scene $18 only, sets flag $2E (triggers mayor reaction) and prints the result. Otherwise prints 'nothing happened.'

UseItem_IncanMelody {
    COP [PrintDialogString] ( &dialogstring_038836 )
    LDA $sceneCurrent
    CMP #$0018
    BNE loc_038831
    COP [SetFlagByte] ( #2E )
    COP [PrintDialogString] ( &dialogstring_03885A )
    RTS 

  loc_038831:
    COP [PrintDialogString] ( &dialogstring_03887A )
    RTS 
}

dialogstring_038836 `[DEF]Will softly played the [N]Incan melody. [FIN]`

dialogstring_03885A `The Mayor's expression[N]changed![END]`

dialogstring_03887A `But nothing happened.[END]`

---------------------------------------------
; Herb — healing item with yes/no confirmation.
; 
; Prints 'Take the medicine?' and presents a 2-choice dialogue (Yes/No). Selecting Yes triggers damageFlashTimer = 8 (initiates HP restoration flash effect), removes the herb from inventory. Selecting No cancels with a message.

UseItem_Herb {
    COP [PrintDialogString] ( &dialogstring_0388AD )
    COP [DialogueOptions] ( #02, #01, &code_list_038894 )
}

code_list_038894 [
  &code_0388A8   ;00
  &code_03889A   ;01
  &code_0388A8   ;02
]

code_03889A {
    COP [PrintDialogString] ( &dialogstring_0388E9 )
    LDA #$0008            ; damageFlashTimer = 8 triggers the HP restoration flash effect
    STA $damageFlashTimer
    JSR $&RemoveEquippedItem ; Consume the herb — remove from equipped slot
    RTS 
}

code_0388A8 {
    COP [PrintDialogString] ( &dialogstring_0388CA )
    RTS 
}

dialogstring_0388AD `[DEF]Take the medicine?[N] Yes[N] No`

dialogstring_0388CA `[CLR]He stopped eating [N]the herb. [END]`

dialogstring_0388E9 `[CLR]Eating the herb, he [N]regained his strength. [END]`

---------------------------------------------
; Diamond Block — fit into a tile slot in the Diamond Mine (scene $25).
; 
; Checks tiles ($0E–$0F, $19–$1A). Falls through to UseItem_DiamondBlock_Place on match.

UseItem_DiamondBlock {
    LDA $sceneCurrent
    CMP #$0025
    BNE loc_038939
    LDA $playerYTile
    CMP #$0019
    BEQ loc_03892C
    CMP #$001A
    BNE loc_038939

  loc_03892C:
    LDA $playerXTile
    CMP #$000E
    BEQ UseItem_DiamondBlock_Place
    CMP #$000F
    BNE loc_038939

  loc_038939:
    COP [PrintDialogString] ( &dialogstring_03893E )
    RTS 
}

dialogstring_03893E `[DEF]I can't find a space [N]that the diamond-shaped [N]block fits. [END]`

---------------------------------------------
; Diamond Block placement — removes item and sets flag $2F.

UseItem_DiamondBlock_Place {
    COP [PrintDialogString] ( &dialogstring_03897C )
    COP [RemoveItem] ( #07 )
    COP [SetFlagByte] ( #2F )
    RTS 
}

dialogstring_03897C `[DEF]He fit the block[N]into the tile![END]`

---------------------------------------------
; Wind Melody — play for the Gold Ship effect (scene $24).
; 
; First of three melody item handlers sharing FluteMusicActorController. Requires Will (form 0) — Freedan/Shadow cannot play. Checks IsMusicPlaying to prevent concurrent melody actors.
; 
; In scene $24 (Gold Ship), if flag $01 is not yet set: suppresses rendering (displayModeFlags $0080), spawns FluteMusicActorController at the player's position with flags $2000, and configures the spawned actor with music track $19 and melody index 0. If the actor pool is full (Y=$1FC0), jumps to the no-input-lock path. Otherwise locks all buttons via joypadMaskStd = $CFF0.
; 
; Outside scene $24, prints 'nothing happened.' If not Will, prints 'doesn't have the Flute.'

UseItem_WindFlute {
    LDA $characterForm    ; Melody items require Will (form 0); Freedan/Shadow see failure message
    BNE loc_0389F5
    JSL $@music_actors.IsMusicPlaying ; Abort if a melody actor is already active (prevents concurrent playback)
    BCC loc_0389A6
    RTS 

  loc_0389A6:
    LDA $sceneCurrent     ; Scene $24 = Gold Ship; flag $01 = wind effect already activated
    CMP #$0024
    BNE code_0389F0
    COP [BranchIfFlagByte] ( #01, #01, &code_0389F0 )
    LDA #$0080            ; Suppress normal rendering during music playback
    TSB $displayModeFlags
    COP [PrintDialogString] ( &dialogstring_038A2B )
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @FluteMusicActorController, #00, #00, #$2000 ) ; Spawn FluteMusicActorController; $2000 = display-filtered actor flags
    CPY #$1FC0            ; Y=$1FC0 = actor pool full — spawn failed, skip input suppression
    BNE loc_0389D3
    JMP $&code_0389D9

  loc_0389D3:
    LDA #$CFF0            ; Lock all buttons ($CFF0) except D-pad/Select during melody
    TSB $joypadMaskStd
}

code_0389D9 {
    LDA $0012, Y          ; Configure music actor: set display-filter ($1000), track ID, melody index
    ORA #$1000
    STA $0012, Y
    LDA #$0019            ; Music track $19 = Wind Melody SPC module
    STA $0026, Y
    LDA #$0000            ; Melody index 0 (Wind) — FluteMusicActorController dispatches via SwitchCase
    STA $0020, Y
    PLX 
    RTS 
}

code_0389F0 {
    COP [PrintDialogString] ( &dialogstring_038A8A ) ; No matching scene — played melody but nothing happened
    RTS 

  loc_0389F5:
    COP [PrintDialogString] ( &dialogstring_038B76 )
    RTS 
}

code_0389FA {
    COP [PrintDialogString] ( &dialogstring_038B8F )
    RTS 
}

dialogstring_0389FF `[DEF]Play the Flute?[N] Yes[N] No`

---------------------------------------------
; Wind Melody success effect — triggered by FluteMusicActorController after playback.
; 
; Sets flag $01, prints the prophecy text about the Gold Block glowing, spawns a palette cycling thinker, and uses RestoreSavedPtr to continue the music restoration phase.

UseItem_WindFlute_Effect {
    COP [SetFlagByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_038A46 )
    COP [SpawnThinkerParam] ( #2F, @ambient_palette_cycler.PaletteCycleLoop )
    COP [RestoreSavedPtr]

  loc_038A25:
    COP [PrintDialogString] ( &dialogstring_038AB5 )
    COP [RestoreSavedPtr]
}

dialogstring_038A2B `[DEF]He softly played[N]the Wind Melody.[END]`

dialogstring_038A46 `[DEF][CLR]When touched by the echo[N]of the Flute, the Gold[N]Block began to glow![END]`

dialogstring_038A8A `[DEF]He softly played[N]the Wind Melody.[FIN]But nothing happened.[END]`

dialogstring_038AB5 `[DEF][CLR]When the melody flowed[N]around his body, strange[N]words filled his head.[FIN]Chant in the room paved[N]with gold, and meditate[N]a while in the place[N]that shines brightly.[FIN]For that person the road[N]to the ocean of[N]freedom will open...[END]`

dialogstring_038B76 `[DEF][CLR]He doesn't have[N]the Flute...[END]`

dialogstring_038B8F `[CLR]He stopped playing.[END]`

---------------------------------------------
; Lola's Melody — play in Edward's Castle/Itory/Tower of Babel.
; 
; Same melody actor pattern as UseItem_WindFlute but supports three scenes: $15 (Itory meadow, flag $40), $11 (Edward's Castle, flags $0113 + $02), and $CD (Tower of Babel, flags $BB/$0E/$0D). Requires Will (form 0). Music track $18, melody index 1.

UseItem_LolaMelody {
    LDA $characterForm
    BEQ loc_038BAC
    JMP $&code_038C30

  loc_038BAC:
    JSL $@music_actors.IsMusicPlaying
    BCC loc_038BB3
    RTS 

  loc_038BB3:
    LDA $sceneCurrent
    CMP #$0015
    BEQ loc_038BD6
    CMP #$0011
    BEQ loc_038BC7
    CMP #$00CD
    BEQ loc_038BDE
    BRA code_038C2B

  loc_038BC7:
    COP [BranchIfFlagWord] ( #$0113, #01, &code_038C2B )
    COP [BranchIfFlagByte] ( #02, #01, &code_038C2B )
    BRA loc_038BEF

  loc_038BD6:
    COP [BranchIfFlagByte] ( #40, #01, &code_038C2B )
    BRA loc_038BEF

  loc_038BDE:
    COP [BranchIfFlagByte] ( #BB, #01, &code_038C2B )
    COP [BranchIfFlagByte] ( #0E, #00, &code_038C2B )
    COP [SetFlagByte] ( #0D )
    BRA loc_038BEF

  loc_038BEF:
    LDA #$0080
    TSB $displayModeFlags
    COP [PrintDialogString] ( &dialogstring_038C76 )
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @FluteMusicActorController, #00, #00, #$2000 )
    CPY #$1FC0
    BNE loc_038C0E
    JMP $&code_038C14

  loc_038C0E:
    LDA #$CFF0
    TSB $joypadMaskStd
}

code_038C14 {
    LDA $0012, Y          ; Same actor config as code_0389D9: display-filtered, track $18, melody index 1 (Lola)
    ORA #$1000
    STA $0012, Y
    LDA #$0018
    STA $0026, Y
    LDA #$0001
    STA $0020, Y
    PLX 
    RTS 
}

code_038C2B {
    COP [PrintDialogString] ( &dialogstring_038CDB )
    RTS 
}

code_038C30 {
    COP [PrintDialogString] ( &dialogstring_038F82 )
    RTS 
}

---------------------------------------------
; Lola's Melody success effects — dispatches per-scene results.
; 
; Scene $15: sets flag $40, melody spreads over meadow. Scene $11: sets flag $02, voice guides to wall switch. Scene $CD: sets flag $01 and clears flag $0E. Fallthrough prints 'nothing happened.'

UseItem_LolaMelody_Effect {
    LDA $sceneCurrent
    CMP #$0015
    BEQ loc_038C49
    CMP #$0011
    BEQ loc_038C58
    CMP #$00CD
    BEQ code_038C68
    BRA code_038C70

  loc_038C49:
    COP [BranchIfFlagByte] ( #40, #01, &code_038C68 )
    COP [SetFlagByte] ( #40 )
    COP [PrintDialogString] ( &dialogstring_038CA0 )
    COP [RestoreSavedPtr]

  loc_038C58:
    COP [BranchIfFlagWord] ( #$0113, #01, &code_038C70 )
    COP [SetFlagByte] ( #02 )
    COP [PrintDialogString] ( &dialogstring_038D17 )
    COP [RestoreSavedPtr]
}

code_038C68 {
    COP [SetFlagByte] ( #01 )
    COP [ClearFlagByte] ( #0E )
    COP [RestoreSavedPtr]
}

code_038C70 {
    COP [PrintDialogString] ( &dialogstring_038CDB+M )
    COP [RestoreSavedPtr]
}

dialogstring_038C76 `[DEF]He softly played the[N]melody he had learned[N]from Lola.[END]`

dialogstring_038CA0 `[DEF][CLR]The melody, carried on [N]the wind, spread [N]over the meadow. [END]`

dialogstring_038CDB `[DEF]He softly played the[N]melody he had learned[N]from Lola.[FIN][::][DEF][CLR]But nothing happened.[END]`

dialogstring_038D17 `[DEF][CLR]He heard a soft voice[N]from somewhere...[FIN][TPL:2]Strange Voice:[N]Go to the switch on[N]the right-hand wall.[PAL:0][END]`

---------------------------------------------
; Smoked Meat — feed to the villagers on the raft (scene $2F).
; 
; Requires flag $02 to be set (villagers are hungry). Removes the item, sets flag $03, and prints the eating message.

UseItem_SmokedMeat {
    LDA $sceneCurrent
    CMP #$002F
    BNE code_038D80
    COP [BranchIfFlagByte] ( #02, #00, &code_038D80 )
    COP [RemoveItem] ( #0A )
    COP [PrintDialogString] ( &dialogstring_038DDA )
    COP [SetFlagByte] ( #03 )
    RTS 
}

code_038D80 {
    COP [PrintDialogString] ( &dialogstring_038D85 )
    RTS 
}

dialogstring_038D85 `[DEF]He bit off some [N]of the smoked meat. [FIN]It had a flavor he'd[N]never tasted before.[N]What could it be?[END]`

dialogstring_038DDA `[DEF]We bit off[N]some of the meat.[FIN]It was better than any[N]food we'd ever had.[END]`

---------------------------------------------
; Mine Key A — unlock the mine entrance (scene $44).
; 
; Checks tile region ($0F,$16)–($11,$19). On match, removes item and sets flag $5B.

UseItem_MineKeyA {
    COP [PrintDialogString] ( &dialogstring_038E39 )
    LDA $sceneCurrent
    CMP #$0044
    BNE loc_038E29
    COP [BranchIfPlayerInAbsTiles] ( #0F, #16, #11, #19, &code_038E2E )

  loc_038E29:
    COP [PrintDialogString] ( &dialogstring_038E61 )
    RTS 
}

code_038E2E {
    COP [PrintDialogString] ( &dialogstring_038E73 )
    COP [RemoveItem] ( #0B )
    COP [SetFlagByte] ( #5B )
    RTS 
}

dialogstring_038E39 `[DEF]He tries using the key [N]to the mine. [FIN]`

dialogstring_038E61 `But there's no keyhole![END]`

dialogstring_038E73 `The key turns, making a [N]strange sound. [END]`

---------------------------------------------
; Mine Key B — unlock the mine entrance (scene $44). Same tile region as Mine Key A. Removes item and sets flag $5C.

UseItem_MineKeyB {
    COP [PrintDialogString] ( &dialogstring_038EBA )
    LDA $sceneCurrent
    CMP #$0044
    BNE loc_038EAA
    COP [BranchIfPlayerInAbsTiles] ( #0F, #16, #11, #19, &code_038EAF )

  loc_038EAA:
    COP [PrintDialogString] ( &dialogstring_038EE2 )
    RTS 
}

code_038EAF {
    COP [PrintDialogString] ( &dialogstring_038EF4 )
    COP [RemoveItem] ( #0C )
    COP [SetFlagByte] ( #5C )
    RTS 
}

dialogstring_038EBA `[DEF]He tries using the key [N]to the mine. [FIN]`

dialogstring_038EE2 `But there's no keyhole![END]`

dialogstring_038EF4 `The key turns, making a [N]strange sound. [END]`

---------------------------------------------
; Memory Melody — play in the Mountain Temple (scene $39).
; 
; Third melody handler. Requires Will (form 0) and scene $39 with flag $68 clear. Checks tile region ($13,$18)–($1A,$1D). Music track $1D, melody index 2. Unlike the other melodies, this handler does not use the shared code_0389D9 subroutine — it configures the music actor inline and additionally sets musicParentActor to $0E.

UseItem_MemoryMelody {
    LDA $characterForm
    BEQ loc_038F21
    COP [PrintDialogString] ( &dialogstring_038F82 )
    RTS 

  loc_038F21:
    LDA $sceneCurrent
    CMP #$0039
    BEQ loc_038F2B
    BRA code_038F7D

  loc_038F2B:
    COP [BranchIfFlagByte] ( #68, #01, &code_038F7D )
    COP [BranchIfPlayerInAbsTiles] ( #13, #18, #1A, #1D, &code_038F3B )
    BRA code_038F7D
}

code_038F3B {
    LDA #$0080
    TSB $displayModeFlags
    COP [PrintDialogString] ( &dialogstring_038FCD )
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @FluteMusicActorController, #00, #00, #$2000 )
    LDA $0012, Y          ; Inline actor config: display-filtered, track $1D, melody index 2 (Memory)
    ORA #$1000
    STA $0012, Y
    LDA #$001D
    STA $0026, Y
    LDA #$0002
    STA $0020, Y
    PLX 
    LDA #$000E            ; Override musicParentActor = $0E for Memory Melody restoration tracking
    STA $musicParentActor
    RTS 
}

---------------------------------------------
; Memory Melody success — removes the item, spawns a palette reset thinker, and sets flag $0F.

UseItem_MemoryMelody_Effect {
    COP [RemoveItem] ( #0D )
    COP [SpawnThinkerParam] ( #1B, @actor_pool.PaletteResetAndKillThinker )
    COP [SetFlagByte] ( #0F )
    COP [RestoreSavedPtr]
}

code_038F7D {
    COP [PrintDialogString] ( &dialogstring_038F98 )
    RTS 
}

dialogstring_038F82 `[DEF]He doesn't have[N]the Flute.[END]`

dialogstring_038F98 `[DEF]Will began playing the [N]melody he remembered. [FIN]But nothing happened.[END]`

dialogstring_038FCD `[DEF][CLR]Will began playing the [N]melody he remembered. [END]`

---------------------------------------------
; Crystal Ball — place in pedestals in Mu (scene $4C).
; 
; Four placement positions, each with an independent flag ($60–$63). All four use the same placement message. If a ball is already placed, prints a duplicate message. Unlike most key items, the Crystal Ball is removed via RemoveEquippedItem (JSR) rather than COP RemoveItem, since the same item can be placed in multiple slots.

UseItem_CrystalBall {
    LDA $sceneCurrent
    CMP #$004C
    BNE loc_03901B
    COP [BranchIfPlayerInAbsTiles] ( #16, #0C, #18, #0F, &code_039020 )
    COP [BranchIfPlayerInAbsTiles] ( #16, #10, #18, #13, &code_03902B )
    COP [BranchIfPlayerInAbsTiles] ( #08, #0A, #0B, #0D, &code_039036 )
    COP [BranchIfPlayerInAbsTiles] ( #08, #0E, #0B, #11, &code_039041 )

  loc_03901B:
    COP [PrintDialogString] ( &dialogstring_039057 )
    RTS 
}

code_039020 {
    COP [BranchIfFlagByte] ( #60, #01, &code_039052 )
    COP [SetFlagByte] ( #60 )
    BRA loc_03904A
}

code_03902B {
    COP [BranchIfFlagByte] ( #61, #01, &code_039052 )
    COP [SetFlagByte] ( #61 )
    BRA loc_03904A
}

code_039036 {
    COP [BranchIfFlagByte] ( #62, #01, &code_039052 )
    COP [SetFlagByte] ( #62 )
    BRA loc_03904A
}

code_039041 {
    COP [BranchIfFlagByte] ( #63, #01, &code_039052 )
    COP [SetFlagByte] ( #63 )

  loc_03904A:
    COP [PrintDialogString] ( &dialogstring_039083 )
    JSR $&RemoveEquippedItem
    RTS 
}

code_039052 {
    COP [PrintDialogString] ( &dialogstring_0390A5 )
    RTS 
}

dialogstring_039057 `[DEF]He raises the [N]Crystal Ball, but [N]nothing happened... [END]`

dialogstring_039083 `[DEF]The Crystal Ball is [N]set in the hole! [END]`

dialogstring_0390A5 `[DEF]The Crystal Ball is [N]already set in the hole![END]`

---------------------------------------------
; Elevator Key — activate the mine elevator (scene $3F).
; 
; Checks tiles ($18,$34)–($1A,$37). Removes item and sets flag $69.

UseItem_ElevatorKey {
    COP [PrintDialogString] ( &dialogstring_0390F2 )
    LDA $sceneCurrent
    CMP #$003F
    BNE loc_0390E2
    COP [BranchIfPlayerInAbsTiles] ( #18, #34, #1A, #37, &code_0390E7 )

  loc_0390E2:
    COP [PrintDialogString] ( &dialogstring_039110 )
    RTS 
}

code_0390E7 {
    COP [PrintDialogString] ( &dialogstring_039122 )
    COP [RemoveItem] ( #0F )
    COP [SetFlagByte] ( #69 )
    RTS 
}

dialogstring_0390F2 `[DEF]He tries using [N]the elevator key. [FIN]`

dialogstring_039110 `But there's no keyhole![END]`

dialogstring_039122 `The key turns, making a[N]strange sound. [END]`

---------------------------------------------
; Seaside Palace Key — open the palace entrance (scene $5A).
; 
; Checks tiles ($08,$07)–($0A,$08). Gate: flag $0138 must not be set (door not already opened). On success, removes item, applies tilemap change #$38, sets flag $0138, and prints Lilly's dialogue about Mu.

UseItem_SeasidePalaceKey {
    COP [PrintDialogString] ( &dialogstring_039179 )
    LDA $sceneCurrent
    CMP #$005A
    BNE code_039158
    COP [BranchIfPlayerInAbsTiles] ( #08, #07, #0A, #08, &code_03915D )

  code_039158:
    COP [PrintDialogString] ( &dialogstring_0391A4 )
    RTS 
}

code_03915D {
    COP [BranchIfFlagWord] ( #$0138, #01, &code_039158 )
    COP [PrintDialogString] ( &dialogstring_0391B6 )
    COP [RemoveItem] ( #10 )
    COP [StageBgChange] ( #38 )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$0138 )
    COP [PrintDialogString] ( &dialogstring_0391D9 )
    RTS 
}

dialogstring_039179 `[DEF]He tries using the key [N]to the Seaside Palace.[FIN]`

dialogstring_0391A4 `But there's no keyhole![END]`

dialogstring_0391B6 `The key turns, making a[N]strange sound. [FIN]`

dialogstring_0391D9 `[CLR][TPL:2]Lilly spoke from[N]his pocket.[FIN]The phantom land of[N]Mu lies ahead.[PAL:0][END]`

---------------------------------------------
; Purification Stone — purify the spring (scene $5D).
; 
; Checks tile region ($0A,$11)–($17,$1A). On match, places a solid tile at ($0D,$0F), removes item, and sets flag $0E.

UseItem_PurificationStone {
    COP [PrintDialogString] ( &dialogstring_039244 )
    LDA $sceneCurrent
    CMP #$005D
    BNE loc_03923F
    COP [BranchIfPlayerInAbsTiles] ( #0A, #11, #17, #1A, &code_039230 )
    BRA loc_03923F
}

code_039230 {
    COP [SolidHighAbs] ( #0D, #0F )
    COP [RemoveItem] ( #11 )
    COP [PrintDialogString] ( &dialogstring_03926F )
    COP [SetFlagByte] ( #0E )
    RTS 

  loc_03923F:
    COP [PrintDialogString] ( &dialogstring_03925F )
    RTS 
}

dialogstring_039244 `[DEF]He raises the [N]Purification Stone. [FIN]`

dialogstring_03925F `But nothing happened![END]`

dialogstring_03926F `The stone began to glow, [N]then disappeared into [N]the spring. [END]`

---------------------------------------------
; Statue of Hope — place in pedestals at Angel Village (scene $63).
; 
; Two positions: ($06,$06)–($0A,$08) sets flag $7B; ($16,$06)–($1A,$08) sets flag $7E. Uses RemoveEquippedItem (JSR) since either pedestal consumes the statue.

UseItem_StatueOfHope {
    COP [PrintDialogString] ( &dialogstring_0392DE )
    LDA $sceneCurrent
    CMP #$0063
    BNE code_0392D9
    COP [BranchIfPlayerInAbsTiles] ( #06, #06, #0A, #08, &code_0392C8 )
    COP [BranchIfPlayerInAbsTiles] ( #16, #06, #1A, #08, &code_0392B7 )
    BRA code_0392D9
}

code_0392B7 {
    COP [BranchIfFlagByte] ( #7E, #01, &code_0392D9 )
    JSR $&RemoveEquippedItem
    COP [PrintDialogString] ( &dialogstring_03930B )
    COP [SetFlagByte] ( #7E )
    RTS 
}

code_0392C8 {
    COP [BranchIfFlagByte] ( #7B, #01, &code_0392D9 )
    JSR $&RemoveEquippedItem
    COP [PrintDialogString] ( &dialogstring_03930B )
    COP [SetFlagByte] ( #7B )
    RTS 
}

code_0392D9 {
    COP [PrintDialogString] ( &dialogstring_0392FB )
    RTS 
}

dialogstring_0392DE `[DEF]He raises the [N]Statue of Hope. [FIN]`

dialogstring_0392FB `But nothing happened![END]`

dialogstring_03930B `A strange whisper is[N]heard from somewhere...[END]`

---------------------------------------------
; Rama Statue — place in pedestals at the Great Wall (scene $66).
; 
; Two positions: ($23,$08)–($26,$0A) sets flag $80; ($2A,$08)–($2D,$0A) sets flag $81. Same RemoveEquippedItem pattern as UseItem_StatueOfHope.

UseItem_RamaStatue {
    COP [PrintDialogString] ( &dialogstring_039370 )
    LDA $sceneCurrent
    CMP #$0066
    BNE code_03936B
    COP [BranchIfPlayerInAbsTiles] ( #23, #08, #26, #0A, &code_039349 )
    COP [BranchIfPlayerInAbsTiles] ( #2A, #08, #2D, #0A, &code_03935A )
    BRA code_03936B
}

code_039349 {
    COP [BranchIfFlagByte] ( #80, #01, &code_03936B )
    JSR $&RemoveEquippedItem
    COP [PrintDialogString] ( &dialogstring_03939F )
    COP [SetFlagByte] ( #80 )
    RTS 
}

code_03935A {
    COP [BranchIfFlagByte] ( #81, #01, &code_03936B )
    JSR $&RemoveEquippedItem
    COP [PrintDialogString] ( &dialogstring_03939F )
    COP [SetFlagByte] ( #81 )
    RTS 
}

code_03936B {
    COP [PrintDialogString] ( &dialogstring_03938F )
    RTS 
}

dialogstring_039370 `[DEF]He raises the [N]Rama Statue. [FIN]`

dialogstring_03938F `But nothing happened![END]`

dialogstring_03939F `[CLD]`

---------------------------------------------
; Magic Powder — use on Kara's painting (scene $74).
; 
; Checks tiles ($07,$08)–($09,$0A). Removes item and sets flag $01.

UseItem_MagicPowder {
    COP [PrintDialogString] ( &dialogstring_0393C5 )
    LDA $sceneCurrent
    CMP #$0074
    BNE loc_0393B5
    COP [BranchIfPlayerInAbsTiles] ( #07, #08, #09, #0A, &code_0393BA )

  loc_0393B5:
    COP [PrintDialogString] ( &dialogstring_0393EA )
    RTS 
}

code_0393BA {
    COP [PrintDialogString] ( &dialogstring_0393FA )
    COP [RemoveItem] ( #14 )
    COP [SetFlagByte] ( #01 )
    RTS 
}

dialogstring_0393C5 `[DEF]He tries using the [N]Magic Powder. [FIN]`

dialogstring_0393EA `But nothing happened![END]`

dialogstring_0393FA `He spreads Magic Powder [N]on Kara's picture! [END]`

---------------------------------------------
; Lance's Father's Journal — read entries via 3-option menu.
; 
; Presents a dialogue with three topics: Tower of Babel, Mystic Statues, Great Wall of China. Each option prints a short journal excerpt. Cancelling closes the journal.

UseItem_Journal {
    COP [PrintDialogString] ( &dialogstring_03944D )
    COP [DialogueOptions] ( #03, #01, &code_list_039431 )
}

code_list_039431 [
  &code_039439   ;00
  &code_03943E   ;01
  &code_039443   ;02
  &code_039448   ;03
]

code_039439 {
    COP [PrintDialogString] ( &dialogstring_0394B5 )
    RTS 
}

code_03943E {
    COP [PrintDialogString] ( &dialogstring_0394CE )
    RTS 
}

code_039443 {
    COP [PrintDialogString] ( &dialogstring_0394E5 )
    RTS 
}

code_039448 {
    COP [PrintDialogString] ( &dialogstring_0394FD )
    RTS 
}

dialogstring_03944D `[DEF]He opened Lance's father's[N]journal. [FIN]Read which entry? [N] Tower of Babel [N] Mystic Statues [N] Great Wall of China `

dialogstring_0394B5 `[DEF]He closes the journal. [END]`

dialogstring_0394CE `[DEF]The Tower of Babel...[END]`

dialogstring_0394E5 `[DEF]The Mystic Statues... [END]`

dialogstring_0394FD `[DEF]The Great Wall...[END]`

---------------------------------------------
; Lance's Letter — display-only. Sets flag $8E on use to track that the player has read the letter.

UseItem_LanceLetter {
    COP [SetFlagByte] ( #8E )
    COP [PrintDialogString] ( &dialogstring_039514 )
    RTS 
}

dialogstring_039514 `[DEF]He opened Lance's letter. [FIN][TPL:4]Lance: [N]I'm going to the [N]Great Wall of China. [FIN]I intended to keep it [N]secret, but I told Will [N]just in case... [FIN]I'm putting this letter[N]in his luggage, but he[N]probably won't notice.[FIN]The townspeople say[N]there's some kind of[N]cure for my father[N]at the Great Wall.[FIN]It's a long journey, but[N]I'd go anywhere if[N]it would help him.[N]Don't worry about me...[FIN]P.S.: [N]By the way, Lilly [N]has left me.[PAL:0][END]`

---------------------------------------------
; Lilly's Necklace — display-only description.

UseItem_LillyNecklace {
    COP [PrintDialogString] ( &dialogstring_03966F )
    RTS 
}

dialogstring_03966F `[DEF]Lance made this necklace [N]for Lilly...[END]`

---------------------------------------------
; Will (testament) — display-only. Shows the full text of the will from Russian Glass.

UseItem_Will {
    COP [PrintDialogString] ( &dialogstring_039696 )
    RTS 
}

dialogstring_039696 `[DEF]He opened the will.[FIN][N]    To the Opponent[FIN]Even if I perish, don't[N]mourn for me.[FIN]Even if Russian Glass[N]doesn't cost me[N]my life, it's my fate[N]to pass away soon.[FIN]Six months ago, when I[N]found out I was dying,[N]I decided to amass as[N]much money as possible.[FIN]I wanted to leave it to [N]my wife, and the child [N]I'll never see. [FIN]I made my fortune [N]in spite of the  [N]unhappiness I have [N]caused others. [FIN]If I lose, I want to[N]leave part of my[N]estate to you.[FIN]Please take care of my [N]four favorite [N]Kruk horses. [END]`

---------------------------------------------
; Teapot — pour spirits' tears at Dao (scene $95).
; 
; Checks tiles ($28,$09)–($2D,$0D). Removes item and sets flag $A8.

UseItem_Teapot {
    COP [PrintDialogString] ( &dialogstring_039861 )
    LDA $sceneCurrent
    CMP #$0095
    BNE loc_039851
    COP [BranchIfPlayerInAbsTiles] ( #28, #09, #2D, #0D, &code_039856 )

  loc_039851:
    COP [PrintDialogString] ( &dialogstring_039880 )
    RTS 
}

code_039856 {
    COP [PrintDialogString] ( &dialogstring_039890 )
    COP [RemoveItem] ( #19 )
    COP [SetFlagByte] ( #A8 )
    RTS 
}

dialogstring_039861 `[DEF]He tries using [N]the Teapot. [FIN]`

dialogstring_039880 `But nothing happened![END]`

dialogstring_039890 `The spirits' tears [N]rained down. [END]`

---------------------------------------------
; Mushroom Water — pour on plant stems.
; 
; Supports two scenes: $A2 (single position at ($14,$08)–($16,$09), sets flag $01) and $A5 (two positions — stem A at ($2E,$12)–($30,$13) sets flag $01, stem B at ($28,$24)–($2A,$25) sets flag $02). Falls through to UseItem_MushroomWater_Alt for scene $A5 positions.

UseItem_MushroomWater {
    COP [PrintDialogString] ( &dialogstring_0398FC )
    LDA $sceneCurrent
    CMP #$00A2
    BEQ loc_0398C8
    CMP #$00A5
    BEQ UseItem_MushroomWater_Alt

  loc_0398C3:
    COP [PrintDialogString] ( &dialogstring_039925 )
    RTS 

  loc_0398C8:
    COP [BranchIfPlayerInAbsTiles] ( #14, #08, #16, #09, &code_0398D2 )
    BRA loc_0398C3
}

code_0398D2 {
    COP [PrintDialogString] ( &dialogstring_039935 )
    COP [SetFlagByte] ( #01 )
    RTS 

; Mushroom Water alternate scene positions (scene $A5). See UseItem_MushroomWater.

  UseItem_MushroomWater_Alt:
    COP [BranchIfPlayerInAbsTiles] ( #2E, #12, #30, #13, &code_0398EC )
    COP [BranchIfPlayerInAbsTiles] ( #28, #24, #2A, #25, &code_0398F4 )
    BRA loc_0398C3
}

code_0398EC {
    COP [PrintDialogString] ( &dialogstring_039935 )
    COP [SetFlagByte] ( #01 )
    RTS 
}

code_0398F4 {
    COP [PrintDialogString] ( &dialogstring_039935 )
    COP [SetFlagByte] ( #02 )
    RTS 
}

dialogstring_0398FC `[DEF]He tries using the water [N]from the mushroom. [FIN]`

dialogstring_039925 `But nothing happened![END]`

dialogstring_039935 `He pours the mushroom[N]water on the stems! [END]`

---------------------------------------------
; Prize Money — display-only description.

UseItem_PrizeMoney {
    COP [PrintDialogString] ( &dialogstring_039961 )
    RTS 
}

dialogstring_039961 `[DEF]It's the prize money[N]from Russian Glass.[END]`

---------------------------------------------
; Black Glasses — display-only description.

UseItem_BlackGlasses {
    COP [PrintDialogString] ( &dialogstring_039984 )
    RTS 
}

dialogstring_039984 `[DEF]These are glasses made[N]of black crystal. They[N]can cut out a lot[N]of light...[END]`

---------------------------------------------
; Gorgon Flower — place petals in three statue mouths (scene $AE).
; 
; Three positions, each gated by an independent flag: ($06,$06)–($07,$08) flag $BF, ($08,$06)–($09,$08) flag $C0, ($0A,$06)–($0B,$08) flag $C1. After placing each petal, checks whether all three flags are set. Only when all three are placed is the item removed from inventory via COP RemoveItem. This partial-use mechanic is unique among IOG items.

UseItem_GorgonFlower {
    LDA $sceneCurrent
    CMP #$00AE
    BNE code_0399ED
    COP [BranchIfPlayerInAbsTiles] ( #06, #06, #07, #08, &code_0399F2 )
    COP [BranchIfPlayerInAbsTiles] ( #08, #06, #09, #08, &code_039A01 )
    COP [BranchIfPlayerInAbsTiles] ( #0A, #06, #0B, #08, &code_039A10 )

  code_0399ED:
    COP [PrintDialogString] ( &dialogstring_039A35 )
    RTS 
}

code_0399F2 {
    COP [BranchIfFlagByte] ( #BF, #01, &code_0399ED )
    COP [SetFlagByte] ( #BF )
    COP [PrintDialogString] ( &dialogstring_039A63 )
    BRA loc_039A1F
}

code_039A01 {
    COP [BranchIfFlagByte] ( #C0, #01, &code_0399ED )
    COP [SetFlagByte] ( #C0 )
    COP [PrintDialogString] ( &dialogstring_039A63 )
    BRA loc_039A1F
}

code_039A10 {
    COP [BranchIfFlagByte] ( #C1, #01, &code_0399ED )
    COP [SetFlagByte] ( #C1 )
    COP [PrintDialogString] ( &dialogstring_039A63 )
    BRA loc_039A1F

  loc_039A1F:
    COP [BranchIfFlagByte] ( #BF, #00, &code_039A34 ) ; All three petals placed? Check flags $BF/$C0/$C1 — remove item only when all set
    COP [BranchIfFlagByte] ( #C0, #00, &code_039A34 )
    COP [BranchIfFlagByte] ( #C1, #00, &code_039A34 )
    COP [RemoveItem] ( #1D )
}

code_039A34 {
    RTS 
}

dialogstring_039A35 `[DEF]He stares at the Gorgon [N]Flower, but [N]nothing happens! [END]`

dialogstring_039A63 `[DEF]He puts one petal of[N]the Gorgon Flower into[N]the statue's mouth. [END]`

---------------------------------------------
; Hieroglyph Plate handler — shared by items $1E–$23 (six plates).
; 
; Scene $CD (Tower of Babel) only. If flag $0F is set (Memory Melody already played), shows a timing message. Otherwise checks tile region ($04,$09)–($0C,$0B) for the puzzle area, then presents a 6-option dialogue (code_039AC2) to choose a slot position.
; 
; After selection, the loc_039B0F subroutine extracts the plate ID (item byte − $1E, stored in $0AA6), removes the plate from inventory, and spawns a metatile-drawing actor. If the chosen slot ($0B28 table, indexed by $0AAC) already contains a plate, the old plate is returned to inventory via GiveItemToPlayer before the new one is stored. Empty slots ($FFFF) receive a first-time placement message.

UseItem_HieroglyphPlate {
    LDA $sceneCurrent
    CMP #$00CD
    BEQ loc_039AB2

  loc_039AA8:
    COP [PrintDialogString] ( &dialogstring_039C8B )
    RTS 
}

---------------------------------------------
; Hieroglyph Plate timing guard — prints 'not the time to fit the tile' when flag $0F is active.

UseItem_HieroglyphPlate_Detail {
    COP [PrintDialogString] ( &dialogstring_039C60 )
    RTS 

  loc_039AB2:
    COP [BranchIfFlagByte] ( #0F, #01, &UseItem_HieroglyphPlate_Detail )
    COP [BranchIfPlayerInAbsTiles] ( #04, #09, #0C, #0B, &code_039AC2 )
    BRA loc_039AA8
}

code_039AC2 {
    COP [PrintDialogString] ( &dialogstring_039BA5 )
    COP [DialogueOptions] ( #63, #01, &code_list_039ACC )
}

code_list_039ACC [
  &code_039ADA   ;00
  &code_039ADF   ;01
  &code_039AE7   ;02
  &code_039AEF   ;03
  &code_039AF7   ;04
  &code_039AFF   ;05
  &code_039B07   ;06
]

code_039ADA {
    COP [PrintDialogString] ( &dialogstring_039C89 )
    RTS 
}

code_039ADF {
    LDA #$0000
    STA $0AAC
    BRA loc_039B0F
}

code_039AE7 {
    LDA #$0001
    STA $0AAC
    BRA loc_039B0F
}

code_039AEF {
    LDA #$0002
    STA $0AAC
    BRA loc_039B0F
}

code_039AF7 {
    LDA #$0003
    STA $0AAC
    BRA loc_039B0F
}

code_039AFF {
    LDA #$0004
    STA $0AAC
    BRA loc_039B0F
}

code_039B07 {
    LDA #$0005
    STA $0AAC
    BRA loc_039B0F

  loc_039B0F:
    LDY $inventoryEquippedIndex ; Extract plate ID: item byte − $1E gives index 0–5
    LDA $inventorySlots, Y
    AND #$00FF
    SEC 
    SBC #$001E
    STA $0AA6
    JSR $&RemoveEquippedItem ; Remove equipped plate before spawning placement actor
    PHX 
    LDX #$0000
    COP [SpawnLastRel] ( @code_039B70, #00, #00, #$2000 )
    LDA $0AA6
    STA $0024, Y          ; Pass plate ID to spawned actor via DP $24 for metatile selection
    LDA $0AAC
    CLC                   ; Slot position ($0AAC + 5) = X tile for spawned metatile actor
    ADC #$0005
    STA $0014, Y
    LDA #$0006
    STA $0016, Y          ; Y tile = 6 for all six hieroglyph slots
    PLX 
    LDA $0AAC
    ASL                   ; Check slot table ($0B28): negative ($FFFF) = empty, else plate already placed
    TAY 
    LDA $0B28, Y
    BMI loc_039B65
    CLC 
    ADC #$001E            ; Occupied slot: reconstruct old plate as item ID (+$1E), return to inventory
    PHY 
    JSL $@inventory_mgmt.GiveItemToPlayer
    PLY 
    LDA $0AA6
    STA $0B28, Y          ; Store new plate ID in slot, print swap message
    COP [PrintDialogString] ( &dialogstring_039C19 )
    RTS 

  loc_039B65:
    LDA $0AA6             ; Empty slot: store plate ID and print first-time placement message
    STA $0B28, Y
    COP [PrintDialogString] ( &dialogstring_039C39 )
    RTS 
}

code_039B70 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_039B7B )
}

code_list_039B7B [
  &code_039B87   ;00
  &code_039B8C   ;01
  &code_039B91   ;02
  &code_039B96   ;03
  &code_039B9B   ;04
  &code_039BA0   ;05
]

code_039B87 {
    COP [DrawMetatileHere] ( #84 )
    COP [Die]
}

code_039B8C {
    COP [DrawMetatileHere] ( #85 )
    COP [Die]
}

code_039B91 {
    COP [DrawMetatileHere] ( #86 )
    COP [Die]
}

code_039B96 {
    COP [DrawMetatileHere] ( #8C )
    COP [Die]
}

code_039B9B {
    COP [DrawMetatileHere] ( #8D )
    COP [Die]
}

code_039BA0 {
    COP [DrawMetatileHere] ( #8E )
    COP [Die]
}

dialogstring_039BA5 `[DEF][TPL:0]There are six hollows [N]where a tile can fit. [FIN]Put it where?[N] 1st from L. 4th from L.[N] 2nd from L. 5th from L.[N] 3rd from L. 6th from L.`

dialogstring_039C19 `[CLR][TPL:0]He exchanges the [N]hieroglyph plate![PAL:0][END]`

dialogstring_039C39 `[CLR][TPL:0]He puts the hieroglyph [N]plate in the hole![PAL:0][END]`

dialogstring_039C60 `[DEF][TPL:0]Now is not the time to[N]fit the tile...[PAL:0][END]`

dialogstring_039C89 `[CLD]`

dialogstring_039C8B `[DEF]There's no place to put[N]the hieroglyph plate.[PAL:0][END]`

---------------------------------------------
; Aura — Shadow's transformation ability.
; 
; Multiple guard conditions must pass: playerFlags bits $1000 (cutscene lock) and $0100 (dialogue active) must be clear, both playerSpeedEw and playerSpeedNs must be zero (standing still), and characterForm must be 2 (Shadow). On success, overwrites the player actor's function pointer to PlayerAuraTransformEntry via SetPlayerTransition, initiating the Aura transformation sequence. If not Shadow or any guard fails, prints failure message or returns silently.

UseItem_Aura {
    LDA $playerFlags      ; Guard: $1000 = cutscene lock, $0100 = dialogue active — both block Aura
    BIT #$1000
    BNE loc_039CE0
    BIT #$0100
    BNE loc_039CE0
    LDA $playerSpeedEw    ; Guard: must be stationary — any speed in either axis blocks transformation
    ORA $playerSpeedNs
    BNE loc_039CE0
    LDA $characterForm    ; Shadow (form 2) only — other forms see failure message
    CMP #$0002
    BNE loc_039CDC
    LDY $playerActor      ; Initiate Aura transformation by overriding player function to PlayerAuraTransformEntry
    LDA #$*player_transition_handlers.PlayerAuraTransformEntry
    STA $0002, Y
    LDA #$&player_transition_handlers.PlayerAuraTransformEntry
    JSR $&SetPlayerTransition
    RTS 

  loc_039CDC:
    COP [PrintDialogString] ( &dialogstring_039CE1 )

  loc_039CE0:
    RTS 
}

dialogstring_039CE1 `[DEF]He holds up the Aura,[N]but nothing happens...[END]`

---------------------------------------------
; Bill & Lola's Letter — display-only.

UseItem_BillLolaLetter {
    COP [PrintDialogString] ( &dialogstring_039D0E )
    RTS 
}

dialogstring_039D0E `[DEF][TPL:3]Have you been OK? [N]Neil told us that he was [N]in Dao, so I'm sending [N]this letter. [FIN]I heard the reason why.[N]Grandpa and I are[N]looking forward to[N]seeing you.[FIN]When we looked in your [N]father's luggage, we [N]found a journal written [N]about the Pyramid. [FIN]I thought it would help[N]you, so I sent it along.[N]Take care.[N]            Bill / Lola[PAL:0][END]`

---------------------------------------------
; Father's Journal — display-only. Shows the hieroglyph decipherment text.

UseItem_FatherJournal {
    COP [PrintDialogString] ( &dialogstring_039E1A )
    RTS 
}

dialogstring_039E1A `[DEF]I've deciphered the[N]hieroglyphs. No one[N]has ever done[N]it before.[FIN]It says there's a key to[N]solving the riddle of[N]human history in[N]the Pyramid.[FIN][ESC:C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,CA,CB][N]The first part says, [N]"The Sun Spirit rises [N]from the horizon.ˮ [FIN]I went to the Pyramid,[N]and found the same[N]inscription. So...[FIN]Here a page is missing.[END]`

---------------------------------------------
; Crystal Ring — display-only description.

UseItem_CrystalRing {
    COP [PrintDialogString] ( &dialogstring_039F35 )
    RTS 
}

dialogstring_039F35 `[DEF]This is the Crystal Ring [N]that King Edward  [N]is looking for. [END]`

---------------------------------------------
; Apple — consumable healing item. Removes from inventory and sets damageFlashTimer to 1, triggering a brief HP restoration effect. Unlike Herb, no confirmation dialogue.

UseItem_Apple {
    COP [PrintDialogString] ( &dialogstring_039F6B )
    COP [RemoveItem] ( #28 )
    LDA #$0001
    STA $damageFlashTimer
    RTS 
}

dialogstring_039F6B `[DEF]When I bite a bright red [N]apple, I feel better. The [N]apple was delicious. [END]`

---------------------------------------------
; Unused item slot — immediate RTS, no effect.

UseItem_Unused {
    RTS 
}

---------------------------------------------
; Remove the currently equipped item from inventory.
; 
; Reads inventoryEquippedIndex into Y, switches to 8-bit accumulator mode, and writes $00 to the item slot byte at inventorySlots,Y. Returns to 16-bit mode, sets inventoryEquippedType to $0000 and inventoryEquippedIndex to $FFFF (−1 = no selection). Called by item handlers that consume the equipped item via JSR rather than the COP RemoveItem command.

RemoveEquippedItem {
    LDA $inventoryEquippedIndex ; Load equipped slot index; 8-bit STA $00 zeroes the item byte
    TAY 
    SEP #$20
    LDA #$00
    STA $inventorySlots, Y
    REP #$20
    LDA #$0000            ; Clear equip type ($0000) and set index to $FFFF (no selection)
    STA $inventoryEquippedType
    DEC 
    STA $inventoryEquippedIndex
    RTS 
}

---------------------------------------------
; Multi-phase music playback actor for melody items.
; 
; Orchestrates the complete melody playback lifecycle shared by Wind Melody, Lola's Melody, and Memory Melody:
; 
; Phase 1 — Setup: Suppress rendering (displayModeFlags $0080), store the original music ID from musicParentActor into DP $24, spawn SpcTransferMusicData to upload the melody's music data to the SPC700. If spawn fails (Y=$1FC0 = pool full), jump to cleanup and die. Otherwise swap X/Y registers to configure the spawned music actor: store track number (+1) in chatPtr, set display-filter bit ($1000). Override the player actor to static idle pose (PlayerStaticBodyPose via SetPlayerTransition), set playerFlags $0800 (special movement lock), mask joypad ($CFF0). Yield and poll each frame until musicTransitionState == $FFFF.
; 
; Phase 2 — Playback: Poll APUIO1 ($2141) each frame. When the SPC signals $FF (track finished), restore the player to normal pose (PlayerWalkingIdlePose), re-enable joypad, and dispatch to the melody-specific *_Effect handler via SwitchCase on DP $20 (melody index 0/1/2).
; 
; Phase 3 — Restoration (code_03A06E): After the effect handler, spawn another SpcTransferMusicData to restore the original background music. Wait for musicTransitionState == $FFFF again, delay 1 frame (WaitByte), then die.
; 
; Cleanup (code_03A098): Reached on spawn failure — clears displayModeFlags $0080 and dies.

FluteMusicActorController {
    LDA #$0080            ; Phase 1 setup: suppress rendering for display-filtered-only mode
    TSB $displayModeFlags
    LDA $musicParentActor ; Save original music ID from the calling melody handler for later restoration
    STA $24
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 ) ; Spawn SPC data transfer actor to upload melody music to sound chip
    CPY #$1FC0            ; Y=$1FC0 = actor pool full — spawn failed, skip to cleanup (code_03A098)
    BNE loc_039FE4
    JMP $&code_03A098

  loc_039FE4:
    TXA                   ; Swap X/Y: X → new music actor slot, Y → this controller
    TYX 
    TAY 
    LDA $26
    INC 
    STA $chatPtr, X       ; Store music track number (+1) in music actor's chatPtr field
    LDA $0012, X          ; Set display-filter bit ($1000) on the SPC transfer actor
    ORA #$1000
    STA $0012, X
    TXA 
    TYX 
    TAY 
    LDY $playerActor      ; Lock the player actor to display-filtered mode too
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    LDA #$*player_transition_handlers.PlayerStaticBodyPose ; Override player to static idle pose (PlayerStaticBodyPose) during playback
    STA $0002, Y
    LDA #$&player_transition_handlers.PlayerStaticBodyPose
    JSR $&SetPlayerTransition
    LDA #$0800            ; playerFlags $0800 = special movement lock, prevents walking
    TSB $playerFlags
    LDA #$CFF0            ; Mask all buttons ($CFF0 = everything except D-pad and Select)
    TSB $joypadMaskStd
    COP [SetEntryContinue] ; Yield — re-enter each frame to poll music upload state
    LDA $musicTransitionState ; Wait for musicTransitionState == $FFFF (music upload complete, track started)
    CMP #$FFFF
    BEQ loc_03A029
    RTL 

  loc_03A029:
    COP [SetEntryContinue] ; Phase 2: music is playing — poll SPC for completion each frame
    SEP #$20
    LDA $APUIO1           ; Read APUIO1 ($2141); SPC signals $FF when the track finishes
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_03A03B
    RTL 

  loc_03A03B:
    LDY $playerActor      ; Music finished — begin cleanup and effect dispatch
    LDA $0012, Y          ; Clear display-filter ($1000) from player actor, restore normal rendering
    AND #$EFFF
    STA $0012, Y
    LDA #$*player_transition_handlers.PlayerWalkingIdlePose ; Restore player to walking idle pose (PlayerWalkingIdlePose)
    STA $0002, Y
    LDA #$&player_transition_handlers.PlayerWalkingIdlePose
    JSR $&SetPlayerTransition
    LDA #$CFF0            ; Unlock buttons — remove $CFF0 mask from joypadMaskStd
    TRB $joypadMaskStd
    COP [SetSavedPtr] ( &code_03A06E ) ; Set return point for after the melody-specific effect handler runs
    LDA $20               ; Dispatch to effect handler: DP $20 = melody index (0=Wind, 1=Lola, 2=Memory)
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_03A068 )
}

code_list_03A068 [
  &UseItem_WindFlute_Effect   ;00
  &UseItem_LolaMelody_Effect   ;01
  &UseItem_MemoryMelody_Effect   ;02
]

code_03A06E {
    COP [SpawnAfterFlags] ( @hdma_dma_spc.SpcTransferMusicData, #$2000 ) ; Phase 3: spawn SPC transfer to restore the original background music
    TXA 
    TYX 
    TAY 
    LDA $24               ; Store original music ID in restoration actor's chatPtr
    STA $chatPtr, X
    LDA $0012, X          ; Set display-filter on the restoration music actor
    ORA #$1000
    STA $0012, X
    TXA 
    TYX 
    TAY 
    COP [SetEntryContinue] ; Yield — poll each frame for background music restoration
    LDA $musicTransitionState ; Wait for musicTransitionState == $FFFF (original music restored)
    CMP #$FFFF
    BEQ loc_03A095
    RTL 

  loc_03A095:
    COP [WaitByte] ( #01 ) ; Delay 1 frame after restoration completes, then die
}

code_03A098 {
    LDA #$0080            ; Spawn-failed cleanup: restore rendering mode and kill this actor
    TRB $displayModeFlags
    COP [Die]
}

---------------------------------------------
; Set the player actor's function pointer and clear its frame timer.
; 
; Stores A into $0000,Y (function pointer low word) and zeros $0008,Y (frame wait counter) for immediate execution on the next actor tick. Y must point to the player actor slot. Used by melody handlers and UseItem_Aura to override the player's behavior state.

SetPlayerTransition {
    STA $0000, Y          ; Set player function pointer ($0000,Y) and clear frame timer ($0008,Y)
    LDA #$0000
    STA $0008, Y
    RTS 
}