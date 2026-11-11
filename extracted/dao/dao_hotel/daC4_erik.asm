; Erik at the Dao hotel (scene $C4): dies at spawn when $D2 is set; otherwise he stands solid with 'I can't go outside in a sandstorm like this.'.
---------------------------------------------

---------------------------------------------

daC4_erik [
  actor-def < #0A, #00, #10, {

  code_08A56A:
    COP [BranchOnFlagByte] ( #D2, #01, &code_08A579 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_08A57B )
    COP [SetEntryHere]
    RTL 
} >
]

code_08A579 {
    COP [Die]
}

code_08A57B {
    COP [PrintDialogString] ( &dialogstring_08A580 )
    RTL 
}

dialogstring_08A580 `[TPL:A][TPL:3]Erik: [N]I can't go outside in [N]a sandstorm like this.[PAL:0][END]`