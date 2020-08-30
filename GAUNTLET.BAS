OPTION BASE 0

CLEAR

Version$="v0.4a"

#INCLUDE "ENEMIES.INC"
#INCLUDE "PRINT.INC"
#INCLUDE "LOAD_MAP.INC"
#INCLUDE "SOUND.INC"

GoTo INIT

Sub PlaySample(N,S)
 local t
 for t=1 to 4
  if MM.INFO(SAMPLE PLAYING t)=0 THEN PLAY MODSAMPLE N,t,64,S: exit for
 next t
End Sub

' REFRESH STATUS PANEL WITH CHARACTER PHOTO FOR PLAYER N 
Sub PanelStatus(type,n)
 Local X,Y,A$
 X=MM.HRES-34: Y=40+(n-1)*76 
 PAGE WRITE 0: BLIT (PType(n)-1)*34,170,X,Y,30,30,12,4
 BOX X-33,Y+2,9,30,0,RGB(0,0,0),RGB(0,0,0)
 BOX X-13,Y+2,9,30,0,RGB(0,0,0),RGB(0,0,0)
 PrintG(x-38,y+ 3,str$(Cmag(n)))
 PrintG(x-38,y+13,str$(Csht(n)))
 PrintG(x-38,y+23,str$(Cfig(n)))
 PrintG(x-18,y+ 3,str$(Cspd(n)))
 PrintG(x-18,y+13,str$(Carm(n)))
 PrintG(x-18,y+23,str$(Cshs(n)))
 PrintG(x-12-Len(PlName$(n))*3,y+65,PlName$(n))
 Box x-7-Len(PlName$(n))*3,y+65,1,8,1,rgb(0,0,0),rgb(0,0,0)
 A$="ROOM "+STR$(room)
 PrintG(x-12-Len(A$)*3,27,A$)
 'PtypeA=4:CoP=2:Cmag=3:Csht=2:Cfig=2
 'Cshs=8:Carm=2:Cspd=4:MaxEn=820:hpg=120:EL=2:ER=7
End Sub

' SHOW MAIN CHARACTER
Sub PutSpriteChar(spr,pl,xtt,ytt)
 spr=spr+(PType(pl)-1)*40 
 YTp=FIX(SPR*17/306)*17
 XTp=(SPR MOD 18)*17
 PAGE WRITE 3: BLIT XTp,YTp,Xtt,Ytt,16,16,12,4
End Sub

' GENERAL TILE
Sub PutTile(spr,x,y)
 sprt=spr
 SELECT CASE SPRt
  CASE 400 TO 599: PGe=8: SPRt=SPRt-400
  CASE 600 TO 798: PGe=9: SPRt=SPRt-600+difwall
  CASE 799       : PGe=9: SPRt=11+difwall
 END SELECT   
 BLIT (SPRt MOD 18)*17,FIX(SPRt*17/306)*17,X,Y,16,16,PGe,4
End Sub

' GENERAL SPRITE
Sub PutSprite(spr,x,y,WRX)
 IF SPR=0 THEN EXIT SUB
 sprt=spr
 SELECT CASE SPRt
  CASE   0 TO 199: PGs=12:WRs=3
  'CASE 200 TO 399: PGs=9:WRs=3:SPRt=SPRt-200
  CASE 400 TO 599: PGs=8:WRs=1: SPRt=SPRt-400
  CASE 600 TO 798: PGs=9:WRs=1: SPRt=SPRt-600+difwall
  CASE 799       : PGs=9:WRs=1: SPRt=11+difwall
 END SELECT  
 IF WRX>0 THEN WRs=WRX
 IF PGs=1 THEN PGs=0
 PAGE WRITE WRs: BLIT (SPRt MOD 18)*17,FIX(SPRt*17/306)*17,X,Y,16,16,PGs,4
End Sub

' READ OR WRITE ON STAGE ARRAY CONVERTED TO PIXELS
Sub BlockStage(mx,my,r)
 if r<0 then mx=mx\1: my=my\1
 SELECT CASE r
  CASE >=0: ' READ PIXEL
   ad%=(FStage%+(dbR*2*my)+mx*2)
   r=r+PEEK(BYTE ad%)+PEEK(BYTE ad%+1)+PEEK(BYTE ad%+dbR)+PEEK(BYTE ad%+dbR+1)
  CASE -1:  ' CLEAR PIXEL
   ad%=(CStage%+(dbR*2*my)+mx*2)
   POKE BYTE ad%,0: POKE BYTE ad%+1,0: POKE BYTE ad%+dbR,0: POKE BYTE ad%+dbR+1,0
   ad%=(FStage%+(dbR*2*my)+mx*2)
   POKE BYTE ad%,0: POKE BYTE ad%+1,0: POKE BYTE ad%+dbR,0: POKE BYTE ad%+dbR+1,0
  CASE <-1: ' WRITE PIXEL
   ad%=(FStage%+(dbR*2*my)+mx*2)
   POKE BYTE ad%,-r: POKE BYTE ad%+1,-r: POKE BYTE ad%+dbR,-r: POKE BYTE ad%+dbR+1,-r
 END SELECT
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

'-- INITIAL BOOT --

INIT:

test=0 'test here
music=1:copyright=0

Cls

If (MM.INFO(VERSION) < 5.05) Then
 Print "THIS PROGRAM NEEDS A 5.05 FIRMWARE VERSION OR BETTER":Print
 End
EndIf

Mode 7,16: Cls
for t=0 to 8:page write t: cls: next t

CONST K_ESC=27,K_SPC=32,K_N0= 48,K_N2= 50,K_N4= 52,K_N6=54,K_N8=56
CONST K_U=128, K_D=129, K_L=130, K_R=131,K_NP= 80

maxg=80 'MAX ENEMIES IN SCREEN
plq=1: f=3
t=0: tt=0: ttt=0
dbR=MM.hres*2
Dim st(37,37),ModMus$(20,1)
Dim xe(maxg+3),ye(maxg+3), xh(maxg+3),yh(maxg+3),lv(maxg+3)
Dim ae(maxg+3),te(maxg+3), ce(maxg+3),en(maxg+3),EaIni(maxg+3)
DIM xex(10),yex(10),anx(10),sprx(10),spdEx(10),maxx(10),expl(10)
Dim SndTst$(100,2) LENGTH 100
Dim Crd$(80) LENGTH 100

Dim Ptype(4), CoP(4), Cmag(4), Csht(4), Cfig(4), Cshs(4), Carm(4), Cspd(4)
Dim MaxEn(4), energy(4), hpg(4), key(4), bomb(4), score(4), PlName$(4)
Dim x(4), y(4), xx(4), yy(4), xf(4), yf(4), xfs(4), yfs(4), xfa(4), yfa(4), xtf(4), ytf(4)
Dim side(4), fire(4), firstf(4), repFire(4), fstart(4), xs(4), ys(4), shotv(4), fireCol(4)
Dim animSpr(4), anim(4), mv(4), mov(4), tspd(4), spd(4), nowalk(4), kspace(4), timeRAW(4)
Dim plu(4),pld(4),pll(4),plr(4), start(4)
Dim CtrlType(4),CtrlChange(4)

