
;eu95_neils_mother

code_07E316! {
    LDA $0B5A
    BIT #$0040
    BNE eu95_neils_mother_use
    COP [BranchIfHasItem] ( #19, &eu95_neils_mother_use )
    COP [PrintDialogString] ( &dialogstring_07E31B )
    RTL 
}

eu95_neils_mother_use {
    JML $@eu95_neils_mother_use_stub
}

code_039856+ {
  eu95_neils_mother_use_stub:
    COP [PrintDialogString] ( &dialogstring_039861 )
    JSR $&code_039856
    RTL
}
