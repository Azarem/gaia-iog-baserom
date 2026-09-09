---------------------------------------------

ec0A_edwina [
  actor-def < #2B, #00, #18, {

  code_04C571:
    LDA #$0200
    TSB $12
    COP [AddPosition] ( #08, #00 )
    COP [SetOnInteract] ( &code_04C588 )
    COP [ExitIfFlagByte] ( #0B, #01 )
    COP [SetFlagByte] ( #0C )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C588 {
    COP [PrintWideString] ( &widestring_04C58D )
    RTL 
}

widestring_04C58D `[DEF][TPL:3]Queen Edwina:[N]The King sent you the[N]letter. Talk to him.[PAL:0][END]`