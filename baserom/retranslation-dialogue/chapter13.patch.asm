; GaiaLabs Retranslation, chapter 13. Dialogue only.

?INCLUDE 'fr32_kara'
fr32_kara.dialogstring_05B100! `[CLD][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Wow, it's so[N]pretty[AD]![WAI][N]It really deserves to be[N]called the Capital of[N]Flowers.[WAI][N]I bet people who live[N]somewhere this beautiful[N]have beautiful hearts too[AD][END]`

?INCLUDE 'fr32_guide'
fr32_guide.dialogstring_05B225! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]Man: Well now, a pair of[N]young travelers.[WAI][N]Have you found a place to[N]stay tonight?[FIN][CLD][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Not yet. We're also[N]looking for our friends.[FIN][CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]Man: Then use my inn as[N]your base while you search[N]the city.[FIN][CLD][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Really? Thank you![N]I was starting to worry.[END]`

?INCLUDE 'fr32_kara'
fr32_kara.dialogstring_05B14B! `[CLD][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]Kara: You're fine with[N]this too, right, Will?[N]Come on, let's go![END]`
fr32_kara.dialogstring_05B16F! `[CLD][BOR:7][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1]Kara: That's what the[N]innkeeper said.[N]Come on, let's go in![END]`

?INCLUDE 'fr32_guide'
fr32_guide.dialogstring_05B2D3! `[BOR:A][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme20]Well, please, come in,[N]come in.[END]`

?INCLUDE 'fr39_lily'
fr39_lily.dialogstring_05C654! `[BOR:6][DLG:3,4][SIZ:D,1][PRT:@RetranslationTheme2]Lilly: Welco-[FIN]Will and Kara…?![END]`

?INCLUDE 'fr39_kara'
fr39_kara.dialogstring_05C4CD! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Lilly? Is that[N]really you?![FIN][CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: I was so worried![WAI][N]We've been separated for[N]nearly a month![WAI][N]I've been working here at[N]the inn while we waited.[FIN][::][CLD][BOR:6][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme2]Lance is in the room on[N]the right. Come with me.[END]`
fr39_kara.dialogstring_05C571! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: I'm glad we found[N]Lilly.[WAI][N]After all that time at[N]sea, I was starting to[N]think we never would.[END]`

?INCLUDE 'fr39_lance'
fr39_lance.dialogstring_05C7FA! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Lance: They tell me I[N]don't remember who I am.[WAI][N]If I don't even know that,[N]how am I supposed to know[N]why I'm here?[END]`

?INCLUDE 'fr39_lily'
fr39_lily.dialogstring_05C67C! `[CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: When the ship broke[N]apart, Lance made sure[N]Erik and I were safe.[FIN]He rigged up a sail and[N]rowed constantly.[FIN]I'd wake up and he'd still[N]be going. Whenever we[N]told him to rest, he'd say[N]he was fine.[FIN]Then, once we reached[N]shore, he collapsed.[WAI][N]He didn't wake up for an[N]entire week.[FIN]I stayed beside him every[N]day, wondering if he'd[N]ever open his eyes again.[FIN]When he finally did[AD] he[N]didn't know who I was.[FIN]He didn't even remember[N]his own name.[WAI][N]The doctor says his[N]memory should return.[FIN][::][CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]So I'm staying here until[N]it does.[END]`
fr39_lily.dialogstring_05C70B! `[CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: And that's not all.[N]I haven't seen any sign of[N]Erik since yesterday[N]evening.[WAI][N]I don't know what happened[N]to him[AD][END]`

?INCLUDE 'fr3B_tornado'
fr3B_tornado.dialogstring_05BC00! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]Don't worry. I may look[N]like this, but I haven't[N]been robbed.[WAI][N]What? You don't think I'd[N]choose to dress this badly[N]on purpose?[END]`

?INCLUDE 'fr32_locked_door'
fr32_locked_door.dialogstring_05CFFD! `[CLD][BOR:3][DLG:3,15][SIZ:D,2][PRT:@CastleV051Thought](It seems like this[N]house is locked[AD])[END]`

?INCLUDE 'fr32_guide'
fr32_guide.dialogstring_05B2DC! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]We haven't had many[N]travelers lately.[N]Business is terrible.[END]`

?INCLUDE 'fr38_ashamed'
fr38_ashamed.dialogstring_05BA62! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]Good grief[AD] When those two[N]upstairs carry on like[N]that, I start feeling[N]awfully lonely.[FIN]`

?INCLUDE 'f_inventory_full'

fr38_ashamed.code_05BA5D! {
    COP [PrintDialogString] ( &dialogstring_05BA62 )
    COP [BranchIfHasItem] ( #1C, &FreejiaGlassesAlreadyOwned )
    COP [PrintDialogString] ( &FreejiaGlassesOffer )
    COP [GiveItem] ( #1C, &freejia_glasses_inventory_full )
    COP [PrintDialogString] ( &FreejiaGlassesReceived )
    RTL
  freejia_glasses_inventory_full:
    JML $@f_inventory_full.InventoryFullMessage
}

FreejiaGlassesAlreadyOwned {
    COP [PrintDialogString] ( &FreejiaGlassesAdvice )
    RTL
}

FreejiaGlassesOffer `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]I got these sunglasses[N]so the couple upstairs[N]wouldn't catch me staring.[FIN]Then I started seeing[N]weird sparkles around[N]pots whenever I wore them.[FIN]Here, take them.[WAI][N]I don't want to be called[N]a peeping tom anyway.[END]`
FreejiaGlassesAdvice `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]Sunglasses won't make you[N]look cooler or make you[N]more popular with the[N]ladies.[FIN]They just make certain[N]things stand out more.[END]`
FreejiaGlassesReceived `[CLD][DEF]Will receives the Black[N]Crystal Glasses![END]`

