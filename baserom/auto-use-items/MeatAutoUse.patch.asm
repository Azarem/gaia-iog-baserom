; ==============================================================================
; MeatAutoUse - auto-feed Smoked Meat during the raft starvation cutscene
; ==============================================================================
; What it does: When the adrift sequence sets hunger flag $02 via code_05976D,
;   immediately runs UseItem_SmokedMeat if the player has item #0A or the auto-use
;   bit in key_item_flags, instead of only setting flag $02 and stopping.
; Vanilla behavior: dc2F_adrift code_05976D prints dialogstring_059E6F and sets
;   flag byte $02; the player must open inventory and use Smoked Meat separately.
; Hooks (overrides): dc2F_adrift.code_05976D!.
; Adds: meat_auto_use -> JML $@ItemUseStub.
; Depends on: !key_item_flags $0B58 bit $0002; item #0A; UseItem_SmokedMeat (bank 03).
; State: Flag $02 (hungry villagers), $03 set by UseItem_SmokedMeat; scene $2F.
; Hazards/notes: Reached when flag $01 already set (branch from code_059749); COP context.
; ==============================================================================

!key_item_flags      0B58

----------------------------------------------

dc2F_adrift.code_05976D! {
    COP [PrintDialogString] ( &dialogstring_059E6F )
    COP [SetFlagByte] ( #02 )
    LDA $key_item_flags
    BIT #$0002
    BNE meat_auto_use
    COP [BranchIfHasItem] ( #0A, &meat_auto_use )
    RTL 
}

meat_auto_use {
    LDA #$UseItem_SmokedMeat+E
    JML $@ItemUseStub
}
