?INCLUDE 'func_06B9F2'
?INCLUDE 'table_0EDA00'

---------------------------------------------

av69_signs [
  actor-def < #05, #00, #10, {

  code_06BA0C:
    JSL $@func_06B9F2
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_06BA28 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_06BA28 {
    LDA $24
    BNE loc_06BA31
    COP [PrintDialogString] ( &dialogstring_06BA36 )
    RTL 

  loc_06BA31:
    COP [PrintDialogString] ( &dialogstring_06BA6B )
    RTL 
}

dialogstring_06BA36 `[DEF]       Travellers[N]Please use this room.[N][N]       Angel Tribe[END]`

dialogstring_06BA6B `[DEF][N] Angel Village Entrance[END]`