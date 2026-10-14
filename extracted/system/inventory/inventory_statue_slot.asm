; Inventory menu actor that displays a collected mystic statue sprite at one of six pedestal positions when its event flag is set (53033–53134, Bank 00).
; 
; Spawned on scene $FF (inventory screen) alongside InventoryMenuDef. Six instances are spawned from scene_actors, one per pedestal position. Each actor reads its $0E parameter (set by InitActorFromSceneData from the actor-spawn byte 2, mode 1: AND $FF then LSR) to determine which statue_reward table entry to check.
; 
; === $0E PARAMETER ENCODING ===
; 
; The actor-spawn byte 2 encodes two fields after the LSR transformation:
; - Low nibble (AND $000F): Index into statue_reward_00CE97 table (0–5)
; - Bit 4 ($0010): Y-position nudge flag — if set, COP NudgePosition(0,$F8) shifts the actor 8 pixels upward (top-row adjustment)
; 
; Scene $FF actor-spawn entries and their decoded $0E values:
; | Spawn byte | After LSR | Index | Bit 4 | Flag | Sprite | Position |
; |-----------|-----------|-------|-------|------|--------|----------|
; | $21 | $10 | 0 | Yes | $F8 | $3A | (2,3) top-left |
; | $03 | $01 | 1 | No | $F9 | $3B | (1,5) mid-left |
; | $05 | $02 | 2 | No | $FA | $3C | (2,8) bot-left |
; | $27 | $13 | 3 | Yes | $FB | $3D | (12,3) top-right |
; | $09 | $04 | 4 | No | $FC | $3E | (13,5) mid-right |
; | $0B | $05 | 5 | No | $FD | $3F | (12,8) bot-right |
; 
; The spawn position parameters are identical between scene $FF (inventory) and scene $FD (reward ceremony).
; 
; === FLAG CHECK AND DISPLAY ===
; 
; On init: loads $0E → $24, applies NudgePosition(8,8) for all actors plus an additional (0,$F8) for bit-4 actors, then indexes statue_reward_00CE97[low_nibble × 4]. Calls TestFlagRaw with the flag byte (event flags $F8–$FD at $0A00 array). If flag is clear (statue not collected), COP Die kills the actor immediately — no sprite displayed.
; 
; If flag is set (statue collected): enters InventoryStatueSlotClaimed. Loads sprite index from table byte 1 ($3A–$3F), sets as animation frame $28, calls UpdateActorAnimation, clears $2000 hidden flag to make visible.
; 
; Main loop (SetEntryHere): checks inventoryTabIndex each frame. On tabs 0/1/2 (Use/Arrange/Discard), clears $2000 → statue visible. On tab 3 (Status), sets $2000 → statue hidden. This ensures statues only appear when the item grid is showing.
; 
; === PEDESTAL LAYOUT ===
; 
; Six pedestals arranged symmetrically around the 4×4 inventory grid:
;   Left column (pixel X ~24–40): statues 0, 1, 2 (top to bottom)
;   Right column (pixel X ~200–216): statues 3, 4, 5 (top to bottom)
;   Y positions: ~48 (top), ~88 (middle), ~136 (bottom)
; 
; === RELATIONSHIP TO statue_inventory_reward ===
; 
; This actor is the passive display counterpart to statue_inventory_reward (scene $FD). The reward ceremony actor SETS the event flags ($F8–$FD); this actor merely READS them to show/hide the statue sprite. Both share the same statue_reward_00CE97 lookup table and identical scene_actors spawn parameters.
---------------------------------------------

?INCLUDE 'flag_helpers'
?INCLUDE 'inventory_spritemap'
?INCLUDE 'sprite_composition'
?INCLUDE 'statue_inventory_reward'

!inventoryTabIndex              0AFA

---------------------------------------------

inventory_statue_slot [
  actor-def < #00, #00, #38, {

  code_00CF2C:
    COP [NudgePosition] ( #08, #08 ) ; Slot entry: NudgePosition(8,8), SetMetasprite(@inventory_spritemap)
    COP [SetMetasprite] ( @inventory_spritemap )
    LDA $0E
    STA $24
    BIT #$0010
    BEQ loc_00CF42
    COP [NudgePosition] ( #00, #F8 )

  loc_00CF42:
    LDA #$2000            ; Store $2000 to $0E; extract statue_reward index from $24 AND $000F × 4
    STA $0E
    PHX 
    LDA $24
    AND #$000F
    ASL 
    ASL 
    TAX 
    LDA $@statue_inventory_reward.statue_reward_00CE97, X ; Index statue_reward_00CE97: load flag, TestFlagRaw — if clear (not collected), Die
    AND #$00FF
    JSL $@flag_helpers.TestFlagRaw
    BCC loc_00CF60
    JMP $&InventoryStatueSlotClaimed

  loc_00CF60:
    PLX 
    COP [Die]             ; InventoryStatueSlotClaimed: load sprite ($3A–$3F), set $28, UpdateActorAnimation
} >
]

InventoryStatueSlotClaimed {
    LDA $@statue_inventory_reward.statue_reward_00CE97+1, X
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@sprite_composition.UpdateActorAnimation
    LDA #$2000
    TRB $10
    COP [SetEntryHere]
    LDA $inventoryTabIndex
    CMP #$0003
    BEQ loc_00CF88
    LDA #$2000
    TRB $10
    RTL 

  loc_00CF88:
    LDA #$2000
    TSB $10
    RTL 
}