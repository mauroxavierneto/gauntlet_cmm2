'PLAYER SELECTION

Mode 7,16

for t=1 to 2
 if CtrlType(t)=1 then ON ERROR SKIP 1: WII CLASSIC OPEN
 if CtrlType(t)=2 then ON ERROR SKIP 1: WII NUNCHUK OPEN
next t

if retro=1 then UnloadVGM
PAGE WRITE 0: CLS
PAGE WRITE 2: CLS: LOAD PNG ".\images\select.png",,,8
PAGE WRITE 4: CLS: LOAD PNG ".\IMAGES\ATARI_LOGO.PNG",0,0,8
PAGE WRITE 7: CLS: LOAD PNG ".\IMAGES\SELECTED.PNG",,,8

PAGE COPY 2 TO 0,I

Font #7
MVO=0:MVS=0:tt=187

PlayMOD(2)
PlayWav("welcome",201,"V")

for t=1 to 4
 Ptype(t)=0
next t

PtypeS=0
XC=0:YC=0:EL=1:ER=6:xa=115:xb=124
xe(1)=6:xe(2)=2:xe(3)=3
xe(4)=1:xe(5)=5:xe(6)=4
TICKSND=0: sel=0
xlogo=0:ylogo=0:delaylogo=0

do while keydown(1)=32
loop

pause(50)


tt=2: pl_num=1: KB=0: First=1

Do While (pl_num<=PLQ)

 PtypeS=0: Sel=0

 Do

  PAGE COPY 2 TO 5,I
  PAGE WRITE 5
  tt=tt+1: if tt>5 then tt=1
  KB=0
  if CtrlType(pl_num)=0 then KB=KeyDown(tt): if KB=0 Then MVO=0

  MINF$=MM.INFO$(SOUND)

  Sel=0

  if CtrlType(pl_num)=1 then  
   KC$=RIGHT$("00000000000000"+BIN$(CLASSIC(B,3)),14)
   LX=CLASSIC(LX,3)
   LY=CLASSIC(LY,3)
   if PEEK(VAR KC$, 7)=49 OR LY>195 then KB=128 'UP
   if PEEK(VAR KC$, 9)=49 OR LY< 60 then KB=129 'DOWN
   if PEEK(VAR KC$, 6)=49 OR LX< 60 then KB=130 'LEFT
   if PEEK(VAR KC$, 8)=49 OR LX>195 then KB=131 'RIGHT
   if PEEK(VAR KC$,13)=49 then Sel=1
   if PEEK(VAR KC$, 1)=49 then Sel=1
   if KC$="00000000000000" then MVO=0
  endif
  if CtrlType(pl_num)=0 and (KB=32 or KB=13) then Sel=1

  if first=1 then first=0: KB=128: MVO=0

  If MVO=0 Then
   
   IF TICKSND>0 THEN
    TICKSND=TICKSND-1
    IF TICKSND=0 AND RETRO=1 THEN PLAY SOUND 2,B,O,1,1:SetChannelType(2,"W")
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
   If (KB>=128 And KB<=131) Or (KB>=48 And KB<=57) Then MVO=1

  EndIf 'If MVO=0
  
  If XC=0 And YC=0 And (PtypeA<>1 or pl_num=1) Then
   BLIT 0,0,0,0,160,120,7,0
   Sel=Sel+1
   plname$(pl_num)="WARRIOR": PtypeS=1
   CoP(pl_num) =4: Cmag(pl_num)=1: Csht(pl_num)=8
   Cfig(pl_num)=8: Carm(pl_num)=5: Cspd(pl_num)=4: Cshs(pl_num)=4
   MaxEn(pl_num)=  980
   hpg(pl_num)=     80
   TimeRAW(pl_num)=1000
   EL=4:ER=9
  ElseIf XC=0 And YC=1 And (PtypeA<>2 or pl_num=1) Then
   BLIT 0,120,0,120,160,120,7,0
   Sel=Sel+1
   plname$(pl_num)="VALKYRIE": PtypeS=2
   CoP(pl_num) =3: Cmag(pl_num)=3: Csht(pl_num)=3
   Cfig(pl_num)=6: Carm(pl_num)=8: Cspd(pl_num)=6: Cshs(pl_num)=5
   MaxEn(pl_num)=  900
   hpg(pl_num)=    100
   TimeRAW(pl_num)=1200
   EL=5:ER=10
  ElseIf XC=1 And YC=1 And (PtypeA<>3 or pl_num=1) Then
   BLIT 160,120,160,120,160,120,7,0
   Sel=Sel+1
   plname$(pl_num)="WIZARD": PtypeS=3
   CoP(pl_num) =6: Cmag(pl_num)=8: Csht(pl_num)=4
   Cfig(pl_num)=1: Carm(pl_num)=0: Cspd(pl_num)=4: Cshs(pl_num)=8
   MaxEn(pl_num)=  800
   hpg(pl_num)=    100
   TimeRAW(pl_num)=1100
   EL=3:ER=8
  ElseIf XC=1 And YC=0 And (PtypeA<>4 or pl_num=1) Then
   BLIT 160,0,160,0,160,120,7,0
   Sel=Sel+1
   plname$(pl_num)="ELF": PtypeS=4
   CoP(pl_num) =2: Cmag(pl_num)=4: Csht(pl_num)=2
   Cfig(pl_num)=2: Carm(pl_num)=2: Cspd(pl_num)=8: Cshs(pl_num)=8
   MaxEn(pl_num)=  820
   hpg(pl_num)=    120
   TimeRAW(pl_num)=700
   EL=2:ER=7
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
  
  BLIT xlogo,ylogo,148,211,24,18,4,4
  PAGE COPY 5 TO 0,I
  
 Loop Until Sel=2 ' PTypeA=0
 
 if Pl_num=1 then PType(pl_num)=PTypeS else Ptype(pl_num)=PtypeS
 PlayWAV(PlName$(pl_num),201,"V")
 pl_num=pl_num+1
 PAUSE(800)
 'INSERT SELECTED PLAYER ON VIDEO PAGE
 PAGE COPY 0 TO 2,I 

Loop 'pl_num

if retro=1 then StopVGM: UnloadVGM
If KB=k_ESC Then k=0: KB=0: GoTo OPTIONS

for t=1 to 4
 energy(t)=MaxEn(t)
next t

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