If test>0 Then
 Ptype(1)=4:CoP(1)=2:Cmag(1)=3:Csht(1)=2:Cfig(1)=2:PlName$(1)="ELF"
 Cshs(1)=8:Carm(1)=2:Cspd(1)=8:MaxEn(1)=820:hpg(1)=120:EL=2:ER=7
 key(1)=3:bomb(1)=2:score(1)=0
 KILLDE=2:SAVEKE=2:SAVEPO=2:GETTRE=2:SHOTPOT=2:SHOTFOOD=2:energy(1)=maxEn(1)
Else
 for t=1 to 4
  key(t)=0:bomb(t)=0:score(t)=0
 next t
 KILLDE=0:SAVEKE=0:SAVEPO=0:GETTRE=0:SHOTPOT=0:SHOTFOOD=2
EndIf
Silence: actg=0:cntg=maxg:mapside=1

'STORE TEXT VARIABLES
#INCLUDE "INIT_TEXT.INC"


'-- GENERAL RESTART --

RESTART:

room=1

for t=0 to 4
 key(t)=0: bomb(t)=0: score(t)=0
next t

MusVol=10: clmap=0

if test=0 then KILLDE=0: SAVEKE=0: SAVEPO=0: GETTRE=0: SHOTPOT=0: SHOTFOOD=0
Play Stop: actg=0: cntg=maxg


'-- TITLE SCREEN --

INTRO:
#INCLUDE "INTRO.INC"

for t=7 to 0 step -1: k=keydown(t): next t
PAUSE(150)

'-- GAME OPTIONS --

OPTIONS:
#INCLUDE "OPTIONS.INC"


'-- SHOW CREDITS --

CREDITS:

 t=75: tt=0
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
GoTo OPTIONS


'-- PLAYER SELECT --

SELECTION:
#INCLUDE "PLAYER_SELECT.INC"


'-- START VIDEO SETTINGS AND PAGES --

START_VIDEO:

'MAIN GAME
song=7+room
if song=9 then song=10

updOSD=1
MODE 7,8

PLN=1

for t=1 to 2
 if CtrlType(t)=1 then ON ERROR SKIP 1: WII CLASSIC OPEN
 if CtrlType(t)=2 then ON ERROR SKIP 1: WII NUNCHUK OPEN
next t

COLOR RGB(255,255,255),RGB(0,0,0)
FOR T=0 TO 12: PAGE WRITE T: CLS: NEXT T

PAGE WRITE 12: CLS: LOAD PNG ".\IMAGES\PLAYERS_NEW.PNG",,,8
PAGE WRITE 5: CLS: LOAD PNG ".\IMAGES\ENEMIES1.PNG",,,8
PAGE WRITE 6: CLS: LOAD PNG ".\IMAGES\ENEMIES2.PNG",,,8
PAGE WRITE 7: CLS: LOAD PNG ".\IMAGES\ENEMIES3.PNG",,,8
PAGE WRITE 8: CLS: LOAD PNG ".\IMAGES\OBJECTS.PNG",,,8
PAGE WRITE 9: CLS: LOAD PNG ".\IMAGES\WALLS.PNG",,-17*0,8

PAGE WRITE 10
FRAMEBUFFER CREATE 640,640
FRAMEBUFFER WRITE

GoTo START_STAGE

' INSERT EXPLOSION
Sub PutExplosion(tp,xtt,ytt)
 tcEx=0: okEx=0
 Do While (tcEx<=10 And okEx=0) 
  if expl(tcEx)=0 then
   xex(tcEx)=xtt:yex(tcEx)=ytt:okEx=1:expl(tcEx)=1
   SELECT CASE tp 
    CASE 0: sprx(tcEx)=430:maxx(tcEx)=431: spdEx(tcEx)=1   ' MINI SPARKLES
    CASE 1: sprx(tcEx)=430:maxx(tcEx)=433: spdEx(tcEx)=1   ' THUNDER SPARKLES
    CASE 2: sprx(tcEx)=167:maxx(tcEx)=172: spdEx(tcEx)=1   ' SMOKE
    CASE 3: sprx(tcEx)=489:maxx(tcEx)=489: spdEx(tcEx)=0.2 ' 100 POINTS
   END SELECT
  endif
  tcEx=tcEx+1
 Loop 
End Sub


'SCAN MAP AND DRAW EACH BLOCK FOR FRAMEBUFFER
Sub Map_FrameBuffer

 'CREATE A BACKUP OF ALL STAGE (ONLY WALLS, FLOORS AND INDESTRUCTIBLE STRUCTURES)
 FRAMEBUFFER WRITE
 For xxm=0 To 35
  For yym=0 To 35
   tts=st(yym,xxm):xcm=xxm*16:ycm=yym*16
   PutTile(616,xcm,ycm)
   SELECT CASE tts
    CASE 434:  PutTile(434,xcm,ycm) 'EXIT
    CASE 1023: PutTile(434,xcm,ycm) 'HIDDEN EXIT
    CASE 600 TO 798: PutTile(tts,xcm,ycm): if tts=617 then PutTile(616,xcm,ycm)
   END SELECT
 Next yym,xxm
 FRAMEBUFFER BACKUP

 'CREATE BUFFER WITH ALL OBJECTS
 For xxm=0 To 35
  For yym=0 To 35
   tts=st(yym,xxm):xcm=xxm*16:ycm=yym*16
   PutTile(616,xcm,ycm)
   SELECT CASE tts
    CASE 0 TO 199: PutSprite(tts,xcm,ycm,1): if (tts=0 and clmap=1) or clmap=3 then BlockStage(xxm+xz,yym+yz,-1)
    CASE 434:  PutTile(434,xcm,ycm) 'EXIT
    CASE 1023: PutTile(611,xcm,ycm) 'HIDDEN EXIT
    CASE 400 TO 999: PutTile(tts,xcm,ycm)
   END SELECT
 Next yym,xxm
 PAGE WRITE 0

End Sub