?INCLUDE 'fr38_boyfriend'
fr38_boyfriend.dialogstring_05BB1C! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]M-my girlfriend was just[N]helping me get something[N]out of my eye[AD][N]Hahahahahahahaha.[END]`

?INCLUDE 'fr38_girlfriend'
fr38_girlfriend.dialogstring_05BAC2! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]I was just helping my[N]boyfriend get something[N]out of his eye.[N]Hohohohohohohoho.[END]`

?INCLUDE 'fr32_fragrance'
fr32_fragrance.dialogstring_05BA1D! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]Flowers have become the[N]symbol of Freejia.[WAI][N]The whole town smells[N]wonderful, doesn't it?[END]`

?INCLUDE 'fr37_caution'
fr37_caution.dialogstring_05BD10! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]Stay out of the back[N]streets, for your own sake.[WAI][N]Even the prettiest rose[N]has thorns.[END]`

?INCLUDE 'fr32_slap'
fr32_slap.dialogstring_05B59B! `[BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]That dive gave me[N]goosebumps! Here, take[N]this as a reward for the[N]show.[END]`
fr32_slap.dialogstring_05B60C! `[BOR:2][SEP:11,673F][SEP:12,24FF][PAL:4][BOR:2][DLG:8,9][SIZ:4,1][PAL:4]Thwack!![FIN][CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]You brat[AD]! Pull a[N]dangerous stunt like that[N]again and I'll make you[N]regret it[AD]!![END]`

?INCLUDE 'fr36_mother'
fr36_mother.dialogstring_05BB6F! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]When my children are late,[N]I worry they've been hurt[N]or someone's taken them.[FIN]I used to laugh when my[N]mother worried like that.[WAI][N]Now I do the same thing.[END]`

?INCLUDE 'fr32_kidnapper'
fr32_kidnapper.dialogstring_05B42E! `[BOR:A][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme20]Man's voice: If you value[N]your life, go home…!![END]`

?INCLUDE 'fr32_honest_life'
fr32_honest_life.dialogstring_05BE24! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]Whee[AD] *Hic*[AD] Live[N]seriously, or spend your[N]days drinking and[N]laughing[AD][WAI][N]Either way, you only get[N]one life, right?[END]`

?INCLUDE 'fr32_hp_jewel'
fr32_hp_jewel.dialogstring_05CFA7! `[DLG:3,15][SIZ:D,2]Will finds the HP Jewel![N]His maximum HP increases.[END]`

?INCLUDE 'fr32_slaver1'
fr32_slaver1.dialogstring_05B840! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]Damn it, where did he run[N]off to[AD][END]`

