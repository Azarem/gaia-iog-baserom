---------------------------------------------

awB6_bones [
  actor-def < #2C, #01, #10, {

  code_089FFF:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08A00D )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08A00D {
    COP [PrintWideString] ( &widestring_08A027 )
    COP [DialogueOptions] ( #02, #02, &code_list_08A017 )
}

code_list_08A017 [
  &code_08A022   ;00
  &code_08A01D   ;01
  &code_08A022   ;02
]

code_08A01D {
    COP [PrintWideString] ( &widestring_08A096 )
    RTL 
}

code_08A022 {
    COP [PrintWideString] ( &widestring_08A094 )
    RTL 
}

widestring_08A027 `[DEF][TPL:0]The bones of a lost [N]explorer fascinated by [N]something...? [FIN]There's some kind of[N]journal hidden there...[N] Read[N] Quit[PAL:0]`

widestring_08A094 `[CLD]`

widestring_08A096 `[CLR]We crossed the jungle[N]to the native village.[N][PAU:1E][FIN]We didn't understand the[N]language, but they[N]beckoned for us to stay.[FIN]When I awoke in the [N]morning, only Captain [N]Friezer and I remained. [FIN]Hunger had destroyed [N]many people during the [N]night. Even our friends. [FIN]We saw the bodies of our[N]comrades and ran into [N]the jungle. That's when [N]we discovered Ankor Wat. [FIN]Rumor says that you can[N]gain immortality here[N]where the spirits live,[FIN]but all I saw were[N]demons... [FIN]I'm going back to my[N]friends... If I don't[N]survive, who [N]would mourn?[END]`