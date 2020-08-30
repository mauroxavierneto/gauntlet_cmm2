'-- ENEMIES FUNCTIONS --



'-- INSERT ENEMIES ON SCREEN AND CONTROL THEM --

Sub PutEnemies
 Local t,tt,spd,mov,pl
 PAGE WRITE 3
 For n=eini To cntg step stp
  if ae(n)<=0 then Continue For

 If en(n)<=0 Then RetEnemy(n,0): Continue For
 xt=xe(n):yt=ye(n)
 If xt<-16 Or xt>240 Or yt<-16 Or yt>240 Then RetEnemy(n,ce(n)): GoSortEnemies=1: Continue For

 dist=100
 for t= PLN to PLQ
  tt= SQR( (xe(n)-x(t))^2 + (ye(n)-y(t))^2 )  
  if tt < dist then dist=tt: pl=t
 next t

 if lv(n)<0 then lv(n)=0
 cee=ce(n):enn=en(n):tee=te(n):xa=xt:ya=yt:lev=lv(n)*1000
 xb=Cint((xa+SCX)/16+xz):yb=Cint((ya+SCY)/16+yz)
 xant=(xa+SCX)/16+xz:yant=(ya+SCY)/16+yz
 If tee<>13 Then st(int(yb),int(xb))=0: BlockStage(xant,yant,-1)

 'WALKING ENEMIES
 IF tee Mod 2<>0 Then 
  sx=0:sy=0:spd=8
  'CHASE PLAYER
  SELECT CASE ya
   CASE >y(pl)+7:
    sy=-spd
    SELECT CASE xa
     CASE <x(pl)-7: mov=2: sx=spd
     CASE >x(pl)+7: mov=8: sx=-spd
     CASE ELSE: mov=1
    END SELECT
   CASE <y(pl)-7:
    sy=spd
    SELECT CASE xa
     CASE <x(pl)-7: mov=4: sx=spd
     CASE >x(pl)+7: mov=6: sx=-spd
     CASE ELSE: mov=5
    END SELECT 
   CASE ELSE:
    SELECT CASE xa
     CASE <x(pl)-7: mov=3: sx=spd
     CASE >x(pl)+7: mov=7: sx=-spd
    END SELECT
  END SELECT
  
  xa=xa+sx:ya=ya+sy: xb=(xa+SCX)/16+xz:yb=(ya+SCY)/16+yz: PlHurt=0
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

  'REMOVE ENEMY IF IS INSIDE PLAYER (EXCEPT DEAD AND SLIME)
  if xa=x(pl) and ya=y(pl) and tee<>9 and tee<>11 then RetEnemy(n,0): Continue For

  If ae(n)>1 Then xa=xt:ya=yt:ae(n)=ae(n)-1

  SELECT CASE tee   
   CASE  1: cee=200+Mov-1 'GHOST
   CASE  3: cee=224+Mov-1 'GRUNT   
   CASE  5:               'DEMON 
    cee=248+Mov-1: If Rnd(75)*1>0.40 And DFire=0 Then AddEnemy(xa,ya,13,445+Mov,pl):DnFire=n
   CASE  7: cee=296+Mov-1 'SORCERER
   CASE  9:               'SLIME
    cee=344+Mov-1: mx=spd*(Int(Rnd(20)*3)-1):my=spd*(Int(Rnd(70)*3)-1):xa=xa+mx:sx=mx:ya=ya+my:sy=my
   CASE 11: cee=320+Mov-1 'DEAD
  END SELECT

  '** ATTACK ON PLAYER **
  if PlHurt=1 and start(pl)=0 then
   
   'PLAYER HURT SOUND
   xa=xt:ya=yt: updOSD=1
   
   'PLAYER FIGHT WITH THE ENEMY
   if mov<>0 then Enn=Enn-Cfig(pl): Anim(pl)=1
   
   'DAMAGE ON PLAYER - PLAYER'S ARMOR
   if tee=1 or swi=0 then HurtSound(PType(pl)): Energy(pl)=Energy(pl)-(tee*5)+(Carm(pl)*tee)/2:refresh=1
   If cee<=399 Then SPR=cee+Ean+Lev: BLIT (((SPR-200) MOD 1000) MOD 18)*17,FIX(((SPR-200) MOD 1000)*17/306)*17,xt,yt,16,16,5,4
   'PutSpriteEnemy(cee+Ean+lev,xt,yt)

   'ENEMY ATTACK SOUND
   SELECT CASE tee
    CASE  1: xe(n)=xa:ye(n)=ya: RetEnemy(n,0): PlaySample(20,28000): Continue For
    CASE  3: If swi=0 Then PlaySample(20,16000)
    CASE  5: If swi=0 Then PlaySample(20,12000)
    CASE  7: If swi=0 Then PlaySample(20,22050)
    CASE  9: PlayWAV("SLIME_ATTACK",99)
    CASE 11: PlayWAV("DEAD_ATTACK",99): IF KILLDE=0 THEN KILLDE=1
    CASE <>13: st(Cint((yt+SCY)/16+yz),Cint((xt+SCX)/16+xz))=cee+5000      
   END SELECT

  '** FREE ENEMY - NO COLLISION **
  Else
    If en(n)>0 Then SPR=cee+Ean+lev: BLIT (((SPR-200) MOD 1000) MOD 18)*17,FIX(((SPR-200) MOD 1000)*17/306)*17,xa,ya,16,16,5,4
    If tee<>13 Then st(yb,xb)=cee+5000
  EndIf

 '** ENEMY GENERATORS **
 else
  atmp=xa-x(pl):btmp=ya-y(pl)
  If (atmp*atmp)+(btmp*btmp)<=196 Then
   enn=enn-Cfig(pl)
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
   'PutSpriteEnemy(tt+lev,xa,ya)
   SPR=tt+lev:BLIT (((SPR-200) MOD 1000) MOD 18)*17,FIX(((SPR-200) MOD 1000)*17/306)*17,xa,ya,16,16,5,4
   'DEFINE GENERATOR TYPE
   gtp=1000 'GHOST AND GRUNT GENERATORS
   SELECT CASE tee
    CASE 4: tee=1200 'DEMON GENERATOR
    CASE 6: tee=1300 'SORCERER GENERATOR
   END SELECT
   st(int(yb),int(xb))=cee+gtp
   cee=tt
  EndIf

  ' ** GENERATE ENEMIES **
  If mv(pl)=0 Then
   If Rnd(1)>0.50 Then 'RANDOM SEED
    tx=Int(Rnd(320)*3)-1:ty=Int(Rnd(120)*3)-1
    tt=0: BlockStage(xb,yb,tt)
    If st(int(yb+ty),int(xb+tx))=0 and tt=0 then
     'SIDE OF GENERATED ENEMIES
     SELECT CASE xa+tx*16
      CASE <x(pl): mov=3
      CASE >x(pl): mov=7
     END SELECT
     SELECT CASE ya+ty*16
      CASE >y(pl):
       mov=1
       if xa+tx*16<x(pl) then mov=2 
       if xa+tx*16>x(pl) then mov=8
      CASE <y(pl):
       mov=5
       if xa+tx*16<x(pl) then mov=4 
       if xa+tx*16>x(pl) then mov=6
     END SELECT
     'TYPE OF GENERATED ENEMIES
     SELECT CASE tee
      CASE 0: tt=200+Mov-1 'GHOST
      CASE 2: tt=224+Mov-1 'GRUNT
      CASE 4: tt=248+Mov-1 'DEMON
      CASE 6: tt=296+Mov-1 'SORCERER
     END SELECT
     AddEnemy(xa+tx*16,ya+ty*16,tee+1,tt+lev,pl)
    EndIf
   EndIf
  EndIf
  'PutSpriteEnemy(cee+lev,xa,ya)
  SPR=cee+lev: BLIT (((SPR-200) MOD 1000) MOD 18)*17,FIX(((SPR-200) MOD 1000)*17/306)*17,xa,ya,16,16,5,4
 EndIf
 xe(n)=xa:ye(n)=ya: ce(n)=cee: en(n)=enn: lv(n)=fix(lev/1000)
 If enn<=0 Then RetEnemy(n,0) else BlockStage(xant,yant,-5)

 EaIni(n)=1
 Next n