?INCLUDE 'fr32_slaver2'
fr32_slaver2.dialogstring_05B8CD! `[BOR:A][DLG:3,17][SIZ:D,1][PRT:@RetranslationTheme20]A slave escaped.[FIN][CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]You haven't noticed him[N]anywhere, have you?[N][PAL:0] Yes[N] No[PAL:4]`
fr32_slaver2.dialogstring_05B90C! `[CLR]Tell me where he's hiding,[N]and I might make it worth[N]your while. How does a[N]Red Jewel sound?[WAI][N][PAL:0] Inform him[N] Smile and lie[PAL:4]`
fr32_slaver2.dialogstring_05B8F1! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]Is that so.[N]If you see him, tell me.[END]`
fr32_slaver2.dialogstring_05B9AF! `[CLD][DLG:3,13][SIZ:D,3]But Will doesn't know[N]where the escaped slave[N]is hiding.[FIN][::][CLD][BOR:A][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme20]Man: Hey[AD] Little boy[AD][N]Don't make fun of adults![END]`

?INCLUDE 'fr32_alley_guard'
fr32_alley_guard.dialogstring_05B7CA! `[BOR:A][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme20]This isn't a place for[N]kids. Go home, go home.[END]`

?INCLUDE 'fr32_showman'
fr32_showman.dialogstring_05BDBE! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]I'm a fire performer, and[N]I'm the best at what I do.[N]Come on, take a look[AD]![END]`

?INCLUDE 'fr35_slave1'
fr35_slave1.dialogstring_05C38B! `[BOR:A][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme20]After this, we're going to[N]be taken from this place[N]to be sold…[END]`

?INCLUDE 'fr35_slave2'
fr35_slave2.dialogstring_05C3BB! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]I try not to let my mind[N]wander.[WAI][N]Whenever I do, all I can[N]think about is dying…[END]`

?INCLUDE 'fr35_slave3'
fr35_slave3.dialogstring_05C40E! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]I don't believe the[N]spirits are watching over[N]us.[WAI][N]If they were, how could[N]they let us suffer so?[END]`

?INCLUDE 'fr32_alley_guard'
fr32_alley_guard.dialogstring_05B7E6! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]You brat[AD]! How did you get[N]in here?! Alright, go[N]home, go home[AD]!![END]`

?INCLUDE 'fr32_hotel_hint'
fr32_hotel_hint.dialogstring_05B688! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]Girl: A boy who works at[N]the inn tried to help.[WAI][N]It sounds like a slave[N]merchant caught him.[END]`

?INCLUDE 'fr3A_harborer'
fr3A_harborer.dialogstring_05BC6F! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]I know I might lose my[N]life or freedom if we're[N]caught.[WAI][N]How could I live with[N]myself if I just ignored[N]it?[WAI][N]Please, don't turn us in.[N]Not for my sake, but for[N]his.[END]`

?INCLUDE 'fr3A_sympathetic'
fr3A_sympathetic.dialogstring_05C32F! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]I'm begging you! Please[N]overlook this[AD]!![WAI][N]Do whatever you want to[N]me, but leave this person[N]out of it[AD][END]`

?INCLUDE 'fr32_slaver2'
fr32_slaver2.dialogstring_05B94D! `[CLD][DLG:3,13][SIZ:D,3]Will tells them where the[N]escaped slave is hiding.[FIN][BOR:A][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme20]Man: Hey, thanks. Here's[N]your reward. Hang on to[N]it.[FIN][CLD][DLG:3,15][SIZ:D,2]Will receives a[N]Red Jewel.[END]`

?INCLUDE 'fr32_doomsday'
fr32_doomsday.dialogstring_05BE6B! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]"They say a great terror[N]will come from the sky,[N]and humanity will perish."[WAI][N]I don't know where that[N]prophecy started, but[N]I won't waste my life[N]fearing some story. *Hic*[END]`

?INCLUDE 'fr3C_man1'
fr3C_man1.dialogstring_05C23F! `[CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]Sometimes I look at them[N]and think, "What if that[N]were me?"[FIN]Then I get scared and tell[N]myself I have enough[N]problems of my own.[FIN]Maybe that's cowardly,[N]but it's the truth.[END]`

?INCLUDE 'fr3C_man2'
fr3C_man2.dialogstring_05C2BE! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]These slaves are about the[N]same age as you.[WAI][N]Don't forget what you're[N]seeing.[WAI][N]Kids your age are living[N]like this too.[END]`

