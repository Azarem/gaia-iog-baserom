; Inventory menu actor that displays a collected mystic statue sprite at one of six grid slots when its flag is set.
; 
; Reads statue_reward table entries indexed by actor $0E nibble, checks TestFlagRaw, and shows the appropriate inventory_spritemap frame on inventory tab #3. Spawned on scene $FF alongside the inventory menu. Shows which statues the player has placed in the inventory grid.
---------------------------------------------

?INCLUDE 'cop_handlers_flags'
?INCLUDE 'inventory_spritemap'
?INCLUDE 'sprite_composition'
?INCLUDE 'statue_inventory_reward'

!inventoryTabIndex              0AFA

---------------------------------------------

inventory_statue_slot [
  actor-def < #00, #00, #38, {

  code_00CF2C:
    COP [AddPosition] ( #08, #08 )
    COP [SetMetasprite] ( @inventory_spritemap )
    LDA $0E
    STA $24
    BIT #$0010
    BEQ loc_00CF42
    COP [AddPosition] ( #00, #F8 )

  loc_00CF42:
    LDA #$2000
    STA $0E
    PHX 
    LDA $24
    AND #$000F
    ASL 
    ASL 
    TAX 
    LDA $@statue_inventory_reward.statue_reward_00CE97, X
    AND #$00FF
    JSL $@cop_handlers_flags.TestFlagRaw
    BCC loc_00CF60
    JMP $&InventoryStatueSlotClaimed

  loc_00CF60:
    PLX 
    COP [Die]
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
    COP [SetEntryContinue]
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