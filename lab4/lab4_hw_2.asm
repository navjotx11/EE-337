; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
ljmp main

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
		
start:
      using 0
	  push ar0
	  	  
	  mov P2,#00h
	  mov P1,#00h
	  ;initial delay for lcd power up

;here1:setb p1.0
      acall delay
;	  clr p1.0
	  acall delay
;	  sjmp here1


	  acall lcd_init      ;initialise LCD
	
	  acall delay
	  acall delay
	  acall delay
	  ; Write the FIRST screen----------------------------------------
	  mov a,#81h		 ;Put cursor on first row,1 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#mystring_1   ;Load DPTR with string1 Addr
	  acall lcd_sendstring1	   ;call text strings sending routine
	  acall delay
	  
	  mov a,#88h		 ;Put cursor on first row,8 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   r0,#81h   
	  acall lcd_sendstring2	  
	  acall delay
	  
	  mov a,#0C1h		 ;Put cursor on second row,1 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#mystring_2   ;Load DPTR with string1 Addr
	  acall lcd_sendstring1	   ;call text strings sending routine
	  acall delay
	  
	  mov a,#0C7h		 ;Put cursor on second row,7 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   r0,#85h     ;store location in r0
	  acall lcd_sendstring2	    ;write to lcd the data at these locations
	  acall delay
      
	  acall delay5
	  ; Write the SECOND screen	-------------------------------------------  
	    mov a,#081h		  ;Put cursor on first row,1 column
	    acall lcd_command  ;send command to LCD
	    acall delay
	    mov dptr,#mystring_3   ;Load DPTR with string3 Addr
	    acall lcd_sendstring1
		acall delay
		
		mov a,#088h		  ;Put cursor on first row,8 column
	    acall lcd_command ;send command to LCD
	    acall delay
	    mov r0,#090H      ;store location in r0
	    acall lcd_sendstring2   ;write to lcd the data at these locations
		acall delay

	    mov a,#0C1h		  ;Put cursor on second row,1 column
	    acall lcd_command ;send command to LCD
	    acall delay
	    mov dptr,#mystring_4 ;Load DPTR with string4 Addr 
	    acall lcd_sendstring1
		acall delay

	    mov a,#0C7h		  ;Put cursor on second row,7 column
	    acall lcd_command ;send command to LCD
	    acall delay
	    mov r0,#095H      ;store location in r0
	    acall lcd_sendstring2   ;write to lcd the data at these locations
        acall delay		
	   
	  pop ar0

here: sjmp here				//stay here 

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

;------------------------memory stored string------------------------------------------------
lcd_sendstring2:                       ; incase of data sending by r0
         push acc
  do_2:  mov a,@r0
		 jz exit2
		 LCALL ASCIICONV               ;Returns higher nibble in A and lower in B (ASCII)
		 acall lcd_senddata
		 mov a,b
		 acall lcd_senddata
		 inc r0
		 sjmp do_2
		 
exit2:   pop acc
 	     ret	 
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

;------------- ROM text strings---------------------------------------------------------------
org 900h
mystring_1:
         DB   "ABPSW=", 00H
mystring_2:
		 DB   "R012=", 00H
mystring_3:
         DB   " R345=", 00H
mystring_4:
         DB   "R67SP=", 00H
;----------------------------------------------------------------------------------------------		 

main:
   ;MOV SP,#0CFH
   mov a,#01H
   mov b,#02H
   mov r0,#03H
   mov r1,#04H
   mov r2,#05H
   mov r3,#06H
   mov r4,#07H
   mov r5,#08H
   mov r6,#09H
   mov r7,#0AH
   lcall storevals ;Store the current values of different registers
   lcall start     ;start displaying on LCD


storevals:                 ;Routine for storing values at defined locations
   push acc
   push ar0
   push ar0                 ;Push ar0 two times
   mov r0,#81H              ;start storing ABPSW form 81H
   mov @r0,a                ;***Indirect Accessing***
   inc r0
   mov a,b
   mov @r0,a
   inc r0
   setB C
   mov a,psw
   mov @r0,a
   inc r0
   mov @r0,#00H            ;** Explicitly defined zeros to end lcd_sendstring2 loop **
   
   mov r0,#85H              ;start storing R012 from 85H
   pop acc                  ;store original value of R1
   mov @r0,a
   inc r0
   mov a,r1
   mov @r0,a
   inc r0
   mov a,r2
   mov @r0,a
   inc r0
   mov @r0,#00H
   
   mov r0,#90H              ;start storing R345 from 90H
   mov a,r3
   mov @r0,a
   inc r0
   mov a,r4
   mov @r0,a
   inc r0
   mov a,r5
   mov @r0,a
   inc r0
   mov @r0,#00H
   
   mov r0,#95H              ;start storing R67SP from 95H
   mov a,r6
   mov @r0,a
   inc r0
   mov a,r7
   mov @r0,a
   inc r0
   mov a,SP
   mov @r0,a
   inc r0
   mov @r0,#00H
   
   pop ar0
   pop acc
   ret 
   
end