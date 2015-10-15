org 000h
ljmp main

org 000Bh           ; ISR for timer T0 overflow, should reset when #OV,TH0,TH0= 1E8480
acall sec1time

reti

org 001Bh
push acc
push psw
inc r6           ;Used to measure 30ms (i.e. r6 =15)
pop psw
pop acc
reti

org 0200h

sec1time:
push acc
push psw
inc r5             ;Used to measure overflow for 1sec timer (i.e. r5=1Eh)
acall reset
pop psw 
pop acc
ret

reset:
cjne r5,#1Eh,norst
clr TR1        ;stop T1
;clr TF1
clr TR0        ;stop T0
;clr TF0        ;clear T0 overflow
pop acc        ;exit reset
pop acc        ;exit reset
pop psw 
pop acc
pop acc        ;exit sec1time
pop acc        ;exit sec1time
pop acc        ;POP PC
pop acc        ;POP PC
jmp start 

norst: 
 acall conv2cpl1
; clr TF0        ;clear T0 overflow
 ret

conv2cpl1:      ;to store 2's complement corresponding to 1sec      
push acc
mov a,#080h
cpl a
add a,#01
mov TL0,a
mov a,#84h
cpl a
addc a,#00h
mov TH0,a
pop acc
ret

conv2cpl2:      ;to store 2's complement corresponding to 2ms delay (#3E8h)
push acc
mov a,#0E8h
cpl a
add a,#01
mov TL1,a
mov a,#03h
cpl a
addc a,#00h
mov TH1,a
pop acc
ret

delay2:                  ;2ms delay
setb TR1
setb TF1
again: jb TF1,again     
clr TF1
clr TR1
ret

start:
setb IP.1
mov SP,#09h
mov TMOD,#11h                 ;Set 16 bit counting mode for both timers
mov P1,#0Fh
mov a,P1
anl a,#0Fh
mov b,#02
mul ab                       ;multiply input by 2, this should be the delay in ms
;we need to repeat a*2ms
setb IE.7                    ;enable interrupts
setb ET0                     ;enable interrupts for T0 overflow
acall conv2cpl1
mov r5,#00h                  ;used to store overflow for T0
setb TR0                     ;start 1sec timer
;mov r6,#00h                 ;used for implementing 30ms delay
mov a,#08
do:
 setb ET1                    ;enable interrupt for T0 overflow
 mov r1,a
 mov r6,#00h
 rep:
 acall conv2cpl2
 mov P1,#80h                 ;glow LED
 acall delay2
 djnz r1,rep            ;Keep LED glowing for k*2ms
 mov P1,#00h
 again2: 
 acall delay2
 acall conv2cpl2
 cjne r6,#0Fh,again2
 clr TR1                     ;stop timer
 sjmp do
 
org 900h

main:
lcall start

END





