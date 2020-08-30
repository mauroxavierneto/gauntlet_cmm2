'-- TEXT PRINT ROUTINES --


'-- FONTS FOR OPTIONS AND LOADING --
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
  BLIT LX,LY,x+T*sx,y,sx,sy,8,4
 NEXT T
End Sub


'-- FONTS FOR COPYRIGHT --
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


'-- FONTS IN-GAME --
Sub PrintG(x,y,st$)
 FOR L_T = 1 TO LEN(st$)
  LXt=(ASC(mid$(st$,L_T,1))-32)*6
  LYt=170: IF LXt>318 THEN LXt=LXt-318:LYt=178
  BLIT LXt,LYt,x+L_T*6,y,6,8,8,0
 NEXT L_T
End Sub

