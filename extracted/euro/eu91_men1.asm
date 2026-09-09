?INCLUDE 'func_06B9F2'

---------------------------------------------

eu91_men1 [
  actor-def < #02, #00, #10, {

  code_07C405:
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0003
    CLC 
    ADC #$0002
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    JSL $@func_06B9F2
    COP [SetOnInteract] ( &code_07C427 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_07C427 {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07C432 )
}

code_list_07C432 [
  &code_07C444   ;00
  &code_07C449   ;01
  &code_07C44E   ;02
  &code_07C453   ;03
  &code_07C458   ;04
  &code_07C45D   ;05
  &code_07C462   ;06
  &code_07C467   ;07
  &code_07C46C   ;08
]

code_07C444 {
    COP [PrintWideString] ( &widestring_07C480 )
    RTL 
}

code_07C449 {
    COP [PrintWideString] ( &widestring_07C4AA )
    RTL 
}

code_07C44E {
    COP [PrintWideString] ( &widestring_07C4D0 )
    RTL 
}

code_07C453 {
    COP [PrintWideString] ( &widestring_07C509 )
    RTL 
}

code_07C458 {
    COP [PrintWideString] ( &widestring_07C56C )
    RTL 
}

code_07C45D {
    COP [PrintWideString] ( &widestring_07C5AB )
    RTL 
}

code_07C462 {
    COP [PrintWideString] ( &widestring_07C60A )
    RTL 
}

code_07C467 {
    COP [PrintWideString] ( &widestring_07C63F )
    RTL 
}

code_07C46C {
    COP [PrintWideString] ( &widestring_07C6FE )
    RTL 
}

code_07C471 {
    COP [PrintWideString] ( &widestring_07C74B )
    RTL 
}

code_07C476 {
    COP [PrintWideString] ( &widestring_07C74D )
    RTL 
}

code_07C47B {
    COP [PrintWideString] ( &widestring_07C74F )
    RTL 
}

widestring_07C480 `[DEF]This is Euro. It's a[N]crowded merchant town.[END]`

widestring_07C4AA `[DEF]Villagers live here.[N]Outsiders can't enter.[END]`

widestring_07C4D0 `[DEF]This is the marketplace.[N]You can find anything[N]you want here.[END]`

widestring_07C509 `[DEF]The town prospers thanks[N]to the Rolek company.[FIN]There are lots of bad[N]rumors, but I think[N]the company is great.[END]`

widestring_07C56C `[DEF]This is the shrine. The [N]president of the [N]company and his [N]wife come here often.[END]`

widestring_07C5AB `[DEF]This is the Rolek[N]corporate office.[FIN]Almost everything you [N]buy in the town comes [N]through the company.[END]`

widestring_07C60A `[DEF]Man: Yes, the company[N]handles almost anything[N]you can imagine.[END]`

widestring_07C63F `[DEF]My brother and I once[N]went to Mt.Kress and[N]got lost at the temple.[FIN]Big mushrooms and[N]plants grow in circles[N]like a maze.[FIN]Water from the mushrooms[N]drips onto broken stems.[N]New growth sprouts up,[N]forming a path.[END]`

widestring_07C6FE `[DEF]The drops from the[N]mushrooms are all around[N]the temple grounds...[FIN]Ah, you're growing up[N]quickly.[END]`

widestring_07C74B `[DEF][END]`

widestring_07C74D `[DEF][END]`

widestring_07C74F `[DEF][END]`