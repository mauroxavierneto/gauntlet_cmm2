' -- SHARED COLLISION GEOMETRY (SCREEN PIXELS TO WORLD TILES) --

Function SafeTile(tx,ty)
 If tx<0 Or ty<0 Or tx>35 Or ty>35 Then
  SafeTile=600
 Else
  SafeTile=st(Int(ty),Int(tx))
 EndIf
End Function

'A TWO PIXEL INSET LEAVES ROOM TO TURN IN ONE TILE WIDE PASSAGES
Function StageBlocked(sx,sy,player)
 Local leftTile,rightTile,topTile,bottomTile,tx,ty,tile,passable
 leftTile=Int((sx+SCX+2)/16)+px+1
 rightTile=Int((sx+SCX+13)/16)+px+1
 topTile=Int((sy+SCY+2)/16)+py+1
 bottomTile=Int((sy+SCY+13)/16)+py+1
 StageBlocked=0
 For tx=leftTile To rightTile
  For ty=topTile To bottomTile
   tile=SafeTile(tx,ty)
   passable=0
   If player>0 Then
    Select Case tile
     Case 426,427,444,455,459: passable=1
     Case 490 To 504
      If key(player)>0 Then passable=1
    End Select
   EndIf
   If tile>0 And tile<5000 And tile<>434 And tile<>617 And passable=0 Then
    StageBlocked=1
    Exit Function
   EndIf
  Next ty
 Next tx
End Function

'RETURN -1 FOR SCENERY/ENEMIES, OR THE INDEX OF A PLAYER IN THE WAY
Function ActorCollision(sx,sy,skipEnemy,skipPlayer)
 Local other
 ActorCollision=-1
 If StageBlocked(sx,sy,skipPlayer) Then Exit Function
 For other=1 To maxg
  If other<>skipEnemy And ae(other)>0 And en(other)>0 Then
   If sx+14>xe(other)+2 And sx+2<xe(other)+14 And sy+14>ye(other)+2 And sy+2<ye(other)+14 Then Exit Function
  EndIf
 Next other
 For other=PLN To PLQ
  If other<>skipPlayer And start(other)=0 And energy(other)>0 Then
   If sx+14>x(other)+2 And sx+2<x(other)+14 And sy+14>y(other)+2 And sy+2<y(other)+14 Then
    ActorCollision=other
    Exit Function
   EndIf
  EndIf
 Next other
 ActorCollision=0
End Function

'SWEEP EACH AXIS SO SIX/EIGHT PIXEL STEPS CANNOT SKIP A WALL OR A CORNER
Sub MovePlayer(pl,targetX,targetY)
 Local delta,stepX,stepY,remaining,candidate
 x(pl)=xx(pl):y(pl)=yy(pl)
 delta=targetX-x(pl):stepX=Sgn(delta):remaining=Abs(delta)
 Do While remaining>0
  candidate=x(pl)+stepX*Min(1,remaining)
  If ActorCollision(candidate,y(pl),0,pl)<>0 Then Exit Do
  x(pl)=candidate:remaining=remaining-Min(1,remaining)
 Loop
 delta=targetY-y(pl):stepY=Sgn(delta):remaining=Abs(delta)
 Do While remaining>0
  candidate=y(pl)+stepY*Min(1,remaining)
  If ActorCollision(x(pl),candidate,0,pl)<>0 Then Exit Do
  y(pl)=candidate:remaining=remaining-Min(1,remaining)
 Loop
End Sub
