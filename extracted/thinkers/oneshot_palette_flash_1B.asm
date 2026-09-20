; One-shot palette flash using animation index #1B, run once then killed.
; 
; Used in Mu prayer room and Edward Castle prison cutscenes, alternated with flash #1C. Provides the first half of a distinct flash pair separate from the #18/#19 combination.
---------------------------------------------

---------------------------------------------

oneshot_palette_flash_1B [
  thinker-def < #00, #08, {

  FlashPalette1B:
    COP [PaletteStart] ( #1B )
    COP [PaletteStep]
    COP [KillThinker]
    RTL 
} >
]