'SCAN MAP AND DRAW EACH BLOCK / RESPAWN A ENEMY
Sub MapScan(pl)
 xz=px+1:yz=py+1:ss=mapside
 scx=(scx*8)\8: scy=(scy*8)\8
 If ss<0 Then atmp=xa:xa=xb:xb=atmp

 PAGE WRITE 10
 For xxm=xa To xb Step ss
  For yym=ya To yb
   tts=st(yym+yz,xxm+xz)

   'TO EXPLODE IN CORRECT POSITION OF 16X16 BLOCKS
   if tts<0 then PutExplosion(abs(t),xxm*16-SCX+BX,yym*16-SCY+BY):tts=0:st(yym+yz,xxm+xz)=0
   SELECT CASE tts
    CASE 0 TO 199:
     'PutSprite(tts,xxm*16-SCX+BX,yym*16-SCY+BY,1)
     'REMOVE DOORS AND OTHERS
     if (tts=0 and clmap=1) or clmap=3 then BlockStage(xxm+xz,yym+yz,-1)
    'EXIT
    CASE 434:
    'PutTile(434,xxm*16-SCX+BX,yym*16-SCY+BY)
     If start(pl)>3 And start(pl)<=100 Then x(pl)=xxm*16-SCX+BX:y(pl)=yym*16-SCY+BY
    'CASE 1023: PutTile(611,xxm*16-SCX+BX,yym*16-SCY+BY)
    'CASE 400 TO 599: PutTile(tts,xcm,ycm)
    'CASE 600 TO 798: PutTile(tts,xcm,ycm)
    'ENEMIES
    CASE 200 TO 2999:
     if ((start(pl)<=2 and clmap=0) or clmap=3) then
      SELECT CASE tts
       'LEVEL 1
       CASE  200 TO  399,  595 TO  597,  695 TO  697:
        AddEnemy(xxm*16-SCX+BX,yym*16-SCY+BY,0,tts,pl):st(yym+yz+by\16,xxm+xz+bx\16)=0
       'LEVEL 2
       CASE 1200 TO 1399, 1595 TO 1597, 1695 TO 1697:
        AddEnemy(xxm*16-SCX+BX,yym*16-SCY+BY,0,tts,pl):st(yym+yz+by\16,xxm+xz+bx\16)=0
       'LEVEL 3
       CASE 2200 TO 2399, 2595 TO 2597, 2695 TO 2697:
        AddEnemy(xxm*16-SCX+BX,yym*16-SCY+BY,0,tts,pl):st(yym+yz+by\16,xxm+xz+bx\16)=0
      END SELECT
    endif
   END SELECT
  Next yym,xxm

  'START STAGE - PLAYER RESPAWN SMOKE
  If start(pl)=1 Then start(pl)=0: PutExplosion(2,x(pl),y(pl)): PlaySample(15,22050)
  clmap=0  

End Sub

'SCAN MAP AND RESTORE FRAMEBUFFER TO THE CLEAN ONE (SLOWER TO PRECISE SCANNING)
Sub MapClear
 Local xx,yy,s
 xz=px+1:yz=py+1:s=mapside
 If s<0 Then atmp=xa:xa=xb:xb=atmp
 PAGE WRITE 10
 For xx=xa To xb Step s
  For yy=ya To yb
   For tx=-4 to 0 step 4
    For ty=-4 to 0 step 4
     xxz=((xx+xz)*16+tx+SCX)\16:yyz=((yy+yz)*16+ty+SCY)\16
     SELECT CASE st(yyz,xxz)
      CASE  0,434:
       FRAMEBUFFER WRITE: BOX xxz*16,yyz*16,16,16,0,,RGB(0,0,0)
       FRAMEBUFFER RESTORE xxz*16,yyz*16,16,16
       if clmap=1 or clmap=3 then BlockStage(xxz,yyz,-1)
      CASE <0: 
       FRAMEBUFFER WRITE: BOX xxz*16,yyz*16,16,16,0,,RGB(0,0,0)
       FRAMEBUFFER RESTORE xxz*16,yyz*16,16,16
       PutExplosion(abs(st(yyz,xxz)),xx*16-SCX,yy*16-SCY):st(yyz,xxz)=0
       if clmap=3 then BlockStage(xxz,yyz,-1)
     END SELECT
   next ty,tx
 next yy,xx
End Sub

'FASTER SCAN MAP AND RESTORE FRAMEBUFFER TO THE CLEAN ONE (USED TO OPEN DOORS)
Sub Fast_MapClear
 Local xx,yy,s
 xz=px+1:yz=py+1:s=mapside
 If s<0 Then atmp=xa:xa=xb:xb=atmp

 PAGE WRITE 10
 For xx=xa To xb Step s
  For yy=ya To yb
   xxz=((xx+xz)*16-4+SCX)\16:yyz=((yy+yz)*16-4+SCY)\16
   SELECT CASE st(yyz,xxz)
    CASE  0:
     FRAMEBUFFER WRITE: BOX xxz*16,yyz*16,16,16,0,,RGB(0,0,0)
     FRAMEBUFFER RESTORE xxz*16,yyz*16,16,16
     if clmap=1 or clmap=3 then BlockStage(xxz,yyz,-1)
    CASE <0: 
     FRAMEBUFFER WRITE: BOX xxz*16,yyz*16,16,16,0,,RGB(0,0,0)
     FRAMEBUFFER RESTORE xxz*16,yyz*16,16,16
     PutExplosion(abs(st(yyz,xxz)),xx*16-SCX,yy*16-SCY):st(yyz,xxz)=0
     if clmap=3 then BlockStage(xxz,yyz,-1)
   END SELECT
 next yy,xx
End Sub

'RENDER THE PLAYER
Sub YOU(C,pl)
 MINF$=MM.INFO$(SOUND)
 SELECT CASE start(pl)
  'ON STAGE
  CASE 0: PutSpriteChar(C,pl,x(pl),y(pl))
  'EXITING
  CASE 42 TO 100:  
   start(pl)=start(pl)-1
   if start(pl)=99 then PlayWAV("EXIT",100)
   anim(pl)=-10:side(pl)=0:tspd(pl)=0
   AnimSpr(pl)=AnimSpr(pl)+2:if AnimSpr(pl)>23 then AnimSpr(pl)=0
   PutSpriteChar(C,pl,x(pl),y(pl)) 
  CASE 31 TO 41:  
   if start(pl)=40 then PlaySample(22,22050)
   anim(pl)=-10:side(pl)=0:AnimSpr(pl)=172-(start(pl)-31)\2 
   PutSprite(AnimSpr(pl),x(pl),y(pl)) 
  CASE 30:
   c=0:nextroom=1:room=room+1
   AnimSpr(pl)=0:anim(pl)=0
   PlaySample(17,11000)
   pause(100)
 END SELECT 
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
 Next t:clmap=1:start(pl)=2:x(pl)=xx(pl):y(pl)=yy(pl):mv(pl)=-1
 ya=0:yb=15:xa=0:xb=15:fast_mapclear:start(pl)=0
 start(pl)=2:x(pl)=xx(pl):y(pl)=yy(pl):start(pl)=0:mv(pl)=0:clmap=0:updOSD=1
End Sub

' **** MAIN GAME LOOP ****
GAMELOOP:

DO 'GAME LOGIC

pl=PLN          ' RESET TO START LOGIC FROM FIRST PLAYER
sgxE=0: sgyE=0  ' TO MOVE OBJECTS WITH THE SCREEN SCROLL
MOVED=0         ' SOMEONE SCROLLED THE SCREEN?

DO 'PLAYER'S LOGIC

' KEYB/PAD ROTINES
If start(pl)=0 Then
 k=KeyDown(1):ka$=UCase$(Chr$(k))
Else
 k=0:ka$=""
EndIf

mov(pl)=0:xx(pl)=x(pl):yy(pl)=y(pl)
mv(pl)=0: If nowalk(pl)>0 Then nowalk(pl)=nowalk(pl)-1

' PAUSE
'If ka$="P" And pausegame=0 Then
' PAUSEGAME=1
' Do While ka$="P": k=KeyDown(1):ka$=UCase$(Chr$(k)): Loop
' Do While ka$<>"P": k=KeyDown(1):ka$=UCase$(Chr$(k)): Loop
'Else
' PAUSEGAME=0
'EndIf

