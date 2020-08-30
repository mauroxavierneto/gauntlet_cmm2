'---- INITIALIZE TEXT ----


'-- COPYRIGHT NOTICE --
If test=0 and copyright=1 Then
 t=0
 t=t+1:crd$(t)="\3"
 t=t+1:crd$(t)="COPYRIGHT NOTICE"
 t=t+1:crd$(t)=""
 t=t+1:crd$(t)="\2"
 t=t+1:crd$(t)="ALL MATERIALS BASED"
 t=t+1:crd$(t)="OR DIRECTLY USED"
 t=t+1:crd$(t)="BELONGS TO YOUR"
 t=t+1:crd$(t)="RESPECTIVE OWNERS"
 t=t+1:crd$(t)="AND WE HAVE NO RIGHTS"
 t=t+1:crd$(t)="ABOUT THEM"
 t=t+1:crd$(t)=""
 t=t+1:crd$(t)=""
 t=t+1:crd$(t)="GAUNTLET IS A"
 t=t+1:crd$(t)="TRADEMARK OF"
 t=t+1:crd$(t)="\0"
 t=t+1:crd$(t)="ATARI GAMES CORP."
 t=t+1:crd$(t)=""
 t=t+1:crd$(t)="MIDWAY GAMES WEST INC"
 t=t+1:crd$(t)=""
 t=t+1:crd$(t)="WARNER BROS"
 t=t+1:crd$(t)="ENTERTAINMENT INC"
 t=t+1:crd$(t)="\2"
 t=t+1:crd$(t)=""
 t=t+1:crd$(t)="THIS VERSION OF THE" 
 t=t+1:crd$(t)="GAME WAS DEVELOPED"
 t=t+1:crd$(t)="WITHOUT ANY"
 t=t+1:crd$(t)="PROFIT INTENTION"
 t=t+1:crd$(t)=""
 t=t+1:crd$(t)=""
 t=t+1:crd$(t)="THIS IS ONLY A"
 t=t+1:crd$(t)="TRIBUTE TO A"
 t=t+1:crd$(t)="BELOVED GAME"
 for i=1 to 15 
  t=t+1:crd$(t)=""
 next i
 ttt=t

 nocop=0
 MODE 2,16
 'Load BMP ".\IMAGES\gcopy1.bmp": t=0
 'Do While t<500 And KeyDown(1)<>K_ESC And KeyDown(1)<>K_SPC: t=t+1: Pause(1): Loop
 PAGE WRITE 1: CLS: Load PNG ".\IMAGES\COPYRIGHT.png"
 PAGE WRITE 6: CLS: LOAD PNG ".\fonts\big_fonts.png",,,1
 PAGE WRITE 3: CLS
 PAGE WRITE 0
 Play MODFile ".\MOD\echobeat.mod", 22050
 PAUSE(2000)
 tt=0
 for t=0 to 320 step 0.5
  tt=tt+0.32: if tt>200 then tt=200
  BLIT MM.HRES\2-t,MM.VRES\2-tt,MM.HRES\2-t,MM.VRES\2-tt,t*2,tt*2,1,0
  if keydown(1)=K_SPC or keydown(1)=K_ESC then nocop=1: exit for
 next t

 'PAGE WRITE 1: Load PNG ".\IMAGES\COPYRIGHT_DIM.png"
 tt=0: PAGE WRITE 0
 'for t=0 to 320 step 0.5
 ' tt=tt+0.32: if tt>200 then tt=200
 ' BLIT MM.HRES\2-t,MM.VRES\2-tt,MM.HRES\2-t,MM.VRES\2-tt,t*2,tt*2,1,0
 'next t
 PAGE COPY 0 TO 2,I
 COLOR rgb(255,255,0)
 PAGE COPY 2 TO 4,I
 PAGE WRITE 4: CLS

 go=nocop:ii=2
 for t=1 to ttt
  if go=1 then continue for
  PAGE WRITE 3
  for i=1 to 34 step ii
   if go=1 then continue for
   PAGE COPY 2 TO 3,D
   PAGE WRITE 4
   PAGE SCROLL 4,0,ii,1
   printC(MM.HRES\2+8-LEN(crd$(t))*17,MM.VRES-i,crd$(t));
   PAGE WRITE 3
   BLIT 0,0,0,0,MM.HRES,MM.VRES,4,4
   PAGE COPY 3 TO 0,B
   if keydown(1)=K_ESC or keydown(1)=K_SPC then go=1   
  next i
  if keydown(1)=K_ESC or keydown(1)=K_SPC then go=1
 next t
 do while keydown(1)=32 or keydown(1)=27
 loop
 'PSGLibAniG
 Cls
 play stop
