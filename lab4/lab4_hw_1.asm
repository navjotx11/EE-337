; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
ljmp main

org 200h
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
	  mov a,#81h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string1  ;Load DPTR with string1 Addr
	  acall lcd_sendstring1	   ;call text strings sending routine
	  acall delay

	  mov a,#0C2h		  ;Put cursor on second row,3 column
	  acall lcd_command
	  acall delay
	  mov   r0,#81h          ;store mem. location in r0
	  acall lcd_sendstring2   ;to display data in these mem. locations
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
lcd_sendstring1:              ;incase mem. location by dptr (rom string)
       		 
         clr a                   ;clear Accumulator for any previous data
         movc a,@a+dptr          ;load the first character in accumulator
		 jz  exit1             ;go to exit if zero
         acall lcd_senddata      ;send first char
         inc   dptr              ;increment data pointer
         sjmp  lcd_sendstring1    ;jump back to send the next character
exit1:     
         ret                     ;End of routine

;------------------------memory stored string------------------------------------------------
lcd_sendstring2:              ;incase mem. location is defined to r0
         mov a,@r0 
		 jz exit2
		 acall lcd_senddata
		 inc r0
		 sjmp lcd_sendstring2
		 
exit2:
 	     ret	 

;----------------------delay routine-----------------------------------------------------
delay:	 
         mov r3,#1
loop2:	 mov r4,#255
loop1:	 djnz r4, loop1
		 djnz r3,loop2
		 ret

;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "EE337 - Lab4", 00H
my_string2:
		 DB   "Navjot Singh", 00H


main:                              ;used to store the string to memory location
        mov r0,#81H      ;Stored data form memory location 81H (in upper RAM)
        mov @r0,#"N"
		inc r0
        mov @r0,#"a"
		inc r0
        mov @r0,#"v"         ;**Note the indirect addressing method used**
		inc r0
        mov @r0,#"j"
		inc r0
		mov @r0,#"o"
		inc r0
		mov @r0,#"t"
		inc r0
		mov @r0,#" "
		inc r0
		mov @r0,#"S"
		inc r0
		mov @r0,#"i"
		inc r0
		mov @r0,#"n"
		inc r0
		mov @r0,#"g"
		inc r0
		mov @r0,#"h"
		inc r0
		mov @r0,#00H        ;Explicity defined zero to end lcd_sendstring2 loop
		
/*		mov r1,#0A0H
		mov @r1,#"E"
		inc r1
		mov @r1,#"E"
		inc r1
		mov @r1,#"3"
		inc r1
		mov @r1,#"3"
		inc r1
		mov @r1,#"7"
		inc r1
		mov @r1,#" "
		inc r1
		mov @r1,#"-"
		inc r1
		mov @r1,#" "
		inc r1
		mov @r1,#"L"
		inc r1
		mov @r1,#"a"
		inc r1
		mov @r1,#"b"
		inc r1
		mov @r1,#" "
		inc r1
		mov @r1,#"4"
		inc r1
		mov @r1,#00H */
		
		lcall start
        		
end 