' DIRECTIONAL
spx=0: spy=0: Pup=0: Pdown=0: Pright=0: Pleft=0: k=0: kspace(pl)=0
for t=1 to 5
 if start(pl)=0 then k=keydown(t) 
 'KEYBOARD
 if CtrlType(pl)=0 and nowalk(pl)=0 then 
  If k=K_N8 or k=K_U Then spy=-spd(pl): side(pl)=0: mov(pl)=1: Pup=1:    plu(pl)=1: pld(pl)=0
  If k=K_N2 or k=K_D Then spy= spd(pl): side(pl)=4: mov(pl)=1: Pdown=1:  pld(pl)=1: plu(pl)=0
  If k=K_N4 or k=K_L Then spx=-spd(pl): side(pl)=6: mov(pl)=1: Pleft=1:  pll(pl)=1: plr(pl)=0
  If k=K_N6 or k=K_R Then spx= spd(pl): side(pl)=2: mov(pl)=1: Pright=1: plr(pl)=1: pll(pl)=0
  If k=K_SPC then
   kspace(pl)=1: if fire(pl)<>0 then spd(pl)=0: Anim(pl)=0: AnimSpr(pl)=0: tspd(pl)=0
  endif
 endif
 If k=K_ESC Then 
  PAGE WRITE 0
  mode 1: cls: end
 endif
next t

'WII CLASSIC CONTROLLER
if CtrlType(pl)=1 and nowalk(pl)=0 then
 KC$=RIGHT$("00000000000000"+BIN$(CLASSIC(B,3)),14)
 LX=CLASSIC(LX,3)
 LY=CLASSIC(LY,3)
 if PEEK(VAR KC$, 7)=49 OR LY>195 then spy=-spd(pl): side(pl)=0: mov(pl)=1: Pup=1:    plu(pl)=1: pld(pl)=0 'UP
 if PEEK(VAR KC$, 9)=49 OR LY< 60 then spy= spd(pl): side(pl)=4: mov(pl)=1: Pdown=1:  pld(pl)=1: plu(pl)=0 'DOWN
 if PEEK(VAR KC$, 6)=49 OR LX< 60 then spx=-spd(pl): side(pl)=6: mov(pl)=1: Pleft=1:  pll(pl)=1: plr(pl)=0 'LEFT
 if PEEK(VAR KC$, 8)=49 OR LX>195 then spx= spd(pl): side(pl)=2: mov(pl)=1: Pright=1: plr(pl)=1: pll(pl)=0 'RIGHT
 if PEEK(VAR KC$,13)=49 then ka$="M" 'START - OPTIONS (NOT YET)
 if PEEK(VAR KC$, 3)=49 then ka$="M" 'A BUTTON - MAGIC
 if PEEK(VAR KC$, 1)=49 then
  kspace(pl)=1: if fire(pl)<>0 then spd(pl)=0: Anim(pl)=0: AnimSpr(pl)=0: tspd(pl)=0 'B
 endif
endif

' MAGIC
If ka$="M" And bomb(pl)>0 Then 
 For t=1 To maxg:If ae(t)>0 Then PutSprite(432,xe(t),ye(t),3)
 Next t
 updOSD=1:bomb(pl)=bomb(pl)-1
 PlaySample(22,22050): FixEnemies(-1,pl)
EndIf

' PLAYER ANIMATION AND SPEED
spd(pl)=0
if start(pl)=0 then
 if mov(pl)=0 then
  Anim(pl)=0: AnimSpr(pl)=0: tspd(pl)=0
  x(pl)=(x(pl)*8)\8: y(pl)=(y(pl)*8)\8 :scx=(scx*8)\8: scy=(scy*8)\8
 endif
 If mov(pl)=1 and kspace(pl)=0 Then
  spd(pl)=cspd(pl)
  'if sw=0 then spd(pl)=(spd(pl)*4)\4 else spd(pl)=(spd(pl)*8)\8
  Anim(pl)=Anim(pl)+1: if Anim(pl)>3 then Anim(pl)=0 
  SELECT CASE Anim(pl)
   CASE 0: AnimSpr(pl)=0
   CASE 1: AnimSpr(pl)=8
   CASE 2: AnimSpr(pl)=0
   CASE 3: AnimSpr(pl)=16
  END SELECT
 endif
endif

' PLAYER SHOOTING ANIMATION
if fire(pl)>0 and start(pl)=0 then
 SELECT CASE firstf(pl)
  CASE 0 TO 1: Anim(pl)=3: AnimSpr(pl)=16
  CASE 2 TO 5: Anim(pl)=0: AnimSpr(pl)=24
  CASE 6:      Anim(pl)=3: AnimSpr(pl)=16
 END SELECT
endif

' POINT TO THE DIRECTION
if Pup=1 then
 y(pl)=y(pl)-spd(pl)
 if Pleft=0 then pll(pl)=0 else side(pl)=7
 if Pright=0 then plr(pl)=0 else side(pl)=1
endif
If Pdown=1 then
 y(pl)=y(pl)+spd(pl)
 if Pleft=0 then pll(pl)=0 else side(pl)=5
 if Pright=0 then plr(pl)=0 else side(pl)=3
endif
if Pleft=1 then
 x(pl)=x(pl)-spd(pl)
 if Pup = 0 then plu(pl)=0
 if Pdown= 0 then pld(pl)=0
endif
if Pright=1 then
 x(pl)=x(pl)+spd(pl)
 if Pup = 0 then plu(pl)=0
 if Pdown= 0 then pld(pl)=0
endif

' SCREEN "ROTATION" (HORIZONTAL SCROLL)
'If x(pl)<0 And spx<0 Then px=limR-16:x=240-16:SCX=0:xx(pl)=x(pl):xxx=x(pl):atmp=1:mapside=1
'If x(pl)>240-16 And spx>0 Then px=limL:x=0:SCX=0:xx(pl)=x(pl):xxx=x(pl):atmp=1:mapside=-1
'If atmp=1 Then
' Dfire=0:xf(0)=-64:yf(0)=-64:PAGE WRITE 10: CLS RGB(0,0,0):clmap=3
' start(pl)=0:mv(pl)=0:ya=0:yb=12:xa=0:xb=15:FixEnemies(2,pl):mapscan:start=0
'EndIf

