; GaiaLabs Retranslation, chapter 11. Dialogue only.

?INCLUDE 'dc2F_adrift'
dc2F_adrift.dialogstring_059D42! `[BOR:7][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme1]Kara: You finally came[N]to, huh. We were split up[N]from everyone…[FIN]Are you hurt?[N][PAL:0] I'm fine[N] I'm still dizzy[PAL:4]`
dc2F_adrift.dialogstring_059D91! `[DLG:3,4][SIZ:D,4]Kara: Is that so? It[N]seems like you recover[N]quickly, huh. You're like[N]a lizard's tail.[FIN][JMP:&dialogstring_059DCD+M]`
dc2F_adrift.dialogstring_059DCD! `[CLR]Kara: No wonder, right?[N]You were unconscious for[N]over half a day.[FIN][::][DLG:3,4][SIZ:D,5]I've read stories of being[N]adrift in books, but I[N]would have thought it[N]ridiculous that it would[N]turn out like this for me.[FIN][CLD][BOR:7][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme1]I guess that disaster[N]comes around suddenly,[N]huh.[END]`
dc2F_adrift.dialogstring_059E6F! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: I can't help[N]worrying.[WAI][N][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Still[AD] if we don't think[N]too much about what comes[N]next, maybe we can enjoy[N]being adrift a little.[WAI][N]I'm starving already.[N]Let's have the meat we[N]took from the castle's[N]basement for lunch.[END]`

?INCLUDE 'item_use_system'
item_use_system.dialogstring_038DDA! `[DEF]Will and Kara bite into[N]the smoked meat.[FIN][CLD][DEF]Neither can remember[N]anything tasting so good.[END]`

?INCLUDE 'dc2F_adrift'
dc2F_adrift.dialogstring_059CEB! `[DLG:9,7][SIZ:7,1]2nd Day Adrift[END]`
dc2F_adrift.dialogstring_059EE3! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: It's beautiful[AD][N]Even though I'm watching[N]it all day, I don't think[N]I'm getting tired of it[AD][WAI][N]Kara: I miss home a[N]little. Mother and Father[N]weren't always bad.[WAI][N]Father would read me[N]stories sometimes while[N]I lay in bed.[WAI][N]He'd tell me about a[N]wondrous light that healed[N]the sick[AD][WAI][N][AD]and an order of[N]guardians and scholars[N]who fought to save all[N]from pain and suffering.[WAI][N]I used to love those[N]stories.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: What happened[N]to them?[FIN][CLD][BOR:7][DLG:3,4][SIZ:D,1][PRT:@RetranslationTheme1]Kara: I don't know.[END]`

; Day two starts with Kara's story about home, then cycles through the three repeat talks.
dc2F_adrift.code_05993C! {
    COP [PrintDialogString] ( &dialogstring_059EE3 )
    COP [SetInteractHandler] ( &RaftTalkRhythm )
    RTL
}

RaftTalkRhythm {
    COP [PrintDialogString] ( &RaftKaraRhythm )
    COP [SetInteractHandler] ( &RaftTalkFish )
    RTL
}
RaftKaraRhythm `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: I'm starting to get[N]used to the rocking.[N]At first, I hated it.[FIN]But now I can feel a[N]rhythm in the waves.[N]Almost like a clock.[FIN]If I stop fighting it,[N]I can feel time passing[N]with the sea.[FIN]Even my breathing has[N]started to follow[N]its rhythm.[END]`

RaftTalkFish {
    COP [PrintDialogString] ( &RaftKaraFish )
    COP [SetInteractHandler] ( &RaftTalkRing )
    RTL
}
RaftKaraFish `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Look at those fish.[N]They keep leaping out[N]of the water.[FIN]There's an endless ocean[N]beneath them, yet they[N]still jump into the air.[FIN]Maybe even in a world[N]that vast, they need[N]a moment of escape.[FIN]Just one breath of air[N]before falling back[N]into the sea.[END]`

