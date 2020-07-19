OPTION CONSOLE SCREEN
OPTION BASE 0

#INCLUDE ".\PSGMINI\PSGMINI.INC"
'sub initsound
'end sub
'sub playvgm
'end sub
'sub stopvgm
'end sub
'sub loadvgm(a$)
'end sub
'sub unloadvgm
'end sub
'sub setintvgm(a)
'end sub
'sub changespeed(a)
'end sub
'sub setchannelVol(a,b)
'end sub
'sub setchanneltype(a,typ$)
'end sub
'sub EnableChannel(a)
'end sub
'sub DisableChannel(a)
'end sub
GoTo INIT

Sub PSGLibAniG
 Local T,TT,TTT
 Cls: Option error continue: Play Stop
 Pause(150): LoadVGM(".\PSGMINI\PSGLIB.VGM")
 PlayVGM
 Pause(120): ChangeSpeed(5): SetIntVGM(1)
 For T=10 To 1 Step -1
  A$=".\PSGMINI\PSGLIB"+Str$(T)+".BMP": Pause(8)
  Load BMP A$,68,85
 Next T
 Changespeed(1): t=0: Pause(100): tt=Timer: show=0
 Do While t<tt+5000
  t=Timer
  If t>tt+350 And show=0 Then
   show=1
   Load BMP ".\PSGMINI\MXAVIER.BMP",27,135
   Load BMP ".\PSGMINI\POWERED.BMP",67,60
   For ttt=0 To 1: Print@(92,MM.VRes-14+ttt,1) "CDN 2020": Next ttt
  EndIf
  If t>tt+2750 And show=1 and retro=1 Then show=2: stopVGM
  If KeyDown(1)=32 Or KeyDown(1)=27 Then
   If T<tt+2750 Then
    if retro=1 then stopVGM: UnloadVGM
    Cls: Exit Sub
   EndIf
  EndIf
  Pause(1)
 Loop
 if retro=1 then UnloadVGM
End Sub

' SHOW MAIN CHARACTER
Sub PutSpriteChar(spr,x,y)
 Local XT,YT
 spr=spr+(PTypeA-1)*40 
 YT=FIX(SPR*17/306)*17
 XT=(SPR MOD 18)*17
 PAGE WRITE 11: BLIT XT,YT,X,Y,16,16,12,4
End Sub

' SHOW MAIN CHARACTER
Sub PutSpriteEnemy(spr,x,y)
 'box x,y,16,16,1,rgb(255,0,0),rgb(255,0,0)
 'return
 Local XT,YT,PG
 if spr>=5000 then spr=spr-5000
 SELECT CASE spr
  CASE    0 TO  999: spr=spr- 200:PG=5
  CASE 1000 TO 1999: spr=spr-1200:PG=4
  CASE 2000 TO 2999: spr=spr-2200:PG=9
 END SELECT
 PG=3
 YT=FIX(SPR*17/306)*17
 XT=(SPR MOD 18)*17
 BLIT XT,YT,X,Y,16,16,PG,4
End Sub

' REFRESH STATUS PANEL WITH CHARACTER PHOTO FOR PLAYER N 
Sub PanelStatus(type,n)
 Local X,Y,A$
 X=MM.HRES-34: Y=40+(n-1)*76 
 PAGE WRITE 0: BLIT (PTypeA-1)*34,170,X,Y,30,30,12,4
 BOX X-33,Y+2,9,30,0,RGB(0,0,0),RGB(0,0,0)
 BOX X-13,Y+2,9,30,0,RGB(0,0,0),RGB(0,0,0)
 PrintG(x-38,y+ 3,str$(Cmag))
 PrintG(x-38,y+13,str$(Csht))
 PrintG(x-38,y+23,str$(Cfig))
 PrintG(x-18,y+ 3,str$(Cspd))
 PrintG(x-18,y+13,str$(Carm))
 PrintG(x-18,y+23,str$(Cshs))
 PrintG(x-12-Len(PlName$)*3,y+65,PlName$)
 Box x-7-Len(PlName$)*3,y+65,1,8,1,rgb(0,0,0),rgb(0,0,0)
 A$="ROOM "+STR$(room)
 PrintG(x-12-Len(A$)*3,27,A$)
 'PtypeA=4:CoP=2:Cmag=3:Csht=2:Cfig=2
 'Cshs=8:Carm=2:Cspd=4:MaxEn=820:hpg=120:EL=2:ER=7
End Sub

' GENERAL TILE
Sub PutTile(spr,x,y)
 Local PG,XT,YT,sprt
 sprt=spr
 SELECT CASE SPRt
  CASE 400 TO 599: PG=6: SPRt=SPRt-400
  CASE 600 TO 798: PG=7: SPRt=SPRt-600+difwall
  CASE 799       : PG=7: SPRt=11+difwall
 END SELECT   
 YT=FIX(SPRt*17/306)*17: XT=(SPRt MOD 18)*17
 BLIT XT,YT,X,Y,16,16,PG,4
End Sub

' GENERAL SPRITE
Sub PutSprite(spr,x,y,WRX)
 Local PG,XT,YT,WR,sprt
 IF SPR=0 THEN EXIT SUB
 sprt=spr
 SELECT CASE SPRt
  CASE   0 TO 199: PG=12:WR=11
  CASE 200 TO 399: PG=9:WR=11:SPRt=SPRt-200
  CASE 400 TO 599: PG=6:WR=1: SPRt=SPRt-400
  CASE 600 TO 798: PG=7:WR=1: SPRt=SPRt-600+difwall
  CASE 799       : PG=7:WR=1: SPRt=11+difwall
 END SELECT  
 IF WRX>0 THEN WR=WRX
 YT=FIX(SPRt*17/306)*17
 XT=(SPRt MOD 18)*17
 IF PG=1 THEN PG=0
 PAGE WRITE WR: BLIT XT,YT,X,Y,16,16,PG,4
End Sub

' CREATE THE FLOOR SCREEN PAGE
Sub CreateFloor
 Local x,y
 PAGE WRITE 8: CLS
 for x=0 to 320 step 16
  for y=0 to 200 step 16
   PutSprite(616,x,y,8)
 next y,x  
End Sub

' READ OR WRITE ON STAGE ARRAY CONVERTED TO PIXELS
Sub BlockStage(mx,my,r)
 local b%
 SELECT CASE ColDepth
  CASE 8:
   SELECT CASE r
    CASE >=0: ' READ PIXEL
     b%=(FStage%+(dbR*2*my)+mx*2)
     r=r+PEEK(BYTE b%)+PEEK(BYTE b%+1)+PEEK(BYTE b%+dbR)+PEEK(BYTE b%+dbR+1)
    CASE -1:  ' CLEAR PIXEL
     b%=(CStage%+(dbR*2*my)+mx*2)
     POKE BYTE b%,0: POKE BYTE b%+1,0: POKE BYTE b%+dbR,0: POKE BYTE b%+dbR+1,0
     b%=(FStage%+(dbR*2*my)+mx*2)
     POKE BYTE b%,0: POKE BYTE b%+1,0: POKE BYTE b%+dbR,0: POKE BYTE b%+dbR+1,0
    CASE <-1: ' WRITE PIXEL
     b%=(FStage%+(dbR*2*my)+mx*2)
     POKE BYTE b%,-r: POKE BYTE b%+1,-r: POKE BYTE b%+dbR,-r: POKE BYTE b%+dbR+1,-r
   END SELECT
  CASE 16:
   SELECT CASE r
    CASE >=0:
     b%=(FStage%+((dbR*2*my)+mx*2)*2)
     r=r+PEEK(SHORT b%)+PEEK(SHORT b%+2)+PEEK(SHORT b%+dbR*2)+PEEK(SHORT b%+dbR*2+2)
    CASE -1:
     b%=(CStage%+((dbR*2*my)+mx*2)*2)
     POKE SHORT b%,0: POKE SHORT b%+2,0: POKE SHORT b%+dbR*2,0: POKE SHORT b%+dbR*2+2,0
     b%=(FStage%+((dbR*2*my)+mx*2)*2)
     POKE SHORT b%,0: POKE SHORT b%+2,0: POKE SHORT b%+dbR*2,0: POKE SHORT b%+dbR*2+2,0
    CASE <-1:
     b%=(FStage%+((dbR*2*my)+mx*2)*2)
     POKE SHORT b%,-r: POKE SHORT b%+2,-r: POKE SHORT b%+dbR*2,-r: POKE SHORT b%+dbR*2+2,-r
   END SELECT
 END SELECT
End Sub

' TEMPORARY CONVERSION TABLE GAUNTLET CMM TO CMM2
Sub ConvertTable(spr,SPRT,PG)
 'SPRT=199 
 SELECT CASE SPR
  CASE   0: SPRT=0
  'PLAYERS
  CASE   1: SPRT=12
  CASE   2: SPRT=20
  CASE   3: SPRT=10
  CASE   4: SPRT=18
  CASE   5: SPRT=14
  CASE   6: SPRT=22
  CASE   7: SPRT=8
  CASE   8: SPRT=16
  'PLAYER SHOOT
  CASE   9: SPRT=24
  CASE  10: SPRT=25
  CASE  11: SPRT=26
  CASE  12: SPRT=27
  CASE  13: SPRT=28
  CASE  14: SPRT=29
  CASE  15: SPRT=30
  CASE  16: SPRT=31
  'OBJECTS
  CASE  17: SPRT=455  'TREASURE  
  CASE  20: SPRT=434  'EXIT
  CASE  21: SPRT=427  'FOOD
  CASE  22: SPRT=490  'VERTICAL DOOR  
  CASE  23: SPRT=495  'HORIZONTAL DOOR
  CASE  24: SPRT=444  'KEY
  CASE  25: SPRT=426  'ENERGY POTION
  CASE  26: SPRT=459  'MAGIC POTION
  CASE  27: SPRT=432  'EXPLODE MAX
  CASE  28: SPRT=430  'EXPLODE MIN
  CASE  29: SPRT=481  'TELEPORT 1
  CASE  30: SPRT=483  'TELEPORT 2
  'GHOSTS GENERATORS
  CASE  31: SPRT=394
  CASE  32: SPRT=393
  CASE  33: SPRT=392
  'GHOSTS
  CASE  34: SPRT=208
  CASE  35: SPRT=208+8
  CASE  36: SPRT=209
  CASE  37: SPRT=209+8
  CASE  38: SPRT=210
  CASE  39: SPRT=210+8
  CASE  40: SPRT=211
  CASE  41: SPRT=211+8
  CASE  42: SPRT=212
  CASE  43: SPRT=212+8
  CASE  44: SPRT=213
  CASE  45: SPRT=213+8
  CASE  46: SPRT=214
  CASE  47: SPRT=214+8
  CASE  48: SPRT=215
  CASE  49: SPRT=215+8
  'GENERATORS
  CASE  50: SPRT=397
  CASE  51: SPRT=396
  CASE  52: SPRT=395
  'GRUNTS
  CASE  53: SPRT=232
  CASE  54: SPRT=232+8
  CASE  55: SPRT=234
  CASE  56: SPRT=234+8
  CASE  57: SPRT=236
  CASE  58: SPRT=236+8
  CASE  59: SPRT=238
  CASE  60: SPRT=238+8
  'DEMONS
  CASE  61: SPRT=248
  CASE  62: SPRT=248+8
  CASE  63: SPRT=249
  CASE  64: SPRT=249+8
  CASE  65: SPRT=250
  CASE  66: SPRT=250+8
  CASE  67: SPRT=251
  CASE  68: SPRT=251+8
  CASE  69: SPRT=252
  CASE  70: SPRT=252+8
  CASE  71: SPRT=253
  CASE  72: SPRT=253+8
  CASE  73: SPRT=254
  CASE  74: SPRT=254+8
  CASE  75: SPRT=255
  CASE  76: SPRT=255+8
  'DEAD
  CASE  77: SPRT=200+18*6+12
  CASE  78: SPRT=200+18*6+14
  CASE  79: SPRT=200+18*6+16
  CASE  80: SPRT=200+18*6+18
  'SLIME
  CASE  81: SPRT=200+18*8
  CASE  82: SPRT=200+18*6+1
  CASE  83: SPRT=200+18*6+2
  'SORCERER
  CASE  84: SPRT=296
  CASE  85: SPRT=298
  CASE  86: SPRT=300
  CASE  87: SPRT=302
  'WALLS
  CASE  88 TO 105: SPRT=600-88+SPR
  'FALSE WALL
  CASE 106: SPRT=799
  'SPECIAL CASES
  CASE 200 TO 255: SPRT=SPR+800
 END SELECT

