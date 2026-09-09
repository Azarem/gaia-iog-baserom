?INCLUDE 'f_inventory_full'

---------------------------------------------

eu91_merchant_counter [
  actor-def < #00, #00, #10, {

  code_07C05E:
    LDA #$0200
    TSB $12
    LDA $0E
    LSR 
    LSR 
    LSR 
    LSR 
    AND #$0007
    STA $24
    LDA $0E
    AND #$000F
    CLC 
    ADC #$001B
    STA $28
    STZ $2A
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    LDA #$3000
    STA $0E
    COP [SetOnInteract] ( &code_07C08B )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07C08B {
    LDA $24
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_07C096 )
}

code_list_07C096 [
  &code_07C0A6   ;00
  &code_07C0A7   ;01
  &code_07C0BF   ;02
  &code_07C0C4   ;03
  &code_07C0C9   ;04
  &code_07C0CE   ;05
  &code_07C0D3   ;06
  &code_07C0D8   ;07
]

code_07C0A6 {
    RTL 
}

code_07C0A7 {
    COP [BranchIfNoItem] ( #28, &code_07C0B6 )
    COP [PrintWideString] ( &widestring_07C0F3 )
    COP [GiveItem] ( #28, &code_07C0BB )
    RTL 
}

code_07C0B6 {
    COP [PrintWideString] ( &widestring_07C0DD )
    RTL 
}

code_07C0BB {
    JML $@f_inventory_full.InventoryFullMessage
}

code_07C0BF {
    COP [PrintWideString] ( &widestring_07C12A )
    RTL 
}

code_07C0C4 {
    COP [PrintWideString] ( &widestring_07C142 )
    RTL 
}

code_07C0C9 {
    COP [PrintWideString] ( &widestring_07C160 )
    RTL 
}

code_07C0CE {
    COP [PrintWideString] ( &widestring_07C182 )
    RTL 
}

code_07C0D3 {
    COP [PrintWideString] ( &widestring_07C1B6 )
    RTL 
}

code_07C0D8 {
    COP [PrintWideString] ( &widestring_07C1DC )
    RTL 
}

widestring_07C0DD `[DEF]How about a sweet apple?[END]`

widestring_07C0F3 `[DEF]I see that you want[N]it. I'll give you one.[FIN]Will got the apple![END]`

widestring_07C12A `[DEF]This is a green apple.[END]`

widestring_07C142 `[DEF]Our fruit is soft[N]and tasty.[END]`

widestring_07C160 `[DEF]Heh heh.[N]You're probably too[N]young for this.[END]`

widestring_07C182 `[DEF]This is the fish shop.[N]We can buy fresh[N]fish from Watermia.[END]`

widestring_07C1B6 `[DEF]This is corn meal,[N]for making bread.[END]`

widestring_07C1DC `[DEF]This is a teapot.[N]We call it a "Tear Potˮ.[FIN]Once we were caught[N]up in a war.[FIN]After the women sent[N]their husbands to war,[N]they saved their tears[N]in these pots.[END]`