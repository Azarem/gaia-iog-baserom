; GaiaLabs Retranslation, chapter 27. Dialogue only.

?INCLUDE 'eu91_intro'
eu91_intro.dialogstring_07BEDA! `[CLD][DEF][SFX:10][DLY:1]After crossing a desert[N]howling with sandstorms,[N]Will and the others[N]finally reached Euro.[PAU:60][CLR]It was the largest city[N]Will had ever seen.[PAU:30][CLR]Merchants and workers[N]hurried through every[N]street.[PAU:7C][CLR]Neil's parents ran the[N]Reuleck Corporation[N]from here.[PAU:60][CLR]When their son returned[N]after three years, they[N]welcomed the group like[N]royalty:[PAU:30][CLR]fireworks, dancers,[N]music[AD][PAU:60][CLR]For a moment, the whole[N]city felt like a festival.[PAU:60][CLD]`
eu91_intro.dialogstring_07C011! `[DEF]This is the mansion where[N]Neil's parents live.[FIN][CLD][DEF]Neil leads the others to[N]a guest room.[END]`

?INCLUDE 'eu96_neil'
; In the first guest-room scene, the flute speaks after Neil walks out.
eu96_neil.eu96_neil! [
  actor-def < #13, #00, #10, {

  EuroGuestRoomNeilStart:
    COP [BranchOnFlagByte] ( #AC, #01, &code_07DB5D )
    COP [BranchOnFlagByte] ( #AB, #01, &code_07DBD2 )
    COP [BranchOnFlagByte] ( #AA, #01, &code_07DB5F )
    COP [BranchOnFlagByte] ( #A4, #01, &code_07DB5D )
    COP [SetFlagByte] ( #A4 )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07DBE9 )
    COP [StageSpriteLoopMoveY] ( #16, #02, #01 )
    COP [AnimLoop]
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &EuroGuestRoomFluteDialogue )
    LDA #$CFFC
    TRB $joypadMaskStd
} >
]

EuroGuestRoomFluteDialogue `[CLD][DEF]A few minutes later, a[N]familiar voice comes[N]from Will's flute.[FIN][CLD][BOR:4][DLG:3,4][SIZ:D,4][PRT:@CastleV051Flute]Flute: Will[AD] Something in[N]this city is hidden[N]behind familiar faces.[FIN]I cannot see it clearly[N]from where I am.[FIN]Long ago, I heard of a[N]vessel kept at the[N]sanctuary on Mount Kehres.[FIN]It is called the Tearpot.[N]They say its waters[N]reveal what ordinary[N]sight cannot.[FIN]Find it. Then look again.[FIN][CLD][DEF]The voice fades from[N]the flute.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]Erik: Will! You weren't[N]lying! I mean, I didn't[N]think you were a liar.[FIN]I just thought maybe[N]you'd gone a little crazy.[N]You do talk to yourself[N]a lot.[FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Erik![AD]Will, that[N]really was your father?[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: Yeah. That's the[N]voice I've been hearing.[END]`

eu96_neil.dialogstring_07DBE9! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme6]Neil: Make yourselves at[N]home. I'm going to talk[N]to my parents for a while.[FIN]It has been three years,[N]after all.[END]`

?INCLUDE 'eu96_erik'
eu96_erik.dialogstring_07DAC1! `[BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]Erik: This house is so[N]huge, I wonder what I'll[N]do if I want to go pee at[N]night…[END]`

?INCLUDE 'eu96_kara'
eu96_kara.dialogstring_07DA00! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: It's an amaaazing[N]house, isn't it[AD]?[WAI][N]I suppose some merchants[N]are richer than kings[N]these days[AD][END]`

?INCLUDE 'eu95_ann'
eu95_ann.dialogstring_07DF7A! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Ann: A man in a dark blue[N]mantle came here a few[N]days ago.[FIN]He asked whether a girl[N]named Kara had come to[N]the city.[FIN]The way he stared at me[N]with those cold eyes[AD] I[N]was terrified.[FIN]Maybe I should tell Kara,[N]but[AD][N][PAL:0] Tell her if you want.[N] Please don't tell her.[PAL:4]`
eu95_ann.dialogstring_07E03D! `[CLR]I can't stand the way[N]Kara acts like such a[N]proper little lady.[FIN]Maybe I'll tease her a[N]little instead.[END]`
eu95_ann.dialogstring_07E092! `[CLR]Hehehe. Now I know your[N]weak point.[FIN][::]Aah. I suddenly want an[N]apple. Go buy one from[N]the market for me![END]`
eu95_ann.dialogstring_07E0DE! `[BOR:D][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme1][JMP:&dialogstring_07E092+M]`

?INCLUDE 'eu95_neils_mother'
eu95_neils_mother.dialogstring_07E31B! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1E]Neil's mother: We've[N]already made more money[N]than we could ever spend.[WAI][N]We'd like to enjoy the[N]rest of our lives now.[WAI][N]Neil, won't you come home[N]and take over the company?[END]`

?INCLUDE 'eu95_neil'
eu95_neil.dialogstring_07E3B5! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme6]Neil: I spent three years[N]trying to build a life[N]that was mine.[FIN]But Reuleck is mine too,[N]whether I like it or not.[N]The question is what I[N]do with it.[END]`

?INCLUDE 'eu91_men2'
eu91_men2.dialogstring_07C9DB! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]Neil's parents, who run[N]the Reuleck Corporation,[N]live here.[END]`
eu91_men2.dialogstring_07C970! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]A man named Jackal,[N]or something like that,[N]showed up a few days ago.[WAI][N]He went around asking all[N]kinds of questions.[WAI][N]One look at his eyes and[N]I knew he was dangerous.[N]Maybe an assassin.[WAI][N]No idea who he's after,[N]though.[END]`