Collided=0
If start(pl)=0 Then

 ' PLAYER SCREEN LIMIT
 if x(pl)<=0 then x(pl)=0
 if x(pl)>=224 then x(pl)=224
 if y(pl)<=0 then y(pl)=0
 if y(pl)>=224 then y(pl)=224

 ' PLAYER COLLISION
 xant=x(pl):yant=y(pl)
 For tx=0 To 1: For ty=0 To 1
  rx=(x(pl)-tx*8+SCX+4)/16+xz:ry=(y(pl)-ty*8+SCY+4)/16+yz
  if rx>=0 and ry>=0 and rx<=35 and ry<=35 then US=st(ry,rx)
  SELECT CASE US
   'KEY
   CASE 444:
    if key(pl)<=9 Then
     score(pl)=score(pl)+15:Key(pl)=Key(pl)+1:updOSD=1
     anim(pl)=0:If SAVEKE=0 Then SAVEKE=1
     mv(pl)=-1:st(ry,rx)=0
     x(pl)=xx(pl):y(pl)=yy(pl)
     PlaySample(21,22050): Collided=1
    endif
   'TREASURE
   CASE 455:
    score(pl)=score(pl)+100:anim(pl)=0:updOSD=1:If GETTRE=0 Then GETTRE=1
    mv(pl)=-1:st(ry,rx)=-3:x(pl)=xx(pl):y(pl)=yy(pl)
    PlaySample(26,22050): Collided=1
   'DOOR
   CASE 490 TO 504:
    Collided=1
    if (key(pl)>0) Then
     key(pl)=key(pl)-1:anim(pl)=0: PlaySample(25,22050)
     OpenDoor(rx,ry): refresh=1: x(pl)=xx(pl): y(pl)=yy(pl): updOSD=1
    endif
   'FOOD
   CASE 426, 427:
    score(pl)=score(pl)+25 
    mv(pl)=-1
    st(ry,rx)=0:Energy(pl)=Energy(pl)+hpg(pl):updOSD=1
    anim(pl)=0:If Energy(pl)>MaxEn(pl) Then Energy(pl)=MaxEn(pl)
    SELECT CASE Ptype(pl)
     CASE 1: PlaySample(24,22050)
     CASE 2: PlaySample(27,22050)
     CASE 3: PlaySample(24,28000)
     CASE 4: PlaySample(24,32000)
    END SELECT
    x(pl)=xx(pl):y(pl)=yy(pl): Collided=1
   'POTION
   CASE 459:
    if bomb(pl)+key(pl)<13 Then
     score(pl)=score(pl)+25:bomb(pl)=bomb(pl)+1:updOSD=1:anim(pl)=0:If SAVEPO=0 Then SAVEPO=1
     mv(pl)=-1:st(ry,rx)=0:x(pl)=xx(pl):y(pl)=yy(pl): Collided=1
     PlaySample(19,22050)
    endif
   'EXIT
   CASE 434:
    start(pl)=100:mv(pl)=-4:anim(pl)=0:x(pl)=xx(pl):y(pl)=yy(pl): Collided=1
    PlayWAV("EXIT",100)
   'FREEZE FLOOR
   CASE 617:
    BlockStage(rx,ry,-1)
    st(ry,rx)=0:mv(pl)=-1:nowalk(pl)=40:anim(pl)=0
    x(pl)=xx(pl):y(pl)=yy(pl): Collided=1
    PlaySample(18,22050)
  END SELECT
  if start(pl)=0 then
   'OTHER BLOCKS / WALLS - SWAP EACH AXYS ON GAME LOGIC TICK TO ALLOW DIAGONAL MOVEMENT
   SELECT CASE US
    CASE 200 TO 1000, 1023, 1392 TO 1397, 1592 TO 1597, 1692 TO 1697: 
     if Anim(pl) Mod 2=0 then
      x(pl)=xx(pl): rx=(x(pl)-tx*8+SCX+4)/16+xz: if st(ry,rx)<>0 then y(pl)=yy(pl)
     else 
      y(pl)=yy(pl): ry=(y(pl)-ty*8+SCY+4)/16+yz: if st(ry,rx)<>0 then x(pl)=xx(pl)
     endif
    Collided=1
   END SELECT
  endif
 Next ty,tx

 ' PLAYER COLLISION WITH OTHERS
 for t=PLN TO PLQ
  if t<>pl then
   if x(pl)+16>x(t) and x(pl)<x(t)+16 and y(pl)+16>y(t) and y(pl)<y(t)+16 then Collided=1: x(pl)=xx(pl): y(pl)=yy(pl)
  endif
 next t
  
 ' CENTRALIZE COLLISION
 if Collided=1 then x(pl)=(x(pl)*8)\8: y(pl)=(y(pl)*8)\8: scx=(scx*8)\8: scy=(scy*8)\8
EndIf

' DEFINE PLAYER SPRITE WHEN NOT MOVING
If mov(pl)<>0 Then
 If fstart(pl)<4 And fire(pl)>0 Then Anim(pl)=0
Else
 Anim(pl)=0
EndIf

' RESPOND TO SHOT ONLY AFTER VERIFY PLAYER COLLISION
if kspace(pl)=1 and fire(pl)=0 then
 fire(pl)=1:firstf(pl)=6
 SELECT CASE Ptype(pl)
  CASE 1: PlaySample(30,18000)
  CASE 2: PlaySample(17,16000)
  CASE 3: PlaySample(30,22050)
  CASE 4: PlaySample(17,32000)
 END SELECT
 xfs(pl)=0:yfs(pl)=0:shotv(pl)=0 ':tac=0
 If Plu(pl)=1 Then yfs(pl)=-8:xs(pl)=32
 If Pld(pl)=1 Then yfs(pl)= 8:xs(pl)=36
 If Pll(pl)=1 Then xfs(pl)=-8:xs(pl)=38
 If Plr(pl)=1 Then xfs(pl)= 8:xs(pl)=34
 If Plu(pl)=1 And Plr(pl)=1 Then xs(pl)=33
 If Plu(pl)=1 And Pll(pl)=1 Then xs(pl)=39
 If Pld(pl)=1 And Plr(pl)=1 Then xs(pl)=35
 If Pld(pl)=1 And Pll(pl)=1 Then xs(pl)=37 
 scx=(scx*8)\8: scy=(scy*8)\8
 xf(pl)=((x(pl)+xfs(pl))*8)\8
 yf(pl)=((y(pl)+yfs(pl))*8)\8
 fstart(pl)=0:repFire(pl)=1
 If cshs(pl)>=8 Then repFire(pl)=2 
 if PType(pl)=0 then xs(pl)=xs(pl)-8
 if PType(pl)<>1 then xf(pl)=xf(pl)+xfs(pl):yf(pl)=yf(pl)+yfs(pl)
EndIf

' DEFINE IF THE SHOT IS TOO FAST AND NEED A SECOND COLLISION DETECTION
If cshs(pl)>=4 and cshs(pl)<=7 And tac=0 Then repFire(pl)=1 Else repFire(pl)=2

' IT'S A DEMON FIRE? THEN ADD ANOTHER SCAN
repD=-1:If dfire>0 Then repFire(pl)=repFire(pl)+1:repD=repFire(pl)

