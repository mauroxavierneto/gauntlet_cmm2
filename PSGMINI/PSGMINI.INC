' PSGMINI - SN76489 SIMULATOR - VGM PLAYER
' MAURO XAVIER 2020
'
' VERSION 0.2A
'
' EXCLUSIVE VERSION MADE FOR GAUNTLET CMM2 EDITION ONLY
' THIS IS A NOT RECOMMENDED INCLUDE FILE TO USE WITH OTHER GAMES
' USE A RECENT PSGMINI INCLUDE FILE INSTEAD

'INIT SOUND AND VARIABLES
Sub InitSound 
 If StartedPSG=0 then
  Dim MUS%(20000),ChVol(3),Ton(3),ChType$(3),ChgChan(3),MaxVol(3),EnChan(3)
  StartedPSG=1
 endif
 speed=1
 LONGSTRING CLEAR MUS%()
 Play Stop
End Sub

'CHANGE MUSIC SPEED (USE IT AFTER PLAY)
Sub ChangeSpeed(xx)
 Local SRate
 SRate=44100
 If xx=0 Then
  W60=0:W50=0:SWait=0
 Else
  W60=(1000/(SRate/735))/xx:W50=(1000/(SRate/882))/xx
  SWait=(1000/SRate)/xx
 EndIf
 Speed=xx
End Sub

' SEEK INTEGER NUMBER
Function SkInt(HMus,size)
 Local Temp$
 Temp$="": For SMus=size To 1 Step -1
  Seek #4,HMus+SMus:Temp$=Temp$+Hex$(Asc(Input$(1,#4)))
 Next SMus:SkInt=Val("&H"+Temp$)
End Function

