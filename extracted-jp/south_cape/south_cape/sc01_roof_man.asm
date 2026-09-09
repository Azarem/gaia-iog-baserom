?INCLUDE 'chunk_008000'

!currentHp                      7F0026

---------------------------------------------

h_sc01_roof_man [
  actor-def < #0D, #00, #10, {

  code_04845A:
    LDA #$000A
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D
    COP [SetOnInteract] ( &code_048475 )

  loc_048469:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_048469
} >
]

code_048475 {
    COP [PrintWideString] ( &widestring_04847A )
    RTL 
}

widestring_04847A `[DEF]こらっ テムっ.[N]あれほど ここへ 上っちゃ[N]いけないと···[FIN]お前は いろんなところから[N]飛び降りるクセが あるからなぁ.[N]心配で しかたないよ.[N]トホホ.[END]`