' ** PLAYER SHOT LOOP **
rept=0
h=15 'shot collision size
Do While rept<repFire(pl)
 rept=rept+1
 ' DEMON FIRE
 If dfire>0 And rept=repD Then plf=0 else plf=pl

 ' ** EXECUTE ON SHOOTING **
 If fire(plf)=1 Then 
  firstf(plf)=firstf(plf)-1:xfa(plf)=xf(plf):yfa(plf)=yf(plf):fstart(plf)=fstart(plf)+1
  if rept<>repD then
   SELECT CASE Ptype(pl)
    CASE 1:
     atmp=xfs(plf): If atmp=0 Then atmp=yfs(plf)
     xs(plf)=xs(plf)+atmp/16
     If xs(plf)<32 and atmp<0 Then xs(plf)=39
     if xs(plf)>39 and atmp>0 Then xs(plf)=32
   END SELECT   
   shotv(plf)=shotv(plf)+cshs(plf)
   If shotv(plf)>8 Then shotv(plf)=shotv(plf)-8:xf(plf)=xf(plf)+xfs(plf):yf(plf)=yf(plf)+yfs(plf)
  else   
   if sw=0 then
    xf(plf)=xf(plf)+(xfs(plf)*4)\4:yf(plf)=yf(plf)+(yfs(plf)*4)\4
   else
    xf(plf)=xf(plf)+(xfs(plf)*8)\8:yf(plf)=yf(plf)+(yfs(plf)*8)\8
   endif
   shotv(plf)=0
  EndIf
  
  ' TEST WITH COLLISION MAP
  fireCol(plf)=0
  for t=-1 to 1: for i=-1 to 1
   BlockStage( (xf(plf)+SCX)\16+xz+t, (yf(plf)+SCY)\16+yz+i,fireCol(plf)) 
  next i,t

  ' SHOT OFFSCREEN? 
  If xf(plf)<-16 Or xf(plf)>240 Or yf(plf)<-16 Or yf(plf)>240 Then
   fire(plf)=2  
  Elseif fireCol(plf)>0 then ' ONLY WHEN FOUND A PIXEL IN THE COLLISION MAP

   'SHOT COLLISION ON WALLS AND OBJECTS
   For tx=0 To 1:For ty=0 To 1
    txx=(xf(plf)+tx*8+SCX-4)/16+xz:tyy=(yf(plf)+ty*8+SCY-4)/16+yz
    If txx>34 Then txx=34
    If tyy>34 Then tyy=34
    if tyy>=0 and txx>=0 then US=st(tyy,txx) else US=0
    'DON'T BLOCK SHOT ON ENEMY STRINGS AND SHOCK FLOOR
    If US<>0 AND US<>617 AND US<=1055 Then
     'SHOT MAGIC POTION OR FOOD
     If US=426 Or US=459 Then
      mv(plf)=-2:fstart(plf)=2:atmp=US: PlaySample(15,22050)
      If atmp=459 Then 
       st(tyy,txx)=-1
       FixEnemies(-2,plf): PlaySample(22,22050): IF SHOTPOT=0 THEN SHOTPOT=1      
      ELSE
       IF SHOTFOOD=0 THEN SHOTFOOD=1
       st(tyy,txx)=-2
      ENDIF
     EndIf
     'SHOT FAKE WALL OR HIDDEN EXIT
     If US=799 OR US=1023 Then
      PlaySample(15,22050)
      If rept<>repD Then      
       If US=799 Then
        ' FAKE WALL
        Atmp=-1: mv(plf)=-2
       else
        ' HIDDEN EXIT
        Atmp=434: mv(plf)=-2
        PutExplosion(1,xf(plf)-tx*8+xfs(plf),yf(plf)-ty*8+yfs(plf))
       EndIf
       st(tyy,txx)=Atmp
      EndIf
      fstart(plf)=2
     EndIf
     PutExplosion(0,xf(plf),yf(plf))
     If US>=400 Then fire(plf)=2    
    EndIf 'IF US<>0
   Next ty,tx  

   ' SHOT COLLISION WITH ENEMIES
   tx=Abs(xfs(plf))+h:ty=Abs(yfs(plf))+h
   If xfs(plf)<>0 And yfs(plf)<>0 Then tx=h:ty=h
   If fire(plf)<>2 then
    For n=1 To cntg
     If ae(n)>0 And (n<>DnFire Or rept<>repD) Then
      xt=xe(n):yt=ye(n)
      If xt+tx>=xf(plf) And xt<=xf(plf)+tx And yt+ty>=yf(plf) And yt<=yf(plf)+ty Then
       en(n)=en(n)-(Csht(plf)*2):lv(n)=lv(n)-1
       xtf(plf)=xt:ytf(plf)=yt:cef=ce(n):tt=te(n)
       If rept=repd Then xtf(0)=xt:ytf(0)=yt      
       PutExplosion(0,xt,yt)
       If tt Mod 2=0 Then 'GENERATORS
        PlaySample(15,22050)
       Else 'ENEMIES
        PlaySample(25,44100)
       EndIf
       If en(n)<=0 Then
        If rept<>repd Then score(plf)=score(plf)+(te(n)*5+5): updOSD=1
        RetEnemy(n,0):fire(plf)=2:PutExplosion(2,xt,yt)
       Else
        fire(plf)=3
       EndIf
       xf(plf)=xe(n):yf(plf)=ye(n)
       if lv(n)<0 then lv(n)=0
      EndIf
     EndIf
    Next n
   EndIf 'fire<>2

  EndIf 'fireCol>0

  if rept=1 or (PType(plf)=3 and sw=0) then PutSpriteChar(fix(xs(plf)),plf,xf(plf),yf(plf))
  if dfire>0 and rept=repD then PutSprite(xs(plf),xf(plf),yf(plf),3)

  'DEMON SHOT ON PLAYER
  If rept=repD And x(plf)+h>=xf(plf) And x(plf)<=xf(plf)+h And y(plf)+h>=yf(plf) And y(plf)<=yf(plf)+h Then
   HurtSound(PType(plf)): Energy(plf)=Energy(plf)-22+Carm(plf)*2
   PutExplosion(0,xf(plf),yf(plf)): fire(plf)=2  
  EndIf

 EndIf 'fire=1
Loop

'RESET VARIABLES FOR SCROLL
MVS=0
u=0: d=0: l=0: r=0: i=0
ok_u=1: ok_d=1: ok_l=1: ok_r=1
BL=0: xxx=x(pl): yyy=y(pl): atmp=0
BX=0:BY=0

'ALL PLAYERS IS ON THE SCREEN?
for t=PLN to PLQ
 if x(t)<=0 then ok_r=0
 if x(t)>=224 then ok_l=0
 if y(t)<=0 then ok_d=0
 if y(t)>=224 then ok_u=0
next t

'BLITTING / SCROLL / MAP LIMITS
'MOVE PLAYER AND SCROLL BLOCK SET - ONLY IF ALL PLAYERS IS ON THE SCREEN
IF MOVED=0 THEN
 If x(pl)< 80 and ok_l=1 and PLeft=1  And px>limL    Then MVS=7:l=spd(pl):x(pl)=x(pl)+spd(pl):BL=1:BX=-l
 If y(pl)< 80 and ok_u=1 And PUp=1    And py>1       Then MVS=1:u=spd(pl):y(pl)=y(pl)+spd(pl):BL=1:BY=-u
 If x(pl)>144 and ok_r=1 And PRight=1 And px<limR-16 Then MVS=3:r=spd(pl):x(pl)=x(pl)-spd(pl):BL=1:BX=r
 If y(pl)>144 and ok_d=1 And PDown=1  And py<32-17   Then MVS=5:d=spd(pl):y(pl)=y(pl)-spd(pl):BL=1:BY=d

 scx=scx-l+r
 scy=scy-u+d
 if scx< 0 then scx=scx+16:px=px-1
 if scx>15 then scx=scx-16:px=px+1
 if scy< 0 then scy=scy+16:py=py-1
 if scy>15 then scy=scy-16:py=py+1
ENDIF

' PAGE 3 - SPRITES
' PAGE 10 - STAGE + SPRITES
' PAGE  1 - STAGE ONLY

' PLAYER SPRITE
'YOU(side(pl)+AnimSpr(pl),pl)

sgx=0:sgy=0 ' RESET SCROLL VARIABLES 

ya=0:yb=15:xa=0:xb=15 ' RESET SCAN BORDERS COORDINATES