EndIf


'--- MOD FILE NAMES ---

ModMus$( 0,0)="Nomusic"
ModMus$( 0,1)=""
ModMus$( 1,0)="China-Dudeludium"
ModMus$( 1,1)="BY JPN OF LEVEL 4-ASD"
ModMus$( 2,0)="Copenhagen at Night"
ModMus$( 2,1)="BY UNKNOWN AUTHOR"
ModMus$( 3,0)="Daisy Chain"
ModMus$( 3,1)="BY RHESUS MINUS"
ModMus$( 4,0)="Deadlock"
ModMus$( 4,1)="BY UNKNOWN AUTHOR"
ModMus$( 5,0)="Demonology"
ModMus$( 5,1)="BY ALLISTER BRIMBLE"
ModMus$( 6,0)="Echobeat"
ModMus$( 6,1)="BY UNKNOWN AUTHOR"
ModMus$( 7,0)="Exodus 1990"
ModMus$( 7,1)="BY UNKNOWN AUTHOR"
ModMus$( 8,0)="Wanderlust"
ModMus$( 8,1)="BY LEVIATHAN"
ModMus$( 9,0)="Towards Immortality"
ModMus$( 9,1)="BY GROO"
ModMus$(10,0)="Mazes of Gauntlet"
ModMus$(10,1)="BY UNKNOWN AUTHOR"
ModMus$(11,0)="Progressive-Funk"
ModMus$(11,1)="BY MOBY / LEOPARD"
ModMus$(12,0)="PetShopBoys in Hell"
ModMus$(12,1)="BY UNKNOWN AUTHOR"
ModMus$(13,0)="Title"
ModMus$(13,1)="BY HAL CANON"
ModMus$(14,0)="Treasure Room"
ModMus$(14,1)="BY HAL CANON"


'--- VOICE NAMES ---

