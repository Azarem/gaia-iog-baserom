; GaiaLabs Retranslation, chapter 24. Dialogue only.

?INCLUDE 'wa78_intro'
; Luke's welcome waits for the arrival narration to close. Flag $0A is
; local to this scene and is cleared before and after the handoff.
wa78_intro.wa78_intro! [
  actor-def < #00, #00, #38, {

  WatermiaArrivalStart:
    COP [BranchOnFlagByte] ( #8D, #01, &code_07808E )
    LDA #$0008
    TSB $12
    LDA #$CFFC
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #01 )
    LDA #$0800
    TSB $10
    COP [ClearFlagByte] ( #0A )
    COP [SpawnListAppend] ( @code_0780AD, #00, #00, #$2000 )
    COP [SpawnAfterFlags] ( @code_078090, #$2800 )
    COP [StageSpriteLoopMoveY] ( #07, #08, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #07, #10, #11, #02 )
    COP [AnimLoop]
    LDY $playerActor
    LDA $14
    STA $0014, Y
    LDA $16
    STA $0016, Y
    COP [SetFlagByte] ( #8D )
    LDA #$0800
    TRB $10
    COP [WaitByte] ( #1D )
    COP [WaitOnFlagByte] ( #0A, #01 )
    COP [ClearFlagByte] ( #0A )
    COP [PrintDialogString] ( &dialogstring_078139 )
    COP [WaitByte] ( #3B )
    LDA #$0404
    STA $gfxCacheIdxB
    COP [QueueMapChange] ( #79, #$0070, #$00B0, #00, #$1100 )
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL
} >
]

wa78_intro.code_0780AD! {
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_0780B6 )
    COP [SetFlagByte] ( #0A )
    COP [Die]
}

wa78_intro.dialogstring_0780B6! `[DEF][DLY:2]Will and the others[N]reach Watermia, the[N]Floating City.[PAU:58][CLR]Houses rest on rafts[N]all across the bright[N]water.[PAU:58][CLR]The townspeople welcome[N]them. Luke, a fisherman,[N]has offered them his home[N]while he's away at sea.[PAU:58][CLR]Will expects to welcome[N]the chance to rest[AD][PAU:58][CLR]But after a few quiet[N]days, he grows restless.[PAU:58][CLR]He wonders what waits[N]beyond the next horizon.[PAU:84][CLD]`
wa78_intro.dialogstring_078139! `[DEF]This is Luke's house.[N]He's a fisherman, and a[N]generous one.[FIN][DEF]He'll be away on a long[N]voyage, so he told Will[N]and the others to make[N]themselves at home.[END]`

?INCLUDE 'wa79_kara'
wa79_kara.dialogstring_07A613! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Watermia is[N]beautiful, but I've heard[N]some ugly rumors.[WAI][N]Something about people[N]gambling with their lives.[WAI][N]Maybe beautiful places[N]always have another side.[WAI][N]Freejia did too.[END]`

?INCLUDE 'wa79_erik'
wa79_erik.dialogstring_07A475! `[BOR:3][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme3]Erik: Eheheh. I found[N]something good just now.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]Take a look behind this[N]house. It might hurt your[N]conscience a little, but[N]hey…[END]`

?INCLUDE 'wa79_lily'
wa79_lily.dialogstring_07A92F! `[BOR:6][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme2]Lilly: Hey, by the way,[N]Lance noticed someone he[N]knows in town.[FIN]And it looks like he went[N]looking for them.[END]`

?INCLUDE 'wa79_neil'
wa79_neil.dialogstring_07A217! `[BOR:D][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme6]Neil: These houses on[N]rafts are inspiring me[N]for a new invention…[END]`

?INCLUDE 'wa78_men'
wa78_men.dialogstring_07879B! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Luke: Yo. How do you like[N]the house? You're free to[N]use it while I'm away on[N]my voyage.[END]`

?INCLUDE 'wa78_diary'
wa78_diary.dialogstring_079C19! `[BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Thought](Kara hid her diary here[AD][N]Should I read it?)[N][PAL:0] Yes[N] No[PAL:4]`
wa78_diary.dialogstring_079C4A! `[CLR][BOR:3][PRT:@CastleV051Thought](No. I'd feel guilty[N]reading it without[N]permission.)[END]`
wa78_diary.dialogstring_079C81! `[CLR][BOR:1][DLG:3,D][SIZ:D,6][PRT:@RetranslationTheme1][SFX:0]Day X of month X:[N]After a very long road, we[N]finally reached Watermia.[FIN]I was thirsty on the way.[N]My feet blistered, and I[N]wrapped them in my[N]handkerchief.[FIN]Before this journey, I[N]would have complained the[N]whole time.[N]This time I kept going.[N]Maybe I've changed more[N]than I realized.[FIN]Today I heard a Watermia[N]legend.[N]"Make a wish from a lotus[N]leaf beneath the full[N]moon, and the one you love[N]will look closely at you."[FIN]It's a lovely story.[N]Maybe I'll try it[AD][END]`

?INCLUDE 'wa78_kruk'
wa78_kruk.dialogstring_079AEF! `[DLG:3,17][SIZ:D,1]Kyuui!!… Kyuui!!…[END]`

?INCLUDE 'wa78_children'
wa78_children.dialogstring_078CC5! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Savvas: My dad is an[N]explorer.[WAI][N]He's going to come back[N]to us soon, right after he[N]discovers the Gold Ship![END]`

?INCLUDE 'wa78_women'
wa78_women.dialogstring_078A26! `[BOR:9][DLG:3,F][SIZ:D,5][PRT:@RetranslationTheme1C]Nana: We haven't heard[N]news from our dad even[N]though it's already been[N]half a year since we[N]received his last letter…[FIN][CLD][BOR:9][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme1C]It'll be fine so long as[N]he's safe, but…[END]`

?INCLUDE 'wa78_crazy_man'
wa78_crazy_man.dialogstring_07A0A7! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]A strange white-haired man[N]wandered into town a[N]little over a year ago.[WAI][N]Ever since, he's done[N]nothing but ramble about[N]the Tower of Babel.[END]`

?INCLUDE 'wa78_children'
wa78_children.dialogstring_078C59! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Child: A snake bit me when[N]I went to the Great Wall[N]of China before[AD][WAI][N]If one of those snakes[N]bites you, it won't let go[N]easily.[END]`
wa78_children.dialogstring_078C12! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Child: If a snake bites[N]you, run around like[N]crazy. It'll eventually[N]plop off.[END]`

?INCLUDE 'wa78_centipede_man'
wa78_centipede_man.dialogstring_0782BD! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Man: They say that a[N]giant centipede called[N]the Sand Fanger inhabits the[N]Great Wall of China.[END]`

?INCLUDE 'wa78_children'
wa78_children.dialogstring_078D02! `[BOR:9][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme1C]Child: I'll teach you[N]something good.[FIN][CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Try waiting behind the[N]gambling house, on the[N]right side. A lotus leaf[N]will arrive.[END]`

?INCLUDE 'wa78_women'
wa78_women.dialogstring_078B73! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]They call him the "crazy[N]old man," but he's[N]actually still young.[WAI][N]His hair turned completely[N]white.[WAI][N]I wonder what he saw that[N]frightened him so badly[AD][END]`

?INCLUDE 'wa78_men'
wa78_men.dialogstring_0788E0! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]A strange white-haired man[N]lives in a house deep in[N]this town.[WAI][N]I'm not sure, but I think[N]he was part of Olman's[N]expedition to survey the[N]Tower of Babel.[END]`

?INCLUDE 'wa78_moving_woman'
wa78_moving_woman.dialogstring_07842C! `[BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Woman: This is Watermia.[N]It's really easy to move[N]because everyone's houses[N]are on rafts.[END]`

?INCLUDE 'wa78_women'
wa78_women.dialogstring_078AF8! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Woman: I'm going to have[N]a baby soon.[WAI][N]My husband is so excited.[N]He's been working harder[N]than ever to support us.[END]`

?INCLUDE 'wa7D_glass_opponent'
wa7D_glass_opponent.dialogstring_078E01! `[BOR:9][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme24]Man: *cough* *cough*[N]Wh-what? I've only caught[N]a little cold.[END]`

?INCLUDE 'wa78_men'
wa78_men.dialogstring_0785C9! `[BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Man: If a neighbor moves,[N]look along the water.[FIN]The whole house might be[N]tied up somewhere else.[END]`

?INCLUDE 'wa78_water_kid'
wa78_water_kid.dialogstring_0784CF! `[BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Child: We drink this[N]water, we cook our rice in[N]this water, we wash our[N]clothes with this water.[END]`

?INCLUDE 'wa78_women'
wa78_women.dialogstring_0789C7! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Water never stays in one[N]place. It keeps moving,[N]clear and alive.[WAI][N]I think people should live[N]a little more like that.[END]`

?INCLUDE 'wa78_men'
wa78_men.dialogstring_07876E! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]This lotus leaf is full.[N]Find another if you want[N]a ride.[END]`
wa78_men.dialogstring_078607! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Man: This animal is[N]called a Kruk.[WAI][N]It's perfect for crossing[N]the desert because it can[N]go a long time without[N]food or water.[END]`
wa78_men.dialogstring_078674! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Man: This is a gambling[N]house.[WAI][N]A kid coming in here must[N]be pretty desperate for[N]money[AD][END]`

?INCLUDE 'wa78_women'
wa78_women.dialogstring_078ABA! `[BOR:9][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme1C]As you can see, this is a[N]drinking contest. We're[N]betting on who will win.[END]`

?INCLUDE 'wa78_men'
wa78_men.dialogstring_078881! `[CLD][BOR:9][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1C]They're gambling with[N]human lives.[WAI][N]One bad choice and someone[N]dies for the crowd's[N]entertainment.[WAI][N]I don't understand how[N]people can get used to[N]watching that.[END]`

?INCLUDE 'wa78_women'
wa78_women.dialogstring_078A73! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]A human life isn't cheap.[WAI][N]Don't throw yours away on[N]worthless gambling.[END]`

?INCLUDE 'wa78_men'
wa78_men.dialogstring_0787DA! `[BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]You can try going to the[N]raft floating behind this[N]building if you want to[N]make big money.[END]`
wa78_men.dialogstring_07881B! `[CLD][BOR:9][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1C]You won't make much[N]betting small.[WAI][N]Of course, if you're[N]willing to bet your life,[N]you can make a fortune.[END]`

?INCLUDE 'wa7B_competitor_right'
wa7B_competitor_right.dialogstring_07A188! `[BOR:9][DLG:3,4][SIZ:D,1][PRT:@RetranslationTheme1C]Ugh, ugh…[END]`

?INCLUDE 'wa7B_competitor_left'
wa7B_competitor_left.dialogstring_07A132! `[BOR:9][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme1C]Raaaaaagh…![N]I can still keep going…!![END]`

?INCLUDE 'wa7A_lances_father'
wa7A_lances_father.dialogstring_07B3C2! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]Lance's father: They[N]went into the room[AD][WAI][N]Screaming[AD] then suddenly[N]nothing.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]You were left in there[AD][N][PAU:1E]alone, Will.[WAI][N]Had to get you out.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]Threw a blanket over[N]myself. Went in.[WAI][N]Just to grab you.[WAI][N]Didn't[AD] I couldn't[AD][FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]You were in a daze.[WAI][N]Got you home, but[AD][N]my mind[AD] broken.[WAI][N]Couldn't go back.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]Didn't want them to see[N]me broken.[WAI][N]Better if they thought[N]I died[AD][FIN][CLD][BOR:3][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme4]Lance: Ya should've come[N]home.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme3]Lance's father: So[N]sorry[AD][N]So sorry[AD][END]`

?INCLUDE 'wa7A_lance'
wa7A_lance.dialogstring_07AB82! `[BOR:3][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme4]Lance: Will… Don't ya[N]remember this guy…?[FIN]That's right, it's my old[N]man.[END]`
wa7A_lance.dialogstring_07ABC4! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Lance: Something's wrong[N]with him[AD][WAI][N]I finally found my missin'[N]old man, and he can't[N]speak or think straight[AD][END]`
wa7A_lance.dialogstring_07AC08! `[BOR:3][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme4]Lance: Will, wait. I'm[N]going too.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]It's Lilly's birthday[N]party after this, ain't[N]it. We can't be gloomy[N]today.[FIN]Alright, let's head back[N]ta our room.[END]`

?INCLUDE 'wa79_lance'
wa79_lance.dialogstring_07AD31! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Lance: Alright, now that[N]everyone's here, let's[N]celebrate Lilly's[N]birthday.[END]`

?INCLUDE 'wa79_lily'
wa79_lily.dialogstring_07A974! `[BOR:6][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme2]Lilly: Wha…? Wha…?[N]Everyone remembered my[N]birthday…?[FIN][BOR:3][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme3]Erik: Isn't it obvious?[FIN]We thought we'd surprise[N]you so we kept it a[N]secret.[FIN][BOR:D][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme6]Neil: Hey Kara.[N]Bring that out now.[END]`

?INCLUDE 'wa79_kara'
wa79_kara.dialogstring_07A6AF! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Here it is![N]A birthday cake![FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Neil made it.[FIN][CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme6]Neil: Hahaha. My first[N]cake.[FIN][CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme6]I think the aeroplane was[N]easier.[FIN][CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: Thank you[AD][N]All of you[AD][FIN][CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Today I might be the[N]happiest girl in the[N]world.[FIN][CLD][DEF]And so Lilly's modest[N]birthday party begins.[FIN][DEF]Near the end of the party[AD][END]`

?INCLUDE 'wa79_lance'
wa79_lance.dialogstring_07AD63! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Lance: Lilly, hey[AD][N]Can I talk to ya for a[N]minute?[WAI][N]I'll be waitin' outside.[END]`

?INCLUDE 'wa79_lily'
wa79_lily.dialogstring_07A9F2! `[BOR:6][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme2]Lilly: Huh? What in the[N]world is that about…?[END]`
wa79_lily.dialogstring_07AA09! `[BOR:6][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme2]Lilly: Sorry.[N]I'll head out for a bit.[END]`

?INCLUDE 'wa7F_lily'
wa7F_lily.dialogstring_07B277! `[CLD][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: What is it?[WAI][N]You're acting awfully[N]nervous. That's not like[N]you.[FIN][CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme4]Lance: Feels strange to[N]me too. I brought ya a[N]birthday present.[WAI][N]I thought about a lot of[N]things, but this seemed[N]most like ya.[END]`
wa7F_lily.dialogstring_07B2E4! `[CLD][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: Wow! This is[N]amaaazing! It's a bouquet[N]of roses[AD]![WAI][N]Rosebuds[AD] These will bloom[N]into roses, won't they?[END]`
wa7F_lily.dialogstring_07B329! `[CLD][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: They smell[N]wonderful. Thank you.[N]I really am happy.[FIN][CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme4]Lance: There's somethin'[N]else I wanted to give ya.[N]Not a thing. Just words.[FIN][CLD][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: What?[END]`

?INCLUDE 'wa7F_lance'
wa7F_lance.dialogstring_07B0A2! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme4]Lance: Yeah. Words that're[N]harder to say than any[N]tongue twister I've ever[N]tried[AD][END]`
wa7F_lance.dialogstring_07B0E1! `[BOR:3][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme4][DLY:2]Lance: Lilly…[N]I care about ya a lot…[END]`
wa7F_lance.dialogstring_07B108! `[BOR:3][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme4][DLY:2]Lance: Ya don't have to[N]answer me right now.[FIN]I just needed ya to know[N]how I feel.[END]`
wa7F_lance.dialogstring_07B158! `[BOR:3][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme4]Lance: Lilly![N]Please wait…!![PAU:50][CLD]`
wa7F_lance.dialogstring_07B174! `[CLD][DEF]Lilly doesn't return to[N]their room that night.[END]`

?INCLUDE 'wa79_kara'
wa79_kara.dialogstring_07A79C! `[CLD][DEF]When Will wakes, Lance[N]is gone, too.[END]`
wa79_kara.dialogstring_07A7E2! `[BOR:7][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme1]Kara: I wonder what[N]happened to Lance and[N]Lilly. I'm worried…[END]`

?INCLUDE 'item_use_system'
item_use_system.dialogstring_039514! `[DLG:3,15][SIZ:D,2]Will opens Lance's letter.[FIN][CLD][BOR:1][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme4]I'm going to the[N]Great Wall of China.[FIN]I meant to keep it secret,[N]but I figured I'd tell[N]you.[FIN]I'm hiding this letter in[N]your luggage. Betting it[N]takes you a bit to notice.[FIN]Lilly turned me down.[N]I think maybe she's got[N]feelings for you, Will.[FIN]Don't worry. I don't blame[N]you. You never did[N]anything wrong.[FIN]Maybe I just haven't given[N]her much reason to see me[N]that way.[FIN]I heard an old legend[N]about the Great Wall.[FIN]They say living sculptures[N]that never age still[N]guard a sacred statue[N]hidden there.[FIN]Sounds a lot like one of[N]the Mystic Statues we're[N]looking for, doesn't it?[FIN]So I'm going to find it.[N]Maybe if I come back with[N]one of those things, Lilly[N]will see me differently.[FIN]Don't follow me.[N]I need to do this one[N]myself.[END]`

?INCLUDE 'wa78_glass_game'
wa78_glass_game.dialogstring_07927C! `[CLD][BOR:9][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1C]Every month on a full moon[N]night, people play Russian[N]Glass.[WAI][N]It's the ultimate form of[N]gambling where you bet[N]your very life.[WAI][N]But you're still young,[N]little boy. I definitely[N]don't think you should be[N]throwing your life away.[END]`

item_use_system.dialogstring_03944D! `[DEF]Will opens Lance's[N]father's journal.[FIN]Read which entry? [N] Tower of Babel [N] Mystic Statues [N] Great Wall of China `
