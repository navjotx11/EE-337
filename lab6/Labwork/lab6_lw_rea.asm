LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable


org 0000h
ljmp main

;------------------------------------------------------------------
org 000Bh               ;Interrupt vector address for T0
push acc
push psw
inc r4
pop psw
pop acc
reti
;------------------------------------------------------------------
org 600h

dispavg:
using 0
push ar5
mov r0,#60h
mov r5,#5
mov a,#00h
mov r4,#00h    ;used to store no. of carries
lp1:
 push acc
 mov a,@r0
 pop ar2
 add a,r2
 inc r0
 jnc contdo
 inc r4
 contdo:
 djnz r5,lp1
mov r6,a
; R6 now stores total sum of overflows
; Total no. = [R4,R6] (16bit)
/*
acall delay
mov a,#82h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#mystring_5   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay

acall delay
mov a,#0C0h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#mystring_6   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay

mov a,#0C8h
acall lcd_command
acall delay
mov a,r4
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay
mov a,r6
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay

*/

mov b,#7
mov a,r6
mul ab
mov r6,a          ;store lower byte in r6
push b            ;b stores the higher byte
mov b,#7
mov a,r4
mul ab
pop ar2
add a,r2          
mov r4,a          ;store higher byte in r4
mov r3,b          ;store overhead in r3

acall delay
mov a,#82h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#mystring_5   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay

acall delay
mov a,#0C0h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#mystring_6   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay

mov a,#0C8h
acall lcd_command
acall delay
mov a,r3
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay
mov a,r4
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay
mov a,r6
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay

pop ar5
ret


/*using 0
push ar5
using 0
mov r0,#60h          ;Stores LSB
mov r1,#65h          ;Stores MSB
mov r5,#5
mov r3,#0            ;Store no. of carries
mov a,#00h
clr c
 lp1:
 push acc
 mov a,@r0
 pop ar2
 add a,r2
 jnc cont1
 carryadd1:
 inc r3
 cont1:
  djnz r5,lp1          ;DJNZ does not affect carry flag
mov r6,a               ;R6 stores count of LSBs
mov r5,#5
mov a,#00h
lp2:
 push acc
 mov a,@r1
 pop ar2
 add a,r2
 jnc cont2
 carryadd2:
 inc r4
 cont2:
 djnz r5,lp2
 clr c
add a,r3 
 jnc contdo
 addcarry:
 inc r4
contdo:
mov r7,a              ;R7 stores count of MSBs
;[R4,R7,R6] represent the total count   (6bit no. in total)

divisiondisp:
;only displaying [R7,R6]/5
mov b,#05h
mov a,r7
div ab
; rem in b
; quo in a
mov 70h,a    ;quotient
mov a,b
anl a,#0fh
swap a
push acc
mov a,r6
anl a,#0F0h
swap a
mov r2,#00h
add a,r2
mov r2,a
pop acc
add a,r2    ;a now stores the a new no.
mov b,#5
div ab
mov 71h,a
mov a,b
anl a,#0fh
swap a
push acc
mov a,r6
anl a,#0Fh
mov r2,a
pop acc
add a,r2    ;a now stores a new no.
mov 72h,a

acall delay
mov a,#82h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#mystring_5   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay

acall delay
mov a,#0C0h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#mystring_6   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay

mov a,#0C8h
acall lcd_command
acall delay
mov a,70h
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay
mov a,71h
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay
mov a,72h
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay*/

pop ar5
ret







storeval:

mov @r0,a             ;Store no. of overflows starting from 60H
inc r0
/*push acc
mov a,b
mov @r1,a             ;Store MSB of multiplications by 33
pop acc
inc r1*/

ret

display_msg1:
using 0

acall delay
mov a,#80h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#mystring_1   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay

mov a,#0C0h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#mystring_2   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay
ret


display_msg2:

acall delay
mov a,#80h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#mystring_3   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay

mov a,#0C0h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#mystring_4   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay

mov b,#33         ;Each overflow corresponds to 33ms
mov a,r4
acall storeval
mul ab            ;Time in ms. for no. of overflows
;a now stores LSB of multiplication
;b now stores MSB of multiplication
; we need to display this time on the LCD (Note : we are not taking into account TH0 and TL0 yet)
/*mov a,#0CAh		        ;Put cursor on first row,1 column
acall lcd_command	    ;send command to LCD
acall delay
pop a                ;Display MSB of multiplication by 33
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay
*/

push acc
push b 

