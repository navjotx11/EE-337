ORG 000H
LED EQU P1
LJMP MAIN

delay:                        ;Total Delay Provided is D/2 seconds
   USING 0                    ;where D is stored in location 4FH
   PUSH AR4
   PUSH AR1
   PUSH AR2
   PUSH AR3
   PUSH ACC
   MOV R4,4FH                 ;Or mention this Value inexplicitly
   LOOP:
   MOV R3,#10                 ;Module Provides delay of 0.5 sec
   BACK2:
    MOV R2,#200
    BACK1:
     MOV R1,#0FFH
      BACK:
       DJNZ R1, BACK
       DJNZ R2, BACK1
       DJNZ R3, BACK2
       DJNZ R4, LOOP
   POP ACC
   POP AR3
   POP AR2
   POP AR1
   POP AR4
   RET   


zeroOut:                         ;Set an array to zero
   PUSH AR0
   PUSH AR1
   MOV R0,50H
   MOV R1,51H
   dozero:
	 MOV @R1,#00H
	 INC R1
	 DJNZ R0,dozero
   POP AR1
   POP AR0   
   RET
   
   
display:                          ;Function to display on LED
   PUSH ACC
   PUSH AR1
   PUSH AR3
   PUSH 4FH
   MOV R3,50H
   MOV R1,51H
   MOV 4FH,#02
   dodisplay:
	MOV A,@R1                  
	ANL A,#0FH
	SWAP A
	MOV LED,A
	INC R1
	LCALL delay
	DJNZ R3,dodisplay
   POP 4FH
   POP AR3
   POP AR1
   POP ACC
   RET

   
sumOfSquares:                 ;Function to implement sum of squares
   PUSH B
   PUSH ACC
   PUSH AR0
   PUSH AR1
   PUSH AR3
   PUSH AR4
   MOV R0,50H
   MOV R1,51H
   MOV R3,#01H
   MOV R4,#00H
   dososq:
    MOV A,R3
	MOV B,R3
	MUL AB
	ADD A,R4
	MOV @R1,A
	MOV R4,A
	INC R1
	INC R3
	DJNZ R0,dososq
   POP AR4
   POP AR3
   POP AR1
   POP AR0
   POP ACC
   POP B
   RET

memcpy:                              ;Function to copy values for A to B
USING 0
 PUSH AR0
 PUSH AR1
 PUSH AR2 
 PUSH ACC
  dopush:                            ;Push all A values
   MOV R2,50H
   MOV A,51H
   ADD A,R2
   MOV R1,A
   DEC R1
   loop1:
    MOV A,@R1
    PUSH ACC
    DEC R1
	DJNZ R2,loop1   
  dopop:                            ;Pop all A values to B
   MOV R2,50H
   MOV R0,52H
   loop3:
    POP AR1
	MOV A,R1
	MOV @R0,A
    INC R0
	DJNZ R2,loop3
 POP ACC
 POP AR2
 POP AR1
 POP AR0
 RET


;======================================MAIN=============================================

MAIN:
MOV SP,#0CFH;-----------------------Initialize STACK POINTER
MOV 50H,#07H;------------------------N memory locations of Array A
MOV 51H,#60H;------------------------Array A start location
LCALL zeroOut;----------------------Clear memory
MOV 50H,#07H;------------------------N memory locations of Array B
MOV 51H,#60H;------------------------Array B start location
LCALL zeroOut;----------------------Clear memory
MOV 50H,#07H;------------------------N memory locations of Array A
MOV 51H,#60H;------------------------Array A start location
LCALL sumOfSquares;-----------------Write at memory location
MOV 50H,#07H;------------------------N elements of Array A to be copied in Array B
MOV 51H,#60H;------------------------Array A start location
MOV 52H,#5BH;------------------------Array B start location
LCALL memcpy;-----------------------Copy block of memory to other location
MOV 50H,#07H;------------------------N memory locations of Array B
MOV 51H,#65H;------------------------Array B start location
MOV 4FH,#02H;------------------------User defined delay value
LCALL display;----------------------Display the last four bits of elements on LEDs
here:SJMP here;---------------------WHILE loop(Infinite Loop)
END
;------------------------------------END MAIN-------------------------------------------