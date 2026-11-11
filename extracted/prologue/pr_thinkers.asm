; Prologue palette thinkers.
; 
; Two palette-bundle thinkers: e_pr_thinker_0BD031 starts bundle $75, steps once and kills itself; e_pr_thinker_0BD039 starts bundle $76, steps once, sets scratch flag $0F and kills itself. e_pr_thinker_0BD039 is spawned in scenes $8C-$8F; no actor of those scenes reads $0F.
---------------------------------------------

---------------------------------------------

e_pr_thinker_0BD031 {
    COP [PaletteStart] ( #75 )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
}
---------------------------------------------

e_pr_thinker_0BD039 {
    COP [PaletteStart] ( #76 )
    COP [PaletteStep]
    COP [SetFlagByte] ( #0F )
    COP [KillThinker]
    RTL 
}