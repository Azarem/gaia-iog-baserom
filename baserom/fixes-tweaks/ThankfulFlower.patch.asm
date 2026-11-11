; ==============================================================================
; Edward Castle flower - thank-you dialog on interact
; ==============================================================================
; What it does: Replaces the flower's empty interact handler with dialog when
;   the player uses the tile (COP D0/D1 routes to thankful_flower_interact).
; Vanilla behavior: code_09BC4C is an empty interact stub after SetInteractHandler.
; Hooks (overrides): ec11_flower code_09BC4C (prepend COP interact wiring).
; Adds: thankful_flower_interact, thankful_flower_str dialog text.
; Depends on: ec11_flower scene actor.
; Hazards/notes: COP D0/D1; RTL from interact handler.
; ==============================================================================

-------------------------------------
?INCLUDE 'ec11_flower'
-------------------------------------


ec11_flower.code_09BC4C-= {
    COP [D1] ( #$0113, #01, &thankful_flower_interact )
    COP [D0] ( #02, #01, &thankful_flower_interact )
}

thankful_flower_interact {
    COP [BF] ( &thankful_flower_str )
    RTL 
}

thankful_flower_str `[TPL:18][TPL:D]Thank you, that was[N]lovely![END]`
