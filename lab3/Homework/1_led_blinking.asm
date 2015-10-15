ORG 000H
LED EQU P1
LJMP main


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
  

main: 
 
  MOV 4FH,#02H               ;Store Value of D
  SETB LED.4
  InfDelay: LCALL delay     ;This is used to check LED "blinking"
          CPL LED.4
          SJMP InfDelay
		  
END