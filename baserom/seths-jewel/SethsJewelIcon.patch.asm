; ==============================================================================
; Seth's Jewel (item $29) - equipped-item HUD icon
; ==============================================================================
; What it does: Appends HUD icon routine for item $29 using Red Jewel CHR tiles with a
;   custom 16-color palette (inventory purple on key colours via pal_item_exprite2+80).
; Vanilla behavior: item_icon_list in EquippedIcon.patch.asm ends at index $28; no icon for $29.
; Hooks (overrides): item_icon_list+= entry $29 (target lives in baserom EquippedIcon patch, not extracted).
; Adds: item_icon_seths_jewel -> PEA palette, PEA gfx+240, LDX gfx+40, JMP item_icon_next.
; Depends on: EquippedIcon item_icon_list / item_icon_next; gfx_item_exprite, pal_item_exprite2.
; Hazards/notes: Palette slot at pal_item_exprite2+80 ($80-$9F bytes in equipped-icon bundle).
; ==============================================================================

EquippedIcon.item_icon_list+= [
  &item_icon_seths_jewel   ;29
]

item_icon_seths_jewel {
    PEA #$&pal_item_exprite2+80
    PEA #$&gfx_item_exprite+240
    LDX #$&gfx_item_exprite+40
    JMP item_icon_next
}