t=0
SndTst$(t,1)="BETTER HURRY"
SndTst$(t,2)="better hurry":t=t+1
SndTst$(t,1)="BETTER LUCK NEXT TIME"
SndTst$(t,2)="better luck":t=t+1
SndTst$(t,1)="BEWARE THE DEMONS"
SndTst$(t,2)="beware demons":t=t+1
SndTst$(t,1)="I'VE NOT SEEN SUCH BRAVERY"
SndTst$(t,2)="bravery":t=t+1
SndTst$(t,1)="DON'T SHOOT YOUR FRIENDS ON THIS LEVEL"
SndTst$(t,2)="dontshootfriends":t=t+1
SndTst$(t,1)="ONE"
SndTst$(t,2)="one":t=t+1
SndTst$(t,1)="TWO"
SndTst$(t,2)="two":t=t+1
SndTst$(t,1)="THREE"
SndTst$(t,2)="three":t=t+1
SndTst$(t,1)="FOUR"
SndTst$(t,2)="four":t=t+1
SndTst$(t,1)="FIVE"
SndTst$(t,2)="five":t=t+1
SndTst$(t,1)="SIX"
SndTst$(t,2)="six":t=t+1
SndTst$(t,1)="SEVEN"
SndTst$(t,2)="seven":t=t+1
SndTst$(t,1)="EIGHT"
SndTst$(t,2)="eight":t=t+1
SndTst$(t,1)="NINE"
SndTst$(t,2)="nine":t=t+1
SndTst$(t,1)="WARRIOR"
SndTst$(t,2)="warrior":t=t+1
SndTst$(t,1)="VALKYRIE"
SndTst$(t,2)="valkyrie":t=t+1
SndTst$(t,1)="WIZARD"
SndTst$(t,2)="wizard":t=t+1
SndTst$(t,1)="WELCOME"
SndTst$(t,2)="welcome":t=t+1
SndTst$(t,1)="LET'S SEE YOU GET OUT OF HERE"
SndTst$(t,2)="get out of here":t=t+1
SndTst$(t,1)="GOOD COOPERATION"
SndTst$(t,2)="good coop":t=t+1
SndTst$(t,1)="FIND THE HIDDEN POTION"
SndTst$(t,2)="hidden potion":t=t+1
SndTst$(t,1)="YOUR LIFE FORCE IS RUNNING OUT"
SndTst$(t,2)="life force":t=t+1
SndTst$(t,1)="FIND THE EXIT"
SndTst$(t,2)="find the exit":t=t+1
SndTst$(t,1)="YOU HAVE FOUND MY TREASURE"
SndTst$(t,2)="found treasure":t=t+1
SndTst$(t,1)="LOOKS LIKE YOU LOSE"
SndTst$(t,2)="looks like you lose":t=t+1
SndTst$(t,1)="USE MAGIC TO KILL DEATH"
SndTst$(t,2)="magic kill death":t=t+1
SndTst$(t,1)="... NEEDS FOOD, BADLY"
SndTst$(t,2)="needs food":t=t+1
SndTst$(t,1)="REMEMBER, DON'T SHOOT FOOD!"
SndTst$(t,2)="remember dont shoot food":t=t+1
SndTst$(t,1)="... SHOT THE FOOD"
SndTst$(t,2)="shot the food":t=t+1
SndTst$(t,1)="... SHOT THE POTION"
SndTst$(t,2)="shot the potion":t=t+1
SndTst$(t,1)="YOU JUST SHOT THE POTION"
SndTst$(t,2)="you shot potion":t=t+1
SndTst$(t,1)="SAVE KEYS TO OPEN DOORS"
SndTst$(t,2)="save keys open doors":t=t+1
SndTst$(t,1)="SAVE POTIONS FOR LATER USE"
SndTst$(t,2)="save potions":t=t+1
SndTst$(t,1)="YOUR SHOTS NOW HURT OTHER PLAYERS"
SndTst$(t,2)="shots hurt":t=t+1
SndTst$(t,1)="YOUR SHOTS NOW STUN OTHER PLAYERS"
SndTst$(t,2)="shots stun":t=t+1
SndTst$(t,1)="SHOTS DO NOT HURT OTHER PLAYERS, YET"
SndTst$(t,2)="shots not hurt":t=t+1
SndTst$(t,1)="SOME WALLS MAY BE DESTROYED"
SndTst$(t,2)="some walls":t=t+1
SndTst$(t,1)="SORCERERS MAY BE INVISIBLE"
SndTst$(t,2)="sorcerers":t=t+1
SndTst$(t,1)="TIMES IS ON MY SIDE"
SndTst$(t,2)="times on my side":t=t+1
SndTst$(t,1)="TIMES IS RUNNING OUT"
SndTst$(t,2)="times running out":t=t+1
SndTst$(t,1)="TRY THIS LEVEL NOW"
SndTst$(t,2)="trythislevel":t=t+1
SndTst$(t,1)="TREASURE 100 POINTS"
SndTst$(t,2)="treasure 100 points":t=t+1
SndTst$(t,1)="WELCOME TO THE TREASURE ROOM"
SndTst$(t,2)="welcome treasure":t=t+1
SndTst$(t,1)="WELCOME!"
SndTst$(t,2)="welcome":t=t+1
SndTst$(t,1)="TRY FIND THE WAY OUT"
SndTst$(t,2)="wayout":t=t+1
SndTst$(t,1)="... NOW WAS ..."
SndTst$(t,2)="now has":t=t+1
SndTst$(t,1)="EXTRA ARMOR"
SndTst$(t,2)="armour":t=t+1
SndTst$(t,1)="EXTRA FIGHT POWER"
SndTst$(t,2)="fightpower":t=t+1
SndTst$(t,1)="EXTRA MAGIC POWER"
SndTst$(t,2)="magic":t=t+1
SndTst$(t,1)="EXTRA SHOT POWER"
SndTst$(t,2)="shotpower":t=t+1
SndTst$(t,1)="EXTRA SHOT SPEED"
SndTst$(t,2)="shotspeed":t=t+1
SndTst$(t,1)="EXTRA SPEED"
SndTst$(t,2)="speed":t=t+1
SndTst$(t,1)="LIMITED INVISIBILITY"
SndTst$(t,2)="limited invis":t=t+1
maxSndTst=t-1+14


