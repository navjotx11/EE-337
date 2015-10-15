ORG 000H
LED EQU P1
LJMP main
	

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

display:
   PUSH ACC
   PUSH AR1
   PUSH AR3
   PUSH 4FH
   MOV R3,P1
   MOV A,R3
   ANL A,#0FH
   MOV R3,A
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
   
main:
  USING 0 
  MOV 50H,#0BH     
  MOV 51H,#60H
  MOV R1,51H
  MOV A,#01H
  MOV R2,50H
  looper:
   MOV @R1,A                 
   INC R1
   INC A
   DJNZ R2,looper
   LCALL display
END