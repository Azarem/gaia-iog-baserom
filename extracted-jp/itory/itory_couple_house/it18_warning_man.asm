---------------------------------------------

h_it18_warning_man [
  actor-def < #02, #00, #10, {

  code_04D716:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_04D71F )
    COP [SetEntryHere]
    RTL 
} >
]

code_04D71F {
    COP [PrintDialogString] ( &dialogstring_04D724 )
    RTL 
}

dialogstring_04D724 `[TPL:A]多くの人々が インカの黄金を求めて[N]この地へ やってきたよ.[FIN]だが インカの遺跡へ 足を[N]ふみいれた者は 結局 もどって[N]こなかったな···[END]`