'--- CREDITS TEXT ---

t=1
Crd$(t)="*VERSION REPROGRAMMED BY":t=t+1
Crd$(t)="MAURO XAVIER":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*BETA TESTER / BUG CATCHER":t=t+1
Crd$(t)="JOHN WAALKES (SimpleSafeName)":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*MUSIC FROM MASTER SYSTEM":t=t+1
Crd$(t)="*GAUNTLET (US GOLD) ORIGINAL BY":t=t+1
Crd$(t)="TIERTEX DESIGN STUDIOS LIMITED":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*MUSIC CONVERTED FROM NES":t=t+1
Crd$(t)="*GAUNTLET (TENGEN) ORIGINAL BY":t=t+1
Crd$(t)="HAL CANON / EARL VICKERS":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*OPTIONS SCREEN MUSIC FROM ATARI ST":t=t+1
Crd$(t)="*GHOULS'N GHOSTS THEME ORIGINAL BY":t=t+1
Crd$(t)="TIM FOLLIN":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*CREDITS SCREEN MUSIC FROM MASTER SYSTEM":t=t+1
Crd$(t)="*GAIN GROUND (SEGA) ORIGINAL BY":t=t+1
Crd$(t)="CHIKAKO KAMATANI":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*SELECT SCREEN MUSIC FROM MASTER SYSTEM":t=t+1
Crd$(t)="*GOLVELLIUS (SCROLLING CAVE) ORIGINAL BY":t=t+1
Crd$(t)="MYAM, SHANT, SHIN-KUN, PAZU":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*GRAPHICS BASED IN ARTS OF":t=t+1
Crd$(t)="KEVIN BULMER (ATARI ST)":t=t+1
Crd$(t)="TIERTEX (MASTER SYSTEM)":t=t+1
Crd$(t)="JOSEPH CHIODO (NES)":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*SFX AND SOUND LIBRARY (PSGLIB) BY":t=t+1
Crd$(t)="MAURO XAVIER":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*VOICES CONVERTED FROM ARCADE":t=t+1
Crd$(t)="*ORIGINAL BY":t=t+1
Crd$(t)="ERNIE FOSSELIUS":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*ARCADE VERSION":t=t+1
Crd$(t)="*DESIGNED BY":t=t+1
Crd$(t)="ED LOGG":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*SPECIAL THANKS TO THE":t=t+1
Crd$(t)="*BACK SHED FORUM MEMBERS":t=t+1
Crd$(t)="JOHN WAALKES (SimpleSafeName)":t=t+1
Crd$(t)="GEOFF GRAHAM":t=t+1
Crd$(t)="Ceptimus":t=t+1
Crd$(t)="Turbo46":t=t+1
Crd$(t)="FRANK N. FURTER":t=t+1
Crd$(t)="WhiteWizzard":t=t+1
Crd$(t)="Cosmic Frog":t=t+1
Crd$(t)="Cyber":t=t+1
Crd$(t)="Matherp":t=t+1
Crd$(t)="Chopperp":t=t+1
Crd$(t)="Grogster":t=t+1
Crd$(t)="BrianP":t=t+1
Crd$(t)="Decoy":t=t+1
Crd$(t)="Volhout":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*IN MEMORY OF":t=t+1
Crd$(t)="VAGNER (VAGUINHO)":t=t+1
Crd$(t)="WITHOUT YOUR FRIENDSHIP, PROBABLY":t=t+1
Crd$(t)="I WOULD NEVER KNOW THIS GAME":t=t+1
Crd$(t)="*< THANKS BY YOUR BROTHERHOOD >":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="":t=t+1
Crd$(t)="*GAUNTLET IS A TRADEMARK OF":t=t+1
Crd$(t)="ATARI GAMES CORPORATION":t=t+1
Crd$(t)="MIDWAY GAMES WEST INC":t=t+1
Crd$(t)="WARNER BROS ENTERTAINMENT INC":t=t+1
Crd$(t)="":t=t+1
maxCrd=t-1

CtrlType(1)=0
CtrlType(2)=1
CtrlChange(1)=0

