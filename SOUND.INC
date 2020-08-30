'-- SOUND ROUTINES --


' -- PLAY DIGITAL SOUND EFFECTS WITH MOD MUSIC --
Sub PlayWAV(sndname$,priority,type$)
 if priority>=PrWav then 
  PrWav=priority  
  IF MM.INFO$(SOUND)="MODFILE" THEN 
   SELECT CASE type$
    CASE "S","": Play Effect "./SOUND/SFX/"+sndname$+".WAV",StopWAV
    CASE "V": Play Effect "./SOUND/NARRATOR/"+sndname$+".WAV",StopWAV
   END SELECT
  else
   play stop
   SELECT CASE type$
    CASE "S","": Play WAV "./SOUND/SFX/"+sndname$+".WAV",StopWAV
    CASE "V": Play WAV "./SOUND/NARRATOR/"+sndname$+".WAV",StopWAV
   END SELECT
  endif
 endif
End Sub


' -- PLAY MOD FILE WHEN ENABLED --
Sub PlayMOD(m)
 Play Stop: Play MODFile "./MOD/" + ModMus$(m,0) + ".mod", 22050
End Sub


' -- NOTIFY PRIORITY DIGITAL SFX AS ZERO --
Sub StopWAV
 PrWav=0
End Sub


' -- PLAYER'S HURT SOUND --
Sub HurtSound(A)
 if rnd(88)<0.5 then Exit Sub 
 SELECT CASE A
  CASE 1,3: if rnd(88)>0.8 then PlaySample(29,22050) 'WARRIOR / WIZARD
  CASE 2:   if rnd(88)>0.8 then PlaySample(28,22050) 'VALKYRIE
  CASE 4:   if rnd(88)>0.8 then PlaySample(16,22050) 'ELF
 END SELECT
End Sub

' -- VOICE ON GAME --
Sub VoiceOver(A$,V$,type)
 Local Co
 PAGE WRITE 0
 PlayWAV(V$,999,"V")
 exit sub
 if type=0 then
  if start(pl)=1 then Co=RGB(0,0,0) else Co=RGB(255,0,0)  
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



