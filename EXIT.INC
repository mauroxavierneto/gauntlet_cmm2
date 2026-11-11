' -- PLAYER EXITS --

'KEEP THE ENTERED TILE IN WORLD COORDINATES WHILE OTHER PLAYERS SCROLL
Sub BeginExit(pl,exitTileX,exitTileY)
 If start(pl)<>0 Or energy(pl)<=0 Then Exit Sub
 exitX(pl)=Int(exitTileX):exitY(pl)=Int(exitTileY)
 x(pl)=(exitX(pl)-px-1)*16-SCX
 y(pl)=(exitY(pl)-py-1)*16-SCY
 xx(pl)=x(pl):yy(pl)=y(pl)
 start(pl)=100:mv(pl)=0:anim(pl)=0:AnimSpr(pl)=0:spd(pl)=0
 mov(pl)=0:kspace(pl)=0
 fire(pl)=0:xf(pl)=-64:yf(pl)=-64:firstf(pl)=0:fstart(pl)=0
 PlayWAV("EXIT",100)
End Sub

'A PLAYER WHO HAS ESCAPED WAITS WITHOUT ADVANCING THE ROOM ALONE
Sub CheckStageExit
 Local t,living,finished
 If nextroom=1 Then Exit Sub
 living=0:finished=0
 For t=PLN To PLQ
  If energy(t)>0 Then
   living=living+1
   If start(t)=30 Then finished=finished+1
  EndIf
 Next t
 If living=0 Then
  gameover=1
 ElseIf finished=living Then
  room=room+1
  nextroom=1
  PlaySample(17,11000)
 EndIf
End Sub