RaftTalkRing {
    COP [PrintDialogString] ( &RaftKaraRing )
    COP [SetInteractHandler] ( &RaftTalkRhythm )
    RTL
}
RaftKaraRing `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: I've been looking at[N]the ring I took from[N]the ship.[FIN]The blue stone really[N]is beautiful…[FIN]But beside the horizon,[N]its color almost seems[N]like an imitation.[FIN]Sea below us, sky above…[N]How could a jewel ever[N]hold all that blue?[END]`
dc2F_adrift.dialogstring_059F2E! `[BOR:7][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme1]Kara: How could you do[N]that…! Those poor fish…!![END]`
dc2F_adrift.dialogstring_059F5A! `[DEF]Time passes slowly, with[N]nothing to break the[N]monotony.[FIN][CLD][DEF]Kara watches the fish for[N]hours. Will paces the[N]raft, trying to talk to[N]her.[FIN][CLD][DEF]Each minute seems to[N]stretch into an hour.[FIN][CLD][DEF]Neither can do anything[N]but let time pass.[END]`
dc2F_adrift.dialogstring_059CF9! `[DLG:9,7][SIZ:7,1]4th Day Adrift[END]`
dc2F_adrift.dialogstring_05A03C! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Somehow, I have a[N]hunch rescue might be[N]coming[AD][WAI][N]Oh[AD]?[END]`
dc2F_adrift.dialogstring_05A074! `[BOR:7][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme1]Kara: It looks like[N]something is drifting[N]this way…![END]`
dc2F_adrift.dialogstring_0599FC! `[PAL:0][DLG:3,4][SIZ:D,3][PAL:0]Someone placed a letter[N]into this jar… It read[N]something like this.[FIN][CLD][BOR:1][DLG:3,4][SIZ:D,7][PRT:@RetranslationTheme5]We have been placed on a[N]slave ship; it is heading[N]to unfamiliar land where[N]we will be sold.[N]If anyone reads this[N]letter, please save us…[N]                   Sam[END]`
dc2F_adrift.dialogstring_05A091! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: So much for my[N]feeling that rescue was[N]coming[AD][WAI][N]They're asking us to save[N]them, but we need saving[N]too.[WAI][N]I'm starving[AD]![FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: Which is why we[N]should've eaten some fish[N]when we had the chance.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: Next time[AD][FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: You can't kill those[N]poor fish![FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: So we're supposed[N]to starve instead?![FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: I can't eat raw[N]fish! It's disgusting![WAI][N]And they're trying to live[N]just as hard as we are.[WAI][N]If you want one, eat it.[N]I'm not going to![END]`
dc2F_adrift.dialogstring_05A232! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: [AD][FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Thought](Good grief. What a[N]stubborn princess[AD])[FIN][CLD][DEF]For the rest of the day,[N]Kara barely spoke to Will.[END]`
dc2F_adrift.dialogstring_059D07! `[DLG:9,7][SIZ:7,1]7th Day Adrift[END]`
dc2F_adrift.dialogstring_05A291! `[PAU:1E][DEF]After a full week adrift,[N]they spot another school[N]of fish.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Thought](I'm almost out of[N]strength.)[WAI][N](If I don't eat now, I[N]might die.)[END]`
dc2F_adrift.dialogstring_05A319! `[BOR:7][DLG:3,4][SIZ:D,1][PRT:@RetranslationTheme1]Kara: …[END]`
dc2F_adrift.dialogstring_05A332! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: [AD][WAI][N]Will[AD] I'm sorry about[N]what I said before.[WAI][N]I'll try eating one too.[N]If I die, I can't help[N]anyone, can I?[WAI][N]I guess I could[N]afford to be picky when I[N]always had plenty to eat.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: Alright. I'll catch[N]one for you.[N]The tastiest one.[END]`
dc2F_adrift.dialogstring_05A405! `[CLD][DEF]Kara eats the fish.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Thought](She's really forcing[N]herself[AD])[FIN](I guess I don't need to[N]make her feel worse by[N]telling her I'm worried[N]about her[AD])[FIN](Why was I so hesitant[N]to tell her that? Is it[N]because it's true?)[END]`
dc2F_adrift.dialogstring_059D15! `[DLG:8,7][SIZ:8,1]12th Day Adrift[END]`
dc2F_adrift.dialogstring_05A467! `[CLD][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]Kara: The stars are[N]beautiful, huh[AD][WAI][N][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]It seems like I could[N]touch them with my hands[N]if I was a little taller.[WAI][N][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]I think Lilly, Lance and[N]the rest must also be[N]looking at this same[N]starry sky.[WAI][N][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]If we could talk to the[N]stars, then we would[N]definitely know where[N]everyone is[AD][WAI][N][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Oh, that's right.[WAI][N][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]I noticed recently that[N]there's one more star[N]around the constellation[N]of Cygnus, the swan.[WAI][N][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]See, that red star over[N]there.[WAI][N][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]Hey. Won't you make a wish[N]on that star? I feel like[N]it will definitely come[N]true.[WAI][N][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]Will, you close your eyes[N]tight and make a wish too,[N]okay?[END]`
dc2F_adrift.dialogstring_05A5AB! `[BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme0][DLY:0]Will: I tried praying as[N]hard as I could for[N]everyone's safety, and for[N]my dad…[END]`
dc2F_adrift.dialogstring_059D24! `[DLG:8,7][SIZ:8,1]18th Day Adrift[END]`
dc2F_adrift.dialogstring_05A5E3! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: It's already been[N]nearly three weeks, huh?[WAI][N][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Speaking of it, Will,[N]hasn't your hair grown a[N]little?[WAI][N]Still no mustache, though.[N]*Laughs*[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: And you don't look[N]much like a princess[N]anymore.[WAI][N]Someone could tell me you[N]grew up on an island and[N]I'd believe them.[FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: You're awwwfulll![FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]W-what is that in the[N]water[AD]?[END]`
dc2F_adrift.dialogstring_05A723! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: They're just[N]circling round and round[N]the raft; they're not[N]coming to attack[AD][FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: Let's watch them[N]for a bit.[END]`
dc2F_adrift.dialogstring_05A6EA! `[BOR:7][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme1]Kara: Could they be[N]sharks…?[FIN][CLD][BOR:7][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme1]I wonder if we'll be[N]eaten… What should we do…?[N]Will…[END]`
dc2F_adrift.dialogstring_05A770! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: My butler used to[N]tell me that animals hunt[N]because they need to eat[AD][FIN]But people sometimes hurt[N]things even when they[N]don't need to.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: Then I guess we[N]haven't been acting much[N]like that.[FIN]We didn't eat any fish[N]until we had no other[N]choice.[FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Maybe so. Look,[N]they're leaving.[N]Farewell, dear sharks[AD][END]`
dc2F_adrift.dialogstring_059D33! `[DLG:8,7][SIZ:8,1]21st Day Adrift[END]`
dc2F_adrift.dialogstring_05A853! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: I want to tell you[N]something about myself.[WAI][N]At the castle, I used to[N]love watching the sunset.[WAI][N]It was always so beautiful[N]from the high windows. [PAU:18]But[N]now I've come to hate it.[WAI][N]When the sun disappears,[N]the dark feels endless.[WAI][N]I start wondering whether[N]I'll ever see morning[N]again.[WAI][N]But with you here, I keep[N]seeing another dawn.[WAI][N]Even something this hard[N]can feel a little less[N]frightening beside you.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Thought](I feel the same way...)[WAI][N][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Thought](Why can't I just tell[N]her?)[FIN][CLD][DEF]Will can only nod.[END]`
dc2F_adrift.dialogstring_05A9F9! `[DEF]Suddenly, Will's knees[N]give out. He collapses[N]unconscious[AD][FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Will[AD]! Will[AD]![N]What's wrong?![FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Hold on! Don't leave me[N]alone!![END]`
