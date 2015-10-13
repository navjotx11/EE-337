ORG 000H
LED EQU P1
LJMP MAIN

delay:                         ;Total Delay Provided is D/2 sec
   USING 0
   PUSH AR4
   PUSH AR1
   PUSH AR2
   PUSH AR3
   PUSH ACC
   MOV AR4,4FH                 ;Or mention this Value inexplicitly
   LOOP:
   MOV R3,#10                  ;Module Provides delay of 0.5 sec
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


zeroOut:
   PUSH ACC
   PUSH AR0
   PUSH AR1
   MOV R0,50H
   MOV R1,51H
   MOV A,#01H
   dozero:
     INC A
	 MOV @R1,A
	 INC R1
	 DJNZ R0,dozero
   
   POP AR1
   POP AR0   
   POP ACC
   RET
   
   
display:
   PUSH ACC
   PUSH AR1
   PUSH AR3
   PUSH 4FH
   MOV R3,50H
   MOV R1,51H
   MOV 4FH,#02H                 ; Set the delay to be 1 second
   dodisplay:
	MOV A,@R1                  ;Indirect Register to Register Not Allowed
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

   
sumOfSquares:
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
   

MAIN:
   MOV 51H,#60H               ;Store Value of P (Here, P=60H)
   MOV 50H,#0BH               ;Store Value of N (Here, N=11)
   MOV 4FH,#0AH               ;Store Value of D
   MOV 61H,#01H               ;For Checking zeroOut 
   SETB LED.4
   LCALL zeroOut
   MOV A,#00H
   LCALL display
   MOV A,#00H
   LCALL sumOfSquares
   MOV A,#00H
;InfDelay: LCALL delay     This is used to check LED "blinking"
;          CPL LED.4
;        SJMP InfDelay
  
END
	
	
	
	