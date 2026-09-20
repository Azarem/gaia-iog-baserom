; Necklace stone drop — Lance's necklace piece on the Great Wall.
; 
; Collectible event item. Dialog: "A small stone falls." Then:
; "Ha! This is part of the necklace Lance made for Lilly."
; Key plot item that connects to Lance's story and his
; relationship with Lilly.
---------------------------------------------

?INCLUDE 'cop_handlers_flags'
?INCLUDE 'f_inventory_full'
?INCLUDE 'spriteset_enemies'

---------------------------------------------

gw82_necklace_stone [
  actor-def < #02, #01, #10, {

  code_07B5A1:
    LDA #$0200
    TSB $12
    LDA $0E
    STA $24
    PHX 
    TAX 
    LDA $@byte_07B5F5, X
    AND #$00FF
    PLX 
    JSL $@cop_handlers_flags.TestFlagRaw
    BCS loc_07B5EF
    LDA #$2000
    STA $0E
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetInteractHandler] ( &code_07B5D2 )

  loc_07B5C8:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    BRA loc_07B5C8
} >
]

code_07B5D2 {
    COP [PrintDialogString] ( &dialogstring_07B611 )
    COP [BranchIfMissingItem] ( #17, &code_07B5E0 )
    COP [GiveItem] ( #17, &code_07B5F1 )
}

code_07B5E0 {
    PHX 
    LDX $24
    LDA $@byte_07B5F5, X
    AND #$00FF
    PLX 
    JSL $@cop_handlers_flags.SetFlagRaw

  loc_07B5EF:
    COP [Die]
}

code_07B5F1 {
    JML $@f_inventory_full.InventoryFullMessage
}

byte_07B5F5 [
  #98   ;00
  #99   ;01
  #9A   ;02
  #9B   ;03
  #9C   ;04
]

dialogstring_07B5FA `[TPL:A][TPL:0]A small stone falls.[PAL:0][END]`

dialogstring_07B611 `[TPL:A][TPL:0]A small stone falls.[FIN]Ha! This is part of the [N]necklace Lance made [N]for Lilly! [FIN]I picked up the stones.[PAL:0][END]`