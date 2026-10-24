
;eu95_neils_father

code_07E1BD- {
    COP [SpawnAfterOffsetFlags] ( @eu95_neils_father_activator, #$0000, #$FFF0, #$7000 )
}

code_07E21C+ {
  eu95_neils_father_activator:
    COP [SetInteractHandler] ( &code_07E21C )
    COP [WaitOnFlagByte] ( #A8, #01 )
    COP [Die]
}
