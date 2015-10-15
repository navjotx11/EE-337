org 000h
ljmp main

;-----------------------------------------------------------------------------
org 000Bh
push acc
push psw
inc r6           ;Used to measure 30ms (i.e. r6 =15)
inc dptr
pop psw
pop acc
reti

;-----------------------------------------------------------------------------
org 0200h

conv2cpl2:      ;to store 2's complement corresponding to 2ms delay (#3E8h)
push acc
clr TR0
mov a,#0E8h
cpl a
add a,#01
mov TL0,a
mov a,#03h
cpl a
addc a,#00h
mov TH0,a
setb TR0
pop acc
ret

delay2:                  ;2ms delay
push acc
setb TR0
setb TF0
again: jb TF0,again
;mov a,dpl
;mov b,a                  ;b stores DPL
mov a,dpl                 ;a stores DPL
cjne a,#0F4h,do
mov a,dph
cjne a,#01h,do
pop acc
acall readswitch         ;change value of a
ret
do:
clr TF0
clr TR0
pop acc
ret

;------------------------------------------------------------------------------
start:
acall readswitch

;loop:
;mov r5,#33                    ;Repeat 30ms delay 33 times ~0.99sec
 /*do:
  setb ET0                    ;enable interrupt for T0 overflow
  mov r1,a
  jz again2                   ;If a was 0, djnz r1-> cause r1 to go to 255 
  mov r6,#00h
  rep:
  acall conv2cpl2
  mov P1,#80h                 ;glow LED
  acall delay2
  djnz r1,rep            ;Keep LED glowing for k*2ms
  cjne a,#30,offled      
  sjmp rst 
  offled:
   mov P1,#00h
   again2: 
   acall delay2
   acall conv2cpl2
   cjne r6,#0Fh,again2
   clr TR0                     ;stop timer
  rst:
  djnz r5,do
  sjmp loop*/

del1:
mov r1,a
jz del2
mov P1,#80h
;loop:
;cjne dptr,#1F4h,do
;acall readswitch
 do1:
 acall conv2cpl2
 acall delay2
 djnz r1,do1
 cjne a,#0Fh,del2
 sjmp rst
;-------------------------------------------------------------------------------------
del2:
 mov P1,#00h
 do2: 
 acall conv2cpl2
 acall delay2
 cjne r6,#0Fh,do2
 rst:
 mov r6,#00h
 jmp del1
 
;-------------------------------------------------------------------------------------
readswitch:                  ;store no. of times to repeat in acc
mov dptr,#0000h
mov P1,#0Fh
mov a,P1
anl a,#0Fh
clr c
mov b,r1           ;store current reamaining delay value for del1
cjne a,b,change1
mov r1,#01h
ret 
change1:
jc change2
clr c
push acc           ;store read value
subb a,r1
add a,r1
mov r1,a
pop acc
ret
change2:
mov r1,#01h
ret

;--------------------------------------------------------------------------------------
org 900h


main:
mov TMOD,#01h                 ;Set 16 bit counting mode for T0
setb IE.7                    ;enable interrupts
setb ET0
lcall start

END