End Sub


'-- FIX ENEMIES-- 
Sub FixEnemies(a,pl)
 Local t,xt,yt
 For t=1 To maxg
  If ae(t)>0 And en(t)>0 Then
   xt=xe(t):yt=ye(t)
   If xt>=-16 And xt<=240 And yt>=-16 And yt<=208 Then
    If a=1 Then BLIT (((ce(t)-200) MOD 1000) MOD 18)*17,FIX(((ce(t)-200) MOD 1000)*17/306)*17,xt,yt,16,16,5,4
    'PutSpriteEnemy(ce(t),xt,yt) 'REDRAW
    If a=2 Then RetEnemy(t,ce(t)) 'MARK
    If a=3 Then RetEnemy(t,-1) 'RESET
    If a<0 And int(Rnd(10)*cMag(pl)+1)<=cMag(pl) Then RetEnemy(t,0) 'MAGIC
   EndIf
  EndIf
 Next t
End Sub


' -- ADD ENEMY --
Sub AddEnemy(xg,yg,tp,ch,pl)
 Local tc,ok,i,xb,yb,t,tt,mov,energ,lvcg
 tc=0:ok=0 
 ' ADJUST LEVEL USING SPRITE NUMBER
 level=1
 if ch>2000 then ch=ch-2000:level=3
 if ch>1000 then ch=ch-1000:level=2
 Do While (tc<=maxg And ok=0 And tp<>13)
  tc=tc+1
  If ae(tc)=0 Then
   for i=1 to cntg
    if en(i)>0 and xe(i)=xg and ye(i)=yg then exit sub
   next i
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
      CASE <x(pl): mov=3
      CASE >x(pl): mov=7
     END SELECT
     SELECT CASE yg
      CASE >y(pl):
       mov=1
       if xg<x(pl) then mov=2 
       if xg>x(pl) then mov=8
      CASE <y(pl):
       mov=5
       if xg<x(pl) then mov=4 
       if xg>x(pl) then mov=6
     END SELECT
     mov=mov-1
    endif
    xe(tc)=xg:ye(tc)=yg:ae(tc)=3:te(tc)=tp:ce(tc)=ch+mov:en(tc)=energ:lv(tc)=level
   endif
   Exit Do
  EndIf 'ae(tc)=0
 Loop
 ' DEMON'S FIRE
 If tp=13 And dfire=0 Then
  ' FIRE SIDE    
  If ch=446 Then xfs(0)= 0:yfs(0)=-8
  If ch=447 Then xfs(0)= 8:yfs(0)=-8
  If ch=448 Then xfs(0)= 8:yfs(0)= 0
  If ch=449 Then xfs(0)= 8:yfs(0)= 8
  If ch=450 Then xfs(0)= 0:yfs(0)= 8
  If ch=451 Then xfs(0)=-8:yfs(0)= 8
  If ch=452 Then xfs(0)=-8:yfs(0)= 0
  If ch=453 Then xfs(0)=-8:yfs(0)=-8
  xf(0)=xg:yf(0)=yg:sprDF=ch
  xb=(xf(0)+xfs(0)+SCX)/16+xz:yb=(yf(0)+yfs(0)+SCY)/16+yz:t=0.5:tt=0:dfire=1
  firstf(0)=2:fstart(0)=0:tt=0
  ' DON'T SHOT NEAR WALLS
  For t=0 To 0.5 Step 0.5
   If st(yb,xb)<>0 Or st(yb-t,xb)<>0 Or st(yb,xb-t)<>0 Or st(yb-t,xb-t)<>0 Then tt=1
  Next t
  For t=0 To 0.5 Step 0.5
   If st(yb,xb)=617 Or st(yb-t,xb)=617 Or st(yb,xb-t)=617 Or st(yb-t,xb-t)=617 Then tt=0
  Next t
  if tt=1 then dfire=0: DnFire=0
  If dfire<>0 Then PlaySample(30,22050)
 EndIf
