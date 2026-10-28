; Pedestal statue of the inventory screen (Bank 00, 53033-53134): shows one collected mystic statue, or removes itself when that statue is not collected yet.
; 
; SPAWN: scene $FF (the inventory overlay) lists six copies right after InventoryMenuDef; scene $FD (the reward ceremony) has the same six positions for statue_inventory_reward. Initial flags $3800 (actor-def header byte): $2000 hidden, $1000 and $0800 keep it running in the display-filtered and cutscene-only actor passes (the inventory main loop uses RunActors_CutsceneOnly).
; 
; PARAMETER ($0E): InitActorFromSceneData, mode 1 (spawn byte 2 odd): $0E = (byte AND $FF) >> 1. The low nibble is the index into statue_reward_table (0-5); bit 4 ($0010) marks a top-row pedestal, moved 8 px up. The actor overwrites $0E with $2000 (the OAM attribute word) after reading it.
; 
; | Spawn byte | After >> 1 | Index | Bit 4 | Flag | Sprite | Tile (x,y) | Actor X, Y |
; |-----------|-----------|-------|-------|------|--------|------------|------------|
; | $21 | $10 | 0 | yes | $F8 | $3A | (2,3) top-left | 48, 48 |
; | $03 | $01 | 1 | no | $F9 | $3B | (1,5) mid-left | 32, 88 |
; | $05 | $02 | 2 | no | $FA | $3C | (2,8) bottom-left | 48, 136 |
; | $27 | $13 | 3 | yes | $FB | $3D | (12,3) top-right | 208, 48 |
; | $09 | $04 | 4 | no | $FC | $3E | (13,5) mid-right | 224, 88 |
; | $0B | $05 | 5 | no | $FD | $3F | (12,8) bottom-right | 208, 136 |
; Actor X = tile x 16 + 8 (the engine's centring offset for non-player actors) + 8 (NudgePosition); actor Y = tile y 16 + 8, minus 8 for bit 4. Positions are actor coordinates, not screen pixels.
; 
; STATE: TestFlagRaw(flag) returns carry set when the flag is set; flag N is bit (N AND 7) of byte $0A00 + N / 8, so $F8-$FD are bits 0-5 of the single byte $0A1F. Flag clear: COP Die, nothing is drawn. Flag set: InventoryStatueSlotClaimed sets the animation index $28 from table byte +1 ($3A-$3F), runs UpdateActorAnimation and clears the hidden bit; every frame after that inventoryTabIndex = 3 (Status tab) hides the statue and any other tab shows it, so the statues sit beside the item grid only.
; The table has 4 bytes per entry (flag, sprite, match, one tail byte); this actor reads +0 and +1. The flags are set by statue_inventory_reward (scene $FD), which this actor only displays.
---------------------------------------------

?INCLUDE 'flag_helpers'
?INCLUDE 'inventory_spritemap'
?INCLUDE 'sprite_composition'
?INCLUDE 'statue_inventory_reward'

!inventoryTabIndex              0AFA

---------------------------------------------

inventory_statue_slot [
  actor-def < #00, #00, #38, {

; Actor entry: NudgePosition (+8, +8), metasprite inventory_spritemap, spawn parameter kept in $24, and an extra 8 px up when bit 4 of the parameter marks a top-row pedestal.

  InventoryStatueSlotEntry:
    COP [NudgePosition] ( #08, #08 ) ; Slot entry: +8, +8 on top of the engine's own +8 X centring (see the block note for the positions)
    COP [SetMetasprite] ( @inventory_spritemap ) ; Metasprite = inventory_spritemap (the statue frames $3A-$3F are animation indexes in it)
    LDA $0E               ; $0E = spawn parameter (spawn byte 2 >> 1), kept in $24; bit 4 marks a top-row pedestal, moved 8 px up
    STA $24
    BIT #$0010
    BEQ InventoryStatueSlotSetup
    COP [NudgePosition] ( #00, #F8 )

; Parameter handled: $0E := $2000 (the OAM attribute word), then the statue's event flag is read from statue_reward_table (index = low nibble of $24, 4 bytes per entry) and tested with TestFlagRaw.

  InventoryStatueSlotSetup:
    LDA #$2000            ; $0E = $2000: the OAM attribute word, replacing the spawn parameter
    STA $0E
    PHX                   ; Save the actor slot; X becomes the table offset (index = low nibble x 4, 4 bytes per entry)
    LDA $24
    AND #$000F
    ASL 
    ASL 
    TAX 
    LDA $@statue_inventory_reward.statue_reward_table, X ; Entry +0: event flag index ($F8-$FD)
    AND #$00FF
    JSL $@flag_helpers.TestFlagRaw ; Carry set = this statue was collected
    BCC InventoryStatueSlotUncollected
    JMP $&InventoryStatueSlotClaimed

; Flag clear (statue not collected yet): restore the actor slot and Die; nothing is drawn.

  InventoryStatueSlotUncollected:
    PLX                   ; Not collected: restore the actor slot and remove the actor, nothing is shown
    COP [Die]
} >
]

---------------------------------------------
; Reached by JMP from the actor entry with X = table byte offset and the actor slot still on the stack (the first PLX restores it). Sets the statue frame, clears the hidden bit and runs the per-frame tab test.

InventoryStatueSlotClaimed {
    LDA $@statue_inventory_reward.statue_reward_table+1, X ; Entry +1: sprite (animation index $3A-$3F in inventory_spritemap)
    AND #$00FF
    STA $28               ; Animation index of the statue frame
    STZ $2A
    PLX 
    JSL $@sprite_composition.UpdateActorAnimation ; Stage the statue frame
    LDA #$2000            ; Show the statue (clear the hidden bit) until the tab test below hides it
    TRB $10
    COP [SetEntryHere]    ; Re-entry point: the tab test runs every frame
    LDA $inventoryTabIndex ; inventoryTabIndex: 0 Use, 1 Arrange, 2 Discard, 3 Status
    CMP #$0003
    BEQ InventoryStatueSlotHide ; Status tab: hide the statue; any other tab shows it
    LDA #$2000
    TRB $10
    RTL 

; Status tab (inventoryTabIndex = 3): set the hidden bit $2000 in $10 and return; every other tab clears it in the lines above.

  InventoryStatueSlotHide:
    LDA #$2000
    TSB $10
    RTL 
}