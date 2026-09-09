!joypadMaskStd                  065A
!characterForm                  0AD4

---------------------------------------------

pyDD_mystic_statue [
  actor-def < #00, #00, #30, {

  code_08CE15:
    COP [SetEntryContinue]
    LDA $0AEC
    BEQ loc_08CE1D
    RTL 

  loc_08CE1D:
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_08CE60 )
    LDA #$0004
    STA $0AAC
    LDA #$00CD
    STA $0B12
    LDA #$0007
    STA $0B08
    STA $0B0A
    LDA #$0009
    STA $0B0C
    STA $0B0E
    LDA #$0000
    STA $0B10
    COP [QueueMapChange] ( #FD, #$0000, #$0000, #00, #$1100 )
    LDA #$0000
    STA $characterForm
    COP [Die]
} >
]

widestring_08CE60 `[DEF][TPL:0]Defeating the spirit[N]of the Pyramid,[N]he obtained[N]a Mystic Statue!![PAL:0][END]`