?INCLUDE 'eu91_women2'
eu91_women2.dialogstring_07CAB0! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]Euro is full of narrow[N]back alleys.[WAI][N]You can even squeeze[N]through gaps between the[N]houses.[END]`

?INCLUDE 'eu91_book'
eu91_book.dialogstring_07E4D3! `[BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]It's a book by a person[N]named Rofski. It holds[N]predictions about the[N]future of humanity.[END]`

?INCLUDE 'eu91_merchant'
eu91_merchant.dialogstring_07C337! `[BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]Hey, hey, you mustn't come[N]on this side. Customers[N]should go to the[N]opposite side…![END]`
eu91_merchant.dialogstring_07C38F! `[BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]Hey, hey, you mustn't come[N]on this side. Customers[N]should go to the[N]opposite side…![END]`

?INCLUDE 'eu91_merchant_counter'
eu91_merchant_counter.dialogstring_07C1DC! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]This is a Tearpot--a pot[N]made to hold tears.[WAI][N]Long ago, this town was[N]caught up in a war.[WAI][N]They say women collected[N]their tears in these pots[N]while waiting for their[N]husbands to come home.[END]`

?INCLUDE 'eu91_women1'
eu91_women1.dialogstring_07C836! `[BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]Do you believe in[N]fortune-telling?[N][PAL:0] Yes[N] No[PAL:4]`
eu91_women1.dialogstring_07C860! `[CLR]So you do want your[N]future told?[FIN]Some prophecies speak of[N]a huge comet passing[N]close to Earth and[N]countless people dying.[FIN]Maybe that's why I'd[N]rather not know my future.[FIN]I'd spend the whole time[N]eating from nerves![END]`
eu91_women1.dialogstring_07C8D5! `[CLR]Maybe that's for the best.[N]Me, I'll believe almost[N]anything[AD][END]`

?INCLUDE 'eu91_merchant_counter'
eu91_merchant_counter.dialogstring_07C182! `[BOR:D][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1E]This is a fish market. We[N]sell fish that's arrived[N]fresh from Watermia.[END]`

