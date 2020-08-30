'-- SHOW GAME INTRO --

IF TEST>0 THEN FIRSTLOAD=1: GOTO START_VIDEO
Mode 7,16
Play Stop

PAGE WRITE 6
CLS: Load PNG "./IMAGES/INTRO1.PNG",,,8
FONT #7
COLOR RGB(0,0,0)
PRINT @(MM.HRES-LEN(version$)*6-2,2,1) version$
FONT #1

COLOR RGB(255,255,255)

PAGE WRITE 3
CLS: Load PNG "./IMAGES/RAINBOW.PNG",0,0

k=keydown(1)

if music=1 then
 if retro=1 then
  LoadVGM("./vgm/title.vgm")
  SetChannelType(1,"T")
  SetChannelType(2,"Q")
  SetChannelType(3,"Q")
  PlayVGM: ChangeSpeed(1): SetIntVGM(1)
 else
  PlayMOD(13)
 endif
endif

co=1:temp=0:Timer=0
Do While Kb<>32
 kb=KeyDown(1)
 If kb=27 Then Mode 1:End
 PAGE SCROLL 3,0,2
 PAGE COPY 3 TO 4,I
 PAGE WRITE 4
 BLIT 66,46,66,46,187,40,6,4
 PAGE COPY 6 TO 7,I
 PAGE WRITE 7
 BLIT 66,46,66,46,187,40,4,4 
 PAGE COPY 7 TO 0,I
 If Timer>30000 And temp=0 and retro=1 Then StopVGM:temp=1
Loop
if retro=1 then UnloadVGM