'PAGE WRITE 12: CLS: LOAD PNG ".\IMAGES\PLAYERS.PNG",,,8
'PAGE WRITE 3: CLS: LOAD PNG ".\IMAGES\ENEMIES1.PNG",,,8
'PAGE WRITE 4: CLS: LOAD PNG ".\IMAGES\ENEMIES2.PNG",,,8
'PAGE WRITE 5: CLS: LOAD PNG ".\IMAGES\ENEMIES3.PNG",,,8
'PAGE WRITE 6: CLS: LOAD PNG ".\IMAGES\OBJECTS.PNG",,,8
'PAGE WRITE 7: CLS: LOAD PNG ".\IMAGES\WALLS.PNG",,-17*0,8
End sub

'FONTS FOR OPTIONS AND LOADING
Sub PrintS(x,y,tp,st$)
 Local T,LX,LY,sx,sy
 FOR T = 1 TO LEN(st$)
  if tp<=3 then LY=25+tp*16 else LY=105+(tp-4)*48
  IF tp>=4 then sx=16 else sx=8
  IF TP=-1 THEN SX=6
  IF TP=-2 THEN SX=5
  LX=(ASC(mid$(st$,t,1))-32)*sx
  IF tp=>3 then sy=16 else sy=8
  IF LX>=640 THEN LX=LX-640:LY=LY+sy*2 
  IF LX>=320 THEN LX=LX-320:LY=LY+sy 
  IF TP=-2 THEN LY=0:SX=5:SY=9
  BLIT LX,LY,x+T*sx,y,sx,sy,13,4
 NEXT T
End Sub

'FONTS FOR COPYRIGHT
Sub PrintC(x,y,st$)
 Local T,TT,LX,LY,sx,sy,XX
 SX=32:XX=0
 FOR T = 1 TO LEN(st$)
  IF MID$(ST$,T,1)="\" THEN TPChar=VAL(MID$(ST$,T+1,1)):st$=RIGHT$(ST$,LEN(ST$)-T-1)
  SELECT CASE TPChar
   CASE 0: LY=0:   SY=32
   CASE 1: LY=96:  SY=30
   CASE 2: LY=186: SY=25
   CASE 3: LY=261: SY=25
  END SELECT
  LX=(ASC(mid$(st$,t,1))-32)*sx
  FOR TT=3 TO 1 STEP -1
   IF LX>=640*TT THEN LX=LX-640*TT:LY=LY+SY*TT
  NEXT TT
  IF MID$(ST$,T,1)<>" " THEN XX=XX+(SX-1) ELSE XX=XX+26
  BLIT LX,LY,X+XX,y,sx,sy,6,4
 NEXT T
End Sub

'FONTS IN-GAME
Sub PrintG(x,y,st$)
 Local T,LX,LY
 FOR T = 1 TO LEN(st$)
  LX=(ASC(mid$(st$,t,1))-32)*6
  LY=170: IF LX>318 THEN LX=LX-318:LY=178
  BLIT LX,LY,x+T*6,y,6,8,6,0
 NEXT T
End Sub

Sub RGB_Options
 PAGE COPY 3 TO 4,I
 PAGE SCROLL 3,0,2
 PAGE WRITE 4
 BLIT 0, 0, 0, 0,MM.Hres,53,1,4 
 PAGE WRITE 0
 BLIT 0, 0,40,10,MM.Hres,53,4,4 
 BLIT 0, 0, 0,75,MM.Hres,MM.Vres-75,2
End Sub

'INITIAL BOOT
INIT:
OPTION CONSOLE SCREEN
test=0 'test here
retro=1:music=1: ColDepth=8
Cls
'If MM.Ver < 4.0503 Then
' Print "THIS PROGRAM NEEDS A 4.5C FIRMWARE VERSION OR BETTER":Print
' End
'EndIf
Mode 3,16: Cls
for t=0 to 12:page write t: cls: next t
InitSound

CONST K_ESC=27,K_SPC=32,K_N0= 48,K_N2= 50,K_N4= 52,K_N6=54,K_N8=56
CONST K_U=128, K_D=129, K_L=130, K_R=131,K_NP= 80

maxg=40 'MAX ENEMIES IN SCREEN
ms=4    'MAX SFX
plq=1: f=3
spd=8: t=0: tt=0: ttt=0
dbR=MM.hres*2
Dim st(37,37),CtrlType(2),CtrlChange(2),ModMus$(20)
Dim xe(maxg+3),ye(maxg+3), xh(maxg+3),yh(maxg+3),lv(maxg+3)
Dim ae(maxg+3),te(maxg+3), ce(maxg+3),en(maxg+3),EaIni(maxg+3)
Dim snd(ms+1),sndc(ms+1),sndspd(ms+1),sndmax(ms+1),sndmin(ms+1),vol(ms+1),sndt$(ms+1)
DIM xex(10),yex(10),anx(10),sprx(10),spdEx(10),maxx(10),expl(10)
Dim SndTst$(50,2) LENGTH 50
Dim SndType$(30,4) LENGTH 1
Dim Crd$(80) LENGTH 100

ms=2: for t=1 to 4: vol(t)=25: next t

If test>0 Then
 PtypeA=4:CoP=2:Cmag=3:Csht=2:Cfig=2:PlName$="ELF"
 Cshs=8:Carm=2:Cspd=8:MaxEn=820:hpg=120:EL=2:ER=7
 key=3:bomb=2:score=0:KILLDE=2:SAVEKE=2:SAVEPO=2:GETTRE=2:SHOTPOT=2:SHOTFOOD=2:energy=maxEn
Else
 key=0:bomb=0:score=0:KILLDE=0:SAVEKE=0:SAVEPO=0:GETTRE=0:SHOTPOT=0:SHOTFOOD=2
EndIf
Silence: actg=0:cntg=maxg:mapside=1

'COPYRIGHT NOTICE
If test=0 Then
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

ModMus$( 1)="China-Dudeludium"
ModMus$( 2)="Copenhagen at Night"
ModMus$( 3)="Daisy Chain"
ModMus$( 4)="Deadlock"
ModMus$( 5)="Demonology"
ModMus$( 6)="Dragon Slayer"
ModMus$( 7)="Echobeat"
ModMus$( 8)="Exodus 1990"
ModMus$( 9)="Exorcize"
ModMus$(10)="Leviathan"
ModMus$(11)="Towards Immortality"
ModMus$(12)="Mazes of Gauntlet"
ModMus$(13)="Occ-San-Geen"
ModMus$(14)="PetShopBoys in Hell"
ModMus$(15)="Progressive-Funk"
ModMus$(16)="Title"
ModMus$(17)="Treasure Room"

t=1
SndTst$(t,1)="SONG A"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="T"
SndType$(t,4)="N"
SndTst$(t,2)="song1.vgm":t=t+1

SndTst$(t,1)="SONG B"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="T"
SndType$(t,4)="N"
SndTst$(t,2)="song2.vgm":t=t+1

SndTst$(t,1)="SONG C"
SndType$(t,1)="W"
SndType$(t,2)="Q"
SndType$(t,3)="T"
SndType$(t,4)="N"
SndTst$(t,2)="song3.vgm":t=t+1

SndTst$(t,1)="SONG D"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="T"
SndType$(t,4)="N"
SndTst$(t,2)="song4.vgm":t=t+1

SndTst$(t,1)="SONG E"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="song5.vgm":t=t+1

SndTst$(t,1)="SONG F"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="song6.vgm":t=t+1

SndTst$(t,1)="SONG G"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="song7.vgm":t=t+1

SndTst$(t,1)="SONG H"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="song8.vgm":t=t+1

SndTst$(t,1)="SONG I"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="song9.vgm":t=t+1

SndTst$(t,1)="SONG H"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="song10.vgm":t=t+1

SndTst$(t,1)="SONG J"
SndType$(t,1)="W"
SndType$(t,2)="T"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="song11.vgm":t=t+1

SndTst$(t,1)="SONG K"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="song12.vgm":t=t+1


SndTst$(t,1)="SECRET ROOM"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="Q"
SndType$(t,4)="N"
SndTst$(t,2)="secroom.vgm":t=t+1

SndTst$(t,1)="TREASURE ROOM (NES)"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="Q"
SndType$(t,4)="N"
SndTst$(t,2)="treasure.vgm":t=t+1

SndTst$(t,1)="TREASURE ROOM (SMS)"
SndType$(t,1)="S"
SndType$(t,2)="S"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="treassms.vgm":t=t+1

SndTst$(t,1)="TITLE SCREEN (NES)"
SndType$(t,1)="T"
SndType$(t,2)="Q"
SndType$(t,3)="Q"
SndType$(t,4)="S"
SndTst$(t,2)="TITLE.vgm":t=t+1

SndTst$(t,1)="GAUNTLET THEME (SMS)"
SndType$(t,1)="W"
SndType$(t,2)="W"
SndType$(t,3)="W"
SndType$(t,4)="S"
SndTst$(t,2)="TITLESMS.vgm":t=t+1

SndTst$(t,1)="CREDITS (GAIN GROUND)"
SndType$(t,1)="W"
SndType$(t,2)="Q"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="CREDITS.vgm":t=t+1

SndTst$(t,1)="SELECTION (GOLVELLIUS)"
SndType$(t,1)="Q"
SndType$(t,2)="W"
SndType$(t,3)="W"
SndType$(t,4)="N"
SndTst$(t,2)="SELECT.vgm":t=t+1

SndTst$(t,1)="WARRIOR"
SndTst$(t,2)="warrior.raw":t=t+1
SndTst$(t,1)="VALKYRIE"
SndTst$(t,2)="valkyrie.raw":t=t+1
SndTst$(t,1)="WIZARD"
SndTst$(t,2)="wizard.raw":t=t+1
SndTst$(t,1)="WELCOME"
SndTst$(t,2)="welcome.raw":t=t+1
SndTst$(t,1)="TREASURE 100 POINTS"
SndTst$(t,2)="100poin.raw":t=t+1
SndTst$(t,1)="SAVE KEYS TO OPEN DOORS"
SndTst$(t,2)="opendoor.raw":t=t+1
SndTst$(t,1)="SAVE POT. FOR LATER USE"
SndTst$(t,2)="savepoti.raw":t=t+1
SndTst$(t,1)="YOU H FOUND MY TREASURE"
SndTst$(t,2)="foundtr.raw":t=t+1
SndTst$(t,1)="BEWARE THE DEMONS"
SndTst$(t,2)="bdemons.raw":t=t+1
SndTst$(t,1)="BETTER LUCK NEXT TIME"
SndTst$(t,2)="bettluck.raw":t=t+1
SndTst$(t,1)="W. TO THE TREASURE ROOM"
SndTst$(t,2)="treasure.raw":t=t+1
SndTst$(t,1)="TRY FIND THE WAY OUT"
SndTst$(t,2)="findout.raw":t=t+1
SndTst$(t,1)="YOUR LF IS RUNNING OUT"
SndTst$(t,2)="lifeout.raw":t=t+1
SndTst$(t,1)="NOW WAS"
SndTst$(t,2)="nowhas.raw":t=t+1
SndTst$(t,1)="EXTRA ARMOR"
SndTst$(t,2)="armor.raw":t=t+1
SndTst$(t,1)="EXTRA FIGHT POWER"
SndTst$(t,2)="fightp.raw":t=t+1
SndTst$(t,1)="EXTRA MAGIC POWER"
SndTst$(t,2)="magicp.raw":t=t+1
SndTst$(t,1)="EXTRA SHOT POWER"
SndTst$(t,2)="shotp.raw":t=t+1
SndTst$(t,1)="EXTRA SHOT SPEED"
SndTst$(t,2)="shotspd.raw":t=t+1
SndTst$(t,1)="EXTRA SPEED"
SndTst$(t,2)="speed.raw":t=t+1
SndTst$(t,1)="LIMITED INVISIBILITY"
SndTst$(t,2)="invisib.raw":t=t+1
maxSndTst=t-1

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

'GENERAL RESTART
RESTART:

room=1: key=0: bomb=0: score=0: MusVol=10: clmap=0

if test=0 then KILLDE=0: SAVEKE=0: SAVEPO=0: GETTRE=0: SHOTPOT=0: SHOTFOOD=0
Play Stop: actg=0: cntg=maxg

'TITLE SCREEN
INTRO:

IF TEST>0 THEN FIRSTLOAD=1: GOTO START_VIDEO
Mode 3,16
Play Stop
PAGE WRITE 6: CLS: Load PNG "./IMAGES/INTRO1.PNG",,,8
PAGE WRITE 3: CLS: Load PNG "./IMAGES/RAINBOW.PNG"

k=keydown(1)

if music=1 then
 if retro=1 then
  LoadVGM("./vgm/title.vgm")
  SetChannelType(1,"T")
  SetChannelType(2,"Q")
  SetChannelType(3,"Q")
  PlayVGM: ChangeSpeed(1): SetIntVGM(1)
 else
  PlayMOD(16)
 endif
endif