?INCLUDE 'fr3C_slaver'
fr3C_slaver.dialogstring_05C190! `[BOR:A][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme20]Hey, boy! This isn't a[N]place for children.[N]Go home![FIN][CLD][BOR:A][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme20]Unless[AD] you came to buy[N]a slave too?[WAI][N][PAL:0] Yes[N] No[PAL:4]`
fr3C_slaver.dialogstring_05C1E2! `[CLR]I'm starting to like your[N]courage! I don't know if[N]you're really buying or[N]what, but take a look.[END]`
fr3C_slaver.dialogstring_05C21F! `[CLR]Well, go home, go home!![END]`

?INCLUDE 'fr3C_imas'
fr3C_imas.dialogstring_05BF04! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme5]I'm Imas. I was brought[N]here by ship from a far[N]continent.[WAI][N]My people are hunters. We[N]take only what we need to[N]survive.[WAI][N]But lately animals have[N]been dying from a disease[N]no one understands[AD][END]`

?INCLUDE 'fr3C_remus'
fr3C_remus.dialogstring_05BFDE! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme5]I'm Remus. Famine had[N]taken hold in our[N]homeland.[WAI][N]Rather than die, we drew[N]lots and sold half the[N]men into slavery to save[N]the rest.[WAI][N]My suffering saved my[N]sisters from starvation.[WAI][N]I will endure.[END]`
fr3C_remus.dialogstring_05C059! `[BOR:A][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme20]Why do people divide[N]each other into masters[N]and slaves[AD]?[END]`

?INCLUDE 'fr3C_sam'
fr3C_sam.dialogstring_05C094! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme5]I'm Sam.[WAI][N]A boy named Erik, who[N]works at the inn, tried to[N]save us last night.[WAI][N]But the slave merchants[N]found him and took him[N]away[AD][WAI][N]He's probably locked in[N]the house at the end of[N]the side street.[WAI][N]Please, save him somehow.[END]`

?INCLUDE 'fr32_creep'
fr32_creep.dialogstring_05B6E8! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]Ho ho ho. You understand[N]this place well, don't[N]you?[WAI][N]Sometimes what seems[N]unimportant turns out to[N]matter most.[WAI][N]That's how life is.[WAI][N]This is a bonus. Take it.[FIN][CLD][DEF]The old man stealthily[N]slips something into[N]Will's possessions![END]`
fr32_creep.dialogstring_05B78C! `[BOR:A][DLG:3,17][SIZ:D,1][PRT:@RetranslationTheme20]Ho ho ho…[END]`

?INCLUDE 'fr32_kidnapper'
fr32_kidnapper.dialogstring_05B45E! `[CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]Man's voice: If you value[N]your life, go home!![FIN][CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Will]Will: Isn't a boy named[N]Erik in there?[FIN][CLD][BOR:A][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme20]Man's voice: Never heard[N]of him. Got proof?[FIN][CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme3]Will? That's you, right?[N]Help m-[PAU:40][SFX:5][PAL:0] *Twhack*[FIN][CLD][BOR:2][DLG:3,11][SIZ:7,2][PRT:@RetranslationTheme20]Man's voice: [N]Quiet, brat![FIN][CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@CastleV051Thought](No choice. I'll break[N]down the door.)[END]`

?INCLUDE 'fr33_erik'
fr33_erik.dialogstring_05CDBC! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme3]Erik: That bully jumped[N]out the window the moment[N]you broke down the door.[WAI][N]I had no idea you were[N]that strong, Will![WAI][N]They caught me trying to[N]free some slaves. One of[N]them is a boy named Sam.[WAI][N]He's the same age as me![WAI][N]They're being forced to[N]work in a diamond mine in[N]the southeast.[WAI][N]Sam said it was dangerous,[N]and that almost every[N]week someone doesn't[N]make it out.[WAI][N]Please, Will, save them![FIN][CLD][DEF]Will learns the location[N]of the mine![END]`

?INCLUDE 'fr32_herb'
fr32_herb.dialogstring_05CF49! `[DEF]Will finds the herbs![END]`

fr32_herb.dialogstring_05CF5B! `[DEF]Will finds the herbs, but[N]your inventory is full![END]`