End Sub


' -- RETURN ENEMY TO STAGE ARRAY --
Sub RetEnemy(n,gr)
 Local t,xt,yt,a
 If ae(n)=0 Then Exit Sub
 xt=(xe(n)+SCX)\16+px+1:yt=(ye(n)+SCY)\16+py+1
 If xt>0 And yt>0 And xt<37 And yt<37 Then 
  if gr>0 then gr=ce(n)+lv(n)*1000
  if gr=0 then GoSortEnemies=1

  ' RETURN ONLY ENEMIES - DON'T ALLOW TO OVERWRITE WALLS OR OBJECTS
  t=0
  SELECT CASE st(yt,xt)
   CASE    0, >=5000 : t=1
   CASE  200 TO  399,  595 TO  597,  695 TO  697: t=1
   CASE 1200 TO 1399, 1595 TO 1597, 1695 TO 1697: t=1
   CASE 2200 TO 2399, 2595 TO 2597, 2695 TO 2697: t=1   
  END SELECT

  if t=1 then st(yt,xt)=gr
 EndIf
 If gr<0 Then en(n)=-1 Else ae(n)=0:en(n)=0:xe(n)=-64:ye(n)=-64:xh(n)=0:yh(n)=0
End Sub


' -- SORT ENEMIES ARRAY TO SPEED UP --
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


' -- SHOW ENEMIES (NOT USED, OPTIMIZED TO USE THIS COMMAND DIRECTLY) --
Sub PutSpriteEnemy(spr,xtt,ytt)
 BLIT (((SPR-200) MOD 1000) MOD 18)*17,FIX(((SPR-200) MOD 1000)*17/306)*17,Xtt,Ytt,16,16,5,4
End Sub
 'if spr>=5000 then spr=spr-5000
 'PGe=3
 'SELECT CASE spr
 ' CASE    0 TO  999: spr=spr- 200:PGe=5
 ' CASE 1000 TO 1999: spr=spr-1200:PGe=4
 ' CASE 2000 TO 2999: spr=spr-2200:PGe=9
 'END SELECT
'End Sub


