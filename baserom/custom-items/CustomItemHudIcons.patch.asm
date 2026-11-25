; Equipped-item HUD art for the custom items.
EquippedIcon.item_icon_list+= [
  &CustomItemLedgerHudIcon      ;29
  &CustomItemNegativeArcHudIcon ;2A
  &CustomItemShirasGiftHudIcon   ;2B
  &CustomItemEmblemHudIcon      ;2C
]

CustomItemShirasGiftHudIcon {
    PEA #$&pal_item_exprite2+C0
    PEA #$&gfx_item_exprite+1A40
    LDX #$&gfx_item_exprite+1840
    JMP item_icon_next
}

CustomItemLedgerHudIcon {
    PEA #$&pal_item_exprite2+20
    PEA #$&gfx_item_exprite+12C0
    LDX #$&gfx_item_exprite+10C0
    JMP item_icon_next
}

CustomItemEmblemHudIcon {
    PEA #$&pal_item_exprite+1C0
    PEA #$&gfx_item_exprite+1600
    LDX #$&gfx_item_exprite+1400
    JMP item_icon_next
}

CustomItemNegativeArcHudIcon {
    PEA #$&pal_item_exprite2+A0
    PEA #$&gfx_item_exprite+1A00
    LDX #$&gfx_item_exprite+1800
    JMP item_icon_next
}
