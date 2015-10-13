ORG 00H
LJMP main


memcpy:                              ;Function to copy values for A to B
USING 0
 PUSH AR0
 PUSH AR1
 PUSH AR2 
 PUSH ACC
  dopush:                            ;Push all A values
   MOV R2,50H
   MOV R0,51H
   MOV A,@R0
   ADD A,R2
   DEC A
   loop1:
    MOV R0,A
    PUSH AR0
    DEC A
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
	

main:
  USING 0 
  MOV 50H,#0BH     
  MOV 51H,#65H
  MOV 52H,#60H
  
  MOV R1,51H
  MOV A,#01H
  MOV R2,50H
  looper:
   MOV @R1,A                 
   INC R1
   INC A
   DJNZ R2,looper

  LCALL memcpy
  
END
  