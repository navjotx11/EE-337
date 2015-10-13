LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable


ORG 000H
ljmp main

ASCIICONV:               ;Subroutine returns lower nibble in B and higher nibble in A
using 0
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



switchcheck:
     mov P1,#0FH      ;Select DIP switches
     mov A,P1        
     anl A,#0FH       ;mask LED bits
     swap A           ;Taking lower nibble as location value
	 push acc         ;for further use
	 push acc         ;for further use
	 mov P1,#0FH      ;turn off LEDs
	 lcall delay5
     mov P1,#0FH      ;select DIP switches
	 mov a,P1
	 anl a,#0FH
	 swap a
	 pop ar1          ;store initial value of a in r1 
	 clr c
	 subb a,r1        ;compare if current and initial value are same
	 cjne a,#00H,do   ;else repeat procedure
	 pop acc          ;value is correct, store this value in acc
	 ret
	 do:
	  pop acc
	  sjmp switchcheck


start:
      using 0
	  push ar1
	  push ar2
      push acc	  
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
	  
	  mov r0,a                 ;r1 stores the memory location
	  mov r2,#00H
	  
  
upper:                    ;subroutine for writing in upper line
    mov r4,#08H
	mov b,#81H
dou:                
    mov a,r0
    clr c
	subb a,#80H
	anl a,#80H
	cjne a,#00H,directu
	indirectu:        ;if mem. location is in upper RAM
	  mov a,b         ;b stores cursor posn
	  push b          ;value of b is modified, but requires to be used later
	  lcall lcd_command     ; move cursor
	  push 60H              ;save value of 60H
	  mov 60H,r0            ; Note : r0 stores the memory location
	  mov r1,60H            ; r1 stores value of 60H (i.e memory location)
	  mov a,@r1              ;60H is guaranteed to be in lower RAM
	  pop 60H
	  lcall asciiconv
	  lcall lcd_senddata     ;send ascii msn to LCD
	  mov a,b
	  lcall lcd_senddata     ;send ascii lsn to LCD
	  inc r0 
	  dec r4                 ;next iteration
	  pop b                  ;restore cursor position
	  mov a,b                
	  add a,#02              ;increment cursor position by 2
	  mov b,a
	  djnz r4,dou            ; repeat if not done
	  ;lcall delay5
	  ljmp lower             ; if done, start writing in lower line
	
	directu:          ;if memory location is in lower RAM
	  mov a,b         ;b stores cursor posn
	  push b
	  lcall lcd_command
	  mov a,@r0
	  lcall asciiconv
	  lcall lcd_senddata
	  mov a,b
	  lcall lcd_senddata
	  inc r0
	  dec r4
	  pop b
	  mov a,b
	  add a,#02
	  mov b,a
	  djnz r4,dou
	  ;lcall delay5
	  ljmp lower         ; if done, start writing in lower line

lower:                    ;subroutine for writing in lower line
    mov r4,#08H
    mov b,#0C1H
dol:
    mov a,r0
    clr c
	subb a,#80H
	anl a,#80H
	cjne a,#00H,directl
	indirectl:        ;if memory location is in upper RAM
	  mov a,b         ;b stores cursor posn
	  push b
	  lcall lcd_command
	  PUSH 60H          ;save value of 60H
	  mov 60H,r0        ; Note : r0 stores the memory location
	  mov r1,60H        ; 60H is guaranteed to be in lower RAM    
	  mov a,@r1             
	  POP 60H
	  lcall asciiconv   ;return the ascii value defined by nibbles
	  lcall lcd_senddata ;write first nibble (msn)
	  mov a,b
	  lcall lcd_senddata  ;write second nibble (lsn)
	  inc r0
	  dec r4
	  pop b
	  mov a,b
	  add a,#02
	  mov b,a
	  djnz r4,dol        ;if not done, repeat the lower writing procedure
	  inc r2
	  ljmp nextit
	
	directl:          ;if memory location is in lower RAM
	  mov a,b         ;b stores cursor posn
	  push b
	  lcall lcd_command         ;move cursor
	  mov a,@r0
	  lcall asciiconv
	  lcall lcd_senddata
	  mov a,b
	  lcall lcd_senddata        ;Redundant
	  inc r0                    ;Check the comments
	  dec r4                    ;in directu (only value of B varies)
	  pop b
	  mov a,b
	  add a,#02
	  mov b,a
	  djnz r4,dol
	  inc r2
	  ljmp nextit

toupper: jmp upper      ;repeat upper again if not done till second screen

nextit:
    lcall delay5        
    cjne r2,#02H,toupper   ;if not done twice, repeat upper (although with diff. r0)
	pop acc
	pop ar2
	pop ar1
	RET


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
;--------------------------------------------------------------------------------------------	  
	   

main:
  mov P1,#10100000B        ;Indicator that LED is accepting values(input mem. location value)
  lcall delay5             ;Delay for writing value
  
  mov r0,#90H              ;Store values 1 to 16 starting from location specified
  mov r1,#16
  mov a,#1
  loop:
    mov @r0,a
    inc r0
    inc a
    djnz r1,loop
 
  lcall switchcheck        ;Acc stores values of memory location
  lcall start              ;Start display process
  here: sjmp main          ;Repeat the full procedure again
  
  ;Flow of Command: 
  ; main -> switchcheck -> start -> upper -> lower -> nextit -> (repeat)  
END