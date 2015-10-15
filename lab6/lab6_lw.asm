LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

org 000h
ljmp main

;--------------------------------------------------------------------------

org 000Bh
push acc
push psw
inc r6           ;Used to measure 30ms (i.e. r6 =15)
;lcall printdptr
inc dptr
clr TF0
pop psw
pop acc
reti

;--------------------------------------------------------------------------
org 0200h

;----------------------Convert Binary to ASCII--------------------------------------------		 

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

/*printdptr:
inc dptr
lcall delay
mov a,#81h
lcall lcd_command
lcall delay
mov a,dph
acall asciiconv
acall lcd_senddata
mov a,b
acall lcd_senddata
acall delay
mov a,dpl
acall asciiconv
acall lcd_senddata
mov a,b
acall lcd_senddata
ret*/




;-------------------------------------------------------------------------------
conv2cpl2:      ;to store 2's complement corresponding to 2ms delay (#3E8h)(#0fa0H?)
push acc
mov TL0,#60h
mov TH0,#0F0h
pop acc
ret
;--------------------------------2ms delay using hardware timer------------------------------------
delay2:                  ;2ms delay
push acc
setb TR0
again: jnb TF0,again
clr TR0
;mov a,dpl
;mov b,a                  ;b stores DPL
mov a,dpl                 ;a stores DPL
cjne a,#0F4h,do
mov a,dph
cjne a,#01h,do
pop acc
acall sec1time         ;change value of a
mov TH1,#00h           ;clear timer value
mov TL1,#00h           ;clear timer value
setb TR1               ;enable event counting on timer 1
ret
do:
pop acc
ret
;---------------------------------------------------------------------------------------------------
display_msg1:
acall delay
mov a,#80h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#string_1   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay
mov a,#85h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov  dptr,#string_2   ;Load DPTR with string1 Addr
acall lcd_sendstring1	   ;call text strings sending routine
acall delay
ret


display_msg2:
push acc
mov a,#0C0h		 ;Put cursor on first row,1 column
acall lcd_command	 ;send command to LCD
acall delay
mov P1,#0Fh
mov a,P1
anl a,#0Fh
acall asciiconv
acall lcd_senddata
mov a,b
acall lcd_senddata
mov a,#0C4h
acall lcd_command
acall delay
;clr TR1
mov a,r5                  ;directly usingh TL0
acall asciiconv
acall lcd_senddata
mov a,b
acall lcd_senddata
mov a,r4                 ;directly usingh TL0
acall asciiconv
acall lcd_senddata
mov a,b
acall lcd_senddata
;setb TR1
acall delay
pop acc
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
using 0
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
;-----------------------------------------------------------------------------------------

start:
mov TH1,#00h                ;one time event (at start)
mov TL1,#00h
acall sec1time
setb TR1                      ;enable event counting on timer 1
del1:
mov r1,a
jz del2
mov P1,#80h
setb P3.7
setb P1.6
 do1:
 acall conv2cpl2
 acall delay2
 djnz r1,do1
 cjne a,#0Fh,del2
 sjmp rst
;-------------------------------------------------------------------------------------
del2:
mov P1,#00h
clr P3.7
clr P1.6
 do2: 
 acall conv2cpl2
 acall delay2
 cjne r6,#0Fh,do2
rst:
mov r6,#00h
jmp del1
  
;-------------------------------------------------------------------------------------

sec1time:                  ;store no. of times to repeat in acc
clr TR1                         ;stop timer 1
push ar4
push ar5
mov a,TL1
mov r4,a
mov a,TH1
mov r5,a
acall display_msg2
pop ar5
pop ar4
mov dptr,#0000h
mov P1,#0Fh
mov a,P1
;mov a,#0Ch
anl a,#0Fh
cpl P1.4
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

;-------------------------------------------------------------------------------
org 900h

;strings stored in ROM
string_1:
         DB   "IN", 00H
string_2:
		 DB   "RPM", 00H

;-----------------------------------------------------------------------------------
main:

lcall lcd_init
mov a,#01h                   ;Clear the LCD
lcall lcd_command
lcall delay
lcall display_msg1           ;Display first line (one time event)
mov TMOD,#51h                ;Set 16 bit counting mode for T0,T1 and count event mode on T1
setb IE.7                    ;enable interrupts
setb ET0
;setb EX1
lcall start

END
