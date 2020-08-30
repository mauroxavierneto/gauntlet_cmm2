MODE 7,16
PAGE WRITE 0
COLOR RGB(255,255,255),RGB(41,41,41)
CLS
BOX 0,70,320,200-70,1,RGB(0,0,0),RGB(0,0,0)
PLAY STOP
PAGE WRITE 8: CLS: LOAD PNG ".\fonts\fonts.png",,,1
PAGE WRITE 1: CLS: LOAD PNG ".\images\goptions.png",,,8
COLOR RGB(41,41,41),RGB(0,0,0)
PrintS(77,45,-1,"CMM2 EDITION")
COLOR RGB(255,255,255),RGB(0,0,0)
OPT=1:SndNum=1

t=2
do while keydown(t)=32
 t=t+1: if t>4 then t=2
loop

CHANGE_SOUND_TYPE:

Play Stop
if music=1 then PlayMOD(9) else PlayMOD(0)

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
 For ttt=1 To 2
  If opt=ttt+2 Then co=2 Else co=0
  PrintS(tt,t,co,"CONTROLS P"+Str$(ttt))
  SELECT CASE CtrlType(ttt)
   CASE 0: printS(tt+100,t,co,"ARROW KEYS OR NUMPAD")
   CASE 1: printS(tt+100,t,co,"WII CLASSIC")
   CASE 2: printS(tt+100,t,co,"WII NUNCHUK")
   CASE 3: printS(tt+100,t,co,"A W D X S TAB")
  END SELECT
  t=t+15
 Next ttt
 If opt=5 Then co=2 Else co=0
 PrintS(tt,t,co,"SOUND TEST")
 if SndNum<=14 then
  PrintS(tt+100,t,co,UCASE$(ModMus$(SndNum,0))) 
  PrintS(tt+100,t+10,co,UCASE$(ModMus$(SndNum,1))) 
 else
  A$=UCASE$(SndTst$(SndNum-14,1)): B$=""
  IF LEN(A$)>23 THEN
   for tx=23 to 1 step -1
    IF MID$(A$,tx,1)=" " then exit for    
   next tx
   B$=RIGHT$(A$,LEN(A$)-tx)
   A$=LEFT$(A$,tx-1)
  ENDIF
  PrintS(tt+100,t,co,A$) 
  PrintS(tt+100,t+10,co,B$) 
 endif
 t=t+30
 If opt=6 Then co=2 Else co=0
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
 If k=k_U Or k=k_N8 Then opt=opt-1: If opt<1 Then opt=6
 If k=k_D Or k=k_N2 Then opt=opt+1: If opt>6 Then opt=1
 If opt=1 Then
  If k=k_L Or k=k_N4 Or k=k_R Or k=k_N6 Then
   PlQ=PlQ+1: If PlQ>2 Then PlQ=1
  EndIf
  If k=k_SPC Then k=-1
 EndIf
 If opt=2 Then
  If k=k_L Or k=k_N4 Or k=k_R Or k=k_N6 Then
   SELECT CASE Music
    CASE 0: Music=1: Goto CHANGE_SOUND_TYPE
    CASE 1: Music=0: Goto CHANGE_SOUND_TYPE
   END SELECT
  EndIf
 EndIf
 If opt=5 Then
  If k=k_L Or k=k_N4 Then
   SndNum=SndNum-1: If SndNum<1 Then SndNum=MaxSndTst
   SndTest=2
  EndIf
  If k=k_R Or k=k_N6 Then
   SndNum=SndNum+1: If SndNum>maxSndTst Then SndNum=1
   SndTest=2
  EndIf
  If k=k_SPC Then
   if SndNum>14 then
    PlayWAV(SndTst$(SndNum-14,2),100,"V")
   else
    PlayMOD(SndNum)
   EndIf
  Endif
 EndIf
 If opt=6 And k=k_SPC Then GoTo CREDITS
 
 ON ERROR SKIP 1: WII CLASSIC CLOSE
 ON ERROR SKIP 1: WII NUNCHUK CLOSE

 For ttt=1 To 2
  If opt=ttt+2 Then
   If k=k_L Or k=k_N4 Then
    CtrlType(ttt)=CtrlType(ttt)-1
    CtrlChange(ttt)=1:If CtrlType(ttt)<0 Then CtrlType(ttt)=3
   EndIf
   If k=k_R Or k=k_N6 Then
    CtrlType(ttt)=CtrlType(ttt)+1
    CtrlChange(ttt)=1:If CtrlType(ttt)>3 Then CtrlType(ttt)=0
   EndIf
   CtrlChange(ttt)=1:If CtrlType(ttt)>3 Then CtrlType(ttt)=0
  EndIf
 Next ttt
 if CtrlType(1)=CtrlType(2) Then CtrlType(2)=CtrlType(2)+1: CtrlChange(2)=1
 if CtrlType(1)=1 and CtrlType(2)=2 then CtrlType(2)=0: CtrlChange(2)=1
 if CtrlType(1)=2 and CtrlType(2)=1 then CtrlType(2)=0: CtrlChange(2)=1
Loop
If k=k_ESC Then 
 Pause(100)
 K=0
 GoTo INTRO
endif
GoTo SELECTION

