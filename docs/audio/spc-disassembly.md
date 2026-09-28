# IoG SPC700 Sound Engine — Full Disassembly

```
; Illusion of Gaia N-SPC Sound Engine
; ARAM $0400–$0FC9 (3018 bytes)
; Execution entry: $0400
; Disassembled from spc_sound_engine binary in spc_transfer.asm


EngineEntry:
0400:  20          CLRP
0401:  cd cf       MOV X, #$cf
0403:  bd          MOV SP, X
0404:  e8 00       MOV A, #$00
0406:  5d          MOV X, A

loc_0407:
0407:  af          MOV (X)+, A
0408:  c8 f0       CMP X, #$f0
040a:  d0 fb       BNE $0407
040c:  c2 48       SET1 $48.6
040e:  bc          INC
040f:  3f 76 0a    CALL $0a76
0412:  a2 48       SET1 $48.5
0414:  e8 00       MOV A, #$00
0416:  8d 0c       MOV Y, #$0c
0418:  3f 06 06    CALL $0606
041b:  8d 1c       MOV Y, #$1c
041d:  3f 06 06    CALL $0606
0420:  8d 2c       MOV Y, #$2c
0422:  3f 06 06    CALL $0606
0425:  8d 3c       MOV Y, #$3c
0427:  3f 06 06    CALL $0606
042a:  e8 10       MOV A, #$10
042c:  8d 5d       MOV Y, #$5d
042e:  3f 06 06    CALL $0606
0431:  e8 30       MOV A, #$30
0433:  c4 f1       MOV A, $f1
0435:  e8 10       MOV A, #$10
0437:  c4 fa       MOV A, $fa
0439:  e8 10       MOV A, #$10
043b:  c4 fb       MOV A, $fb
043d:  c4 53       MOV A, $53
043f:  e8 03       MOV A, #$03
0441:  c4 f1       MOV A, $f1

loc_0443:
0443:  e4 36       MOV A, $36
0445:  48 ff       EOR A, #$ff
0447:  24 4a       AND A, $4a
0449:  c4 38       MOV A, $38
044b:  8d 0a       MOV Y, #$0a

loc_044d:
044d:  ad 05       CMP Y, #$05
044f:  f0 07       BEQ $0458
0451:  b0 08       BCS $045b
0453:  69 4d 4c    CMP $4c, $4d
0456:  d0 0f       BNE $0467

loc_0458:
0458:  e3 4c 0c    BBS $4c.7, $0467

loc_045b:
045b:  f6 44 0e    MOV A, $0e44+Y
045e:  c4 f2       MOV A, $f2
0460:  f6 4e 0e    MOV A, $0e4e+Y
0463:  5d          MOV X, A
0464:  e6          MOV A, (X)
0465:  c4 f3       MOV A, $f3

loc_0467:
0467:  fe e4       DBNZ Y, $044d
0469:  cb 45       MOV $45, Y
046b:  cb 46       MOV $46, Y

loc_046d:
046d:  eb fd       MOV Y, $fd
046f:  f0 fc       BEQ $046d
0471:  e8 40       MOV A, #$40
0473:  cf          MUL
0474:  60          CLRC
0475:  84 43       ADC A, $43
0477:  c4 43       MOV A, $43
0479:  90 15       BCC $0490
047b:  e5 fd 0f    MOV A, $0ffd
047e:  68 14       CMP A, #$14
0480:  f0 07       BEQ $0489
0482:  e4 31       MOV A, $31
0484:  f0 03       BEQ $0489
0486:  3f 87 0e    CALL $0e87

loc_0489:
0489:  69 4d 4c    CMP $4c, $4d
048c:  f0 02       BEQ $0490
048e:  ab 4c       INC $4c

loc_0490:
0490:  e4 53       MOV A, $53
0492:  60          CLRC
0493:  84 f5       ADC A, $f5

loc_0495:
0495:  eb fe       MOV Y, $fe
0497:  f0 fc       BEQ $0495
0499:  cf          MUL
049a:  60          CLRC
049b:  84 51       ADC A, $51
049d:  c4 51       MOV A, $51
049f:  b0 04       BCS $04a5
04a1:  ad 00       CMP Y, #$00
04a3:  f0 46       BEQ $04eb

loc_04a5:
04a5:  3f 38 07    CALL $0738
04a8:  e4 31       MOV A, $31
04aa:  f0 37       BEQ $04e3
04ac:  eb 61       MOV Y, $61
04ae:  e4 31       MOV A, $31
04b0:  cf          MUL
04b1:  e4 3e       MOV A, $3e
04b3:  cf          MUL
04b4:  cb 6b       MOV $6b, Y
04b6:  eb 63       MOV Y, $63
04b8:  e4 31       MOV A, $31
04ba:  cf          MUL
04bb:  e4 3e       MOV A, $3e
04bd:  cf          MUL
04be:  cb 6c       MOV $6c, Y
04c0:  8d 60       MOV Y, #$60
04c2:  e4 31       MOV A, $31
04c4:  cf          MUL
04c5:  e4 3e       MOV A, $3e
04c7:  cf          MUL
04c8:  dd          MOV A, Y
04c9:  c4 f7       MOV A, $f7
04cb:  8d 0c       MOV Y, #$0c
04cd:  3f 06 06    CALL $0606
04d0:  8d 1c       MOV Y, #$1c
04d2:  3f 06 06    CALL $0606
04d5:  e4 30       MOV A, $30
04d7:  f0 0a       BEQ $04e3
04d9:  8b 31       DEC $31
04db:  d0 06       BNE $04e3
04dd:  8f 00 04    MOV $04, #$00
04e0:  3f 36 06    CALL $0636

loc_04e3:
04e3:  cd 00       MOV X, #$00
04e5:  3f 04 05    CALL $0504
04e8:  5f 43 04    JMP $0443

loc_04eb:
04eb:  e4 04       MOV A, $04
04ed:  f0 12       BEQ $0501
04ef:  cd 00       MOV X, #$00
04f1:  8f 01 47    MOV $47, #$01

loc_04f4:
04f4:  f4 d5       MOV A, $d5+X
04f6:  f0 03       BEQ $04fb
04f8:  3f 63 0d    CALL $0d63

loc_04fb:
04fb:  3d          INC
04fc:  3d          INC
04fd:  0b 47       ASL $47
04ff:  d0 f3       BNE $04f4

loc_0501:
0501:  5f 43 04    JMP $0443

loc_0504:
0504:  f4 04       MOV A, $04+X
0506:  d4 f4       MOV $f4+X, A

loc_0508:
0508:  f4 f4       MOV A, $f4+X
050a:  74 f4       CMP $f4+X, A
050c:  d0 fa       BNE $0508
050e:  d4 00       MOV $00+X, A

loc_0510:
0510:  6f          RET

loc_0511:
0511:  ad ca       CMP Y, #$ca
0513:  90 05       BCC $051a
0515:  3f 9d 08    CALL $089d
0518:  8d a4       MOV Y, #$a4

loc_051a:
051a:  ad c8       CMP Y, #$c8
051c:  b0 f2       BCS $0510
051e:  e4 1a       MOV A, $1a
0520:  24 47       AND A, $47
0522:  d0 ec       BNE $0510
0524:  dd          MOV A, Y
0525:  28 7f       AND A, #$7f
0527:  60          CLRC
0528:  84 50       ADC A, $50
052a:  60          CLRC
052b:  95 f0 02    ADC A, $02f0+X
052e:  d5 7d 03    MOV A, $037d+X
0531:  f5 a5 03    MOV A, $03a5+X
0534:  d5 7c 03    MOV A, $037c+X
0537:  f5 a1 02    MOV A, $02a1+X
053a:  5c          LSR
053b:  e8 00       MOV A, #$00
053d:  7c          ROR
053e:  d5 8c 02    MOV A, $028c+X
0541:  e8 00       MOV A, #$00
0543:  d4 ac       MOV $ac+X, A
0545:  d5 00 01    MOV A, $0100+X
0548:  d5 c8 02    MOV A, $02c8+X
054b:  d4 c0       MOV $c0+X, A
054d:  09 47 5e    OR $5e, $47
0550:  09 47 45    OR $45, $47
0553:  f5 64 02    MOV A, $0264+X
0556:  d4 98       MOV $98+X, A
0558:  f0 1e       BEQ $0578
055a:  f5 65 02    MOV A, $0265+X
055d:  d4 99       MOV $99+X, A
055f:  f5 78 02    MOV A, $0278+X
0562:  d0 0a       BNE $056e
0564:  f5 7d 03    MOV A, $037d+X
0567:  80          SETC
0568:  b5 79 02    SBC A, $0279+X
056b:  d5 7d 03    MOV A, $037d+X

loc_056e:
056e:  f5 79 02    MOV A, $0279+X
0571:  60          CLRC
0572:  95 7d 03    ADC A, $037d+X
0575:  3f 0a 0b    CALL $0b0a

loc_0578:
0578:  3f 22 0b    CALL $0b22

loc_057b:
057b:  8d 00       MOV Y, #$00
057d:  e4 11       MOV A, $11
057f:  80          SETC
0580:  a8 34       SBC A, #$34
0582:  b0 09       BCS $058d
0584:  e4 11       MOV A, $11
0586:  80          SETC
0587:  a8 13       SBC A, #$13
0589:  b0 06       BCS $0591
058b:  dc          DEC
058c:  1c          ASL

loc_058d:
058d:  7a 10       ADDW $10+Y, A
058f:  da 10       MOVW $10, YA

loc_0591:
0591:  4d          PUSH
0592:  e4 11       MOV A, $11
0594:  1c          ASL
0595:  8d 00       MOV Y, #$00
0597:  cd 18       MOV X, #$18
0599:  9e          DIV YA
059a:  5d          MOV X, A
059b:  f6 5a 0e    MOV A, $0e5a+Y
059e:  c4 15       MOV A, $15
05a0:  f6 59 0e    MOV A, $0e59+Y
05a3:  c4 14       MOV A, $14
05a5:  f6 5c 0e    MOV A, $0e5c+Y
05a8:  2d          PUSH
05a9:  f6 5b 0e    MOV A, $0e5b+Y
05ac:  ee          POP
05ad:  9a 14       SUBW $14+Y, A
05af:  eb 10       MOV Y, $10
05b1:  cf          MUL
05b2:  dd          MOV A, Y
05b3:  8d 00       MOV Y, #$00
05b5:  7a 14       ADDW $14+Y, A
05b7:  cb 15       MOV $15, Y
05b9:  1c          ASL
05ba:  2b 15       ROL $15
05bc:  c4 14       MOV A, $14
05be:  2f 04       BRA $05c4

loc_05c0:
05c0:  4b 15       LSR $15
05c2:  7c          ROR
05c3:  3d          INC

loc_05c4:
05c4:  c8 06       CMP X, #$06
05c6:  d0 f8       BNE $05c0
05c8:  c4 14       MOV A, $14
05ca:  ce          POP
05cb:  f5 28 02    MOV A, $0228+X
05ce:  eb 15       MOV Y, $15
05d0:  cf          MUL
05d1:  da 16       MOVW $16, YA
05d3:  f5 28 02    MOV A, $0228+X
05d6:  eb 14       MOV Y, $14
05d8:  cf          MUL
05d9:  6d          PUSH
05da:  f5 29 02    MOV A, $0229+X
05dd:  eb 14       MOV Y, $14
05df:  cf          MUL
05e0:  7a 16       ADDW $16+Y, A
05e2:  da 16       MOVW $16, YA
05e4:  f5 29 02    MOV A, $0229+X
05e7:  eb 15       MOV Y, $15
05e9:  cf          MUL
05ea:  fd          MOV
05eb:  ae          POP
05ec:  7a 16       ADDW $16+Y, A
05ee:  da 16       MOVW $16, YA
05f0:  f5 73 0e    MOV A, $0e73+X
05f3:  08 02       OR A, #$02
05f5:  fd          MOV
05f6:  e4 16       MOV A, $16
05f8:  3f fe 05    CALL $05fe
05fb:  fc          INC
05fc:  e4 17       MOV A, $17

loc_05fe:
05fe:  2d          PUSH
05ff:  e4 47       MOV A, $47
0601:  24 1a       AND A, $1a
0603:  ae          POP
0604:  d0 04       BNE $060a

loc_0606:
0606:  cb f2       MOV $f2, Y
0608:  c4 f3       MOV A, $f3

loc_060a:
060a:  6f          RET

loc_060b:
060b:  8d 00       MOV Y, #$00
060d:  f7 40       MOV A, [$40]+Y
060f:  3a 40       INCW $40
0611:  2d          PUSH
0612:  f7 40       MOV A, [$40]+Y
0614:  3a 40       INCW $40
0616:  fd          MOV
0617:  ae          POP
0618:  6f          RET

loc_0619:
0619:  8f ff 30    MOV $30, #$ff
061c:  8f ff 31    MOV $31, #$ff
061f:  c4 04       MOV A, $04
0621:  6f          RET

loc_0622:
0622:  2d          PUSH
0623:  e5 fe 0f    MOV A, $0ffe
0626:  ec ff 0f    MOV Y, $0fff
0629:  da 3b       MOVW $3b, YA
062b:  e8 00       MOV A, #$00
062d:  5d          MOV X, A

loc_062e:
062e:  c7 3b       MOV A, [$3b+X]
0630:  3a 3b       INCW $3b
0632:  d0 fa       BNE $062e
0634:  ae          POP
0635:  6f          RET

loc_0636:
0636:  e4 d5       MOV A, $d5
0638:  f0 44       BEQ $067e
063a:  e8 00       MOV A, #$00
063c:  c4 6b       MOV A, $6b
063e:  c4 6c       MOV A, $6c
0640:  8f ff 5c    MOV $5c, #$ff
0643:  8f ff 0e    MOV $0e, #$ff
0646:  8f 00 04    MOV $04, #$00
0649:  e8 00       MOV A, #$00
064b:  8d 0c       MOV Y, #$0c
064d:  3f 06 06    CALL $0606
0650:  8d 1c       MOV Y, #$1c
0652:  3f 06 06    CALL $0606
0655:  8d 2c       MOV Y, #$2c
0657:  3f 06 06    CALL $0606
065a:  8d 3c       MOV Y, #$3c
065c:  3f 06 06    CALL $0606
065f:  a2 48       SET1 $48.5
0661:  e8 00       MOV A, #$00
0663:  c4 d5       MOV A, $d5
0665:  c4 d7       MOV A, $d7
0667:  c4 d9       MOV A, $d9
0669:  c4 db       MOV A, $db
066b:  c4 dd       MOV A, $dd
066d:  c4 df       MOV A, $df
066f:  c4 e1       MOV A, $e1
0671:  c4 e3       MOV A, $e3
0673:  c4 e5       MOV A, $e5
0675:  c4 e7       MOV A, $e7
0677:  c4 31       MOV A, $31
0679:  e8 01       MOV A, #$01
067b:  3f 76 0a    CALL $0a76

loc_067e:
067e:  6f          RET

loc_067f:
067f:  8f ff 0e    MOV $0e, #$ff
0682:  6f          RET

loc_0683:
0683:  3f 89 0f    CALL $0f89
0686:  c4 08       MOV A, $08
0688:  c4 04       MOV A, $04
068a:  6f          RET

loc_068b:
068b:  68 f0       CMP A, #$f0
068d:  f0 a7       BEQ $0636
068f:  68 f1       CMP A, #$f1
0691:  f0 86       BEQ $0619
0693:  68 f2       CMP A, #$f2
0695:  f0 e8       BEQ $067f
0697:  68 ff       CMP A, #$ff
0699:  f0 e8       BEQ $0683
069b:  6f          RET

loc_069c:
069c:  e4 04       MOV A, $04
069e:  68 90       CMP A, #$90
06a0:  f0 18       BEQ $06ba
06a2:  68 91       CMP A, #$91
06a4:  f0 18       BEQ $06be
06a6:  e4 04       MOV A, $04
06a8:  30 0f       BMI $06b9
06aa:  80          SETC
06ab:  a8 40       SBC A, #$40
06ad:  90 0a       BCC $06b9
06af:  1c          ASL
06b0:  1c          ASL
06b1:  48 ff       EOR A, #$ff
06b3:  fd          MOV
06b4:  e8 e0       MOV A, #$e0
06b6:  cf          MUL
06b7:  cb 3e       MOV $3e, Y

loc_06b9:
06b9:  6f          RET

loc_06ba:
06ba:  8f 01 32    MOV $32, #$01
06bd:  6f          RET

loc_06be:
06be:  8f 00 32    MOV $32, #$00
06c1:  6f          RET

loc_06c2:
06c2:  c4 04       MOV A, $04
06c4:  1c          ASL
06c5:  f0 33       BEQ $06fa
06c7:  68 02       CMP A, #$02
06c9:  d0 d1       BNE $069c
06cb:  3f 22 06    CALL $0622
06ce:  e5 fc 0f    MOV A, $0ffc
06d1:  ec fd 0f    MOV Y, $0ffd
06d4:  da 40       MOVW $40, YA
06d6:  3a 40       INCW $40
06d8:  3a 40       INCW $40
06da:  8f 02 0c    MOV $0c, #$02
06dd:  e8 00       MOV A, #$00
06df:  c4 30       MOV A, $30
06e1:  8f 00 31    MOV $31, #$00
06e4:  c4 5f       MOV A, $5f
06e6:  c4 39       MOV A, $39
06e8:  c4 36       MOV A, $36
06ea:  c4 e5       MOV A, $e5
06ec:  c4 e7       MOV A, $e7
06ee:  c4 3d       MOV A, $3d
06f0:  c4 f5       MOV A, $f5
06f2:  8f e0 3e    MOV $3e, #$e0
06f5:  8f 00 0e    MOV $0e, #$00
06f8:  d2 48       CLR1 $48.6

loc_06fa:
06fa:  e4 1a       MOV A, $1a
06fc:  48 ff       EOR A, #$ff
06fe:  0e 46 00    TSET1 $0046
0701:  6f          RET

loc_0702:
0702:  cd 0e       MOV X, #$0e
0704:  8f 80 47    MOV $47, #$80

loc_0707:
0707:  e8 00       MOV A, #$00
0709:  d5 05 03    MOV A, $0305+X
070c:  e8 0a       MOV A, #$0a
070e:  3f 09 09    CALL $0909
0711:  d5 15 02    MOV A, $0215+X
0714:  d5 a5 03    MOV A, $03a5+X
0717:  d5 f0 02    MOV A, $02f0+X
071a:  d5 64 02    MOV A, $0264+X
071d:  d4 ad       MOV $ad+X, A
071f:  d4 c1       MOV $c1+X, A
0721:  1d          DEC
0722:  1d          DEC
0723:  4b 47       LSR $47
0725:  d0 e0       BNE $0707
0727:  c4 5a       MOV A, $5a
0729:  c4 68       MOV A, $68
072b:  c4 54       MOV A, $54
072d:  c4 50       MOV A, $50
072f:  c4 42       MOV A, $42
0731:  8f 00 59    MOV $59, #$00
0734:  8f 20 53    MOV $53, #$20

loc_0737:
0737:  6f          RET

loc_0738:
0738:  eb 08       MOV Y, $08
073a:  e4 00       MOV A, $00
073c:  68 f0       CMP A, #$f0
073e:  90 03       BCC $0743
0740:  5f 8b 06    JMP $068b

loc_0743:
0743:  c4 08       MOV A, $08
0745:  7e 00       CMP $00, Y
0747:  f0 03       BEQ $074c
0749:  5f c2 06    JMP $06c2

loc_074c:
074c:  e4 04       MOV A, $04
074e:  f0 e7       BEQ $0737
0750:  8f 00 0e    MOV $0e, #$00
0753:  e4 0c       MOV A, $0c
0755:  f0 5e       BEQ $07b5
0757:  6e 0c a8    DBNZ $0c, $0702

loc_075a:
075a:  fa 3d f5    MOV $f5, $3d
075d:  3f 0b 06    CALL $060b
0760:  d0 20       BNE $0782
0762:  fd          MOV
0763:  d0 09       BNE $076e
0765:  8f ff 3d    MOV $3d, #$ff
0768:  8f ff f5    MOV $f5, #$ff
076b:  5f c2 06    JMP $06c2

loc_076e:
076e:  8b 42       DEC $42
0770:  10 05       BPL $0777
0772:  c4 42       MOV A, $42
0774:  8f 00 3d    MOV $3d, #$00

loc_0777:
0777:  3f 0b 06    CALL $060b
077a:  f8 42       MOV X, $42
077c:  f0 dc       BEQ $075a
077e:  da 40       MOVW $40, YA
0780:  2f d8       BRA $075a

loc_0782:
0782:  ab 3d       INC $3d
0784:  da 16       MOVW $16, YA
0786:  8d 0f       MOV Y, #$0f

loc_0788:
0788:  f7 16       MOV A, [$16]+Y
078a:  d6 d4 00    MOV A, $00d4+Y
078d:  dc          DEC
078e:  10 f8       BPL $0788
0790:  cd 00       MOV X, #$00
0792:  8f 01 47    MOV $47, #$01

loc_0795:
0795:  f4 d5       MOV A, $d5+X
0797:  f0 0a       BEQ $07a3
0799:  f5 15 02    MOV A, $0215+X
079c:  d0 05       BNE $07a3
079e:  e8 00       MOV A, #$00
07a0:  3f 9d 08    CALL $089d

loc_07a3:
07a3:  e8 00       MOV A, #$00
07a5:  d5 b8 03    MOV A, $03b8+X
07a8:  d4 84       MOV $84+X, A
07aa:  d4 85       MOV $85+X, A
07ac:  bc          INC
07ad:  d4 70       MOV $70+X, A
07af:  3d          INC
07b0:  3d          INC
07b1:  0b 47       ASL $47
07b3:  d0 e0       BNE $0795

loc_07b5:
07b5:  cd 00       MOV X, #$00
07b7:  d8 5e       MOV $5e, X
07b9:  8f 01 47    MOV $47, #$01

loc_07bc:
07bc:  d8 44       MOV $44, X
07be:  f4 d5       MOV A, $d5+X
07c0:  f0 6c       BEQ $082e
07c2:  9b 70       DEC $70+X
07c4:  d0 62       BNE $0828

loc_07c6:
07c6:  3f 93 08    CALL $0893
07c9:  d0 1d       BNE $07e8
07cb:  f5 b8 03    MOV A, $03b8+X
07ce:  f0 8a       BEQ $075a
07d0:  3f 0e 0a    CALL $0a0e
07d3:  f5 b8 03    MOV A, $03b8+X
07d6:  9c          DEC
07d7:  d5 b8 03    MOV A, $03b8+X
07da:  d0 ea       BNE $07c6
07dc:  f5 3c 02    MOV A, $023c+X
07df:  d4 d4       MOV $d4+X, A
07e1:  f5 3d 02    MOV A, $023d+X
07e4:  d4 d5       MOV $d5+X, A
07e6:  2f de       BRA $07c6

loc_07e8:
07e8:  30 20       BMI $080a
07ea:  d5 00 02    MOV A, $0200+X
07ed:  3f 93 08    CALL $0893
07f0:  30 18       BMI $080a
07f2:  2d          PUSH
07f3:  9f          XCN
07f4:  28 07       AND A, #$07
07f6:  fd          MOV
07f7:  f6 00 13    MOV A, $1300+Y
07fa:  d5 01 02    MOV A, $0201+X
07fd:  ae          POP
07fe:  28 0f       AND A, #$0f
0800:  fd          MOV
0801:  f6 08 13    MOV A, $1308+Y
0804:  d5 14 02    MOV A, $0214+X
0807:  3f 93 08    CALL $0893

loc_080a:
080a:  68 e0       CMP A, #$e0
080c:  90 05       BCC $0813
080e:  3f 81 08    CALL $0881
0811:  2f b3       BRA $07c6

loc_0813:
0813:  3f 11 05    CALL $0511
0816:  f5 00 02    MOV A, $0200+X
0819:  d4 70       MOV $70+X, A
081b:  fd          MOV
081c:  f5 01 02    MOV A, $0201+X
081f:  cf          MUL
0820:  dd          MOV A, Y
0821:  d0 01       BNE $0824
0823:  bc          INC

loc_0824:
0824:  d4 71       MOV $71+X, A
0826:  2f 03       BRA $082b

loc_0828:
0828:  3f 72 0c    CALL $0c72

loc_082b:
082b:  3f ea 0a    CALL $0aea

loc_082e:
082e:  3d          INC
082f:  3d          INC
0830:  0b 47       ASL $47
0832:  d0 88       BNE $07bc
0834:  e4 54       MOV A, $54
0836:  f0 0b       BEQ $0843
0838:  ba 56       MOVW YA, $56
083a:  7a 52       ADDW $52+Y, A
083c:  6e 54 02    DBNZ $54, $0841
083f:  ba 54       MOVW YA, $54

loc_0841:
0841:  da 52       MOVW $52, YA

loc_0843:
0843:  e4 68       MOV A, $68
0845:  f0 15       BEQ $085c
0847:  ba 64       MOVW YA, $64
0849:  7a 60       ADDW $60+Y, A
084b:  da 60       MOVW $60, YA
084d:  ba 66       MOVW YA, $66
084f:  7a 62       ADDW $62+Y, A
0851:  6e 68 06    DBNZ $68, $085a
0854:  ba 68       MOVW YA, $68
0856:  da 60       MOVW $60, YA
0858:  eb 6a       MOV Y, $6a

loc_085a:
085a:  da 62       MOVW $62, YA

loc_085c:
085c:  e4 5a       MOV A, $5a
085e:  f0 0e       BEQ $086e
0860:  ba 5c       MOVW YA, $5c
0862:  7a 58       ADDW $58+Y, A
0864:  6e 5a 02    DBNZ $5a, $0869
0867:  ba 5a       MOVW YA, $5a

loc_0869:
0869:  da 58       MOVW $58, YA
086b:  8f ff 5e    MOV $5e, #$ff

loc_086e:
086e:  cd 00       MOV X, #$00
0870:  8f 01 47    MOV $47, #$01

loc_0873:
0873:  f4 d5       MOV A, $d5+X
0875:  f0 03       BEQ $087a
0877:  3f a9 0b    CALL $0ba9

loc_087a:
087a:  3d          INC
087b:  3d          INC
087c:  0b 47       ASL $47
087e:  d0 f3       BNE $0873
0880:  6f          RET

loc_0881:
0881:  1c          ASL
0882:  fd          MOV
0883:  f6 8a 0a    MOV A, $0a8a+Y
0886:  2d          PUSH
0887:  f6 89 0a    MOV A, $0a89+Y
088a:  2d          PUSH
088b:  dd          MOV A, Y
088c:  5c          LSR
088d:  fd          MOV
088e:  f6 29 0b    MOV A, $0b29+Y
0891:  f0 08       BEQ $089b

loc_0893:
0893:  e7 d4       MOV A, [$d4+X]

loc_0895:
0895:  bb d4       INC $d4+X
0897:  d0 02       BNE $089b
0899:  bb d5       INC $d5+X

loc_089b:
089b:  fd          MOV
089c:  6f          RET

loc_089d:
089d:  d5 15 02    MOV A, $0215+X
08a0:  eb 34       MOV Y, $34
08a2:  d0 11       BNE $08b5
08a4:  fd          MOV
08a5:  10 06       BPL $08ad
08a7:  80          SETC
08a8:  a8 ca       SBC A, #$ca
08aa:  60          CLRC
08ab:  84 5f       ADC A, $5f

loc_08ad:
08ad:  4d          PUSH
08ae:  5d          MOV X, A
08af:  f5 e0 0f    MOV A, $0fe0+X
08b2:  ce          POP
08b3:  2f 09       BRA $08be

loc_08b5:
08b5:  fd          MOV
08b6:  10 06       BPL $08be
08b8:  80          SETC
08b9:  a8 ca       SBC A, #$ca
08bb:  60          CLRC
08bc:  84 39       ADC A, $39

loc_08be:
08be:  8d 06       MOV Y, #$06
08c0:  cf          MUL
08c1:  da 14       MOVW $14, YA
08c3:  60          CLRC
08c4:  98 00 14    ADC $14, #$00
08c7:  98 12 15    ADC $15, #$12
08ca:  e4 1a       MOV A, $1a
08cc:  24 47       AND A, $47
08ce:  d0 38       BNE $0908
08d0:  4d          PUSH
08d1:  f5 73 0e    MOV A, $0e73+X
08d4:  08 04       OR A, #$04
08d6:  5d          MOV X, A
08d7:  8d 00       MOV Y, #$00
08d9:  f7 14       MOV A, [$14]+Y
08db:  10 0e       BPL $08eb
08dd:  28 1f       AND A, #$1f
08df:  38 20 48    AND $48, #$20
08e2:  0e 48 00    TSET1 $0048
08e5:  09 47 49    OR $49, $47
08e8:  dd          MOV A, Y
08e9:  2f 07       BRA $08f2

loc_08eb:
08eb:  e4 47       MOV A, $47
08ed:  4e 49 00    TCLR1 $0049

loc_08f0:
08f0:  f7 14       MOV A, [$14]+Y

loc_08f2:
08f2:  d8 f2       MOV $f2, X
08f4:  c4 f3       MOV A, $f3
08f6:  3d          INC
08f7:  fc          INC
08f8:  ad 04       CMP Y, #$04
08fa:  d0 f4       BNE $08f0
08fc:  ce          POP
08fd:  f7 14       MOV A, [$14]+Y
08ff:  d5 29 02    MOV A, $0229+X
0902:  fc          INC
0903:  f7 14       MOV A, [$14]+Y
0905:  d5 28 02    MOV A, $0228+X

loc_0908:
0908:  6f          RET

loc_0909:
0909:  d5 69 03    MOV A, $0369+X
090c:  28 1f       AND A, #$1f
090e:  d5 41 03    MOV A, $0341+X
0911:  e8 00       MOV A, #$00
0913:  d5 40 03    MOV A, $0340+X
0916:  6f          RET
0917:  d4 85       MOV $85+X, A
0919:  2d          PUSH
091a:  3f 93 08    CALL $0893
091d:  d5 68 03    MOV A, $0368+X
0920:  80          SETC
0921:  b5 41 03    SBC A, $0341+X
0924:  ce          POP
0925:  3f 2d 0b    CALL $0b2d
0928:  d5 54 03    MOV A, $0354+X
092b:  dd          MOV A, Y
092c:  d5 55 03    MOV A, $0355+X
092f:  6f          RET
0930:  d5 a0 02    MOV A, $02a0+X
0933:  3f 93 08    CALL $0893
0936:  d5 8d 02    MOV A, $028d+X
0939:  3f 93 08    CALL $0893
093c:  d4 ad       MOV $ad+X, A
093e:  d5 b5 02    MOV A, $02b5+X
0941:  e8 00       MOV A, #$00
0943:  d5 a1 02    MOV A, $02a1+X
0946:  6f          RET
0947:  d5 a1 02    MOV A, $02a1+X
094a:  2d          PUSH
094b:  8d 00       MOV Y, #$00
094d:  f4 ad       MOV A, $ad+X
094f:  ce          POP
0950:  9e          DIV YA
0951:  f8 44       MOV X, $44
0953:  d5 b4 02    MOV A, $02b4+X
0956:  6f          RET
0957:  dd          MOV A, Y
0958:  80          SETC
0959:  a8 1e       SBC A, #$1e
095b:  fd          MOV
095c:  e8 00       MOV A, #$00
095e:  da 58       MOVW $58, YA
0960:  e4 31       MOV A, $31
0962:  d0 03       BNE $0967
0964:  8f ff 31    MOV $31, #$ff
0967:  6f          RET
0968:  c4 5a       MOV A, $5a
096a:  3f 93 08    CALL $0893
096d:  c4 5b       MOV A, $5b
096f:  80          SETC
0970:  a4 59       SBC A, $59
0972:  f8 5a       MOV X, $5a
0974:  3f 2d 0b    CALL $0b2d
0977:  da 5c       MOVW $5c, YA
0979:  6f          RET
097a:  e4 34       MOV A, $34
097c:  d0 04       BNE $0982
097e:  e8 00       MOV A, #$00
0980:  da 52       MOVW $52, YA
0982:  6f          RET
0983:  c4 54       MOV A, $54
0985:  3f 93 08    CALL $0893
0988:  c4 55       MOV A, $55
098a:  80          SETC
098b:  a4 53       SBC A, $53
098d:  f8 54       MOV X, $54
098f:  3f 2d 0b    CALL $0b2d
0992:  da 56       MOVW $56, YA
0994:  6f          RET
0995:  c4 50       MOV A, $50
0997:  6f          RET
0998:  d5 f0 02    MOV A, $02f0+X
099b:  6f          RET
099c:  d5 dc 02    MOV A, $02dc+X
099f:  3f 93 08    CALL $0893
09a2:  d5 c9 02    MOV A, $02c9+X
09a5:  3f 93 08    CALL $0893
09a8:  d4 c1       MOV $c1+X, A
09aa:  6f          RET
09ab:  e8 01       MOV A, #$01
09ad:  2f 02       BRA $09b1
09af:  e8 00       MOV A, #$00
09b1:  d5 78 02    MOV A, $0278+X
09b4:  dd          MOV A, Y
09b5:  d5 65 02    MOV A, $0265+X
09b8:  3f 93 08    CALL $0893
09bb:  d5 64 02    MOV A, $0264+X
09be:  3f 93 08    CALL $0893
09c1:  d5 79 02    MOV A, $0279+X
09c4:  6f          RET
09c5:  d5 64 02    MOV A, $0264+X
09c8:  6f          RET
09c9:  eb 34       MOV Y, $34
09cb:  f0 02       BEQ $09cf
09cd:  e8 b4       MOV A, #$b4
09cf:  d5 05 03    MOV A, $0305+X
09d2:  e8 00       MOV A, #$00
09d4:  d5 04 03    MOV A, $0304+X
09d7:  6f          RET
09d8:  d4 84       MOV $84+X, A
09da:  2d          PUSH
09db:  3f 93 08    CALL $0893
09de:  d5 2c 03    MOV A, $032c+X
09e1:  80          SETC
09e2:  b5 05 03    SBC A, $0305+X
09e5:  ce          POP
09e6:  3f 2d 0b    CALL $0b2d
09e9:  d5 18 03    MOV A, $0318+X
09ec:  dd          MOV A, Y
09ed:  d5 19 03    MOV A, $0319+X
09f0:  6f          RET
09f1:  d5 a5 03    MOV A, $03a5+X
09f4:  6f          RET
09f5:  d5 50 02    MOV A, $0250+X
09f8:  3f 93 08    CALL $0893
09fb:  d5 51 02    MOV A, $0251+X
09fe:  3f 93 08    CALL $0893
0a01:  d5 b8 03    MOV A, $03b8+X
0a04:  f4 d4       MOV A, $d4+X
0a06:  d5 3c 02    MOV A, $023c+X
0a09:  f4 d5       MOV A, $d5+X
0a0b:  d5 3d 02    MOV A, $023d+X

loc_0a0e:
0a0e:  f5 50 02    MOV A, $0250+X
0a11:  d4 d4       MOV $d4+X, A
0a13:  f5 51 02    MOV A, $0251+X
0a16:  d4 d5       MOV $d5+X, A
0a18:  6f          RET
0a19:  c4 4a       MOV A, $4a
0a1b:  3f 93 08    CALL $0893
0a1e:  e8 00       MOV A, #$00
0a20:  da 60       MOVW $60, YA
0a22:  3f 93 08    CALL $0893
0a25:  e8 00       MOV A, #$00
0a27:  da 62       MOVW $62, YA
0a29:  b2 48       CLR1 $48.5
0a2b:  6f          RET
0a2c:  c4 68       MOV A, $68
0a2e:  3f 93 08    CALL $0893
0a31:  c4 69       MOV A, $69
0a33:  80          SETC
0a34:  a4 61       SBC A, $61
0a36:  f8 68       MOV X, $68
0a38:  3f 2d 0b    CALL $0b2d
0a3b:  da 64       MOVW $64, YA
0a3d:  3f 93 08    CALL $0893
0a40:  c4 6a       MOV A, $6a
0a42:  80          SETC
0a43:  a4 63       SBC A, $63
0a45:  f8 68       MOV X, $68
0a47:  3f 2d 0b    CALL $0b2d
0a4a:  da 66       MOVW $66, YA
0a4c:  6f          RET
0a4d:  da 60       MOVW $60, YA
0a4f:  da 62       MOVW $62, YA
0a51:  a2 48       SET1 $48.5
0a53:  6f          RET
0a54:  3f 76 0a    CALL $0a76
0a57:  3f 93 08    CALL $0893
0a5a:  c4 4e       MOV A, $4e
0a5c:  3f 93 08    CALL $0893
0a5f:  8d 08       MOV Y, #$08
0a61:  cf          MUL
0a62:  5d          MOV X, A
0a63:  8d 0f       MOV Y, #$0f
0a65:  f5 25 0e    MOV A, $0e25+X
0a68:  3f 06 06    CALL $0606
0a6b:  3d          INC
0a6c:  dd          MOV A, Y
0a6d:  60          CLRC
0a6e:  88 10       ADC A, #$10
0a70:  fd          MOV
0a71:  10 f2       BPL $0a65
0a73:  f8 44       MOV X, $44
0a75:  6f          RET

loc_0a76:
0a76:  c4 4d       MOV A, $4d
0a78:  8d 7d       MOV Y, #$7d
0a7a:  cb f2       MOV $f2, Y
0a7c:  e4 f3       MOV A, $f3
0a7e:  64 4d       CMP A, $4d
0a80:  f0 29       BEQ $0aab
0a82:  28 0f       AND A, #$0f
0a84:  48 ff       EOR A, #$ff
0a86:  f3 4c 03    BBC $4c.7, $0a8c
0a89:  60          CLRC
0a8a:  84 4c       ADC A, $4c

loc_0a8c:
0a8c:  c4 4c       MOV A, $4c
0a8e:  8d 04       MOV Y, #$04

loc_0a90:
0a90:  f6 44 0e    MOV A, $0e44+Y
0a93:  c4 f2       MOV A, $f2
0a95:  e8 00       MOV A, #$00
0a97:  c4 f3       MOV A, $f3
0a99:  fe f5       DBNZ Y, $0a90
0a9b:  e4 48       MOV A, $48
0a9d:  08 20       OR A, #$20
0a9f:  8d 6c       MOV Y, #$6c
0aa1:  3f 06 06    CALL $0606
0aa4:  e4 4d       MOV A, $4d
0aa6:  8d 7d       MOV Y, #$7d
0aa8:  3f 06 06    CALL $0606

loc_0aab:
0aab:  1c          ASL
0aac:  1c          ASL
0aad:  1c          ASL
0aae:  48 ff       EOR A, #$ff
0ab0:  80          SETC
0ab1:  88 ff       ADC A, #$ff
0ab3:  8d 6d       MOV Y, #$6d
0ab5:  5f 06 06    JMP $0606
0ab8:  2d          PUSH
0ab9:  7d          MOV A, X
0aba:  68 10       CMP A, #$10
0abc:  90 03       BCC $0ac1
0abe:  80          SETC
0abf:  a8 04       SBC A, #$04
0ac1:  9f          XCN
0ac2:  5c          LSR
0ac3:  60          CLRC
0ac4:  88 05       ADC A, #$05
0ac6:  fd          MOV
0ac7:  ae          POP
0ac8:  08 80       OR A, #$80
0aca:  3f fe 05    CALL $05fe
0acd:  fc          INC
0ace:  6d          PUSH
0acf:  3f 93 08    CALL $0893
0ad2:  c4 3f       MOV A, $3f
0ad4:  3f 93 08    CALL $0893
0ad7:  9f          XCN
0ad8:  1c          ASL
0ad9:  04 3f       OR A, $3f
0adb:  ee          POP
0adc:  3f fe 05    CALL $05fe
0adf:  6f          RET
0ae0:  eb 34       MOV Y, $34
0ae2:  d0 03       BNE $0ae7
0ae4:  c4 5f       MOV A, $5f
0ae6:  6f          RET
0ae7:  c4 39       MOV A, $39
0ae9:  6f          RET

loc_0aea:
0aea:  f4 98       MOV A, $98+X
0aec:  d0 33       BNE $0b21
0aee:  e7 d4       MOV A, [$d4+X]
0af0:  68 f9       CMP A, #$f9
0af2:  d0 2d       BNE $0b21
0af4:  3f 95 08    CALL $0895
0af7:  3f 93 08    CALL $0893
0afa:  d4 99       MOV $99+X, A
0afc:  3f 93 08    CALL $0893
0aff:  d4 98       MOV $98+X, A
0b01:  3f 93 08    CALL $0893
0b04:  60          CLRC
0b05:  84 50       ADC A, $50
0b07:  95 f0 02    ADC A, $02f0+X

loc_0b0a:
0b0a:  28 7f       AND A, #$7f
0b0c:  d5 a4 03    MOV A, $03a4+X
0b0f:  80          SETC
0b10:  b5 7d 03    SBC A, $037d+X
0b13:  fb 98       MOV Y, $98+X
0b15:  6d          PUSH
0b16:  ce          POP
0b17:  3f 2d 0b    CALL $0b2d
0b1a:  d5 90 03    MOV A, $0390+X
0b1d:  dd          MOV A, Y
0b1e:  d5 91 03    MOV A, $0391+X

loc_0b21:
0b21:  6f          RET

loc_0b22:
0b22:  f5 7d 03    MOV A, $037d+X
0b25:  c4 11       MOV A, $11
0b27:  f5 7c 03    MOV A, $037c+X
0b2a:  c4 10       MOV A, $10
0b2c:  6f          RET

loc_0b2d:
0b2d:  ed          NOTC
0b2e:  6b 12       ROR $12
0b30:  10 03       BPL $0b35
0b32:  48 ff       EOR A, #$ff
0b34:  bc          INC

loc_0b35:
0b35:  8d 00       MOV Y, #$00
0b37:  9e          DIV YA
0b38:  2d          PUSH
0b39:  e8 00       MOV A, #$00
0b3b:  9e          DIV YA
0b3c:  ee          POP
0b3d:  f8 44       MOV X, $44

loc_0b3f:
0b3f:  f3 12 06    BBC $12.7, $0b48
0b42:  da 14       MOVW $14, YA
0b44:  ba 1c       MOVW YA, $1c
0b46:  9a 14       SUBW $14+Y, A

loc_0b48:
0b48:  6f          RET

; ═══════════════════════════════════════════════════════════
; HandlerAddrTable: N-SPC opcode handler addresses (32 x u16 = 64 bytes, for opcodes $E0-$FF)
; ═══════════════════════════════════════════════════════════
0b49:  .db 9d 08 09 09 17 09 30 09 3c 09 57 09 68 09 7a 09
0b59:  .db 83 09 95 09 98 09 9c 09 a8 09 c9 09 d8 09 f5 09
0b69:  .db 47 09 ab 09 af 09 c5 09 f1 09 19 0a 4d 0a 54 0a
0b79:  .db 2c 0a fa 0a e0 0a 00 00 00 00 00 00 00 00 b8 0a

; ═══════════════════════════════════════════════════════════
; ParamCountTable: N-SPC opcode param counts (32 bytes, for opcodes $E0-$FF)
; ═══════════════════════════════════════════════════════════
0b89:  .db 01 01 02 03 00 01 02 01 02 01 01 03 00 01 02 03
0b99:  .db 01 03 03 00 01 03 00 03 03 03 01 00 00 00 00 01

loc_0ba9:
0ba9:  f4 84       MOV A, $84+X
0bab:  f0 09       BEQ $0bb6
0bad:  e8 04       MOV A, #$04
0baf:  8d 03       MOV Y, #$03
0bb1:  9b 84       DEC $84+X
0bb3:  3f 49 0c    CALL $0c49

loc_0bb6:
0bb6:  fb c1       MOV Y, $c1+X
0bb8:  f0 23       BEQ $0bdd
0bba:  f5 dc 02    MOV A, $02dc+X
0bbd:  de c0 1b    CBNE $c0+X, $0bdb
0bc0:  09 47 5e    OR $5e, $47
0bc3:  f5 c8 02    MOV A, $02c8+X
0bc6:  10 07       BPL $0bcf
0bc8:  fc          INC
0bc9:  d0 04       BNE $0bcf
0bcb:  e8 80       MOV A, #$80
0bcd:  2f 04       BRA $0bd3

loc_0bcf:
0bcf:  60          CLRC
0bd0:  95 c9 02    ADC A, $02c9+X

loc_0bd3:
0bd3:  d5 c8 02    MOV A, $02c8+X
0bd6:  3f ef 0d    CALL $0def
0bd9:  2f 07       BRA $0be2

loc_0bdb:
0bdb:  bb c0       INC $c0+X

loc_0bdd:
0bdd:  e8 ff       MOV A, #$ff
0bdf:  3f fa 0d    CALL $0dfa

loc_0be2:
0be2:  f4 85       MOV A, $85+X
0be4:  f0 09       BEQ $0bef
0be6:  e8 40       MOV A, #$40
0be8:  8d 03       MOV Y, #$03
0bea:  9b 85       DEC $85+X
0bec:  3f 49 0c    CALL $0c49

loc_0bef:
0bef:  e4 47       MOV A, $47
0bf1:  24 5e       AND A, $5e
0bf3:  f0 53       BEQ $0c48
0bf5:  f5 41 03    MOV A, $0341+X
0bf8:  fd          MOV
0bf9:  f5 40 03    MOV A, $0340+X
0bfc:  da 10       MOVW $10, YA

loc_0bfe:
0bfe:  f5 73 0e    MOV A, $0e73+X
0c01:  c4 12       MOV A, $12
0c03:  e4 32       MOV A, $32
0c05:  f0 09       BEQ $0c10
0c07:  8f 0a 11    MOV $11, #$0a
0c0a:  8f 00 10    MOV $10, #$00
0c0d:  8f 0a 11    MOV $11, #$0a

loc_0c10:
0c10:  eb 11       MOV Y, $11
0c12:  f6 11 0e    MOV A, $0e11+Y
0c15:  80          SETC
0c16:  b6 10 0e    SBC A, $0e10+Y
0c19:  eb 10       MOV Y, $10
0c1b:  cf          MUL
0c1c:  dd          MOV A, Y
0c1d:  eb 11       MOV Y, $11
0c1f:  60          CLRC
0c20:  96 10 0e    ADC A, $0e10+Y
0c23:  fd          MOV
0c24:  f5 2d 03    MOV A, $032d+X
0c27:  cf          MUL
0c28:  f5 69 03    MOV A, $0369+X
0c2b:  1c          ASL
0c2c:  13 12 01    BBC $12.0, $0c30
0c2f:  1c          ASL

loc_0c30:
0c30:  dd          MOV A, Y
0c31:  90 03       BCC $0c36
0c33:  48 ff       EOR A, #$ff
0c35:  bc          INC

loc_0c36:
0c36:  eb 12       MOV Y, $12
0c38:  3f fe 05    CALL $05fe
0c3b:  8d 14       MOV Y, #$14
0c3d:  e8 00       MOV A, #$00
0c3f:  9a 10       SUBW $10+Y, A
0c41:  da 10       MOVW $10, YA
0c43:  ab 12       INC $12
0c45:  33 12 c8    BBC $12.1, $0c10

loc_0c48:
0c48:  6f          RET

loc_0c49:
0c49:  09 47 5e    OR $5e, $47
0c4c:  da 14       MOVW $14, YA
0c4e:  da 16       MOVW $16, YA
0c50:  4d          PUSH
0c51:  ee          POP
0c52:  60          CLRC
0c53:  d0 0f       BNE $0c64
0c55:  98 27 16    ADC $16, #$27
0c58:  68 7c       CMP A, #$7c
0c5a:  f0 15       BEQ $0c71
0c5c:  60          CLRC
0c5d:  e8 00       MOV A, #$00
0c5f:  d7 14       MOV A, [$14]+Y
0c61:  fc          INC
0c62:  2f 09       BRA $0c6d

loc_0c64:
0c64:  98 14 16    ADC $16, #$14
0c67:  3f 6b 0c    CALL $0c6b
0c6a:  fc          INC

loc_0c6b:
0c6b:  f7 14       MOV A, [$14]+Y

loc_0c6d:
0c6d:  97 16       ADC A, [$16]+Y
0c6f:  d7 14       MOV A, [$14]+Y

loc_0c71:
0c71:  6f          RET

loc_0c72:
0c72:  f4 71       MOV A, $71+X
0c74:  f0 64       BEQ $0cda
0c76:  9b 71       DEC $71+X
0c78:  f0 05       BEQ $0c7f
0c7a:  e8 02       MOV A, #$02
0c7c:  de 70 5b    CBNE $70+X, $0cda

loc_0c7f:
0c7f:  f5 b8 03    MOV A, $03b8+X
0c82:  c4 17       MOV A, $17
0c84:  f4 d4       MOV A, $d4+X
0c86:  fb d5       MOV Y, $d5+X

loc_0c88:
0c88:  da 14       MOVW $14, YA
0c8a:  8d 00       MOV Y, #$00

loc_0c8c:
0c8c:  f7 14       MOV A, [$14]+Y
0c8e:  f0 1c       BEQ $0cac
0c90:  30 05       BMI $0c97

loc_0c92:
0c92:  fc          INC
0c93:  f7 14       MOV A, [$14]+Y
0c95:  10 fb       BPL $0c92

loc_0c97:
0c97:  68 c8       CMP A, #$c8
0c99:  f0 3f       BEQ $0cda
0c9b:  68 ef       CMP A, #$ef
0c9d:  f0 29       BEQ $0cc8
0c9f:  68 e0       CMP A, #$e0
0ca1:  90 30       BCC $0cd3
0ca3:  6d          PUSH
0ca4:  fd          MOV
0ca5:  ae          POP
0ca6:  96 a9 0a    ADC A, $0aa9+Y
0ca9:  fd          MOV
0caa:  2f e0       BRA $0c8c

loc_0cac:
0cac:  e4 17       MOV A, $17
0cae:  f0 23       BEQ $0cd3
0cb0:  8b 17       DEC $17
0cb2:  d0 0a       BNE $0cbe
0cb4:  f5 3d 02    MOV A, $023d+X
0cb7:  2d          PUSH
0cb8:  f5 3c 02    MOV A, $023c+X
0cbb:  ee          POP
0cbc:  2f ca       BRA $0c88

loc_0cbe:
0cbe:  f5 51 02    MOV A, $0251+X
0cc1:  2d          PUSH
0cc2:  f5 50 02    MOV A, $0250+X
0cc5:  ee          POP
0cc6:  2f c0       BRA $0c88

loc_0cc8:
0cc8:  fc          INC
0cc9:  f7 14       MOV A, [$14]+Y
0ccb:  2d          PUSH
0ccc:  fc          INC
0ccd:  f7 14       MOV A, [$14]+Y
0ccf:  fd          MOV
0cd0:  ae          POP
0cd1:  2f b5       BRA $0c88

loc_0cd3:
0cd3:  e4 47       MOV A, $47
0cd5:  8d 5c       MOV Y, #$5c
0cd7:  3f fe 05    CALL $05fe

loc_0cda:
0cda:  f2 13       CLR1 $13.7
0cdc:  f4 98       MOV A, $98+X
0cde:  f0 2c       BEQ $0d0c
0ce0:  f4 99       MOV A, $99+X
0ce2:  f0 04       BEQ $0ce8
0ce4:  9b 99       DEC $99+X
0ce6:  2f 24       BRA $0d0c

loc_0ce8:
0ce8:  e2 13       SET1 $13.7
0cea:  9b 98       DEC $98+X
0cec:  d0 0b       BNE $0cf9
0cee:  f5 a5 03    MOV A, $03a5+X
0cf1:  d5 7c 03    MOV A, $037c+X
0cf4:  f5 a4 03    MOV A, $03a4+X
0cf7:  2f 10       BRA $0d09

loc_0cf9:
0cf9:  60          CLRC
0cfa:  f5 7c 03    MOV A, $037c+X
0cfd:  95 90 03    ADC A, $0390+X
0d00:  d5 7c 03    MOV A, $037c+X
0d03:  f5 7d 03    MOV A, $037d+X
0d06:  95 91 03    ADC A, $0391+X

loc_0d09:
0d09:  d5 7d 03    MOV A, $037d+X

loc_0d0c:
0d0c:  3f 22 0b    CALL $0b22
0d0f:  f4 ad       MOV A, $ad+X
0d11:  f0 4c       BEQ $0d5f
0d13:  f5 a0 02    MOV A, $02a0+X
0d16:  de ac 44    CBNE $ac+X, $0d5d
0d19:  f5 00 01    MOV A, $0100+X
0d1c:  75 a1 02    CMP A, $02a1+X
0d1f:  d0 05       BNE $0d26
0d21:  f5 b5 02    MOV A, $02b5+X
0d24:  2f 0d       BRA $0d33

loc_0d26:
0d26:  40          SETP
0d27:  bb 00       INC $00+X
0d29:  20          CLRP
0d2a:  fd          MOV
0d2b:  f0 02       BEQ $0d2f
0d2d:  f4 ad       MOV A, $ad+X

loc_0d2f:
0d2f:  60          CLRC
0d30:  95 b4 02    ADC A, $02b4+X

loc_0d33:
0d33:  d4 ad       MOV $ad+X, A
0d35:  f5 8c 02    MOV A, $028c+X
0d38:  60          CLRC
0d39:  95 8d 02    ADC A, $028d+X
0d3c:  d5 8c 02    MOV A, $028c+X

loc_0d3f:
0d3f:  c4 12       MOV A, $12
0d41:  1c          ASL
0d42:  1c          ASL
0d43:  90 02       BCC $0d47
0d45:  48 ff       EOR A, #$ff

loc_0d47:
0d47:  fd          MOV
0d48:  f4 ad       MOV A, $ad+X
0d4a:  68 f1       CMP A, #$f1
0d4c:  90 05       BCC $0d53
0d4e:  28 0f       AND A, #$0f
0d50:  cf          MUL
0d51:  2f 04       BRA $0d57

loc_0d53:
0d53:  cf          MUL
0d54:  dd          MOV A, Y
0d55:  8d 00       MOV Y, #$00

loc_0d57:
0d57:  3f da 0d    CALL $0dda

loc_0d5a:
0d5a:  5f 7b 05    JMP $057b

loc_0d5d:
0d5d:  bb ac       INC $ac+X

loc_0d5f:
0d5f:  e3 13 f8    BBS $13.7, $0d5a
0d62:  6f          RET

loc_0d63:
0d63:  f2 13       CLR1 $13.7
0d65:  f4 c1       MOV A, $c1+X
0d67:  f0 09       BEQ $0d72
0d69:  f5 dc 02    MOV A, $02dc+X
0d6c:  de c0 03    CBNE $c0+X, $0d72
0d6f:  3f e2 0d    CALL $0de2

loc_0d72:
0d72:  f5 41 03    MOV A, $0341+X
0d75:  fd          MOV
0d76:  f5 40 03    MOV A, $0340+X
0d79:  da 10       MOVW $10, YA
0d7b:  f4 85       MOV A, $85+X
0d7d:  f0 0a       BEQ $0d89
0d7f:  f5 55 03    MOV A, $0355+X
0d82:  fd          MOV
0d83:  f5 54 03    MOV A, $0354+X
0d86:  3f c4 0d    CALL $0dc4

loc_0d89:
0d89:  f3 13 03    BBC $13.7, $0d8f
0d8c:  3f fe 0b    CALL $0bfe

loc_0d8f:
0d8f:  f2 13       CLR1 $13.7
0d91:  f5 7d 03    MOV A, $037d+X
0d94:  fd          MOV
0d95:  f5 7c 03    MOV A, $037c+X
0d98:  da 10       MOVW $10, YA
0d9a:  f4 98       MOV A, $98+X
0d9c:  f0 0e       BEQ $0dac
0d9e:  f4 99       MOV A, $99+X
0da0:  d0 0a       BNE $0dac
0da2:  f5 91 03    MOV A, $0391+X
0da5:  fd          MOV
0da6:  f5 90 03    MOV A, $0390+X
0da9:  3f c4 0d    CALL $0dc4

loc_0dac:
0dac:  f4 ad       MOV A, $ad+X
0dae:  f0 af       BEQ $0d5f
0db0:  f5 a0 02    MOV A, $02a0+X
0db3:  de ac a9    CBNE $ac+X, $0d5f
0db6:  eb 51       MOV Y, $51
0db8:  f5 8d 02    MOV A, $028d+X
0dbb:  cf          MUL
0dbc:  dd          MOV A, Y
0dbd:  60          CLRC
0dbe:  95 8c 02    ADC A, $028c+X
0dc1:  5f 3f 0d    JMP $0d3f

loc_0dc4:
0dc4:  e2 13       SET1 $13.7
0dc6:  cb 12       MOV $12, Y
0dc8:  3f 3f 0b    CALL $0b3f
0dcb:  6d          PUSH
0dcc:  eb 51       MOV Y, $51
0dce:  cf          MUL
0dcf:  cb 14       MOV $14, Y
0dd1:  8f 00 15    MOV $15, #$00
0dd4:  eb 51       MOV Y, $51
0dd6:  ae          POP
0dd7:  cf          MUL
0dd8:  7a 14       ADDW $14+Y, A

loc_0dda:
0dda:  3f 3f 0b    CALL $0b3f
0ddd:  7a 10       ADDW $10+Y, A
0ddf:  da 10       MOVW $10, YA
0de1:  6f          RET

loc_0de2:
0de2:  e2 13       SET1 $13.7
0de4:  eb 51       MOV Y, $51
0de6:  f5 c9 02    MOV A, $02c9+X
0de9:  cf          MUL
0dea:  dd          MOV A, Y
0deb:  60          CLRC
0dec:  95 c8 02    ADC A, $02c8+X

loc_0def:
0def:  1c          ASL
0df0:  90 02       BCC $0df4
0df2:  48 ff       EOR A, #$ff

loc_0df4:
0df4:  fb c1       MOV Y, $c1+X
0df6:  cf          MUL
0df7:  dd          MOV A, Y
0df8:  48 ff       EOR A, #$ff

loc_0dfa:
0dfa:  eb 34       MOV Y, $34
0dfc:  d0 03       BNE $0e01
0dfe:  eb 59       MOV Y, $59
0e00:  cf          MUL

loc_0e01:
0e01:  f5 14 02    MOV A, $0214+X
0e04:  cf          MUL
0e05:  f5 05 03    MOV A, $0305+X
0e08:  cf          MUL
0e09:  dd          MOV A, Y
0e0a:  cf          MUL
0e0b:  dd          MOV A, Y
0e0c:  d5 2d 03    MOV A, $032d+X
0e0f:  6f          RET
0e10:  00          NOP
0e11:  01          TCALL 0
0e12:  03 07 0d    BBS $07.0, $0e22
0e15:  15 1e 29    OR A, $291e+X
0e18:  34 42       AND $42+X, A
0e1a:  51          TCALL 5
0e1b:  5e 67 6e    CMP $6e67, Y
0e1e:  73 77 7a    BBC $77.3, $0e9b
0e21:  7c          ROR

; ═══════════════════════════════════════════════════════════
; EnvelopeCurve: ADSR envelope curve table (32 bytes)
; ═══════════════════════════════════════════════════════════
0e22:  .db 7d 7e 7f 7f 00 00 00 00 00 00 00 58 bf db f0 fe
0e32:  .db 07 0c 0c 0c 21 2b 2b 13 fe f3 f9 34 33 00 d9 e5

; ═══════════════════════════════════════════════════════════
; EnvelopeConfig: Envelope config / FIR coefficients (23 bytes)
; ═══════════════════════════════════════════════════════════
0e42:  .db 01 fc eb 2c 3c 0d 4d 6c 4c 5c 3d 2d 5c 6b 6c 4e
0e52:  .db 38 48 45 0e 49 4b 46

; ═══════════════════════════════════════════════════════════
; FreqTable: Frequency table (13 x u16 = 26 bytes, C through C+)
; ═══════════════════════════════════════════════════════════
0e59:  .dw $085f        ; C   = 2143
0e5b:  .dw $08de        ; C#  = 2270
0e5d:  .dw $0965        ; D   = 2405
0e5f:  .dw $09f4        ; D#  = 2548
0e61:  .dw $0a8c        ; E   = 2700
0e63:  .dw $0b2c        ; F   = 2860
0e65:  .dw $0bd6        ; F#  = 3030
0e67:  .dw $0c8b        ; G   = 3211
0e69:  .dw $0d4a        ; G#  = 3402
0e6b:  .dw $0e14        ; A   = 3604
0e6d:  .dw $0eea        ; A#  = 3818
0e6f:  .dw $0fcd        ; B   = 4045
0e71:  .dw $10be        ; C+  = 4286

; ═══════════════════════════════════════════════════════════
; OctaveShiftTable: Octave shift lookup (16 bytes)
; ═══════════════════════════════════════════════════════════
0e73:  .db 00 00 10 00 20 00 30 00 40 00 50 00 60 00 70 00

; ═══════════════════════════════════════════════════════════
; NspcOpcodeJumpTableLo: N-SPC opcode jump table low (16 bytes, possibly init code)
; ═══════════════════════════════════════════════════════════
0e83:  .db 60 00 70 00 fa 1a 37 38 3f 1a 8f ff 34 8f 00 5e

; ═══════════════════════════════════════════════════════════
; NspcOpcodeJumpTableHi: N-SPC opcode jump table high (16 bytes, possibly init code)
; ═══════════════════════════════════════════════════════════
0e93:  .db 8f 40 47 cd 10 e4 f6 f0 0c 09 47 46 09 47 37 09
0ea3:  47 36       EOR A, [$36+X]
0ea5:  3f ca 0e    CALL $0eca

loc_0ea8:
0ea8:  3f 30 0f    CALL $0f30
0eab:  8f 80 47    MOV $47, #$80
0eae:  cd 12       MOV X, #$12
0eb0:  e4 f7       MOV A, $f7
0eb2:  f0 0c       BEQ $0ec0
0eb4:  09 47 46    OR $46, $47
0eb7:  09 47 37    OR $37, $47
0eba:  09 47 36    OR $36, $47
0ebd:  3f ca 0e    CALL $0eca

loc_0ec0:
0ec0:  3f 30 0f    CALL $0f30
0ec3:  8f 00 34    MOV $34, #$00
0ec6:  fa 37 1a    MOV $1a, $37
0ec9:  6f          RET

loc_0eca:
0eca:  1c          ASL
0ecb:  4d          PUSH
0ecc:  5d          MOV X, A
0ecd:  f5 01 14    MOV A, $1401+X
0ed0:  fd          MOV
0ed1:  f5 00 14    MOV A, $1400+X
0ed4:  ce          POP
0ed5:  d4 d4       MOV $d4+X, A
0ed7:  db d5       MOV $d5+X, Y
0ed9:  e8 96       MOV A, #$96
0edb:  d5 05 03    MOV A, $0305+X
0ede:  e8 0a       MOV A, #$0a
0ee0:  3f 09 09    CALL $0909
0ee3:  e8 00       MOV A, #$00
0ee5:  d5 15 02    MOV A, $0215+X
0ee8:  d5 a5 03    MOV A, $03a5+X
0eeb:  d5 f0 02    MOV A, $02f0+X
0eee:  d5 64 02    MOV A, $0264+X
0ef1:  d4 ad       MOV $ad+X, A
0ef3:  d4 c1       MOV $c1+X, A
0ef5:  d5 b8 03    MOV A, $03b8+X
0ef8:  d4 84       MOV $84+X, A
0efa:  d4 85       MOV $85+X, A
0efc:  e8 02       MOV A, #$02
0efe:  d4 70       MOV $70+X, A
0f00:  6f          RET

loc_0f01:
0f01:  e4 47       MOV A, $47
0f03:  48 ff       EOR A, #$ff
0f05:  fd          MOV
0f06:  24 37       AND A, $37
0f08:  c4 37       MOV A, $37
0f0a:  dd          MOV A, Y
0f0b:  24 36       AND A, $36
0f0d:  c4 36       MOV A, $36
0f0f:  09 47 5e    OR $5e, $47
0f12:  fa 47 5c    MOV $5c, $47
0f15:  09 47 46    OR $46, $47
0f18:  8f 00 34    MOV $34, #$00
0f1b:  4d          PUSH
0f1c:  7d          MOV A, X
0f1d:  80          SETC
0f1e:  a8 04       SBC A, #$04
0f20:  5d          MOV X, A
0f21:  f5 15 02    MOV A, $0215+X
0f24:  3f 9d 08    CALL $089d
0f27:  ce          POP
0f28:  8f ff 34    MOV $34, #$ff
0f2b:  e8 00       MOV A, #$00
0f2d:  d4 d5       MOV $d5+X, A
0f2f:  6f          RET

loc_0f30:
0f30:  f4 d5       MOV A, $d5+X
0f32:  f0 54       BEQ $0f88
0f34:  d8 44       MOV $44, X
0f36:  9b 70       DEC $70+X
0f38:  d0 45       BNE $0f7f

loc_0f3a:
0f3a:  3f 93 08    CALL $0893
0f3d:  f0 c2       BEQ $0f01
0f3f:  30 20       BMI $0f61
0f41:  d5 00 02    MOV A, $0200+X
0f44:  3f 93 08    CALL $0893
0f47:  30 18       BMI $0f61
0f49:  2d          PUSH
0f4a:  9f          XCN
0f4b:  28 07       AND A, #$07
0f4d:  fd          MOV
0f4e:  f6 00 13    MOV A, $1300+Y
0f51:  d5 01 02    MOV A, $0201+X
0f54:  ae          POP
0f55:  28 0f       AND A, #$0f
0f57:  fd          MOV
0f58:  f6 08 13    MOV A, $1308+Y
0f5b:  d5 14 02    MOV A, $0214+X
0f5e:  3f 93 08    CALL $0893

loc_0f61:
0f61:  68 e0       CMP A, #$e0
0f63:  90 05       BCC $0f6a
0f65:  3f 81 08    CALL $0881
0f68:  2f d0       BRA $0f3a

loc_0f6a:
0f6a:  3f 11 05    CALL $0511
0f6d:  f5 00 02    MOV A, $0200+X
0f70:  d4 70       MOV $70+X, A
0f72:  fd          MOV
0f73:  f5 01 02    MOV A, $0201+X
0f76:  cf          MUL
0f77:  dd          MOV A, Y
0f78:  d0 01       BNE $0f7b
0f7a:  bc          INC

loc_0f7b:
0f7b:  d4 71       MOV $71+X, A
0f7d:  2f 03       BRA $0f82

loc_0f7f:
0f7f:  3f 72 0c    CALL $0c72

loc_0f82:
0f82:  3f ea 0a    CALL $0aea
0f85:  3f a9 0b    CALL $0ba9

loc_0f88:
0f88:  6f          RET

loc_0f89:
0f89:  8d bb       MOV Y, #$bb
0f8b:  e8 aa       MOV A, #$aa
0f8d:  da f4       MOVW $f4, YA

loc_0f8f:
0f8f:  e4 f4       MOV A, $f4
0f91:  68 cc       CMP A, #$cc
0f93:  d0 fa       BNE $0f8f
0f95:  2f 1e       BRA $0fb5

loc_0f97:
0f97:  eb f4       MOV Y, $f4
0f99:  d0 fc       BNE $0f97

loc_0f9b:
0f9b:  7e f4       CMP $f4, Y
0f9d:  d0 10       BNE $0faf
0f9f:  cb f4       MOV $f4, Y
0fa1:  e4 f5       MOV A, $f5
0fa3:  d6 00 00    MOV A, $0000+Y
0fa6:  fc          INC
0fa7:  d0 f2       BNE $0f9b
0fa9:  ac a5 0f    INC $0fa5
0fac:  5f 9b 0f    JMP $0f9b

loc_0faf:
0faf:  10 ea       BPL $0f9b
0fb1:  7e f4       CMP $f4, Y
0fb3:  10 e6       BPL $0f9b

loc_0fb5:
0fb5:  ba f6       MOVW YA, $f6
0fb7:  c5 a4 0f    MOV A, $0fa4
0fba:  cc a5 0f    MOV $0fa5, Y

; ═══════════════════════════════════════════════════════════
; DSPRegInitTable: Initial DSP register values (13 bytes)
; ═══════════════════════════════════════════════════════════
0fbd:  .db eb f4 e4 f5 cb f4 d0 d2 cd 33 d8 f1 6f
```