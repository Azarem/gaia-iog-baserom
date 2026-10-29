; Escort follower actor (Bank 00, 51206-51522; the delta table follows): spawned as a child of an escort NPC (Kara / Lily), it records the player's path and replays it on the NPC, so the NPC walks the player's route about 8 recorded frames behind.
; 
; === SPAWN AND PARAMETERS ===
; 
; SpawnAfterFlags ( EscortFollowPathTracker, #$2000 ) (#$2800 in btDE_kara_missing) in ec0A_kara, it1A_lily, ir1C_lily, eu97_clerk2, btDF_kara, btDE_kara_missing and btE3_kara. The child sits right behind its parent in the actor list, so its $04 (prevActorLink) is the NPC. The spawner sets orbitAngle = initial facing + 1 (Lily: 4, so facing 3) or 0 (use the player's current facing), and orbitDiameter = the NPC's base animation index (Lily: $1A).
; 
; === RING BUFFER at $7EDF00 ===
; 
; Eight-byte entries: X word, Y word, facing word, unused. The setup writes 9 entries (offsets $00-$40): a trail that starts at the NPC and steps 2 px per entry along the table row of the facing index. The row is the OPPOSITE direction and the entry's facing word the opposite facing (EscortFollowPathDeltaTable: facing 0 South steps Y -2, 1 North Y +2, 2 West X +2, 3 East X -2). Only 8 entries are ever read: every access masks orbitAngle with $3F, so the byte offset runs $00-$38 and the ninth entry ($7EDF40) is unreachable. No other code uses $7EDF00.
; 
; === PER FRAME (after SetEntryHereAndYield) ===
; 
; Own $14 / $16 = the player's position of the last frame, $0E = the facing last applied to the NPC, orbitAngle = ring head (byte offset).
; - Player moved: the NPC jumps to the head entry (written 8 recorded frames ago), the head entry is overwritten with the player's current X / Y, and when the head entry's facing differs from $0E the NPC gets animation orbitDiameter + facing + 4 ($28; $2A and $08 cleared). Then the head entry's facing is refreshed with the player's current facing and the head advances by 8.
; - Player still: the NPC shows animation orbitDiameter + facing of the head entry (no +4); its position is untouched, the head does not advance and $0E := $FFFF so the next move restarts the walk animation.
; 
; Edge: GetPlayerFacingDirection returns carry set and A >= 4 for an unknown facing; the table index then runs past the four rows; whether a caller can reach that case is not traced. The head advances only on frames where the player moved, and the first use of orbitAngle is a seed, not a timer.
---------------------------------------------

?INCLUDE 'GetPlayerFacingDirection'

!playerActor                    09AA
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

; Setup (the frame after the spawn): pick the table row from the seed or the player's facing, lay the 9-entry trail from the NPC's position, copy the player's position into $14 / $16, orbitAngle := 0, SetEntryHereAndYield. The per-frame body follows. See the block note.

EscortFollowPathTracker {
    PHX                   ; Save the actor slot (X is reused as the table offset)
    LDA $orbitAngle, X    ; Seed from the spawner: facing + 1, or 0 = ask for the player's facing
    BEQ EscortTrackerFetchFacing
    DEC                   ; Seed - 1 = facing index
    BRA EscortTrackerSeedKnown

; Seed 0: take the player's current facing.

  EscortTrackerFetchFacing:
    JSL $@GetPlayerFacingDirection ; A = the player's facing (0 South, 1 North, 2 West, 3 East)

; A = facing index; x 8 = row offset in EscortFollowPathDeltaTable; the trail starts at the NPC ($04).

  EscortTrackerSeedKnown:
    ASL 
    ASL 
    ASL                   ; x 8: row offset in EscortFollowPathDeltaTable
    TAX 
    LDY $04               ; Y := $04 = list predecessor = the escorted NPC
    LDA $0014, Y
    STA $0000             ; $00 / $02 = running trail point, starting at the NPC (the entry pointer is reset by SetEntryHereAndYield below)
    LDA $0016, Y
    STA $0002
    LDA $@EscortFollowPathDeltaTable+4, X
    STA $001C             ; $1C := the row's facing word
    LDY #$0000

; Trail loop: point += the row step (dx, dy); store X, Y and the facing word in ring entry Y; 9 entries (CPY #$48).

  EscortTrackerFillTrail:
    LDA $@EscortFollowPathDeltaTable, X ; Next trail point = previous point + row step (dx, dy)
    CLC 
    ADC $0000
    STA $0000
    STA $0018
    LDA $@EscortFollowPathDeltaTable+2, X
    CLC 
    ADC $0002
    STA $0002
    STA $001A
    TXA 
    TYX                   ; X / Y swapped: X = ring offset, Y = table offset
    TAY 
    LDA $0018
    STA $7EDF00, X        ; Entry: X, Y and facing at +0, +2, +4
    LDA $001A
    STA $7EDF02, X
    LDA $001C
    STA $7EDF04, X
    TXA 
    TYX 
    TAY 
    TYA 
    CLC 
    ADC #$0008
    TAY 
    CPY #$0048            ; 9 entries written; the ring uses only 8
    BNE EscortTrackerFillTrail
    PLX 
    LDY $playerActor
    LDA $0014, Y
    STA $14               ; Own $14 / $16 := the player's position (change detection)
    LDA $0016, Y
    STA $16
    LDA $001C
    STA $0E               ; $0E := the facing last applied to the NPC
    LDA #$0000
    STA $orbitAngle, X    ; Ring head := 0 (byte offset, +8 per recorded frame)
    COP [SetEntryHereAndYield] ; From here the actor runs once per frame
    LDY $playerActor
    LDA $0014, Y
    CMP $14               ; Player moved since last frame? (X, then Y)
    BNE EscortTrackerPlayerMoved
    LDA $0016, Y
    CMP $16
    BEQ EscortTrackerPlayerIdle

; Player moved: NPC := head entry position, head entry := the player's position, restart the walk animation when the facing changed.

  EscortTrackerPlayerMoved:
    PHX                   ; Moved: NPC := head entry position, then overwrite the head with the player's position
    LDY $04
    LDA $orbitAngle, X
    AND #$003F
    TAX 
    LDA $7EDF00, X
    STA $0014, Y          ; NPC X := head entry X (recorded 8 frames ago)
    LDA $7EDF02, X
    STA $0016, Y
    LDY $playerActor
    LDA $0014, Y
    STA $14
    STA $7EDF00, X        ; Head entry X := the player's current X
    LDA $0016, Y
    STA $16
    STA $7EDF02, X
    LDA $7EDF04, X
    PLX 
    CMP $0E               ; Head facing changed since the last animation start?
    BEQ EscortTrackerAdvanceHead
    STA $0E
    CLC 
    ADC #$0004            ; Walk animation = orbitDiameter + facing + 4
    PHA 
    LDA $orbitDiameter, X
    CLC 
    ADC $01, S
    STA $01, S
    PLA 
    LDY $04
    STA $0028, Y          ; NPC animation index := base + facing + 4; $2A and $08 are cleared to restart it
    LDA #$0000
    STA $002A, Y
    STA $0008, Y
    BRA EscortTrackerAdvanceHead

; Player still: idle animation for the head entry's facing; $0E := $FFFF.

  EscortTrackerPlayerIdle:
    LDA $orbitAngle, X
    AND #$003F
    PHX 
    TAX 
    LDA $7EDF04, X        ; Facing of the head entry
    PLX 
    PHA 
    LDA $orbitDiameter, X
    CLC 
    ADC $01, S
    STA $01, S
    PLA 
    LDY $04
    STA $0028, Y          ; Idle animation = orbitDiameter + facing (no +4)
    LDA #$0000
    STA $002A, Y
    STA $0008, Y
    LDA #$FFFF            ; $0E := $FFFF: the next move restarts the walk animation
    STA $0E
    RTL 

; Common exit of the moving case: refresh the head entry's facing and advance the head by 8.

  EscortTrackerAdvanceHead:
    LDA $orbitAngle, X    ; Moving case exit: store the player's facing in the head entry, then advance the head
    AND #$003F
    PHX 
    TAX 
    JSL $@GetPlayerFacingDirection
    STA $7EDF04, X
    PLX 
    LDA $orbitAngle, X
    CLC 
    ADC #$0008            ; Head += 8 (not wrapped here; every read masks with $3F)
    STA $orbitAngle, X
    RTL 
}

---------------------------------------------
; Four rows of four words (dx, dy, facing word, unused) indexed by facing 0 South, 1 North, 2 West, 3 East. The step is the opposite direction and the facing word the opposite facing: South (0, -2, North), North (0, +2, South), West (+2, 0, East), East (-2, 0, West).

EscortFollowPathDeltaTable [
  #$0000   ;00
  #$FFFE   ;01
  #$0001   ;02
  #$0000   ;03
  #$0000   ;04
  #$0002   ;05
  #$0000   ;06
  #$0000   ;07
  #$0002   ;08
  #$0000   ;09
  #$0003   ;0A
  #$0000   ;0B
  #$FFFE   ;0C
  #$0000   ;0D
  #$0002   ;0E
  #$0000   ;0F
]