?INCLUDE 'eu91_merchant'
eu91_merchant.dialogstring_07C3D4! `[BOR:D][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1E]I can't do business when[N]the customer is on my[N]side of the counter.[END]`

?INCLUDE 'eu91_merchant_counter'
eu91_merchant_counter.dialogstring_07C1B6! `[BOR:D][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1E]This is cornmeal. You can[N]use it when making[N]cornbread.[END]`
eu91_merchant_counter.dialogstring_07C160! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]This is wine. You're a bit[N]young for that, aren't[N]you?[END]`

?INCLUDE 'eu91_women2'
eu91_women2.dialogstring_07CB60! `[DEF]I saw that. There are[N]many people confined[N]under the school.[END]`
eu91_women2.dialogstring_07CAE0! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]I saw[AD] A lot of people[N]imprisoned in the basement[N]of the shrine[AD][END]`

?INCLUDE 'eu91_men1'
eu91_men1.dialogstring_07C509! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]This town flourishes[N]thanks to the Reuleck[N]Corporation.[WAI][N]There are plenty of bad[N]rumors about them too, but[N]I still think the company[N]is amazing.[END]`

?INCLUDE 'eu91_merchant_counter'
eu91_merchant_counter.dialogstring_07C0F3! `[BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]You're looking at me like[N]you want something[AD][FIN]Alright, alright. Take[N]one of these apples.[FIN]Will receives an apple![END]`
eu91_merchant_counter.dialogstring_07C0DD! `[BOR:D][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme1E]How about a sweet and[N]delicious apple?[END]`

?INCLUDE 'item_use_system'
item_use_system.dialogstring_039F6B! `[DLG:3,F][SIZ:D,5]You felt a tiny bit[N]relaxed when you filled[N]your mouth with the bright[N]red apple. It was a[N]tasty apple.[END]`

?INCLUDE 'eu91_women1'
eu91_women1.dialogstring_07C8EC! `[BOR:D][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1E]They say that there are[N]people in this town who[N]make it powerful.[END]`

?INCLUDE 'eu91_merchant_counter'
eu91_merchant_counter.dialogstring_07C142! `[BOR:D][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme1E]Our fruits are soft and[N]yummy.[END]`

?INCLUDE 'eu91_men1'
eu91_men1.dialogstring_07C4D0! `[BOR:D][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1E]This is the market. You[N]might discover rare goods[N]here.[END]`
eu91_men1.dialogstring_07C5AB! `[BOR:D][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme1E]This is an office of the[N]Reuleck Corporation.[FIN][CLD][BOR:D][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1E]Most of the goods being[N]sold in this town are[N]stocked by that company.[END]`

?INCLUDE 'eu94_employee'
eu94_employee.dialogstring_07CF75! `[DEF][SFX:0]Two men are discussing[N]business[AD][FIN][CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1E]Man: I hear Reuleck trades[N]in almost anything.[FIN][CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Company man: Tea, fruit,[N]animal hides[AD] you name it.[WAI][N]Off the books, labor too.[N]Men, women, children.[WAI][N]If someone has a price,[N]someone will pay it.[END]`

?INCLUDE 'eu91_men1'
eu91_men1.dialogstring_07C60A! `[BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1E]Man: Nahhh, if this[N]company deals with[N]everything, they've really[N]saved me.[END]`

?INCLUDE 'eu94_employee'
eu94_employee.dialogstring_07CF1F! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Company worker: U-umm[AD][N]What's with this kid[AD]?[WAI][N]The adults are discussing[N]business. Go play outside[N]or something![END]`

?INCLUDE 'eu91_women2'
eu91_women2.dialogstring_07CB09! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1E]See all that baggage piled[N]beside the company?[WAI][N]Sometimes, while they're[N]moving it, you can hear[N]groaning from inside.[WAI][N]I've got a bad feeling[N]about it[AD][END]`

?INCLUDE 'eu9A_max'
eu9A_max.dialogstring_07E6AD! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1E]Max: I'm excited to join[N]another expedition[AD][WAI][N]But I'm worried because[N]our leader is so[N]temperamental. Ugh[AD][END]`

