; Sum of N natural numbers

ORG 00H
LJMP MAIN

ADDNOS: ADD A,R1
        MOV @R0,A
        INC R0
		INC R1     
        DJNZ 50H,ADDNOS
		RET

ORG 100H
MAIN: 
      USING 0
	  MOV 50H,#0BH ; specify N in 50H
	  MOV R0,#51H
	  MOV R1,#01H
	  CLR A
	  LCALL ADDNOS
	  
FIN:  SJMP FIN 
	  