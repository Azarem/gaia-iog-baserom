?INCLUDE 'chunk_008000'

!currentHp                      7F0026

---------------------------------------------

h_sc04_poverty [
  actor-def < #15, #00, #10, {

  code_048E75:
    LDA #$0012
    STA $currentHp, X
    JSL $@chunk_008000.code_00C85D
    COP [SetOnInteract] ( &code_048E90 )

  loc_048E84:
    JSL $@chunk_008000.code_00C86A
    COP [SetEntryExit]
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_048E84
} >
]

code_048E90 {
    COP [PrintDialogString] ( &dialogstring_048E95 )
    RTL 
}

dialogstring_048E95 `[DEF]世の中 ちょっとしたことで[N]お金持ちにも貧ぼうにもなるのね.[N]あーあ 何か いい話が[N]ころがってないかなぁ.[END]`