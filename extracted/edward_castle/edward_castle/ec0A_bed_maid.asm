---------------------------------------------

ec0A_bed_maid [
  actor-def < #25, #00, #10, {

  code_04C7B1:
    COP [SetOnInteract] ( &code_04C7BA )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C7BA {
    COP [PrintWideString] ( &widestring_04C7BF )
    RTL 
}

widestring_04C7BF `[DEF]Recently, a hunter was[N]hired.[N]I wonder what the King[N]is thinking...[END]`