co=1:temp=0:Timer=0
Do While Kb<>32
 kb=KeyDown(1)
 If kb=27 Then 
  if retro=1 then UnloadVGM
  Mode 1:End
 endif
 PAGE SCROLL 3,0,2
 PAGE COPY 3 TO 4,I
 PAGE WRITE 4
 BLIT 66,26,66,26,187,40,6,4
 PAGE COPY 6 TO 7,I
 PAGE WRITE 7
 BLIT 66,26,66,26,187,40,4,4 
 PAGE COPY 7 TO 0,I
 If Timer>30000 And temp=0 and retro=1 Then StopVGM:temp=1
Loop
if retro=1 then UnloadVGM

'GAME OPTIONS
OPTIONS:
MODE 3,16
PAGE WRITE 0
COLOR RGB(255,255,255),RGB(41,41,41)
CLS
BOX 0,70,320,200-70,1,RGB(0,0,0),RGB(0,0,0)
PLAY STOP
PAGE WRITE 13: CLS: LOAD PNG ".\fonts\fonts.png",,,1
PAGE WRITE 1: CLS: LOAD PNG ".\images\goptions.png",,,8
COLOR RGB(41,41,41),RGB(0,0,0)
PrintS(77,45,-1,"CMM2 EDITION")
COLOR RGB(255,255,255),RGB(0,0,0)
OPT=1:SndNum=1

do while keydown(1)=32
loop

CHANGE_SOUND_TYPE:

if music=1 then
 if retro=1 then
  LOADVGM(".\vgm\SONG7.vgm")
  SetChannelType(1,"W")
  SetChannelType(2,"W")
  SetChannelType(3,"S")
  SetChannelType(4,"N")
  PlayVGM
  ChangeSpeed(1):SetIntVGM(2)
 else
  PlayMOD(11)
 endif
endif

