ORG 000H
LJMP main

zeroOut:
   USING 0
   PUSH ACC
   PUSH AR0
   PUSH AR1
   MOV A,P1             
   ANL A, #0FH          ;Read value for switches
   PUSH ACC
   MOV R0,A
   MOV R1,51H
   MOV A,#01H
   dozero:
     INC A
	 MOV @R1,A
	 INC R1
	 DJNZ R0,dozero
     POP ACC
   POP AR1   
   SWAP A
   MOV P1,A
   POP AR0   
   POP ACC
   RET
  
main:
    MOV P1,#0FH   
	MOV 51H,#60H
	MOV 61H,#01H
	LCALL zeroOut
	
END