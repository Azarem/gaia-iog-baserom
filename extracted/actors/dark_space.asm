; Dark Space portal actor — the glowing portal object placed in maps that leads to the Gaia system.
; 
; Two variants: dark_space (flags=$3000) and dark_space2 (flags=$2000), differing only in the
; display mode bits stored in $0E. The portal animates between open/closed states based on player
; proximity (BranchIfPlayerNear radius 5). When the player steps on the portal and presses Up
; ($0801), the interaction handler (DarkSpaceEnterWarp) locks input, plays the warp SFX ($0C0C),
; copies the player's position onto the portal, configures gfxCacheIdx for the dark space
; tileset transition, sets layerPriorityFlag $0200, and stores the dark space layout variant
; in $0AAC.
; 
; The spawned child (DarkSpaceInteractionMonitor) monitors player position and display mode each frame,
; triggering the interaction when the player is within 1 tile and presses the button.
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

---------------------------------------------

dark_space [
  actor-def < #24, #00, #0B, {

  code_08D69E:
    LDA $0E               ; Save dark space variant from spawn param
    STA $24
    LDA #$3000            ; Display flags: variant 1
    STA $0E
    BRA DarkSpacePortalInit
} >
]

dark_space2 [
  actor-def < #24, #00, #0B, {

  code_08D6AC:
    LDA $0E               ; Save dark space variant
    STA $24
    LDA #$2000            ; Display flags: variant 2
    STA $0E
} >
]

---------------------------------------------
; Portal initialization — set up sprite, collision, and spawn interaction monitor

DarkSpacePortalInit {
    LDA #$0004            ; Enable collision layer bit
    TSB $12
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSprAndHitbox] ( #24 ) ; Portal closed frame
    COP [SolidHighHere]   ; Block player from walking through
    LDA #$2000            ; Clear walk-through flag
    TRB $10
    LDA #$0B00            ; Set portal display priority bits
    TSB $10
    COP [OrActorFlags] ( #$0200 )
    COP [SpawnAfterFlags] ( @DarkSpaceInteractionMonitor, #$2300 ) ; Spawn interaction monitor child
    LDA $24               ; Pass variant param to child
    STA $0024, Y

  loc_08D6DE:
    COP [StageSprAndHitbox] ( #24 ) ; Portal closed frame

  loc_08D6E1:
    COP [BranchIfPlayerNear] ( #05, &DarkSpacePortalOpen ) ; Player within 5 tiles?
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    BRA loc_08D6E1
}

---------------------------------------------
; Player approached — open the portal

DarkSpacePortalOpen {
    LDA $10
    BIT #$4000            ; Check if already animating
    BNE loc_08D6F5

  loc_08D6F5:
    COP [StageSpriteFrame] ( #1F ) ; Opening animation
    COP [AnimOnce]
    COP [StageSprAndHitbox] ( #20 ) ; Portal open frame

  loc_08D6FD:
    COP [BranchIfPlayerNear] ( #05, &DarkSpacePortalOpenIdle ) ; Stay open while player near
    BRA loc_08D70C        ; Player left — close
}

---------------------------------------------
; Portal open idle loop

DarkSpacePortalOpenIdle {
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryExit]
    BRA loc_08D6FD

  loc_08D70C:
    COP [StageSpriteFrame] ( #21 ) ; Closing animation
    COP [AnimOnce]
    BRA loc_08D6DE        ; Return to closed state
}

---------------------------------------------
; Interaction monitor — child actor that checks if player is standing on portal

DarkSpaceInteractionMonitor {
    COP [SetEntryContinue]
    NOP 
    NOP 
    LDA $displayModeFlags ; Skip during screen transitions
    BIT #$0080
    BEQ loc_08D720
    RTL 

  loc_08D720:
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #01, &DarkSpaceButtonCheck ) ; Player on portal tile?
    RTL 
}

---------------------------------------------
; Button check — player must press Up ($0801) to enter dark space

DarkSpaceButtonCheck {
    COP [BranchIfButton] ( #$0801, &DarkSpaceEnterWarp ) ; Up button
    RTL 
}

---------------------------------------------
; Dark space entry — lock controls, animate warp, reposition player, configure tileset

DarkSpaceEnterWarp {
    LDA #$CFF0            ; Mask most joypad input
    TSB $joypadMaskStd
    PHX 
    LDX $playerActor
    LDA $0010, X          ; Set player frozen flag
    ORA #$2000
    STA $0010, X
    LDA $0014, X          ; Save player X position
    STA $14
    LDA $0016, X          ; Save player Y position
    STA $16
    PLX 
    COP [PlaySoundBoth] ( #$0C0C ) ; Warp sound effect
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #1C ) ; Warp-in animation start
    COP [AnimOnce]
    COP [WaitByte] ( #1D ) ; Wait for warp frame
    PHX 
    LDX $playerActor
    LDY $04               ; Y = portal actor pointer
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
    LDA #$0101            ; Dark space tileset indices
    STA $gfxCacheIdxB
    LDA #$0200
    STA $gfxCacheIdxA
    LDA #$0200            ; Enable dark space layer priority
    TSB $layerPriorityFlag
    LDA $24               ; Store dark space variant ID
    STA $0AAC
    COP [SetEntryContinue]
    RTL 
}