; GaiaLabs Retranslation, chapter 08. Dialogue only.

?INCLUDE 'it1A_lily'
it1A_lily.dialogstring_04F53C! `[CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: Alright, we're[N]here. This is where the[N]Moon Tribe lives.[END]`
it1A_lily.dialogstring_04F7C1! `[CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: Wait a second.[N]We're already here.[WAI][N]Let's at least find the[N]Incan idol before we turn[N]back.[END]`
it1A_lily.dialogstring_04F7F7! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Thought](I can't go back without[N]the Incan Statue[AD])[END]`
it1A_lily.dialogstring_04F860! `[CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: Let's talk to the Moon[N]Tribe before we go poking[N]around.[END]`

?INCLUDE 'it1A_moon_tribe'
; The missing-companion conversation plays as a single exchange. The old
; Yes, No and cancel callbacks all displayed the same follow-up.
it1A_moon_tribe.code_09D1DD! {
    COP [PrintDialogString] ( &dialogstring_09D462 )
    RTL
}

it1A_moon_tribe.dialogstring_09D1FC! `[BOR:8][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1A]Mysterious voice: Gooood[N]evening, gooood evening…[N]Goooing on a stroll?[FIN][BOR:3][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme0]Will: Who's there?![FIN][BOR:8][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme1A]Mysterious voice: Above,[N]above. This body is[N]lighter than air.[FIN][BOR:3][DLG:3,13][SIZ:D,3][PRT:@RetranslationTheme0]Will: What are you?![FIN][CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Mysterious voice:[N]Try to guess.[WAI][N] Cotton candy's relative[N] Bird-human[N] Soul of a dead person…`
it1A_moon_tribe.dialogstring_09D2D0! `[CLR]Mysterious voice:[N]Bzzzzzzzzzt[AD] Wrong[AD][WAI][N]The truth is, we are the[N]Moon Tribe. Also known as[N]the Shadows.[END]`
it1A_moon_tribe.dialogstring_09D388! `[CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: To us, the[N]comet is a destroyer.[WAI][N]Its light changes every[N]living thing it touches.[WAI][N]Our oldest tales call it[N]the remnant of a terrible[N]war from the distant past.[WAI][N]But not every culture[N]feared that light.[WAI][N]Some called the same light[N]holy. Some called it[N]salvation.[WAI][N]We remember what it did[N]to us.[END]`
it1A_moon_tribe.dialogstring_09D30F! `[CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: Wherever[N]there is light, a shadow[N]follows.[WAI][N]Long ago, the comet's[N]light washed over us[N]completely.[WAI][N]Our bodies changed until[N]we became these shadows,[N]untouched by age.[WAI][N]We gained an eternity[N]beyond ordinary life.[WAI][N]Do not assume eternity[N]and mercy are the same.[END]`
it1A_moon_tribe.dialogstring_09D462! `[CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: One of our[N]kind was taken away.[WAI][N]We wonder where they were[N]taken[AD][FIN]Perhaps you'll cross[N]paths with them before[N]we do.[N]Mweheheheheh[AD][END]`
it1A_moon_tribe.dialogstring_09D4AD! `[CLR][PAL:4]Moon Tribe: We may come[N]chase you later.[N]Mweheheheheheheh[AD][END]`
it1A_moon_tribe.dialogstring_09D4DC! `[CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: The comet[N]returns every eight hundred[N]years. This is its fourth[N]approach.[WAI][N]Each return stirs the[N]Power of Darkness more[N]strongly in answer.[WAI][N]What will be born from the[N]light this time[AD]?[END]`
it1A_moon_tribe.dialogstring_09D574! `[CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: We have lived[N]beyond the measure of[N]time.[FIN]With these eyes, we[N]watched the Incan kingdom[N]rise and fall.[FIN]The Incan idol rests in[N]the cave beneath us.[FIN]We have taken a liking to[N]you.[WAI][N]So we'll give you a chance[N]to claim the Incan idol.[FIN]If you can earn it.[N]Mweheheheheh[AD][END]`

?INCLUDE 'it1A_lily'
it1A_lily.dialogstring_04F575! `[BOR:6][DLG:3,4][SIZ:D,2][PRT:@RetranslationTheme2]Lilly: Well, I'll be[N]waiting here, alright?[END]`

?INCLUDE 'it1B_trial'
it1B_trial.dialogstring_04F941! `[CLD][BOR:8][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: The creatures[N]here were changed by the[N]comet's light.[FIN]Some lost their old forms.[WAI][N]Some lost even memory and[N]reason, leaving only rage.[FIN]Defeat them within 20[N]seconds and the Incan[N]idol is yours.[N]Mweheheheheheheh[AD][END]`
it1B_trial.dialogstring_04FA25! `[CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: At that pace,[N]we can't give you the[N]Incan idol, can we?[N]Mweheheheheheheh[AD][END]`
it1B_trial.dialogstring_04FA65! `[CLD][BOR:8][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme1A]Moon Tribe: Oh my, what a[N]splendid boy.[N]Mweheheheheheheh[AD][FIN]With that, we'll give you[N]the Incan idol.[END]`

?INCLUDE 'it1A_lily'
it1A_lily.dialogstring_04F591! `[CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: How did it go?[WAI][N][AD]That face says it didn't[N]go well, huh?[WAI][N]Don't give up. Try again.[END]`
it1A_lily.dialogstring_04F5EA! `[CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: Ah, that's it[AD]![N]Will, you really found[N]one![FIN]That makes two statues,[N]right?[FIN]Do you plan to go to the[N]Incan ruins?[N][PAL:0] Yes[N] No[PAL:4]`
it1A_lily.dialogstring_04F68F! `[CLD][BOR:3][DLG:3,4][SIZ:D,4][PRT:@CastleV051Will]Will: Yeah. Dad told me[N]to go there.[WAI][N]I'm scared of what the[N]comet's light has done to[N]the monsters.[WAI][N]But if Dad is alive, I[N]have to keep going until I[N]find him.[WAI][N]And after everything we've[N]heard, I need to know[N]what's really happening.[FIN][CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: I understand.[N]Then let's go to the[N]ruins.[FIN][CLD][DEF]The two head for the[N]Incan ruins.[END]`
it1A_lily.dialogstring_04F653! `[CLR]Lilly: That's a lie. I[N]know you, Will. Whatever[N]you say now, you're going[N]eventually, aren't you?[FIN]`

?INCLUDE 'it1B_inca_statue_b'
it1B_inca_statue_b.dialogstring_04FAF9! `[DLG:3,15][SIZ:D,2][SFX:0][DLY:9]Will finds[N]Incan Statue B![PAU:A0][CLD]`
it1B_inca_statue_b.dialogstring_04FB16! `[DLG:3,13][SIZ:D,3]Will finds[N]Incan Statue B! But your [N]inventory is full![END]`

?INCLUDE 'ir1C_lily'
ir1C_lily.dialogstring_09CAE5! `[CLD][BOR:6][DLG:3,11][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: This is the[N]entrance to the Incan[N]ruins.[WAI][N]The Inca once ruled a vast[N]land. Their oldest mystery[N]is supposed to be hidden[N]here.[WAI][N]The Elder told me that[N]when invaders came, the[N]Inca prepared to abandon[N]their homeland.[WAI][N]They built a giant ship[N]covered in their finest[N]goldwork and planned to[N]seek a new land.[WAI][N]But no surviving record[N]describes that ship ever[N]leaving.[WAI][N]The legend says it still[N]waits somewhere beneath[N]these ruins.[WAI][N]The Elder doesn't usually[N]involve outsiders in[N]things like this.[WAI][N]He must trust you, Will.[END]`

?INCLUDE 'ir1C_kara'
ir1C_kara.dialogstring_09CF19! `[BOR:7][DLG:3,4][SIZ:D,3][PRT:@RetranslationTheme1]Kara: You two are awful,[N]leaving me behind like[N]that![END]`

?INCLUDE 'ir1C_lily'
ir1C_lily.dialogstring_09CCD0! `[CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: Why are YOU in a[N]place like this[AD]!?[N]Isn't it dangerous!?[FIN][CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: I heard about this[N]place from Mrs. Lola and[N]waited for hours![WAI][N]I thought you'd already[N]gone inside without me.[WAI][N]At least she told me where[N]you were going.[WAI][N]Will, you're searching for[N]something in there, right?[WAI][N]If you're risking[N]yourself, I'm not going to[N]sit in the village eating[N]supper.[WAI][N]I'll wait here until you[N]come back.[FIN][CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: Good grief. Fine.[N]I'll wait with you.[END]`
ir1C_lily.dialogstring_09CE01! `[CLD][BOR:6][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme2]Lilly: Will, remember the[N]Elder's words.[FIN]"At the Cliff of Larai,[N]beneath the ruins,[FIN]offer the Incan idols[N]where the breath of the[N]spirits cannot reach.[FIN]The valley wind shall[N]guide you to the golden[N]ship."[WAI][N]You remember that, right?[END]`

?INCLUDE 'ir1C_kara'
ir1C_kara.dialogstring_09CF59! `[CLD][BOR:7][DLG:3,4][SIZ:D,4][PRT:@RetranslationTheme1]Kara: Any luck? Did you[N]find what you're looking[N]for? Don't give up![END]`