' ADJUST MAP SCAN SIZE
If start(pl)=1 Then x(pl)=(x(pl)*8)\8: y(pl)=(y(pl)*8)\8: MapScan(pl)

' SCROLLING - ONLY IF ANOTHER PLAYER DOESN'T SCROLLED THE SCREEN YET
IF MVS<>0 AND MOVED=0 THEN
 MOVED=1
 x(pl)=(x(pl)*8)\8: y(pl)=(y(pl)*8)\8
 If u>0 And r>0 Then MVS=2
 If u>0 And l>0 Then MVS=8
 If d>0 And r>0 Then MVS=4
 If d>0 And l>0 Then MVS=6 
 If BL=1 Then
  SELECT CASE MVS   
   CASE 1:
    sgy= spd(pl)
    ya= 0:yb= 0: MapScan(pl)
   CASE 2:
    sgx=-spd(pl): sgy= spd(pl)
    xa= 0: xb=15: ya= 0: yb= 0: MapScan(pl)
    xa=15: xb=15: ya= 0: yb=15: MapScan(pl)
   CASE 3:
    sgx=-spd(pl):
    xa=15:xb=15: MapScan(pl)
   CASE 4:
    sgx=-spd(pl): sgy=-spd(pl)
    xa=15: xb=15: ya= 0: yb=15: MapScan(pl)
    xa= 0: xb=15: ya=15: yb=15: MapScan(pl)
   CASE 5:
    sgy=-spd(pl)
    ya=15:yb=15: MapScan(pl)
   CASE 6:
    sgx= spd(pl): sgy=-spd(pl)
    xa= 0: xb=15: ya=15: yb=15: MapScan(pl)
    xa= 0: xb= 0: ya= 0: yb=15: MapScan(pl)
   CASE 7:
    sgx= spd(pl)
    xa= 0:xb= 0: MapScan(pl)
   CASE 8:
    sgx= spd(pl): sgy= spd(pl)
    xa= 0: xb= 0: ya= 0: yb=15: MapScan(pl)
    xa= 0: xb=15: ya= 0: yb= 0: MapScan(pl)
  END SELECT
 EndIf
 sgxE=sgxE+sgx: sgyE=sgyE+sgy
EndIf

If mv(pl)>=-5 And mv(pl)<=-1 Then
 If mv(pl)=-1 or mv(pl)=-4 Then
  atmp=x(pl)+sgx+(x(pl) Mod 16):btmp=y(pl)+sgy+(y(pl) Mod 16):t=2
 Else
  clmap=1:atmp=xf(pl)+sgx+(xf(pl) Mod 16):btmp=yf(pl)+sgy+(yf(pl) Mod 16):t=2
 EndIf
 xa=atmp/16-t:ya=btmp/16-t:xb=atmp/16+t:yb=btmp/16+t
 If ya<0  Then ya=0
 If xa<0  Then xa=0
 If xa>15 Then xa=15
 If xb>15 Then xb=15
 If ya>15 Then ya=15
 If yb>15 Then yb=15
 If mv(pl)=-1 or mv(pl)=-2 then MapClear else MapScan(pl)
EndIf

' MOVE OBJECTS ON SCROLL
If MOVED=1 Then
 MOVED=2
 ' PLAYERS
 for t=PLN to PLQ  
  If fire(t)>0 Then ' PLAYER'S SHOT
   xf(t)=xf(t)+sgx:yf(t)=yf(t)+sgy
   xfa(t)=xfa(t)+sgx:yfa(t)=yfa(t)+sgy
   xtf(t)=xtf(t)+sgx:ytf(t)=ytf(t)+sgy
  endif
  'OTHER PLAYERS
  if pl<>t then
   x(t)=x(t)+sgx: y(t)=y(t)+sgy
   xx(t)=xx(t)+sgx: yy(t)=yy(t)+sgy
  endif
 next t
 ' DEMON'S FIRE
 If dfire>0 Then
  xf(0)=xf(0)+sgx:yf(0)=yf(0)+sgy
  xfa(0)=xfa(0)+sgx:yfa(0)=yfa(0)+sgy
  xtf(0)=xtf(0)+sgx:ytf(0)=ytf(0)+sgy
 EndIf
endif

If start(pl)>0 Then start(pl)=start(pl)-1
If fstart(pl)<4 And fire(pl)>0 Then anim(pl)=1

pl=pl+1

Loop Until pl>PLQ ' PLN TO PLQ - PLAYER'S LOGIC
'-----------------------------------------------

' FPS / SPEED LIMITER
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
' PAGE WRITE 3: BLIT 100,0,0,0,80,80,2,0

PAGE WRITE 2
BLIT 0,0,100,0,80,80,2,0    'RESTORE COLLISION MAP
BLIT 0,100,100,0,80,80,2,4  'RESTORE WALLS FOR COLLISION MAP - FIX

PAGE WRITE 3

' ------- ENEMIES LOGIC --------

' COUNT ENEMIES ON SCREEN
cntg=0: actg=0
for t=1 to maxg
 if ae(t)>0 then cntg=t: actg=actg+1
next t

' MOVE ENEMIES WHEN SCROLLING
if MOVED>0 then
 for t=1 to cntg
  if ae(t)>0 then xe(t)=xe(t)+sgxE:ye(t)=ye(t)+sgyE
 next t
EndIf

' SORT ENEMIES ARRAY TO SPEED UP
if GoSortEnemies=1 then SortEnemies

' CONTROL SPEED OF ENEMIES
t=FIX(actg\7)-1
eini=eini+1:stp=3+t:if eini>stp+2+t then eini=1: if swi=1 then swi=0 else swi=1
if stp=1 then stp=2

scx=(scx*8)\8: scy=(scy*8)\8
' INSERT PLAYER ON COLLISION MAP
for tt=PLN TO PLQ
 for t=4 to 8 step 4: for i=4 to 8 step 4
  BlockStage((x(tt)+SCX+t)\16+xz,(y(tt)+SCY+i)\16+yz,-30)
next i,t,tt

' INSERT ENEMIES ON COLLISION MAP
For t=1 to cntg
 if ae(t)>0 then BlockStage((xe(t)+SCX)/16+xz,(ye(t)+SCY)/16+yz,-5): EaIni(t)=0
next t

' CALL ACTIVE ENEMIES
PutEnemies

' SHOW OTHER ENEMIES THAT ARE NOT ACTIVE IN THIS CYCLE
For t=1 To cntg
 if ae(t)>0 and EaIni(t)=0 then
  if te(t) mod 2<>0 then
   'PutSpriteEnemy(ce(t)+Ean+lv(t)*1000,xe(t),ye(t))
   spr=ce(t)+Ean+lv(t)*1000
   BLIT (((SPR-200) MOD 1000) MOD 18)*17,FIX(((SPR-200) MOD 1000)*17/306)*17,xe(t),ye(t),16,16,5,4
  else
   'PutSpriteEnemy(ce(t)+lv(t)*1000,xe(t),ye(t))
   spr=ce(t)+lv(t)*10000
   BLIT (((SPR-200) MOD 1000) MOD 18)*17,FIX(((SPR-200) MOD 1000)*17/306)*17,xe(t),ye(t),16,16,5,4
  endif
 Endif
Next t

PAGE WRITE 3