mov a,#0CAh		        ;Put cursor on first row,1 column
acall lcd_command	    ;send command to LCD
acall delay
pop acc                   ;Display MSB of multiplication by 33
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay
pop acc                   ;Dipslay LSB multiplication by 33
;mov a,TH0                  ;directly using TH0
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
lcall delay
;mov a,TL0                  ;directly usingh TL0
;lcall asciiconv
;lcall lcd_senddata
;mov a,b
;lcall lcd_senddata
;acall delay

ret

	
;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
		
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring1:                 ; incase of data sending by dptr
         push acc
do_1:    clr a                   ;clear Accumulator for any previous data
         movc a,@a+dptr          ;load the first character in accumulator
		 jz  exit1             ;go to exit if zero
         acall lcd_senddata      ;send first char
         inc   dptr              ;increment data pointer
         sjmp  do_1    ;jump back to send the next character
exit1:   pop acc
         ret                     ;End of routine


;----------------------delay routine-----------------------------------------------------
delay:	 push ar3
         push ar4
		 ;push acc
         mov r3,#1
loop2:	 mov r4,#255
loop1:	 djnz r4, loop1
		 djnz r3,loop2
		; pop acc
		 pop ar4
		 pop ar3
		 ret

;---------------------5secdelay------------------------------------------------------------
delay5:
      push ar3
	  push ar4
      mov r3,#100
	  looper1:
	  mov r4,#200
	  looper2:
	  acall delay
	  djnz r4,looper2
	  djnz r3,looper1
	  pop ar4
	  pop ar3
	  ret

;----------------------Subroutine for starting the timer--------------------------------------
start_timer:
push acc
mov TH0,#00H           ;clear timer
mov TL0,#00H           ;clear timer
mov TMOD,#01h          ;set 16-bit counting mode
setb ea                ;enable interrupts
setb et0               ;enable interrupt for T0 overflow
setb p1.4
setb TR0               ;start timer
again:                 ;waiting for bit to be set 1
mov P1,#8fH
mov a,P1
anl a,#0FH
jz again 
clr TR0                ;stop counting
;clr TF0                ;clear overflow
pop acc
ret


;------------- ROM text strings---------------------------------------------------------------
org 900h
mystring_1:
         DB   "PRESS SWITCH SW1", 00H
mystring_2:
		 DB   "  AS LED GLOWS  ", 00H
mystring_3:
         DB   "REACTION TIME   ", 00H
mystring_4:
         DB   "COUNT IS  ", 00H
mystring_5:
         DB   "AVERAGE TIME",00H
mystring_6:
         DB   "in msec ",00H			 

;----------------------Convert Binary to ASCII--------------------------------------------		 

org 200h

ASCIICONV:
push ar2
push ar3
MOV R2,A
ANL A,#0Fh
MOV R3,A
SUBB A,#0Ah  ;CHECK IF NIBBLE IS DIGIT OR ALPHABET
JNC ALPHA

MOV A,R3
ADD A,#30h   ;ADD 30H TO CONV HEX TO ASCII
MOV B,A
JMP NEXT

ALPHA: MOV A,R3  ;ADD 37H TO CONVERT ALPHABET TO ASCII
ADD A,#37h
MOV B,A

NEXT:MOV A,R2
ANL A,#0F0h          ;CHECK HIGHER NIBBLE IS DIGIT OR ALPHABET
SWAP A
MOV R3,A
SUBB A,#0Ah
JNC ALPHA2 

MOV A,R3			;DIGIT TO ASCII
ADD A,#30h
pop ar3
pop ar2
RET

ALPHA2:MOV A,R3
ADD A,#37h          ;ALPHABET TO ASCII
pop ar3
pop ar2
RET	

;-----------------------------------------------------------------------------------

main:
rep:
mov P2,#00h
mov P1,#00h    ;Delay for LCD Powerup
;mov 63H,#00H
mov r5,#5      ;Repeat loop 5 times
mov r0,#60h    ;Store overflow for each case
;mov r1,#65h
back:
lcall lcd_init
lcall display_msg1
mov r4,#00H                   ;set no. of overflows to zero
lcall start_timer
;r4 stores total no. of overflows
lcall display_msg2            ;should also store the value of times in each case
mov P1,#10100000B          ;Pattern asking user to set value of P1.0
acall delay5
;sjmp back ;MAKE SURE TO RESET THE SWITCH DURING THIS TIME !!!
djnz r5,back
acall dispavg                 ;compute from values at locations starting form 60h and 65h
stop: sjmp stop
END