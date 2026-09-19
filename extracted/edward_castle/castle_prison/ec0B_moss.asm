; Prison wall moss inspection dialog.
; 
; Will examines moss growing on the prison wall and reflects on
; the prisoners who came before him.
---------------------------------------------

---------------------------------------------

ec0B_moss [
  actor-def < #00, #00, #10, {

  code_04DB4D:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04DB59 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04DB59 {
    COP [PrintDialogString] ( &dialogstring_04DB62 )
    COP [SetFlagByte] ( #03 )
    COP [Die]
}

dialogstring_04DB62 `[TPL:E][TPL:0]Will: This moss has seen[N]thousands of prisoners [N]come and go... [FIN]Those prisoners must [N]have been encouraged [N]by any sign of life....[PAL:0][END]`