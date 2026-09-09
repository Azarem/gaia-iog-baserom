?INCLUDE 'chunk_03BAE1'
?INCLUDE 'cop_handlers_script'
?INCLUDE 'inventory_spritemap'
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
    JSL $@cop_handlers_script.TestFlagRaw
    BCC loc_00CF60
    JMP $&code_00CF63

  loc_00CF60:
    PLX 
    COP [Die]
} >
]

code_00CF63 {
    LDA $@statue_inventory_reward.statue_reward_00CE97+1, X
    AND #$00FF
    STA $28
    STZ $2A
    PLX 
    JSL $@chunk_03BAE1.func_03CA55
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