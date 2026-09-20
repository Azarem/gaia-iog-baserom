; Telescope in Neil's cottage — stargazing invention.
; 
; Interactive object: "That's a telescope. You can see stars
; as if they were in your hand." Shows Neil's scientific
; instruments. Connects to the comet observation theme.
---------------------------------------------

?INCLUDE 'spriteset_enemies'

---------------------------------------------

na49_telescope [
  actor-def < #00, #00, #30, {

  code_05E4DA:
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetInteractHandler] ( &code_05E4EB )
    COP [SetEntryHere]
    RTL 
} >
]

code_05E4EB {
    COP [PrintDialogString] ( &dialogstring_05E4F9 )
    LDA $0AA6
    ORA #$0004
    STA $0AA6
    RTL 
}

dialogstring_05E4F9 `[TPL:A][TPL:6]That's a telescope.[N]You can see stars as if[N]they were in your hand.[PAL:0][END]`