' ENERGY ACT AS A TIMER
If Timer > EnTime Or refresh=1 Then 
 EnTime=Timer+1000
 If refresh=0 Then
  for t=PLN TO PLQ
   energy(t)=energy(t)-1
  next t
 Else
  refresh=0 
 endif
EndIf

for t=PLN TO PLQ
 ' SHOW PLAYERS
 YOU(side(t)+AnimSpr(t),t)
 ' FINISH PLAYER SHOT AND DEMON'S FIRE
 If fstart(t)>0 And fstart(t)<6 and fire(t)>0 And xf(t)<=240 Then PutSpriteChar(side(t)+AnimSpr(t),t,x(t),y(t))
 If fire(t)>=2 Then fire(t)=0:xf(t)=-64:yf(t)=-64
next t
If dfire>=2 Then dfire=0:xf(0)=-64:yf(0)=-64:DnFire=0

' SWAP VARIABLE
If sw=0 Then sw=1 Else sw=0

' EXPLOSION ANIMATION
For t=1 to 10
 if expl(t)>0 then
  xex(t)=xex(t)+sgxE: yex(t)=yex(t)+sgyE
  putsprite(FIX(sprx(t)),xex(t),yex(t),3)
  sprx(t)=sprx(t)+spdEx(t): if fix(sprx(t))>maxx(t) then expl(t)=0  
 endif
next t

' COPY FLOOR+STAGE+SPRITES TO BUFFER
PAGE WRITE 1                            'FLOOR + STAGE + SPRITES BUFFER

'MAIN FRAMEBUFFER - STAGE
BLIT (px+1)*16+SCX,(py+1)*16+SCY,0,0,MM.HRES-80,MM.VRES,FRAMEBUFFER,0
BLIT 0,0,0,0,MM.HRES-80,MM.VRES,3,4  'SPRITES

' SHOW TXT TO VOICE OVER
'IF VOver$<>"" then 
' IF MM.INFO$(SOUND)="WAV" THEN
'  PrintS(MM.HRES/2-40-Len(VOver$)*4-8,MM.VRES-8,0,VOver$)
' ELSE
'  VOver$=""
'  BOX 0,MM.VRES-8,MM.HRES-80,8,1,RGB(0,0,0),RGB(0,0,0)
' ENDIF
'Endif

'  9 - FULL CURRENT COLLISION MAP
' 12 - CLEAN COLLISION MAP

' COPY FLOOR+STAGE+SPRITES TO MAIN PAGE

PAGE WRITE 0:  BLIT 0,0,0,0,MM.HRES-80,MM.VRES,1,0

' CLEAR SPRITES PAGE
PAGE WRITE 3: CLS

PAGE WRITE 0

' ON SCREEN DISPLAY -  # BOMB & ENERGY \ KEY
for ttt=PLN to PLQ
 T=MM.HRES-81: TT=74+(ttt-1)*76 
 printG(T+8,TT,RIGHT$("000"+STR$(int(energy(ttt))),4)+"/"+RIGHT$("000"+STR$(maxen(ttt)),4))
 if UpdOSD=1 then
  printG(T,TT+20,"$"+RIGHT$("00000"+STR$(score(ttt)),6))
  'KEY=4: BOMB=2
  box T+4,TT+10,72,10,1,RGB(0,0,0),RGB(0,0,0)
  IF KEY(ttt)>0 THEN FOR I=1 TO KEY(ttt): printG(T+(I-1)*6,TT+10, "\"): NEXT I
  IF BOMB(ttt)>0 THEN FOR I=1 TO BOMB(ttt): printG(T+60-(I-1)*6,TT+10, "#"): NEXT I
 endif
next ttt
UpdOSD=0

' DEBUG INFO
printG(T,   MM.VRES-8,RIGHT$("0"+STR$(fps),2))
printG(T+30,MM.VRES-8,RIGHT$("0"+STR$(cntg),2))

' CALL FIRST VOICE OVERS
If GETTRE=1 Then GETTRE=2:VoiceOver("TREASURE 100 POINTS","treasure 100 points")
If SAVEKE=1 Then SAVEKE=2:VoiceOver("SAVE KEYS TO OPEN DOORS","save keys open doors")
If SAVEPO=1 Then SAVEPO=2:VoiceOver("SAVE POTIONS FOR LATER USE","save potions")
If SHOTFOOD=1 Then SHOTFOOD=2:VoiceOver("REMEMBER, DON'T SHOOT FOOD!","remember dont shoot food")
If SHOTPOT=1 Then SHOTPOT=2:VoiceOver("YOU JUST SHOOT THE POTION!","you shot potion")
If KILLDE=1 Then KILLDE=2:VoiceOver("USE MAGIC TO KILL DEATH!","magic kill death")

' GO TO NEXT LEVEL/ROOM
If nextroom=1 Then nextroom=0: Exit Do

Loop 'GAMELOOP


' (RE)START STAGE
START_STAGE:

PAGE WRITE 1: CLS
PAGE WRITE 10: CLS
PAGE WRITE 3: CLS
PAGE WRITE 13: CLS: LOAD PNG ".\fonts\fonts.png",,,1

CStage% = MM.INFO(PAGE ADDRESS  2)     ' CLEAN COLLISION MAP
FStage% = MM.INFO(PAGE ADDRESS  2)+100 '  FULL COLLISION MAP

for t=0 to 4
 Anim(t)=1:side(t)=3
 nowalk(t)=0:tspd(t)=8
 start(t)=1
next t

GoSortEnemies=1
scx=0:scy=0:difwall=(room-1)*18:VOver$=""
bg=1:time=0

'RESET SOUND
For t=1 To ms:snd(t)=0:Next t

'RESET EXPLOSIONS
For t=1 To 10:expl(t)=0:Next t

If room mod 4=0 Then troom=1 Else troom=0

for t=1 to maxg: ae(t)=0: next t 'DISABLE ALL ENEMIES FOR THE NEXT ROOM
nextroom=0:refresh=1
COLOR RGB(255,255,255),RGB(0,0,0): updOSD=1
PAGE WRITE 0: CLS RGB(0,0,0): LOAD PNG "./IMAGES/PANEL.PNG",MM.HRES-79,0

FOR T=PLN TO PLQ
 FixEnemies(3,T)
 PanelStatus(PType(T),T)
 Plu(T)=0:Pld(T)=0:Pll(T)=0:Plr(T)=1
NEXT T

A$="":B$="":C$="":If room<10 Then A$="0"

PLAY STOP
LoadMap(".\maps\room"+A$+Str$(room)+".map"):B$="":C$=""

'BUILD MAIN STAGE FRAMEBUFFER
MAP_FRAMEBUFFER
PAGE WRITE 10

IF troom=1 then VoiceOver("WELCOME TO THE TREASURE ROOM","welcome treasure")

SELECT CASE room
 CASE 3: VoiceOver("SOME WALLS MAY BE DESTROYED","some walls")
 CASE 5: VoiceOver("BEWARE THE DEMON","beware demons") 
END SELECT

i=room:song=song+1
if song>12 then song=1
if song=9 then song=10
If troom=1 Then song=song-1
If troom=0 and music=0 then song=0
StopWAV: Play Stop
if troom<>1 then PlayMOD(song) else PlayMOD(14)

Goto GAMELOOP