?INCLUDE 'eu9A_friezer'
eu9A_friezer.dialogstring_07E61D! `[BOR:D][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme1E]Friesel: I am Friesel,[N]the explorer.[FIN][CLD][BOR:D][DLG:3,4][SIZ:D,5][PRT:@RetranslationTheme1E]I want history to remember[N]my name, just like when[N]the now-famous Olman[N]discovered the Tower of[N]Babel.[END]`

?INCLUDE 'eu9A_rudy'
eu9A_rudy.dialogstring_07E72A! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1E]Rudy: The truth is, there[N]are still so many[N]unanswered questions about[N]the ruins.[WAI][N]That's why we've set our[N]hearts on going out on a[N]great journey.[END]`

?INCLUDE 'eu91_men1'
eu91_men1.dialogstring_07C6FE! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1E]If I remember right, you[N]can find mushroom droplets[N]all over Mount Kehres[AD][WAI][N]Ah, listen to me ramble.[END]`
eu91_men1.dialogstring_07C63F! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1E]I went to Mount Kehres[N]with my brother when I[N]was little.[FIN]We wandered deep into the[N]grounds and got lost.[FIN]I remember giant mushrooms[N]and plant stalks growing[N]like a maze.[FIN]Pour mushroom droplets on[N]the tip of a stalk and[N]it will spring to life,[N]forming a path.[FIN]Funny how clearly I still[N]remember it.[END]`
eu91_men1.dialogstring_07C4AA! `[BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]The residential area is[N]ahead of here. You can't[N]enter unless you're a[N]townsperson.[END]`

?INCLUDE 'eu91_women1'
eu91_women1.dialogstring_07C7BA! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]The famous writer Rofski[N]and violinist Elazquez[N]live in this house.[WAI][N]They're always arguing.[N]Geniuses can be hard to[N]please, huh?[END]`

?INCLUDE 'eu91_men1'
eu91_men1.dialogstring_07C480! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]This is Euro. Most of the[N]people here are merchants.[END]`

?INCLUDE 'wa79_lily'
wa79_lily.dialogstring_07AAA3! `[CLD][BOR:6][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme2]Lilly: There's a rumor[N]going around that a big[N]star[FIN][CLD][BOR:6][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme2]is going to collide[N]with the Earth or[N]something like that.[FIN][CLD][BOR:6][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme2]I'm definitely not going[N]to believe gossip like[N]that.[END]`

?INCLUDE 'wa79_lance'
wa79_lance.dialogstring_07AEDE! `[BOR:3][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme4]Lance: It seems like my[N]old man is gettin' better[N]day by day…[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]It seems like he's able ta[N]talk normally now.[FIN]I think it would be nice[N]if ya could also meet yer[N]old man soon.[FIN]Oh, that's right. If I[N]remember, I think ya were[N]collectin' Red Jewels.[FIN][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]I found a Red Jewel from[N]inside my old man's[N]possessions. Take it[N]along.[FIN][CLD][DLG:3,4][SIZ:D,1]Will received a Red Jewel![END]`
wa79_lance.dialogstring_07AFA7! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Lance: It'd be nice if[N]ya could meet your old man[N]soon too.[END]`

?INCLUDE 'wa7A_lances_father'
wa7A_lances_father.dialogstring_07B412! `[BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]Lance's father: Oh…[N]Will, isn't it? I'm sorry;[N]I guess I must have[N]worried you.[FIN]Lance and Lilly really did[N]all they could to nurse me[N]back to health…[FIN]I used to think that I[N]didn't want a child to[N]dominate my life.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,5][PRT:@RetranslationTheme3]But now that things have[N]turned out like this, I[N]can see that it's nice to[N]have a child that's loyal[N]to you.[END]`

