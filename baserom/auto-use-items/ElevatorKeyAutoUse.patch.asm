
code_05D661! {
    LDA $0B58
    BIT #$0020
    BNE code_05D66B
    COP [BranchIfHasItem] ( #0F, &code_05D66B )
    COP [PrintDialogString] ( &dialogstring_05D676 )
    RTL 
}
