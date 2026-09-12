?INCLUDE 'func_06B9F2'

---------------------------------------------

av6B_villagers1 [
  actor-def < #02, #00, #10, {

  code_06C758:
    LDA $0E
    AND #$0070
    LSR 
    LSR 
    LSR 
    LSR 
    CLC 
    ADC $28
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@func_06B9F2
    COP [SetOnInteract] ( &code_06C77D )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_06C77D {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_06C788 )
}

code_list_06C788 [
  &code_06C794   ;00
  &code_06C7EA   ;01
  &code_06C840   ;02
  &code_06C896   ;03
  &code_06C97C   ;04
  &code_06C9BA   ;05
]

code_06C794 {
    COP [PrintDialogString] ( &dialogstring_06C799 )
    RTL 
}

dialogstring_06C799 `[TPL:B]This is the Angel [N]Village. If our bodies [N]are exposed to the sun [N]for long, we'll perish. [END]`

code_06C7EA {
    COP [PrintDialogString] ( &dialogstring_06C7EF )
    RTL 
}

dialogstring_06C7EF `[TPL:B]This is the Angel [N]Village. If our bodies [N]are exposed to the sun [N]for long, we'll perish. [END]`

code_06C840 {
    COP [PrintDialogString] ( &dialogstring_06C845 )
    RTL 
}

dialogstring_06C845 `[TPL:B]This is the Angel [N]Village. If our bodies [N]are exposed to the sun [N]for long, we'll perish. [END]`

code_06C896 {
    COP [PrintDialogString] ( &dialogstring_06C8B0 )
    COP [DialogueOptions] ( #02, #02, &code_list_06C8A0 )
}

code_list_06C8A0 [
  &code_06C8A6   ;00
  &code_06C8AB   ;01
  &code_06C8A6   ;02
]

code_06C8A6 {
    COP [PrintDialogString] ( &dialogstring_06C8DC )
    RTL 
}

code_06C8AB {
    COP [PrintDialogString] ( &dialogstring_06C8F7 )
    RTL 
}

dialogstring_06C8B0 `[DEF]Do you know [N]the painter, Ishtar? [N] Yes [N] No `

dialogstring_06C8DC `[CLR]You should speak [N]with everyone. [END]`

dialogstring_06C8F7 `[CLR]Ishtar's studio is[N]on the other side[N]of this door.[FIN]But in front, creatures [N]with hate in their [N]hearts are waiting. [FIN]If you must go, you[N]can open the door.[END]`

code_06C97C {
    COP [PrintDialogString] ( &dialogstring_06C981 )
    RTL 
}

dialogstring_06C981 `[TPL:A]I am a sculptor. I plan[N]to make 1000 statues [N]in my lifetime...[END]`

code_06C9BA {
    COP [PrintDialogString] ( &dialogstring_06C9BF )
    RTL 
}

dialogstring_06C9BF `[TPL:B]This is the Angel [N]Village. If our bodies [N]are exposed to the sun [N]for long, we'll perish. [END]`