' LOAD VGM FILE AND RESET CHANNELS
Sub LoadVGM(Music$)
 Local T,MusBuf
 Play Stop
 Open Music$ For INPUT As #4
 FOR T=0 TO 3
  SetChannelType(T+1,"Q"): SetChannelVol(T+1,15)
  ChgChan(T)=0: ChVol(T)=15: Ton(T)=1
  EnableChannel(T+1)
 NEXT T
 SetChannelType(4,"N")
 Speed=1:VGMoffset=SkInt(&H04,4):VGMO=SkInt(&H34,4)
 If VGMO=0 Then VGMO=&H40
 LOff=SkInt(&H1C,4):GoVGM:Rtim=1
 Seek #4,VGMO-2
 LMus=Lof(#4)
 PTim=0:STim=0:MP=0:MusBuf=250:T=0
 DO WHILE NOT(EOF(#4))
  T=T+250
  IF T>LMus then MusBuf=250-(T-LMus)
  LONGSTRING APPEND MUS%(),INPUT$(MusBuf,#4)
 LOOP 
 Close #4
End Sub

' VERIFY LOOP, OFFSET AND VGM RESTART
Sub GoVGM
  if MP>LMus Then StopVGM:GoTo NoSound
  If MP>=LMus And Loff>0 Then MP=Loff
  NoSound:
End Sub

' PLAY VGM FILE
Sub PlayVGM 
 ChangeSpeed(Speed)
 MP=VGMO-2:If MP>=LMus And Loff>0 Then MP=Loff
 PTim=0:STim=0:MP=0
 SetTick 10,IntSND,4
End Sub

' SET INTERRUPT (USE IT AFTER PLAY COMMAND)
Sub SetIntVGM(tickMus)
 if tickmus=0 then SetTick tickMus,2147483647,4 else SetTick tickMus,IntSND,4
End Sub

' STOP VGM BUT NOT UNLOAD
Sub StopVGM
 SetIntVGM(0):Pause(100):Play Stop
End Sub

' STOP VGM AND UNLOAD
Sub UnloadVGM
 SetIntVGM(0):StopVGM:Pause(100):Play Stop:LONGSTRING CLEAR MUS%():Ra$=""
End Sub

' SET CHANNEL TYPE
Sub SetChannelType(Ch,Type$)
 ChType$(Ch-1)=Type$
End Sub

' SET MAXIMUM CHANNEL VOLUME
Sub SetChannelVol(Ch,Vl)
 MaxVol(Ch-1)=(15-Vl)
End Sub

' DISABLE CHANNEL
Sub DisableChannel(Ch)
 EnChan(Ch-1)=0
End Sub

' ENABLE CHANNEL
Sub EnableChannel(Ch)
 EnChan(Ch-1)=1
End Sub

' VGM INTERRUPTION ROUTINE - SN76489 SIMULATOR
Sub IntSND
 Local H,M$,T,SN, Frames
 If MP>LMus then if Loff>0 Then MP=Loff else StopVGM: Exit Sub
 Do While (Timer-STim<=PTim):Rtim=1:Exit Sub:Loop
 If Rtim=1 Then STim=Timer:PTim=SWait:Rtim=0
 MP=MP+1:H=Peek(VAR MUS%(),MP)
 SELECT CASE H
 CASE &H50:
  ChgChan(0)=0:ChgChan(1)=0:ChgChan(2)=0:ChgChan(3)=0
  MP=MP+1:M$=Bin$(Peek(VAR MUS%(),MP))
  If Left$(M$,1)="1" Then ' LATCH
   Ch=Val("&B"+Mid$(M$,2,2))
   If Mid$(M$,4,1)="0" Then ' SOUND    
    if Ch=3 then
     IF Mid$(M$,6,1)="1" THEN ' WHITE NOISE
      Ton(3)=3579545/((10200-Val("&B"+Right$(M$,2))*1500)*32): ChType$(3)="N"      
     ELSE ' "PERIODIC" NOISE      
      SELECT CASE Val("&B"+Right$(M$,2))
       CASE 0: Ton(3)=40: ChType$(3)="W2"
       CASE 1: Ton(3)=30: ChType$(3)="W2"
       CASE 2: Ton(3)=1:  ChType$(3)="P"
       CASE 3: Ton(3)=110: ChType$(3)="W2"
      END SELECT
     ENDIF
    else ' TONE
     Ton(Ch)=(3579545/((Val("&B"+Right$(Bin$(Peek(VAR MUS%(),MP+2)),6)+Right$(M$,4))+1)*32))
    endif
    MP=MP+2
    If Ton(ch)>20000 Then Ton(ch)=1
    ChgChan(Ch)=1
   Else ' VOLUME
    ChgChan(Ch)=1: ChVol(Ch)=Val("&B"+Right$(M$,4))+MaxVol(Ch): if ChVol(Ch)>15 then ChVol(Ch)=15
   EndIf   
   if ChVol(Ch)<15 and Ton(Ch)>0 and ChgChan(Ch)=1 and MM.INFO$(SOUND)<>"MP3" and MM.INFO$(SOUND)<>"WAV" and EnChan(Ch)=1 then 
    SN=Ton(Ch)
    SELECT CASE ChType$(Ch)
     CASE "Q":  Play Sound Ch+1,B,Q,SN,12-ChVol(Ch)/2
     CASE "W":  Play Sound Ch+1,B,W,SN,16-ChVol(Ch)
     CASE "N":  
      T=20-ChVol(Ch)*1.2: IF T<1 THEN T=1
      Play Sound Ch+1,B,N,SN,T
     CASE "T":  Play Sound Ch+1,B,T,SN,25 'REMOVED VOLUME CONTROL TO SIMULATE NES APU
     CASE "S":  Play Sound Ch+1,B,S,SN,25-ChVol(Ch)
     CASE "P":  
      T=25-ChVol(Ch)*1.7: IF T<1 THEN T=1
      Play Sound Ch+1,B,P,SN,T
     CASE "W2": Play Sound Ch+1,B,W,SN,16-ChVol(Ch)
    END SELECT
    Exit Sub
   else
    if ChType$(Ch)<>"" and MM.INFO$(SOUND)<>"MP3" and MM.INFO$(SOUND)<>"WAV" and EnChan(Ch)=1 then Play Sound Ch+1,B,O,1,1
    Exit Sub
   endif
  endif 
 CASE &H61: PTim=PTim+SWait*(Peek(VAR Mus%(),MP+2)*256+Peek(VAR Mus%(),MP+1)): MP=MP+2
 CASE &H62: PTim=PTim+W60
 CASE &H63: PTim=PTim+W50
 CASE &H66: 
   If Loff>0 Then
    MP=Loff:GoVGM
   Else
    MP=Loff+1
   EndIf
  Exit Sub
 CASE &H70 TO &H7F: Frames=(H-&H6F):PTim=PTim+SWait*Frames
 END SELECT
End Sub

