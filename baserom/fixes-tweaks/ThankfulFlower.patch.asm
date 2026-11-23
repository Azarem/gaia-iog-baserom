; ==============================================================================
; Edward Castle flower - thank-you dialog on interact
; ==============================================================================
; What it does: Routes the flower to its thank-you dialogue when
;   the player talks to the flower after playing the song or opening the door.
; Vanilla behavior: code_09BC4C shows the hint to play the flute.
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

thankful_flower_str `[BOR:6][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme18]Thank you, that was[N]lovely![END]`