?INCLUDE 'eu91_men2'
eu91_men2.dialogstring_07C9FF! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]Reuleck changed this town[N]almost beyond recognition.[WAI][N]Euro became a world center[N]of trade as the company[N]grew.[WAI][N]Growth that fast always[N]casts a shadow somewhere.[END]`

?INCLUDE 'eu91_shop_queue'
eu91_shop_queue.dialogstring_07D3CF! `[BOR:D][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme1E]Wonderful things are being[N]sold in this store.[END]`

?INCLUDE 'eu97_clerk1'
eu97_clerk1.dialogstring_07CC0A! `[BOR:D][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme1E]Employee: Dear customer…![N]This is the exit. Please[N]head to the entrance![END]`

?INCLUDE 'eu91_shop_queue'
eu91_shop_queue.dialogstring_07D423! `[BOR:D][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1E]How many times have I[N]lined up for things like[N]this already?[END]`
eu91_shop_queue.dialogstring_07D43E! `[BOR:D][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1E]There's a lot of joy to be[N]found through hardship,[N]isn't there?[END]`
eu91_shop_queue.dialogstring_07D3F6! `[BOR:D][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1E]Humanity is seeing a queue[N]and wanting to join it for[N]some reason, right?[END]`
eu91_shop_queue.dialogstring_07D479! `[BOR:D][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1E]Humanity is seeing a queue[N]and wanting to join it for[N]some reason, right?[END]`
eu91_shop_queue.dialogstring_07D4A9! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]They're selling something[N]called the Medicine of[N]Life.[WAI][N]I don't know if it works.[N]Still[AD] who doesn't wish[N]for a little more time?[END]`

?INCLUDE 'eu97_clerk2'
eu97_clerk2.dialogstring_07CC88! `[CLD][BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1E]Employee: You came to Euro[N]with Master Neil, didn't[N]you?[WAI][N]The Reuleck Corporation[N]owns this store too.[WAI][N]Please, take anything you[N]like. It's our pleasure.[END]`

?INCLUDE 'eu97_clerk1'
eu97_clerk1.dialogstring_07CBE3! `[BOR:D][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme1E]Employee: Are you[N]returning home? Thank you[N]very much.[END]`

?INCLUDE 'eu97_dark_medicine'
eu97_dark_medicine.dialogstring_07CE28! `[BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]That is called the[N]Medicine of Darkness.[N]Will you drink it?[WAI][N][PAL:0] Yes[N] No[PAL:4]`
eu97_dark_medicine.dialogstring_07CEDD! `[CLR]Is that so…[N]Do you not like it?[END]`
eu97_dark_medicine.dialogstring_07CE54! `[CLR][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme0]It had a scent that[N]irritated your nose…[FIN]However, it seems that[N]Freedan's Power of[N]Darkness grew stronger.[FIN][CLD][DLG:3,17][SIZ:D,1]Dark Flare's power rose!![END]`
eu97_dark_medicine.dialogstring_07CEB6! `[CLR]However, it seems that[N]Dark Flare's power is[N]strong enough...[END]`

?INCLUDE 'eu97_life_medicine'
eu97_life_medicine.dialogstring_07CD39! `[BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]That is the Medicine of[N]Life. Will you drink it?[N][PAL:0] Yes[N] No[PAL:4]`
eu97_life_medicine.dialogstring_07CD9B! `[CLR]Is that so…[N]Do you not like it?[END]`
eu97_life_medicine.dialogstring_07CD64! `[CLR][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme0]The taste burns Will's[N]mouth[AD] But his endurance[N]rises!![END]`
eu97_life_medicine.dialogstring_07CDB3! `[BOR:D][DLG:3,15][SIZ:D,2][PRT:@RetranslationTheme1E]I'm sorry… There is a[N]limit of one per person.[END]`

?INCLUDE 'eu91_men1'
eu91_men1.dialogstring_07C56C! `[CLD][BOR:D][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1E]This is the shrine.[WAI][N]The Reuleck presidents are[N]deeply devout, so they[N]visit often.[END]`

