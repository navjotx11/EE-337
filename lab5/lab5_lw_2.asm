LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable


org 0000h
ljmp main


org 000Bh               ;Interrupt vector address for T0
inc r4
reti

org 600h
	
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

mov a,#0C9h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov a,r4                   ;r4 stores number of times timer overflowed
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
mov a,TH0                  ;directly using TH0
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
mov a,TL0                  ;directly usingh TL0
lcall asciiconv
lcall lcd_senddata
mov a,b
lcall lcd_senddata
acall delay

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
      ;push ar3
	  ;push ar4
      mov r3,#100
	  looper1:
	  mov r4,#200
	  looper2:
	  acall delay
	  djnz r4,looper2
	  djnz r3,looper1
	  ;pop ar4
	  ;pop ar3
	  ret

;----------------------Subroutine for starting the timer--------------------------------------
start_timer:
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
clr TF0                ;clear overflow
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
         DB   "COUNT IS", 00H
;----------------------Convert Binary to ASCII--------------------------------------------		 

org 200h

ASCIICONV: 
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
RET

ALPHA2:MOV A,R3
ADD A,#37h          ;ALPHABET TO ASCII
RET	

;-----------------------------------------------------------------------------------

main:
mov P2,#00h
mov P1,#00h    ;Delay for LCD Powerup
;mov 63H,#00H
back:
lcall lcd_init
lcall display_msg1
mov r4,#00H
lcall start_timer
;r4 stores total no. of overflows
;r2 stores value of TH0
;r3 store value of TL0
lcall display_msg2
mov P1,#10100000B      ;Pattern asking user to set value of P1.0
acall delay5
sjmp back ;MAKE SURE TO RESET THE SWITCH DURING THIS TIME !!!

END