Do While k<>27 And k<>-1
 PAGE WRITE 2
 CLS
 t=0:tt=20 
 PrintS(88,t,4,"OPTIONS")
 t=t+25
 If opt=1 Then co=2 Else co=0
 PrintS(tt,t,co,"START GAME")
 If PlQ=2 Then A$="S" Else A$=""
 printS(tt+100,t,co,Str$(PlQ)+" PLAYER"+A$)
 t=t+15
 If opt=2 Then co=2 Else co=0
 PrintS(tt,t,co,"MUSIC")
 If Music=0 Then printS(tt+100,t,co,"OFF") ELSE printS(tt+100,t,co,"ON")
 t=t+15
 If opt=3 Then co=2 Else co=0
 PrintS(tt,t,co,"SOUND STYLE")
 If Retro=1 Then printS(tt+100,t,co,"8-BIT ERA") ELSE printS(tt+100,t,co,"16-BIT ERA")
 t=t+15
 For ttt=1 To 2
  If opt=ttt+3 Then co=2 Else co=0
  PrintS(tt,t,co,"CONTROLS P"+Str$(ttt))
  SELECT CASE CtrlType(ttt)
   CASE 0: printS(tt+100,t,co,"ARROW KEYS OR NUMPAD")
   CASE 1: printS(tt+100,t,co,"NUNCHUK")
   CASE 2: printS(tt+100,t,co,"A W D X S TAB")
  END SELECT
  t=t+15
 Next ttt
 If opt=6 Then co=2 Else co=0
 PrintS(tt,t,co,"SOUND TEST")
 PrintS(tt+100,t,co,SndTst$(SndNum,1)) 
 t=t+15
 If opt=7 Then co=2 Else co=0
 PrintS(120,t,co,"CREDITS")

 If K<>0 Then  
  IF K<>32 THEN
   if retro=1 then
    PLAY SOUND 2,B,Q,800,25: Pause(20): PLAY SOUND 2,B,O,1,1
   else
    PlayWAV("SELECT",100)
   endif
  ENDIF
  Do While KeyDown(1)<>0
   RGB_Options
   Pause(8)
  Loop
 ELSE
  DO WHILE K=0
   RGB_Options
   Pause(8)
   k=KeyDown(1)
  LOOP 
 EndIf
 k=KeyDown(1)
 
 SndChange=0
 SndTest=0
 If k=k_U Or k=k_N8 Then opt=opt-1: If opt<1 Then opt=7
 If k=k_D Or k=k_N2 Then opt=opt+1: If opt>7 Then opt=1
 If opt=1 Then
  If k=k_L Or k=k_N4 Or k=k_R Or k=k_N6 Then
   PlQ=PlQ+1: If PlQ>2 Then PlQ=1
  EndIf
  If k=k_SPC And PlQ=1 Then k=-1
 EndIf
 If opt=2 Then
  If k=k_L Or k=k_N4 Or k=k_R Or k=k_N6 Then
   SELECT CASE Music
    CASE 0: Music=1: Goto CHANGE_SOUND_TYPE
    CASE 1: Music=0: Play Stop: if retro=1 then UnloadVGM
   END SELECT
  EndIf
 EndIf
 If opt=3 Then
  If k=k_L Or k=k_N4 Or k=k_R Or k=k_N6 Then
   SELECT CASE Retro
    CASE 0: Play Stop: PAUSE(50): Retro=1
    CASE 1: StopVGM: Pause(25): UnloadVGM: Play Stop: PAUSE(25): Retro=0
   END SELECT
   GOTO CHANGE_SOUND_TYPE
  EndIf
 EndIf
 'If (opt=2 Or opt=3) And (k=k_D Or k=k_N2) Then SndChange=1
 'If (opt=2 Or opt=1) And (k=k_U Or k=k_N8) Then SndChange=1
 'If (opt=5 Or opt=6) And (k=k_D Or k=k_N2) Then SndTest=1
 'If (opt=5 Or opt=4) And (k=k_U Or k=k_N8) Then SndTest=1
 If opt=6 Then
  If k=k_L Or k=k_N4 Then
   SndNum=SndNum-1: If SndNum<1 Then SndNum=MaxSndTst
   SndTest=2
  EndIf
  If k=k_R Or k=k_N6 Then
   SndNum=SndNum+1: If SndNum>maxSndTst Then SndNum=1
   SndTest=2
  EndIf
  If k=k_SPC Then
   if retro=1 then
    If Right$(SndTst$(SndNum,2),3)="vgm" Then
     UnloadVGM
     LoadVGM(".\vgm\"+SndTst$(SndNum,2))
     SetChannelType(1,SndType$(SndNum,1))
     SetChannelType(2,SndType$(SndNum,2))
     SetChannelType(3,SndType$(SndNum,3))
     SetChannelType(4,SndType$(SndNum,4))
     PlayVGM
     ChangeSpeed(1)
     SetIntVGM(1)
    Else
     SetIntVGM(0):StopVGM: Play Stop': DAC STOP
     'if retro=1 then PlayRAW(".\raw\"+SndTst$(SndNum,2),3500)
    EndIf
   EndIf
  Endif
 EndIf
 If opt=7 And k=k_SPC Then GoTo CREDITS

 For ttt=1 To 2
  If opt=ttt+3 Then
   If k=k_L Or k=k_N4 Then
    CtrlType(ttt)=CtrlType(ttt)-1
    CtrlChange(ttt)=1:If CtrlType(ttt)<0 Then CtrlType(ttt)=2
   EndIf
   If k=k_R Or k=k_N6 Then
    CtrlType(ttt)=CtrlType(ttt)+1
    CtrlChange(ttt)=1:If CtrlType(ttt)>2 Then CtrlType(ttt)=0
   EndIf
   If CtrlType(1)=CtrlType(2) Then
    CtrlType(2)=CtrlType(2)+1: CtrlChange(2)=1
    If CtrlType(2)>2 Then CtrlType(2)=0
   EndIf
  EndIf
 Next ttt
Loop
If k=k_ESC Then 
 Pause(100)
 K=0: if retro=1 then UnloadVGM: Pause(30): Play Stop: Pause(30)
 GoTo INTRO
endif
GoTo SELECTION

CREDITS:
 t=75: tt=0
 if retro=1 then
  UnloadVGM
  LoadVGM(".\vgm\credits.vgm")
  PlayVGM
  ChangeSpeed(1.05) 
  SetIntVGM(1)
 endif
 Scr=0:roll=0.9
 Do While roll<maxCrd+8
  roll=roll+0.1:cr=Int(roll)
  If cr>maxCrd Then cr=maxCrd
  If Len(Crd$(cr))>2 Then
   tt=tt+2
   If (roll*10) Mod 10=0 Then tt=0
   If Left$(Crd$(cr),1)="*" Then
    A$=Right$(Crd$(cr),Len(Crd$(cr))-1)
    printS(MM.HRes/2-Len(A$)*3,MM.VRes-tt,6,1,A$)
   Else
    printS(MM.HRes/2-Len(Crd$(cr))*3,MM.VRes-tt,7,1,Crd$(cr))
   EndIf
   'Print@(MM.HRes/2-Len(Crd$(cr))*3,MM.VRes-tt) CLR$(7) Crd$(cr)
  Else
   Pause(15)
  EndIf
  BLIT 0,t,0,t-2,MM.HRes,MM.VRes
  If KeyDown(1)=27 Then roll=maxCrd+16
  Pause(100)
 Loop
 if retro=1 then UnloadVGM
GoTo OPTIONS

'PLAYER SELECT
SELECTION:
Mode 3,16

if retro=1 then UnloadVGM
PAGE WRITE 0: CLS
PAGE WRITE 2: CLS: LOAD PNG ".\images\select.png",,,8
PAGE WRITE 4: CLS: LOAD PNG ".\IMAGES\ATARI_LOGO.PNG",0,0,8
PAGE WRITE 7: CLS: LOAD PNG ".\IMAGES\SELECTED.PNG",,,8

PAGE COPY 2 TO 0,I

Font #7
MV=0:MVS=0:tt=187

PlayWav("welcome",201,"V")
PAUSE(750)

if retro=1 then
 LoadVGM(".\vgm\SONG52.vgm")
 SetChannelType(1,"W")
 SetChannelType(2,"Q")
 SetChannelType(3,"W")
 SetChannelType(4,"N")
 PlayVGM
 ChangeSpeed(1.1):SetIntVGM(2)
else
 PlayMOD(2)
endif

PtypeA=0:XC=0:YC=0:EL=1:ER=6:xa=115:xb=124
xe(1)=6:xe(2)=2:xe(3)=3
xe(4)=1:xe(5)=5:xe(6)=4
TICKSND=0
xlogo=0:ylogo=0:delaylogo=0

do while keydown(1)=32
loop

tt=1
Do While (KB<>k_SPC And KB<>k_ESC) Or PTypeA=0
 PAGE COPY 2 TO 5,I
 PAGE WRITE 5
 tt=tt+1: if tt>6 then tt=1
 KB=KeyDown(tt)
 MINF$=MM.INFO$(SOUND)
 If KB=0 Then MV=0
 If MV=0 Then
  IF TICKSND>0 THEN
   TICKSND=TICKSND-1
   IF TICKSND=0 THEN
    IF RETRO=1 THEN PLAY SOUND 2,B,O,1,1:SetChannelType(2,"W")
   ENDIF
  ENDIF
  If (KB>=128 And KB<=131) Or (KB>=48 And KB<=57) Then
   TICKSND=5
   IF RETRO=1 THEN
    IF MINF$<>"WAV" THEN SetChannelType(2,""): PLAY SOUND 2,B,Q,700,25
   ELSE
    PlayWAV("SELECT2",100)
   ENDIF
  ENDIF
  If KB=K_U Or KB=K_N8 Then YC=YC-1
  If KB=K_D Or KB=K_N2 Then YC=YC+1
  If KB=K_L Or KB=K_N4 Then XC=XC-1
  If KB=K_R Or KB=K_N6 Then XC=XC+1
  If XC<0 Then XC=0
  If XC>1 Then XC=1
  If YC<0 Then YC=0
  If YC>1 Then YC=1
  If (KB>=128 And KB<=131) Or (KB>=48 And KB<=57) Then MV=1
 EndIf
 If XC=0 And YC=0 Then
  BLIT 0,0,0,0,160,100,7,0
  plname$="WARRIOR"
  PtypeA=1:CoP=4:Cmag=1:Csht=8:Cfig=8:TimeRAW=1000
  Cshs=3:Carm=4:Cspd=4:MaxEn=980:hpg=80:EL=4:ER=9
 ElseIf XC=0 And YC=1 Then
  BLIT 0,100,0,100,160,100,7,0
  plname$="VALKYRIE"
  PtypeA=2:CoP=3:Cmag=3:Csht=3:Cfig=6:TimeRAW=1200
  Cshs=5:Carm=8:Cspd=6:MaxEn=900:hpg=100:EL=5:ER=10
 ElseIf XC=1 And YC=1 Then
  BLIT 160,100,160,100,160,100,7,0
  plname$="WIZARD"
  PtypeA=3:CoP=6:Cmag=8:Csht=4:Cfig=1:TimeRAW=1100
  Cshs=8:Carm=0:Cspd=4:MaxEn=800:hpg=100:EL=3:ER=8
 ElseIf XC=1 And YC=0 Then
  BLIT 160,0,160,0,160,100,7,0
  plname$="ELF"
  PtypeA=4:CoP=2:Cmag=4:Csht=2:Cfig=2:TimeRAW=700
  Cshs=8:Carm=2:Cspd=8:MaxEn=820:hpg=120:EL=2:ER=7
 EndIf
 xa=xa+1.5: xb=xb-1.5
 tt=tt-3: If tt<187 Then tt=tt+19:xa=105:xb=134
 tc=tc+1: If tc>6 Then tc=1
 tcc=xe(tc)
 delaylogo=delaylogo+1
 if delaylogo>4 then
  ylogo=ylogo+19
  if ylogo>151 then ylogo=0: if xlogo=0 then xlogo=25 else xlogo=0
  delaylogo=0
 endif
 BLIT xlogo,ylogo,148,171,24,18,4,4
 PAGE COPY 5 TO 0,I
Loop
if retro=1 then StopVGM: UnloadVGM
If KB=k_ESC Then k=0: KB=0: GoTo OPTIONS
energy=MaxEn ': PlayWAV("SELECTED",100)
PlayWAV(PlName$,201,"V")
PAUSE(800)

PAGE COPY 5 TO 0,B
'if retro=1 then PlayRAW(".\raw\"+plname$+".raw",3500): PAUSE(800)
FirstLoad=1 

'STAGE LOADING SCREEN
'Cls
'Font #7
'Cls
'Load BMP ".\bmp\loading.bmp",0,3
'PrintF(30+34, 65+105,0,5,4,"ENTERING")
'PrintF(10+34, 90+105,0,5,4,"THE DUNGEON")

'START VIDEO SETTINGS AND PAGES
START_VIDEO:

'MAIN GAME
if retro=1 then song=INT(RND(123)*4+1) else song=10+room

FirstLoad=1: updOSD=1
MODE 3,ColDepth
COLOR RGB(255,255,255),RGB(0,0,0)
FOR T=0 TO 12: PAGE WRITE T: CLS: NEXT T

PAGE WRITE 12: CLS: LOAD PNG ".\IMAGES\PLAYERS_NEW.PNG",,,8
PAGE WRITE 3: CLS: LOAD PNG ".\IMAGES\ENEMIES1.PNG",,,8
PAGE WRITE 4: CLS: LOAD PNG ".\IMAGES\ENEMIES2.PNG",,,8
PAGE WRITE 5: CLS: LOAD PNG ".\IMAGES\ENEMIES3.PNG",,,8
PAGE WRITE 6: CLS: LOAD PNG ".\IMAGES\OBJECTS.PNG",,,8
PAGE WRITE 7: CLS: LOAD PNG ".\IMAGES\WALLS.PNG",,-17*0,8

PAGE WRITE 10
GoTo START_STAGE

' INSERT EXPLOSION
Sub PutExplosion(tp,x,y)
 Local T,tc,ok
 tc=0: ok=0
 Do While (tc<=10 And ok=0) 
  if expl(tc)=0 then
   xex(tc)=x:yex(tc)=y:ok=1:expl(tc)=1
   SELECT CASE tp 
    CASE 0: sprx(tc)=430:maxx(tc)=431: spdEx(tc)=1   ' MINI SPARKLES
    CASE 1: sprx(tc)=430:maxx(tc)=433: spdEx(tc)=1   ' THUNDER SPARKLES
    CASE 2: sprx(tc)=167:maxx(tc)=172: spdEx(tc)=1   ' SMOKE
    CASE 3: sprx(tc)=489:maxx(tc)=489: spdEx(tc)=0.2 ' 100 POINTS
   END SELECT
  endif
  tc=tc+1
 Loop 
End Sub

Sub PutEnemy(n)
 'Local tx,ty,t,tt,ok,sx,sy,xa,ya,xt,yt,tee,cee,enn,xb,yb,xc,yc,i,mov,spd,lev
 'Local xant,yant,PlHurt
 Local t
 If en(n)<=0 Then RetEnemy(n,0):Exit Sub
 xt=xe(n):yt=ye(n)
 If xt<=-16 Or xt>=240 Or yt<=-16 Or yt>=208 Then RetEnemy(n,ce(n)): GoSortEnemies=1: Exit Sub
 if lv(n)<0 then lv(n)=0
 cee=ce(n):enn=en(n):tee=te(n):xa=xt:ya=yt:lev=lv(n)*1000
 xb=Cint((xa+SCX)/16+xz):yb=Cint((ya+SCY)/16+yz)
 xant=(xa+SCX)/16+xz:yant=(ya+SCY)/16+yz
 If tee<>13 Then st(yb,xb)=0: BlockStage(xant,yant,-1)

 'WALKING ENEMIES
 IF tee Mod 2<>0 Then 
  sx=0:sy=0:spd=8
  SELECT CASE xa
   CASE <x: mov=3: sx=spd
   CASE >x: mov=7: sx=-spd
  END SELECT
  SELECT CASE ya
   CASE >y:
    sy=-spd
    SELECT CASE xa
     CASE <x: mov=2
     CASE >x: mov=8
     CASE  x: mov=1
    END SELECT
   CASE <y:
    sy=spd
    SELECT CASE xa
     CASE <x: mov=4
     CASE >x: mov=6
     CASE  x: mov=5
    END SELECT 
  END SELECT
  
  xa=xa+sx:ya=ya+sy: xb=(xa+SCX)/16+xz:yb=(ya+SCY)/16+yz: PlHurt=0
  'PAGE WRITE 3
  SELECT CASE sw
   CASE 0:
    tt=0: BlockStage(xb,yb,tt)
    IF tt>0 THEN xa=xt:xb=(xa+SCX)/16+xz: if tt>=30 and tt<=60 then PlHurt=1
    tt=0: BlockStage(xb,yb,tt)
    IF tt>0 THEN ya=yt:yb=(ya+SCY)/16+yz: if tt>=30 and tt<=60 then PlHurt=1
   CASE ELSE
    tt=0: BlockStage(xb,yb,tt)
    IF tt>0 THEN ya=yt:yb=(ya+SCY)/16+yz: if tt>=30 and tt<=60 then PlHurt=1
    tt=0: BlockStage(xb,yb,tt)
    IF tt>0 THEN xa=xt:xb=(xa+SCX)/16+xz: if tt>=30 and tt<=60 then PlHurt=1
  END SELECT
  'PAGE WRITE 11

  'REMOVE ENEMY IF IS INSIDE PLAYER (EXCEPT DEAD AND SLIME)
  if xa=x and ya=y and tee<>9 and tee<>11 then RetEnemy(n,0): Exit Sub

  'If PlHurt=0 and xa=xt and ya=yt then
  ' xe(n)=xt:ye(n)=yt: BlockStage(xant,yant,-5)
  ' PutSpriteEnemy(ce(n)+Ean+lev,xt,yt): If tee<>13 Then st(yb,xb)=cee+5000
  ' Exit Sub
  'EndIf

  If ae(n)>1 Then xa=xt:ya=yt:ae(n)=ae(n)-1

  SELECT CASE tee   
   CASE  1: cee=200+Mov-1 'GHOST
   CASE  3: cee=224+Mov-1 'GRUNT   
   CASE  5:               'DEMON 
    cee=248+Mov-1: If Rnd(75)*1>0.40 And DFire=0 Then AddEnemy(xa,ya,13,445+Mov):DnFire=n
   CASE  7: cee=296+Mov-1 'SORCERER
   CASE  9:               'SLIME
    cee=344+Mov-1: mx=spd*(Int(Rnd(20)*3)-1):my=spd*(Int(Rnd(70)*3)-1):xa=xa+mx:sx=mx:ya=ya+my:sy=my
   CASE 11: cee=320+Mov-1 'DEAD
  END SELECT

  '** ATTACK ON PLAYER **
  if PlHurt=1 and start=0 then
   
   'PLAYER HURT SOUND
   xa=xt:ya=yt: updOSD=1
   
   'PLAYER FIGHT WITH THE ENEMY
   if mov<>0 then Enn=Enn-Cfig: Anim=1
   
   'DAMAGE ON PLAYER - PLAYER'S ARMOR
   if tee=1 or swi=0 then HurtSound(PTypeA): Energy=Energy-(tee*5)+(Carm*tee)/2:refresh=1
   If cee<=399 Then PutSpriteEnemy(cee+Ean+lev,xt,yt)

   'ENEMY ATTACK SOUND
   SELECT CASE tee
    CASE  1: xe(n)=xa:ye(n)=ya: RetEnemy(n,0): Noise(18000,5000,-120): Exit Sub
    CASE  3: If swi=0 Then PlaySFX(200,-50,40,0,40,"W"): PlayWAV("GRUNT_ATTACK",51)
    CASE  5: If swi=0 Then PlaySFX(120,-20,30,0,15,"W")
    CASE  7: If swi=0 Then PlaySFX(400,-80,240,0,40,"W")
    CASE  9: PlaySFX(2300,20,0,2400,10,"W"): PlayWAV("SLIME_ATTACK",99)
    CASE 11: PlaySFX(3200,-500,540,0,5,"W"): PlayWAV("DEAD_ATTACK",99): IF KILLDE=0 THEN KILLDE=1
    CASE <>13: st(Cint((yt+SCY)/16+yz),Cint((xt+SCX)/16+xz))=cee+5000      
   END SELECT

  '** FREE ENEMY - NO COLLISION **
  Else
    If en(n)>0 Then PutSpriteEnemy(cee+Ean+lev,xa,ya)
    If tee<>13 Then st(yb,xb)=cee+5000
  EndIf

 '** ENEMY GENERATORS **
 else
  atmp=xa-x:btmp=ya-y
  If (atmp*atmp)+(btmp*btmp)<=196 Then
   enn=enn-Cfig
  Else
   SELECT CASE tee
    CASE  0: 'GHOST GENERATOR
     SELECT CASE enn
      CASE 0 TO 3: tt=394: lev=0
      CASE 4 TO 6: tt=393: lev=1000
      CASE     >6: tt=392: lev=2000
     END SELECT
    CASE >0: 'OTHER GENERATORS
     SELECT CASE enn
      CASE 0 TO 4: tt=397: lev=0
      CASE 5 TO 8: tt=396: lev=1000
      CASE     >8: tt=395: lev=2000
     END SELECT
   END SELECT
   PutSpriteEnemy(tt+lev,xa,ya)
   'DEFINE GENERATOR TYPE
   gtp=1000 'GHOST AND GRUNT GENERATORS
   SELECT CASE tee
    CASE 4: tee=1200 'DEMON GENERATOR
    CASE 6: tee=1300 'SORCERER GENERATOR
   END SELECT
   st(yb,xb)=cee+gtp
   cee=tt
  EndIf

  ' ** GENERATE ENEMIES **
  If mv=0 Then
   If Rnd(1)>0.30 Then 'RANDOM SEED
    tx=Int(Rnd(320)*3)-1:ty=Int(Rnd(120)*3)-1
    If st(yb+ty,xb+tx)=0 Then
     'SIDE OF GENERATED ENEMIES
     SELECT CASE xa+tx*16
      CASE <x: mov=3
      CASE >x: mov=7
     END SELECT
     SELECT CASE ya+ty*16
      CASE >y:
       mov=1
       if xa+tx*16<x then mov=2 
       if xa+tx*16>x then mov=8
      CASE <y:
       mov=5
       if xa+tx*16<x then mov=4 
       if xa+tx*16>x then mov=6
     END SELECT
     'TYPE OF GENERATED ENEMIES
     SELECT CASE tee
      CASE 0: tt=200+Mov-1 'GHOST
      CASE 2: tt=224+Mov-1 'GRUNT
      CASE 4: tt=248+Mov-1 'DEMON
      CASE 6: tt=296+Mov-1 'SORCERER
     END SELECT
     AddEnemy(xa+tx*16,ya+ty*16,tee+1,tt+lev)
    EndIf
   EndIf
  EndIf
  PutSpriteEnemy(cee+lev,xa,ya)
 EndIf
 xe(n)=xa:ye(n)=ya: ce(n)=cee: en(n)=enn: lv(n)=fix(lev/1000)
 If enn<=0 Then RetEnemy(n,0) else BlockStage(xant,yant,-5)
End Sub


'SCAN MAP AND DRAW EACH BLOCK / RESPAWN A ENEMY
Sub MapScan
 Local xx,yy,t,tp,xc,yc,tps,s
 xz=px+1:yz=py+1:s=mapside
 If s<0 Then atmp=xa:xa=xb:xb=atmp
 'xa=0:xb=15:ya=0:yb=12:s=1
 PAGE WRITE 10 ': BOX xa,ya,xb-xa,yb-ya,0,RGB(0,0,0),RGB(0,0,0)
 For xx=xa To xb Step s
  For yy=ya To yb
   t=st(yy+yz,xx+xz):xc=xx*16-SCX:yc=yy*16-SCY
   if mv<0 then BOX xc,yc,16,16,0,RGB(0,0,0),RGB(0,0,0)
   'TO EXPLODE IN CORRECT POSITION OF 16X16 BLOCKS
   if t<0 then PutExplosion(abs(t),xc,yc):t=0:st(yy+yz,xx+xz)=0
   SELECT CASE t
    'REMOVE DOORS AND OTHERS
    CASE 0 TO 199:
     PutSprite(t,xc,yc,1): if (t=0 and clmap=1) or clmap=3 then BlockStage(xx+xz,yy+yz,-1)
    CASE 434: PutTile(434,xc,yc):If start>3 And start<=100 Then x=xc:y=yc ':st(yy+yz,xx+xz)=0
    CASE 1023: PutTile(611,xc,yc)
    CASE 400 TO 615,617 TO 999: PutTile(t,xc,yc)
    'ENEMIES
    CASE 200 TO 2999:
     if (start<=2 and clmap=0) or clmap=3 then
      SELECT CASE t
       'LEVEL 1
       CASE  200 TO  399,  595 TO  597,  695 TO  697: AddEnemy(xc-bx,yc-by,0,t):st(yy+yz,xx+xz)=0
       'LEVEL 2
       CASE 1200 TO 1399, 1595 TO 1597, 1695 TO 1697: AddEnemy(xc-bx,yc-by,0,t):st(yy+yz,xx+xz)=0
       'LEVEL 3
       CASE 2200 TO 2399, 2595 TO 2597, 2695 TO 2697: AddEnemy(xc-bx,yc-by,0,t):st(yy+yz,xx+xz)=0
      END SELECT
    endif
   END SELECT
  Next yy,xx

  'START STAGE - PLAYER RESPAWN SMOKE
  If start=1 Then
   start=0:PutExplosion(2,x,y):PlaySFX(33,-0.25,31,33,0,"P"):PlayWAV("BLOW_GENERATOR",101)
  EndIf
  clmap=0  
End Sub

'SCAN MAP AND CLEAR THE FLOOR
Sub MapClear
 Local xx,yy,s
 xz=px+1:yz=py+1:s=mapside
 If s<0 Then atmp=xa:xa=xb:xb=atmp
 PAGE WRITE 10
 For xx=xa To xb Step s
  For yy=ya To yb
   SELECT CASE st(yy+yz,xx+xz)
    CASE  0:
     BOX xx*16-SCX,yy*16-SCY,16,16,0,RGB(0,0,0),RGB(0,0,0)
     if clmap=1 or clmap=3 then BlockStage(xx+xz,yy+yz,-1)
    CASE <0: 
     PutExplosion(abs(st(yy+yz,xx+xz)),xx*16-SCX,yy*16-SCY):st(yy+yz,xx+xz)=0
     BOX xx*16-SCX,yy*16-SCY,16,16,0,RGB(0,0,0),RGB(0,0,0)
     if clmap=3 then BlockStage(xx+xz,yy+yz,-1)
   END SELECT
 next yy,xx
End Sub

'RENDER THE PLAYER
Sub YOU(C)
 MINF$=MM.INFO$(SOUND)
 SELECT CASE start
  'ON STAGE
  CASE 0: PutSpriteChar(C,x,y)
  'EXITING
  CASE 42 TO 100:  
   start=start-1
   if retro=1 then
    Play Sound 1,B,N,start-29,25
    Play Sound 2,B,P,start-29,25
    Play Sound 3,B,W,start-29,25
   else
    if start=99 then PlayWAV("EXIT",100)
   endif
   anim=-10:side=0:tspd=0:AnimSpr=AnimSpr+2:if AnimSpr>23 then AnimSpr=0
   PutSpriteChar(C,x,y) 
  CASE 31 TO 41:  
   if retro=1 then
    Play Sound 1,B,N,start-29,25
    Play Sound 2,B,P,start-29,25
    Play Sound 3,B,W,start-29,25
   else
    if start=40 then PlayWAV("MAGIC",100)
   endif
   anim=-10:side=0:AnimSpr=172-(start-31)\2 
   PutSprite(AnimSpr,x,y) 
  CASE 30:
   c=0:nextroom=1:room=room+1
   if music=1 and retro=1 Then StopVGM 
   AnimSpr=0:anim=0
   Noise(5000,10000,40):Noise(10000,18000,40)
   pause(100)
 END SELECT 
End Sub

Sub IntRAW
 Local t,Ra$
  'if RAWI>0 then
   Ra$=Input$(160,#3)
   For T=1 to 160 STEP 2 
    PLAY SOUND 1,B,Q,((Peek(Var Ra$,t)*256+Peek(Var Ra$,t+1)+32768)/6.6)+1,25
   Next T
   'PLAY SOUND 1,B,O,1,1
   If EOF(#3) Then Close #3: RAWI=0: SetTick 0,0,3: PLAY SOUND 1,B,O,1,1
  'endif
End Sub

'INTERRUPTION FOR SOUND EFFECTS
Sub IntSFX
 Local c,cc,t,cSFX,M$
 for cSFX=3 to 4
  c=snd(cSFX) 
  M$=MM.INFO$(SOUND)
  If c>=20 Then
   cc=sndc(cSFX):t=C-30:if t<1 then t=1
   If C<1 then C=1
   If C>19999 then C=19999
   DisableChannel(cSFX)
   IF M$<>"WAV" THEN
    SELECT CASE sndt$(cSFX)
     CASE "N": PLAY SOUND cSFX,B,N,C,vol(cSFX)
     CASE "W": PLAY SOUND cSFX,B,W,C,vol(cSFX)
     CASE "Q": PLAY SOUND cSFX,B,Q,C,vol(cSFX)
     CASE "T": PLAY SOUND cSFX,B,T,C,vol(cSFX)
     CASE "S": PLAY SOUND cSFX,B,S,C,vol(cSFX)
     CASE "P": PLAY SOUND cSFX,B,P,t,20      
    END SELECT
   ENDIF
   c=c+sndspd(cSFX)
   If c>sndmax(cSFX) And sndmax(cSFX)>0 Then c=1
   If c<sndmin(cSFX) And sndmin(cSFX)>0 Then c=1
  ElseIf c>0 and c<20 Then   
   IF M$<>"WAV" THEN PLAY SOUND cSFX,B,O,10,1
   c=0:EnableChannel(cSFX)
  EndIf:snd(cSFX)=c
 next cSFX
End Sub

'PLAY SOUND EFFECTS
Sub PlaySFX(sndTT,sndspdT,sndminT,sndmaxT,sndcT,type$)
 Local t
 t=sndchange
 if sndchange=3 then sndchange=4 else sndchange=3
 snd(t)=sndTT:sndspd(t)=sndspdT:sndmax(t)=sndmaxT:sndmin(t)=sndminT
 sndc(t)=sndcT:vol(t)=15:ok=1:sndt$(t)=type$ 
End Sub

'PLAY NOISE
Sub Noise(a,b,c)
 PlaySFX(a/70,c/2,a/70,b/70,0,"N")
End Sub

'PLAY DIGITAL SOUND EFFECTS WITH MOD MUSIC
Sub PlayWAV(sndname$,priority,type$)
 if (retro=0 or priority>200) and priority>=PrWav then 
  PrWav=priority  
  if music=1 and retro=0 then
   SELECT CASE type$
    CASE "S","": Play Effect "./SOUND/SFX/"+sndname$+".WAV",StopWAV
    CASE "V": Play Effect "./SOUND/NARRATOR/"+sndname$+".WAV",StopWAV
   END SELECT
  else
   if retro=1 then play stop
   SELECT CASE type$
    CASE "S","": Play WAV "./SOUND/SFX/"+sndname$+".WAV",StopWAV
    CASE "V": Play WAV "./SOUND/NARRATOR/"+sndname$+".WAV",StopWAV
   END SELECT
  endif
 endif
End Sub

'PLAY MOD FILE WHEN ENABLED
Sub PlayMOD(m)
 if retro=0 and music=1 then
  Play Stop: Play MODFile "./MOD/" + ModMus$(m) + ".mod", 22050
 endif
End Sub

'NOTIFY PRIORITY DIGITAL SFX AS ZERO
Sub StopWAV
 PrWav=0
End Sub

'FIX ENEMIES
Sub FixEnemies(a)
 Local t  
 For t=1 To maxg
  If ae(t)>0 And en(t)>0 Then
   xt=xe(t):yt=ye(t)
   If xt>=-16 And xt<=240 And yt>=-16 And yt<=208 Then
    If a=1 Then PutSpriteEnemy(ce(t),xt,yt) 'REDRAW
    If a=2 Then RetEnemy(t,ce(t)) 'MARK
    If a=3 Then RetEnemy(t,-1) 'RESET
    If a<0 And Int(Rnd(10)*cMag+1)<=cMag Then RetEnemy(t,0) 'MAGIC
   EndIf
  EndIf
 Next t
End Sub

' ## PRINT LOADING FONTS ##
Sub PrintF(x,y,ca,cb,cc,st$)
 Local T,TT,co
 'For T=-2 To 2
 ' Print@(x+t,y+3,1) CLR$(0);st$:Print@(x+3,y+t,1) CLR$(0);st$:Next t
 'For T=-2 To 2 Step 2:For TT=-2 To 2 Step 2
 ' Print@(x+T,y+TT,1) CLR$(cc);st$:Next tt,t
 'For T=-1 To 1 Step 2:For TT=-1 To 1 Step 2
 ' Print@(x+T,y+TT,1) CLR$(cb);st$:Next tt,t
 'Print@(x,y,1) CLR$(ca);st$
End Sub

' PLAYER'S HURT SOUND
Sub HurtSound(A)
 SELECT CASE A
  CASE 1,3:
   PlaySFX(200,-20,25,0,10,"W")
   IF MM.INFO$(SOUND)<>"WAV" THEN 
    if (retro=1 and rnd(88)>0.8) or retro=0 then PlayWAV("WARRIOR_WIZARD_HURT",251,"S")
   ENDIF
  CASE 2: PlaySFX(370,-20,195,0,15,"W")
   IF MM.INFO$(SOUND)<>"WAV" THEN
    if (retro=1 and rnd(88)>0.8) or retro=0 then PlayWAV("VALKYRIE_HURT",251,"S")
   ENDIF
  CASE 4: PlaySFX(290,-20,115,0,5,"W")
   IF MM.INFO$(SOUND)<>"WAV" THEN
    if (retro=1 and rnd(88)>0.8) or retro=0 then PlayWAV("ELF_HURT",251,"S")
   ENDIF
 END SELECT
End Sub

' ## VOICE ON GAME ## 
Sub VoiceOver(A$,V$,type)
 Local Co
 if retro=0 and music=1 then exit sub
 PAGE WRITE 0
 IF RETRO=1 THEN PLAY STOP
 PlayWAV(V$,999,"V")
 if type=0 then
  if start=1 then Co=RGB(0,0,0) else Co=RGB(255,0,0)
  Box MM.HRES/2-40-Len(A$)*4-10,MM.VRES/2-28, Len(A$)*8+20,31,2,Co,RGB(0,0,0)
  VOver$=""
  PrintS(MM.HRES/2-40-Len(A$)*4-8,MM.VRES/2-21,3,A$)
  do while MM.INFO$(SOUND)="WAV"
  loop
 else
  VOver$=A$  
 endif
 pause(300)
End Sub

' OPEN DOORS
Sub OpenDoor(xd,yd)
 Local xt,yt,ok,t
 For t=1 To 2
  xt=xd:yt=yd:ok=1
  Do While ok=1
   ok=0
   'FOLLOW THE DOOR ON BOTH SIDES
   If st(yt,xt)  >=490 and st(yt,xt)  <=504 Then ok=1:st(yt,xt)=0
   If st(yt-1,xt)>=490 and st(yt-1,xt)<=504 Then ok=1:st(yt-1,xt)=0:yt=yt-1
   If st(yt+1,xt)>=490 and st(yt+1,xt)<=504 Then ok=1:st(yt+1,xt)=0:yt=yt+1
   If st(yt,xt+1)>=490 and st(yt,xt+1)<=504 Then ok=1:st(yt,xt+1)=0:xt=xt+1
   If st(yt,xt-1)>=490 and st(yt,xt-1)<=504 Then ok=1:st(yt,xt-1)=0:xt=xt-1
  Loop
 Next t:clmap=1:start=2:x=xx:y=yy:mv=-1:ya=0:yb=12:xa=0:xb=15:mapclear:start=0
 start=2:x=xx:y=yy:start=0:mv=0:clmap=0:updOSD=1
End Sub

' LOAD MAP AND APPLY SOME CONVERTIONS
Sub LoadMap(File$)
 Local mx,my,t,A$,Tr,nt,PG,b%,c%,d%,e%
 Tr=0:x=16:y=16:px=1:py=1
 Open File$ For Input As #1
 Line Input #1,A$
 limL=1:limR=35
 PAGE WRITE 2: CLS RGB(0,0,0)
 For my=1 To 34
  For mx=1 To 38
   ConvertTable(Asc(Input$(1,#1))-32,t,PG)
   If mx<=34 Then    
    If t=12 Then
     st(my,mx)=0
     Do While x\16<>mx-px-2 Or y\16<>my-py-1
      If x\16<mx-px-2 Then x=x+16
      If x\16>mx-px-2 Then x=x-16
      If y\16<my-py-1 Then y=y+16
      If y\16>my-py-1 Then y=y-16
      If x<120 And px>1 Then x=x+16:px=px-1
      If y<88 And py>1 Then y=y+16:py=py-1
      If x>128 And px<35-15 Then x=x-16:px=px+1
      If y>96 And py<32-14 Then y=y-16:py=py+1
     Loop
    Else
     SELECT CASE t
      CASE 616: t=0
      CASE 1019 : t=0:Tr=Tr+1:xh(Tr)=mx:yh(Tr)=my 'MARK RANDOM EXIT
      CASE 200 TO 399: t=t+2000                   'ALL MONSTERS LEVEL 3 ON LOAD      
      CASE <=199: t=0                             'TRY TO REMOVE GARBAGE
     END SELECT
     ST(my,mx)=t
     if (t>0 and t<999) or t=1023 then
      box mx*2,my*2,2,2,1,rgb(255,255,255)
      'b%=(AStage%+(MM.hres*my*4)+mx*2)
      'POKE BYTE b%,RGB(127,127,127)
      'POKE BYTE b%+1,RGB(127,127,127)
      'POKE BYTE b%+MM.hres*2,RGB(127,127,127)
      'POKE BYTE b%+MM.hres*2+1,RGB(127,127,127)
     endif
    EndIf
   EndIf
 Next mx,my
 Close #1:If Tr>0 Then i=Int(Rnd(55)*Tr)+1:ST(yh(i),xh(i))=434 'CHOOSE RANDOM EXIT
 PAGE WRITE 0
 'PAGE COPY 9 TO 0,I: PAUSE (10000)
End Sub

' ADD ENEMY
Sub AddEnemy(xg,yg,tp,ch)
 Local tc,ok,i,xb,yb,t,tt,mov,energ,lvcg
 tc=0:ok=0 
 ' ADJUST LEVEL USING SPRITE NUMBER
 level=1
 if ch>2000 then ch=ch-2000:level=3
 if ch>1000 then ch=ch-1000:level=2
 Do While (tc<=maxg And ok=0 And tp<>13)
  tc=tc+1
  If ae(tc)=0 Then
   ok=1:xh(tc)=0:yh(tc)=0
   ' DEFINE TYPE AND LEVEL ON NUMBER OF SPRITE
   SELECT CASE ch     
    CASE  392 TO  394: tp=0:level=395-ch:energ=level*3           'GHOST GEN
    CASE  200 TO  223: ch=200:tp=1:energ=level*3                 'GHOST
    CASE  395 TO  397: tp=2:level=398-ch:energ=level*4           'GRUNT GEN
    CASE  224 TO  247: ch=224:tp=3:energ=level*4                 'GRUNT
    CASE  595 TO  597: tp=4:level=398-ch:ch=ch-200:energ=level*5 'DEMON GEN
    CASE  248 TO  271: ch=248:tp=5:energ=level*5                 'DEMON
    CASE  695 TO  697: tp=6:level=398-ch:ch=ch-300:energ=level*5 'SORCERER GEN
    CASE  296 TO  319: ch=296:tp=7:energ=level*3                 'SORCERER
    CASE  344 TO  367: ch=344:tp=9:energ=9999:level=3            'SLIME
    CASE  320 TO  343: ch=320:tp=11:energ=2500:level=3           'DEAD
   END SELECT
   level=level-1
   if tc>=0 and tc<=maxg then
    mov=0
    ' ENEMY SIDE
    if tp mod 2<>0 then
     SELECT CASE xg
      CASE <x: mov=3
      CASE >x: mov=7
     END SELECT
     SELECT CASE yg
      CASE >y:
       mov=1
       if xg<x then mov=2 
       if xg>x then mov=8
      CASE <y:
       mov=5
       if xg<x then mov=4 
       if xg>x then mov=6
     END SELECT
     mov=mov-1
    endif
    xe(tc)=xg:ye(tc)=yg:ae(tc)=3:te(tc)=tp:ce(tc)=ch+mov:en(tc)=energ:lv(tc)=level
   endif
  EndIf
 Loop
 ' DEMON'S FIRE
 If tp=13 And dfire=0 Then
  ' FIRE SIDE    
  If ch=446 Then xfsd= 0:yfsd=-8
  If ch=447 Then xfsd= 8:yfsd=-8
  If ch=448 Then xfsd= 8:yfsd= 0
  If ch=449 Then xfsd= 8:yfsd= 8
  If ch=450 Then xfsd= 0:yfsd= 8
  If ch=451 Then xfsd=-8:yfsd= 8
  If ch=452 Then xfsd=-8:yfsd= 0
  If ch=453 Then xfsd=-8:yfsd=-8
  xfd=xg:yfd=yg:sprDF=ch
  xb=(xfd+xfsd+SCX)/16+xz:yb=(yfd+yfsd+SCY)/16+yz:t=0.5:tt=0:dfire=1
  firstfd=2:fstartd=0:tt=0
  ' DON'T SHOT NEAR WALLS
  For t=0 To 0.5 Step 0.5
   If st(yb,xb)<>0 Or st(yb-t,xb)<>0 Or st(yb,xb-t)<>0 Or st(yb-t,xb-t)<>0 Then tt=1
  Next t
  For t=0 To 0.5 Step 0.5
   If st(yb,xb)=617 Or st(yb-t,xb)=617 Or st(yb,xb-t)=617 Or st(yb-t,xb-t)=617 Then tt=0
  Next t
  if tt=1 then dfire=0: DnFire=0
  If dfire<>0 Then PlaySFX(210,-50,10,0,10,"W"): PlayWAV("WIZARD_SHOT",51)
 EndIf
End Sub

' RETURN ENEMY TO STAGE ARRAY
Sub RetEnemy(n,gr)
 Local t,xt,yt,a
 If ae(n)=0 Then Exit Sub
 xt=(xe(n)+SCX)/16+xz:yt=(ye(n)+SCY)/16+yz 
 If xt>0 And yt>0 And xt<37 And yt<37 Then 
  if gr>0 then gr=ce(n)+lv(n)*1000 'else BlockStage(xt,yt,-1)
  if gr=0 then GoSortEnemies=1
  st(yt,xt)=gr
 EndIf
 If gr<0 Then en(n)=-1 Else ae(n)=0:en(n)=0:xe(n)=-64:ye(n)=-64:xh(n)=0:yh(n)=0
End Sub

' SORT ENEMIES ARRAY TO SPEED UP
Sub SortEnemies
 Local t,i,l
 if cntg=1 then Exit Sub
 For t=2 to cntg
  if ae(t)>0 and ae(t-1)=0 then
   for i=t to cntg
    ae(i-1)=ae(i):te(i-1)=te(i):ce(i-1)=ce(i):en(i-1)=en(i)
    xe(i-1)=xe(i):ye(i-1)=ye(i):lv(i-1)=lv(i)
    ae(i)=0
   next i        
  endif
 next t
 GoSortEnemies=0
End Sub

' **** MAIN GAME LOOP ****
GAMELOOP:
If nextroom=1 Then nextroom=0:GoTo NEXTLEVEL

' KEYB/PAD ROTINES
If start=0 Then
 k=KeyDown(1):ka$=UCase$(Chr$(k))
Else
 k=0:ka$=""
EndIf

mov=0: xx=x:yy=y
mv=0: If nowalk>0 Then k=0:nowalk=nowalk-1

' PAUSE
'If ka$="P" And pausegame=0 Then
' PAUSEGAME=1
' Do While ka$="P": k=KeyDown(1):ka$=UCase$(Chr$(k)): Loop
' Do While ka$<>"P": k=KeyDown(1):ka$=UCase$(Chr$(k)): Loop
'Else
' PAUSEGAME=0
'EndIf

' MAGIC
If ka$="M" And bomb>0 Then 
 For t=1 To maxg:If ae(t)>0 Then PutSprite(432,xe(t),ye(t),11)
 Next t
 updOSD=1:bomb=bomb-1
 PlaySFX(550,-35,150,0,30,"W"): PlayWAV("MAGIC",100)
 Noise(8000,1000,-40):FixEnemies(-1)
EndIf

' DIRECTIONAL
spx=0: spy=0: Pup=0: Pdown=0: Pright=0: Pleft=0: k=0: kspace=0
for t=1 to 3
 if start=0 then k=keydown(t) 
 If k=K_N8 or k=K_U Then spy=-spd: side=0: mov=1: Pup=1:    plu=1: pld=0
 If k=K_N2 or k=K_D Then spy= spd: side=4: mov=1: Pdown=1:  pld=1: plu=0
 If k=K_N4 or k=K_L Then spx=-spd: side=6: mov=1: Pleft=1:  pll=1: plr=0
 If k=K_N6 or k=K_R Then spx= spd: side=2: mov=1: Pright=1: plr=1: pll=0
 If k=K_ESC Then 
  IF MUSIC=1 and retro=1 Then UnloadVGM
  PAGE WRITE 0
  mode 1: cls: end
 endif
 If k=K_SPC then if fire=0 then kspace=1 else spd=0: Anim=0: AnimSpr=0: tspd=0
next t

' PLAYER ANIMATION AND SPEED
spd=0
if start=0 then
 if mov=1 then tspd=tspd+cspd
 if mov=0 then Anim=0: AnimSpr=0: tspd=0
 If tspd>8 Then
  tspd=tspd-8
  spd=8
  Anim=Anim+1: if Anim>3 then Anim=0 
  SELECT CASE Anim
   CASE 0: AnimSpr=0
   CASE 1: AnimSpr=8
   CASE 2: AnimSpr=0
   CASE 3: AnimSpr=16
  END SELECT
 endif
endif

' PLAYER SHOOTING ANIMATION
if fire>0 and start=0 then
 SELECT CASE firstf
  CASE 0 TO 1: Anim=3: AnimSpr=16
  CASE 2 TO 5: Anim=0: AnimSpr=24
  CASE 6:      Anim=3: AnimSpr=16
 END SELECT
endif

' POINT TO THE DIRECTION
if Pup=1 then
 y=y-spd
 if Pleft=0 then pll=0 else side=7
 if Pright=0 then plr=0 else side=1
endif
If Pdown=1 then
 y=y+spd
 if Pleft=0 then pll=0 else side=5
 if Pright=0 then plr=0 else side=3
endif
if Pleft=1 then
 x=x-spd
 if Pup = 0 then plu=0
 if Pdown= 0 then pld=0
endif
if Pright=1 then
 x=x+spd
 if Pup = 0 then plu=0
 if Pdown= 0 then pld=0
endif
spd=8

' SCREEN "ROTATION" (HORIZONTAL SCROLL)
If x<0 And spx<0 Then px=limR-16:x=240-16:SCX=0:xx=x:xxx=x:atmp=1:mapside=1
If x>240-16 And spx>0 Then px=limL:x=0:SCX=0:xx=x:xxx=x:atmp=1:mapside=-1
If atmp=1 Then
 Dfire=0:xfd=-64:yfd=-64:PAGE WRITE 10: CLS RGB(0,0,0):clmap=3
 start=0:mv=0:ya=0:yb=12:xa=0:xb=15:FixEnemies(2):mapscan:start=0
EndIf

' PLAYER COLLISION
If start=0 Then
For tx=0 To 1
 For ty=0 To 1
  rx=(x-tx*spd+SCX)/16+xz:ry=(y-ty*spd+SCY)/16+yz: if rx>=0 and ry>=0 then US=st(ry,rx)
  page write 1: print @(0,0) "_"+STR$(US)
  SELECT CASE US
   'KEY
   CASE 444:
    if key<=9 Then
     score=score+15:Key=Key+1:updOSD=1:anim=0:If SAVEKE=0 Then SAVEKE=1
     PlaySFX(1500,-250,800,0,50,"W"):mv=-1:st(ry,rx)=0:x=xx:y=yy
     PlayWAV("KEY",60)
    endif
   'TREASURE
   CASE 455:
    score=score+100:anim=0:updOSD=1:If GETTRE=0 Then GETTRE=1
    PlaySFX(1000,1500,0,8000,50,"Q"):mv=-1:st(ry,rx)=-3:x=xx:y=yy
    PlayWAV("TREASURE",60)
   'DOOR
   CASE 490 TO 504:
    if (key>0) Then
     key=key-1:anim=0:PlaySFX(200,-25,100,0,25,"N")
     if (retro=1 and music=0) or retro=0 then PlayWAV("OPEN_DOOR",250)
     OpenDoor(rx,ry): refresh=1: x=xx: y=yy: updOSD=1
    endif
   CASE 426, 427:
    'FOOD
    score=score+25:PlaySFX(25,50,0,300,15,"W"):PlaySFX(300,-30,25,0,10,"W"):mv=-1
    st(ry,rx)=0:Energy=Energy+hpg:updOSD=1:anim=0:If Energy>MaxEn Then Energy=MaxEn
    SELECT CASE PtypeA
     CASE 1: PlayWAV("WARRIOR_FOOD",262)
     CASE 2: PlayWAV("VALKYRIE_FOOD",262)
     CASE 3: PlayWAV("WIZARD_FOOD",262)
     CASE 4: PlayWAV("ELF_FOOD",262)
    END SELECT
    x=xx:y=yy
   CASE 459:
    if bomb+key<13 Then
    'POTION
    score=score+25:bomb=bomb+1:updOSD=1:anim=0:If SAVEPO=0 Then SAVEPO=1
    PlaySFX(650,100,0,850,50,"W"):mv=-1:st(ry,rx)=0:x=xx:y=yy
    PlayWAV("GET_MAGIC",61)
    endif
   CASE 434:
    'EXIT
     start=100:mv=-4:anim=0:x=xx:y=yy
     PlayWAV("EXIT",100): if retro=1 and music=1 then UnloadVGM
   CASE 617:
    'FREEZE FLOOR
     getone=1:st(ry,rx)=0:Noise(12000,500,-40):mv=-1:nowalk=40:anim=0:x=xx:y=yy
     PlayWAV("FLOOR_FREEZE",61)
  END SELECT
  if start=0 then
   SELECT CASE US
    CASE 200 TO 1000, 1023, 1392 TO 1397, 1592 TO 1597, 1692 TO 1697:
     if Anim Mod 2=0 then
      x=xx: rx=(x-tx*spd+SCX)/16+xz: if st(ry,rx)<>0 then y=yy
     else 
      y=yy: ry=(y-ty*spd+SCY)/16+yz: if st(ry,rx)<>0 then x=xx
     endif
   END SELECT
  endif
Next ty,tx
EndIf

' DEFINE PLAYER SPRITE WHEN NOT MOVING
If mov<>0 Then
 If fstart<4 And fire>0 Then Anim=0
Else
 Anim=0
EndIf

' RESPOND TO SHOT ONLY AFTER VERIFY PLAYER COLLISION
if kspace=1 then
 fire=1:firstf=6
 SELECT CASE PtypeA
  CASE 1: PlaySFX(25,200,1000,2500,0,"N"): PlayWAV ("WARRIOR_SHOT",50)
  CASE 2: PlaySFX(31,5,0,41,0,"P"): PlayWAV ("VALKYRIE_SHOT",50)
  CASE 3: PlaySFX(34,-1,31,34,0,"P"): PlayWAV ("WIZARD_SHOT",50)
  CASE 4: PlaySFX(3200,-600,1300,0,11,"P"):PlaySFX(31,10,0,51,0,"P"): PlayWAV ("ELF_SHOT",50)
 END SELECT
 xfs=0:yfs=0:shotv=0:tac=0
 If Plu=1 Then yfs=-8:xs=32
 If Pld=1 Then yfs= 8:xs=36
 If Pll=1 Then xfs=-8:xs=38
 If Plr=1 Then xfs= 8:xs=34
 If Plu=1 And Plr=1 Then xs=33
 If Plu=1 And Pll=1 Then xs=39
 If Pld=1 And Plr=1 Then xs=35
 If Pld=1 And Pll=1 Then xs=37 
 xf=x+xfs:yf=y+yfs:fstart=0:repFire=1:If cshs>=8 Then repFire=2
 if PTypeA=0 then xs=xs-8
 'if PTypeA<>1 then xf=xf+xfs:yf=yf+yfs
 'PutspriteChar(xs,xf,yf)
 ' CANCEL SHOT NEAR WALL TO FIX KILLING ENEMY ON OTHER WALL SIDE
 For tx=0 To 1:For ty=0 To 1
  txx=(xf+xfs+SCX)/16+xz-tx/2:tyy=(yf+yfs+SCY)/16+yz-ty/2
  US=st(tyy,txx)
  if txx<34 and tyy<34 and US<>0 and US<=1055 and US<>617 and US<>799 and US<>1023 then
   fire=2
  endif
 next ty,tx
EndIf

' *FIX* ELF SHOT THAT DISSAPEAR WHEN DEMON FIRE AT SAME TIME
If cshs>=4 and cshs<=7 And tac=0 Then repFire=1 Else repFire=2
'repFire=2
repD=-1:If dfire>0 Then repFire=repFire+1:repD=repFire

' ** PLAYER SHOT LOOP **
rept=0:h=15
'if fire=2 then PutSpriteChar(xs,xf,yf)
Do While rept<repFire
 rept=rept+1
 ' DEMON FIRE
 If dfire>0 And rept=repD Then
  xf2=xf:yf2=yf:xfa2=xfa:yfa2=yfa:fire2=fire:firstf2=firstf
  shotv2=shotv:xfs2=xfs:yfs2=yfs:xs2=sprDF:fstart2=fstart
  xf=xfd:yf=yfd:xfa=xfad:yfa=yfad:fire=dfire:firstf=firstfd
  shotv=shotvd:xfs=xfsd:yfs=yfsd:fstart=fstartd:xs=xs2
 EndIf

 ' ** EXECUTE ON SHOOTING **
 If fire=1 Then 
  firstf=firstf-1:xfa=xf:yfa=yf:fstart=fstart+1
  if rept<>repD then
   SELECT CASE PtypeA
    CASE 1:
     atmp=xfs: If atmp=0 Then atmp=yfs
     xs=xs+atmp/16
     If xs<32 and atmp<0 Then xs=39
     if xs>39 and atmp>0 Then xs=32
   END SELECT   
   shotv=shotv+cshs:If shotv>8 Then shotv=shotv-8:xf=xf+xfs:yf=yf+yfs
  else   
   xf=xf+xfs:yf=yf+yfs:shotv=0
  EndIf
  
  ' TEST WITH COLLISION MAP
  fireCol=0: BlockStage((xf+SCX)/16+xz,(yf+SCY)/16+yz,fireCol) 

  ' SHOT OFFSCREEN? 
  If xf<-16 Or xf>240 Or yf<-16 Or yf>=208 Then
   fire=2  
  Elseif fireCol>0 then ' ONLY WHEN FOUND A PIXEL IN THE COLLISION MAP
  ' SHOT COLLISION WITH ENEMIES
  tx=Abs(xfs)+h:ty=Abs(yfs)+h
  If xfs<>0 And yfs<>0 Then tx=h:ty=h
  if fire<>2 then
   For n=1 To cntg
    If ae(n)>0 And (n<>DnFire Or rept<>repD) Then
     xt=xe(n):yt=ye(n)
     If xt+tx>=xf And xt<=xf+tx And yt+ty>=yf And yt<=yf+ty Then
      en(n)=en(n)-(Csht*2):lv(n)=lv(n)-1
      xtf=xt:ytf=yt:cef=ce(n):tt=te(n)
      If rept=repd Then xtfd=xt:ytfd=yt      
      PutExplosion(0,xt,yt)
      If tt Mod 2=0 Then 'GENERATORS
       Noise(2000,10000-TT*10,40): PlayWAV("BLOW_GENERATOR",59)
      Else 'ENEMIES
       Noise(5000-TT*250,16000,150)
      EndIf
      If en(n)<=0 Then
       If rept<>repd Then score=score+(te(n)*5+5): updOSD=1
       RetEnemy(n,0):fire=2:PutExplosion(2,xt,yt)
      Else
       fire=3
      EndIf
      xf=xe(n):yf=ye(n)
      if lv(n)<0 then lv(n)=0
     EndIf
    EndIf
   Next n
  EndIf

  'SHOT COLLISION ON WALLS AND OBJECTS
  For tx=0 To 1:For ty=0 To 1
   txx=(xf+SCX)/16+xz-tx/2:tyy=(yf+SCY)/16+yz-ty/2
   If txx>34 Then txx=34
   If tyy>34 Then tyy=34
   if tyy>=0 and txx>=0 then US=st(tyy,txx) else US=0
   'DON'T BLOCK SHOT ON ENEMY STRINGS AND SHOCK FLOOR
   If US<>0 AND US<>617 AND US<=1055 Then
    'SHOT MAGIC POTION OR FOOD
    If US=426 Or US=459 Then
     mv=-2:fstart=2:atmp=US:PlaySFX(150,-35,10,0,30+(atmp-25)*15,"W")
     Noise(8000,1000,-60+(atmp-458)*15): PlayWAV("BLOW_GENERATOR",61)
     If atmp=459 Then 
      st(tyy,txx)=-1
      FixEnemies(-2): PlayWAV("MAGIC",100): IF SHOTPOT=0 THEN SHOTPOT=1      
     ELSE
      IF SHOTFOOD=0 THEN SHOTFOOD=1
      st(tyy,txx)=-2
     ENDIF
    EndIf
    'SHOT FALSE BLOCK OR HIDDEN EXIT
    If US=799 OR US=1023 Then
     Noise(2000,6000,30): PlayWAV("BLOW_GENERATOR",61)
     If rept<>repD Then      
      If US=799 Then ' FALSE BLOCK
       Atmp=-1
      else
       Atmp=434: PutExplosion(1,xf-tx*8+xfs,yf-ty*8+yfs) ' HIDDEN EXIT
      EndIf
      st(tyy,txx)=Atmp
     EndIf
     mv=-5:fstart=2
    EndIf
    PutExplosion(0,xf,yf)      
    If US>=400 Then fire=2    
   EndIf
  Next ty,tx  
 EndIf
 if rept=1 or (PTypeA=3 and sw=0) then PutSpriteChar(fix(xs),xf,yf)
 if dfire>0 and rept=repD then PutSprite(xs,xf,yf,11)

 'DEMON SHOT ON PLAYER
 If rept=repD And x+h>=xf And x<=xf+h And y+h>=yf And y<=yf+h Then
  HurtSound(PTypeA): Energy=Energy-22+Carm*2
  PutExplosion(0,xf,yf): fire=2  
 EndIf

EndIf 'fire=1
Loop
If rept=repD Then
 xfd=xf:yfd=yf:xfad=xfa:yfad=yfa:dfire=fire:firstfd=firstf
 shotvd=shotv:xfsd=xfs:yfsd=yfs:fstartd=fstart
 xf=xf2:yf=yf2:xfa=xfa2:yfa=yfa2:fire=fire2:firstf=firstf2
 shotv=shotv2:xfs=xfs2:yfs=yfs2:fstart=fstart2:xs=xs2
EndIf

'BLITTING / SCROLL / MAP LIMITS
blitScr=0:bx=0:by=0:u=0:d=0:l=0:r=0:i=0:BL=0:xxx=x:yyy=y:atmp=0

If (x<80 or l>0)  And px>limL    Then MVS=7:bx= spd:l=spd:x=x+spd:BL=1
If (y<80 or u>0)  And py>1       Then MVS=1:by= spd:u=spd:y=y+spd:BL=1
If (x>144 or r>0) And px<limR-16 Then MVS=3:bx=-spd:r=spd:x=x-spd:BL=1
If (y>96 or d>0)  And py<32-14   Then MVS=5:by=-spd:d=spd:y=y-spd:BL=1

scx=scx-l+r
scy=scy-u+d
if scx< 0 then scx=scx+16:px=px-1
if scx>15 then scx=scx-16:px=px+1
if scy< 0 then scy=scy+16:py=py-1
if scy>15 then scy=scy-16:py=py+1

' PAGE 11 - SPRITES
' PAGE 10 - STAGE + SPRITES
' PAGE  1 - STAGE ONLY

' PLAYER SPRITE
YOU(side+AnimSpr)

' ADJUST MAP SCAN SIZE
ya=0:yb=12:xa=0:xb=15:sgx=0:sgy=0
If start=1 Then MapScan
' SCROLLING
IF MVS<>0 THEN
 If u>0 And r>0 Then MVS=2
 If u>0 And l>0 Then MVS=8
 If d>0 And r>0 Then MVS=4
 If d>0 And l>0 Then MVS=6
 If BL=1 Then
  PAGE WRITE 10
  PAGE SCROLL 10,-r+l,-u+d,RGB(0,0,0)
  PAGE SCROLL 8,-r+l,-u+d    
  SELECT CASE MVS  
   CASE 1: ya= 0:yb= 0:sgy=spd:MapScan
   CASE 2: sgx=-spd:sgy=spd: xa= 0:xb=15:ya= 0:yb= 0:MapScan:xa=15:xb=15:ya= 0:yb=12:MapScan
   CASE 3: xa=15:xb=15:sgx=-spd:MapScan
   CASE 4: sgx=-spd:sgy=-spd:xa=15:xb=15:ya= 0:yb=12:MapScan:xa= 0:xb=15:ya=12:yb=12:MapScan
   CASE 5: ya=12:yb=12:sgy=-spd:MapScan
   CASE 6: sgx=spd:sgy=-spd: xa= 0:xb=15:ya=12:yb=12:MapScan:xa= 0:xb= 0:ya= 0:yb=12:MapScan
   CASE 7: xa= 0:xb= 0:sgx=spd:MapScan
   CASE 8: sgx=spd:sgy=spd:  xa= 0:xb= 0:ya= 0:yb=12:MapScan:xa= 0:xb=15:ya= 0:yb= 0:MapScan
  END SELECT
 EndIf
 blitScr=1
EndIf

If mv>=-5 And mv<=-1 Then
 If mv=-1 or mv=-4 Then
  atmp=x+sgx+(x Mod 16):btmp=y+sgy+(y Mod 16):t=2  
 Else
  clmap=1:atmp=xf+sgx+(xf Mod 16):btmp=yf+sgy+(yf Mod 16):t=2
 EndIf
 xa=atmp/16-t:ya=btmp/16-t:xb=atmp/16+t:yb=btmp/16+t
 If ya<0  Then ya=0
 If xa<0  Then xa=0
 If xa>15 Then xa=15
 If xb>15 Then xb=15
 If ya>12 Then ya=12
 If yb>12 Then yb=12
 If mv=-1 or mv=-2 then MapClear else MapScan
EndIf

' FPS / SPEED LIMITER
If start>0 Then start=start-1
If fstart<4 And fire>0 Then anim=1
if timer=ti then ti=ti+1
fps=1000\(Timer-TI):TI=Timer
Do While pausetimer>Timer 'And mv=0 And blitScr=0
Loop
pausetimer=Timer+50
tac=tac+1:If tac>2 Then tac=0:If tic=1 Then tic=0 Else tic=1

' ENEMY ANIMATION
Eanim=Eanim+1
SELECT CASE Eanim
 CASE 0 TO  2: Ean=0
 CASE 3 TO  5: Ean=8
 CASE 6 TO  8: Ean=0
 CASE 9 TO 11: Ean=16
 CASE 12     : Eanim=0: Ean=0
END SELECT

' SHOW COLLISION MAP FOR DEBUG
' PAGE WRITE 11: BLIT 100,0,0,0,80,80,2,0

' RESTORE COLLISION MAP
PAGE WRITE 2: BLIT 0,0,100,0,80,80,2,0 
PAGE WRITE 11

' ------- ENEMIES LOGIC --------

' COUNT ENEMIES ON SCREEN
cntg=0: actg=0
for t=1 to maxg
 if ae(t)>0 then cntg=t: actg=actg+1
next t

' SORT ENEMIES ARRAY TO SPEED UP
if GoSortEnemies=1 then SortEnemies

' MOVE ENEMIES ON SCROLL
If blitScr=1 Then
 If fire>0 Then xf=xf+sgx:yf=yf+sgy:xfa=xfa+sgx:yfa=yfa+sgy:xtf=xtf+sgx:ytf=ytf+sgy
 If dfire>0 Then
  xfd=xfd+sgx:yfd=yfd+sgy:xfad=xfad+sgx
  yfad=yfad+sgy:xtfd=xtfd+sgx:ytfd=ytfd+sgy
 EndIf
 for t=1 to cntg
  if ae(t)>0 then xe(t)=xe(t)+sgx:ye(t)=ye(t)+sgy
 next t
endif

' CONTROL SPEED OF ENEMIES
t=FIX(actg\10)-1
eini=eini+1:stp=3+t:if eini>stp+2+t then eini=1: if swi=1 then swi=0 else swi=1

' INSERT PLAYER ON COLLISION MAP
BlockStage((x+SCX)/16+xz,(y+SCY)/16+yz,-30)

' INSERT ENEMIES ON COLLISION MAP
For t=1 to cntg
 if ae(t)>0 then BlockStage((xe(t)+SCX)/16+xz,(ye(t)+SCY)/16+yz,-5): EaIni(t)=0
next t

' CALL ACTIVE ENEMIES
PAGE WRITE 11
For t=eini To cntg step stp
 if ae(t)>0 then PutEnemy(t): EaIni(t)=1
Next t

' SHOW OTHER ENEMIES THAT ARE NOT ACTIVE IN THIS CYCLE
For t=1 To cntg
 if ae(t)>0 and EaIni(t)=0 then
  if te(t) mod 2<>0 then
   PutSpriteEnemy(ce(t)+Ean+lv(t)*1000,xe(t),ye(t))
  else
   PutSpriteEnemy(ce(t)+lv(t)*1000,xe(t),ye(t))
  endif
 Endif
Next t

PAGE WRITE 11

' ENERGY ACT AS A TIMER
If Timer > EnTime Or refresh=1 Then 
 EnTime=Timer+1000: If refresh=0 Then energy=energy-1 Else refresh=0 
EndIf

' FINISH PLAYER SHOT AND DEMON'S FIRE
If fstart>0 And fstart<6 and fire>0 And xf<=240 Then PutSpriteChar(side+AnimSpr,x,y)
If fire>=2 Then fire=0:xf=-64:yf=-64
If dfire>=2 Then dfire=0:xfd=-64:yfd=-64:DnFire=0

' SWAP VARIABLE
If sw=0 Then sw=1 Else sw=0

' EXPLOSION ANIMATION
For t=1 to 10
 if expl(t)>0 then
  xex(t)=xex(t)+sgx: yex(t)=yex(t)+sgy
  putsprite(FIX(sprx(t)),xex(t),yex(t),11)
  sprx(t)=sprx(t)+spdEx(t): if fix(sprx(t))>maxx(t) then expl(t)=0  
 endif
next t

' COPY FLOOR+STAGE+SPRITES TO BUFFER
PAGE WRITE 1                            'FLOOR + STAGE + SPRITES BUFFER
'PAGE COPY 8 TO 1,I ' FLOOR
BLIT 0,0,0,0,MM.HRES-80,MM.VRES-8,8,0   'FLOOR
BLIT 0,0,0,0,MM.HRES-80,MM.VRES-8,10,4  'STAGE
BLIT 0,0,0,0,MM.HRES-80,MM.VRES-8,11,4  'SPRITES

' SHOW TXT TO VOICE OVER
IF VOver$<>"" then 
 IF MM.INFO$(SOUND)="WAV" THEN
  PrintS(MM.HRES/2-40-Len(VOver$)*4-8,MM.VRES-8,0,VOver$)
 ELSE
  VOver$=""
  BOX 0,MM.VRES-8,MM.HRES-80,8,1,RGB(0,0,0),RGB(0,0,0)
 ENDIF
Endif

'  9 - FULL CURRENT COLLISION MAP
' 12 - CLEAN COLLISION MAP

' COPY FLOOR+STAGE+SPRITES TO MAIN PAGE

PAGE WRITE 0:  BLIT 0,0,0,0,MM.HRES-80,MM.VRES,1,0

' CLEAR SPRITES PAGE
PAGE WRITE 11: CLS

' ON SCREEN DISPLAY -  # BOMB  & ENERGY  \ KEY
PAGE WRITE 0
Pln=1: T=MM.HRES-81: TT=74+(Pln-1)*76 
printG(T+8,TT,RIGHT$("000"+STR$(energy),4)+"/"+RIGHT$("000"+STR$(maxen),4))
printG(T,   MM.VRES-8,RIGHT$("0"+STR$(fps),2))
printG(T+30,MM.VRES-8,RIGHT$("0"+STR$(cntg),2))
if UpdOSD=1 then
 UpdOSD=0
 printG(T,TT+20,"$"+RIGHT$("00000"+STR$(score),6))
 'KEY=4: BOMB=2
 box T+4,TT+10,72,10,1,RGB(0,0,0),RGB(0,0,0)
 IF KEY>0 THEN FOR TTT=1 TO KEY: printG(T+(TTT-1)*6,TT+10, "\"): NEXT TTT
 IF BOMB>0 THEN FOR TTT=1 TO BOMB: printG(T+60-(TTT-1)*6,TT+10, "#"): NEXT TTT
endif

' CALL FIRST VOICE OVERS
If GETTRE=1 Then GETTRE=2:VoiceOver("TREASURE 100 POINTS","treasure 100 points")
If SAVEKE=1 Then SAVEKE=2:VoiceOver("SAVE KEYS TO OPEN DOORS","save keys open doors")
If SAVEPO=1 Then SAVEPO=2:VoiceOver("SAVE POTIONS FOR LATER USE","save potions")
If SHOTFOOD=1 Then SHOTFOOD=2:VoiceOver("REMEMBER, DON'T SHOOT FOOD!","remember dont shoot food")
If SHOTPOT=1 Then SHOTPOT=2:VoiceOver("YOU JUST SHOOT THE POTION!","you shot potion")
If KILLDE=1 Then KILLDE=2:VoiceOver("USE MAGIC TO KILL DEATH!","magic kill death")

GoTo GAMELOOP


' (RE)START STAGE
START_STAGE:

PAGE WRITE 13: CLS: LOAD PNG ".\fonts\fonts.png",,,1

CStage% = MM.INFO(PAGE ADDRESS  2)     ' CLEAN COLLISION MAP
FStage% = MM.INFO(PAGE ADDRESS  2)+100 '  FULL COLLISION MAP

speeds=2:Anim=1:side=3:GoSortEnemies=1
scx=0:scy=0:difwall=(room-1)*18:VOver$=""
bg=1:time=0:Plu=0:Pld=0:Pll=0:Plr=1:nowalk=0:tspd=8

'RESET SOUND
For t=1 To ms:snd(t)=0:Next t:FixEnemies(3)
'RESET EXPLOSIONS
For t=1 To 10:expl(t)=0:Next t
A$="":B$="":C$="":If room<10 Then A$="0"
'If B$<>"" Then PRINT B$: PlayRAW(".\raw\"+C$+".raw",0,1.8):Pause(300)
PLAY STOP
LoadMap(".\maps\room"+A$+Str$(room)+".map"):B$="":C$=""

for t=1 to maxg: ae(t)=0: next t 'DISABLE ALL ENEMIES FOR THE NEXT ROOM
nextroom=0:start=1:refresh=1
If FirstLoad=1 Then FirstLoad=0:Cls
COLOR RGB(255,255,255),RGB(0,0,0): updOSD=1
CreateFloor
PAGE WRITE 0: CLS RGB(0,0,0): LOAD PNG "./IMAGES/PANEL.PNG",MM.HRES-79,0
PanelStatus(PTypeA,1)

IF troom=1 then VoiceOver("WELCOME TO THE TREASURE ROOM","welcome treasure")

SELECT CASE room
 CASE 3: VoiceOver("SOME WALLS MAY BE DESTROYED","some walls")
 CASE 5: VoiceOver("BEWARE THE DEMON","beware demons") 
END SELECT

if retro=1 then SetTick 50,IntSFX,1
if Music=1 then 
 i=room:song=song+1
 if retro=1 then If song>4 Then song=1
 if retro=0 then if song>15 then song=1
 If troom=1 Then
  songf$="treasure":song=song-1
 Else
  songf$="song"+Str$(song)
 endif
 if retro=1 then    
  LoadVGM(".\vgm\"+songf$+".vgm")
  PlayVGM:ChangeSpeed(1):SetIntVGM(5)
  SetChannelVol(1,MusVol):SetChannelVol(2,MusVol):SetChannelVol(3,MusVol):SetChannelVol(4,MusVol)
  for t=1 to 15
   if songf$+".vgm"=SndTst$(t,2) then   
    SetChannelType(1,SndType$(t,1))
    SetChannelType(2,SndType$(t,2))
    SetChannelType(3,SndType$(t,3))
    SetChannelType(4,SndType$(t,4))
   endif
  next t 
 else
  StopWAV: Play Stop: if Music=1 then if troom<>1 then PlayMOD(song) else PlayMOD(17)
 endif
endif

GoTo GAMELOOP

'STAGE LOADING SCREEN
LOADSCREEN:
If FirstLoad=0 Then
 'A$=Str$(room):A$=Space$(3-Len(A$))+A$:Line(0,0)-(176,215),0,bf
 'Font #2:PrintF(34-Len(A$),85,1,3,7,"LEVEL:"+A$)
 'Font #1:Font Unload #4:Font Load ".\fnt\gauntnes.fnt" As #4
 'Font #4:Print @(241-8*Len(Str$(room)),29) CLR$(7) room
EndIf
if retro=1 then LoadVGM(".\vgm\start.vgm"):PlayVGM:ChangeSpeed(1):SetIntVGM(1)
t=Timer+2500: i=room
If i=4 Or i=8 Then troom=1 Else troom=0
if retro=1 then StopVGM: UnloadVGM
'Sprite Load ".\spr\ingame2.spr"
GoTo START_STAGE


NEXTLEVEL:
 PAGE WRITE 10: CLS
 PAGE WRITE 11: CLS
 PAGE WRITE 1: CLS
GoTo LOADSCREEN