?INCLUDE 'eu9D_altar'
eu9D_altar.dialogstring_07E5BE! `[BOR:3][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme0]Will: Oh? It seems that[N]wind is blowing in from[N]behind the Madonna…[FIN]Try examining it?[N][PAL:0] Yes[N] No`

?INCLUDE 'eu9D_slaves'
eu9D_slaves.dialogstring_07D207! `[BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme16]I understand a little of[N]your language. We were[N]brought here from a[N]distant place…[END]`
eu9D_slaves.dialogstring_07D1D3! `[BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme16]We are forced to learn the[N]language here, and then[N]are sold off to separate[N]places…[END]`
eu9D_slaves.dialogstring_07D196! `[BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme16]The bones scattered over[N]there were our companions…[N]If we don't obey an order,[N]that's how it ends for us.[END]`
eu9D_slaves.dialogstring_07D167! `[BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme16]I want to talk in the[N]language of my motherland…[N]But I'll be beaten if I do[N]that…[END]`
eu9D_slaves.dialogstring_07D0DC! `[CLD][BOR:3][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme16]Strange diseases have been[N]spreading through our[N]homeland.[WAI][N]One illness even turns the[N]body to stone.[WAI][N]I fled hoping to survive[AD][N]only to end up sold as a[N]slave here.[END]`

?INCLUDE 'eu92_rofsky'
eu92_rofsky.dialogstring_07D6C2! `[DLG:3,4][SIZ:D,2][SFX:10]Two elderly people are[N]arguing about something…[WAI][CLD][PAU:1E][BOR:3][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme3]Rofski: What sort of[N]genius violinist are you?[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme3]You're at your best when[N]you take your bow and get[N]off the stage!![FIN][BOR:3][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme4]Elazquez: Hmph! I guess[N]two-bit writers always[N]talk big…!![END]`
eu92_rofsky.dialogstring_07D61E! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme3]Rofski: We were arguing[N]about the Tearpot kept at[N]the sanctuary on Mount[N]Kehres.[WAI][N]Old legends claim it holds[N]tears once shed by the[N]spirits.[WAI][N]They say those tears will[N]reveal truth when humanity[N]needs it most.[END]`

?INCLUDE 'eu92_erasquez'
eu92_erasquez.dialogstring_07D7C7! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Elazquez: You there[AD] I[N]sense a strange power[N]around you.[FIN]Though I am blind, I've[N]learned to notice what my[N]eyes once hid.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: We're looking for[N]something called the[N]Tearpot.[FIN][CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Elazquez: The Tearpot[AD]?[N]Rofski and I were just[N]arguing over whether it[N]was more than a legend.[FIN][CLD][DEF][SFX:10]Rofski marks Mount Kehres[N]on Will's map.[END]`
eu92_erasquez.dialogstring_07D892! `[BOR:3][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme4]Elazquez: It's said that[N]the tears of the gods in[N]the Tearpot can reflect[N]the true form of things.[END]`

?INCLUDE 'eu95_ann'
eu95_ann.dialogstring_07E0E5! `[BOR:7][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme1]Ann: Thank you. I think I[N]still want to eat one.[END]`
eu95_ann.dialogstring_07E10A! `[BOR:D][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Ann: Why do you keep going[N]back and forth to the[N]market like this, bringing[N]apples for me as many[FIN][N]times as I ask…?[FIN]Is it for that Kara[N]girl…? Or…?[FIN]Well, that's alright. As[N]thanks, I'll give you this[N]jewel.[FIN][CLD][SFX:10][DLG:3,4][SIZ:D,1][SFX:10]Will got a Red Jewel![END]`
eu95_ann.dialogstring_07E19D! `[BOR:7][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme1]Ann: Take good care of[N]Kara, alright…?[END]`

?INCLUDE 'eu93_found'
eu93_found.dialogstring_07E531! `[DEF]You found it here. I[N]understand your wishes.[N]I'll give you the power[N]at once.[END]`
eu93_found.dialogstring_07E566! `[DEF]Well, go.[END]`
