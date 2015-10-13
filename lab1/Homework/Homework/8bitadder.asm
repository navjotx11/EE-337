;8-bit adder

ORG 00H
	LJMP MAIN
	
ORG 100H

ADDER: CLR A
       ADD A,50H
	   ADD A,60H
	   MOV 70H,A
	   RET
	   
ORG 90H
	
MAIN: MOV 50H,#77H
      MOV 60H,#90H
	  LCALL ADDER
	  
FIN:  SJMP FIN
