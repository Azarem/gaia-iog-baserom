; Seth's Jewel - equipped-item HUD icon (item ID $29).
;
; EquippedIcon.patch.asm jumps through item_icon_list[inventoryEquippedType]; the list stops at $28, so the
; $29 entry is appended here. The icon reuses the Red Jewel tiles (gfx_item_exprite +40 / +240) and only
; swaps the 16-colour palette. item_icon_next copies the palette from the same bank as pal_item_exprite
; (^pal_item_exprite), so the new palette lives in an unused filler entry of pal_item_exprite2.pal:
;
;   pal_item_exprite2 +80  (equipped-icon/pal_item_exprite2.pal, bytes $80-$9F)
;     colours 0-7, 15  copied from the Red Jewel HUD palette (pal_item_exprite +0)
;     colours 8-13     inventory OAM palette 2, colours 2-7 (HUD colour = inventory colour + 6),
;                      i.e. the same purple the inventory sprite uses
;     colour 14        duplicate of 13, like the Red Jewel palette
;
; Both item_icon_list+ and the routine are merged/inserted into the EquippedIcon patch chunk, so the routine
; stays in the same bank as the JMP ($&item_icon_list, X) dispatch.

item_icon_list+= [
  &item_icon_seths_jewel   ;29
]

item_icon_seths_jewel {
    PEA #$&pal_item_exprite2+80
    PEA #$&gfx_item_exprite+240
    LDX #$&gfx_item_exprite+40
    JMP item_icon_next
}
