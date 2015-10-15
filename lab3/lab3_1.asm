; Program for Binary to Gray Code conversion

ORG 000H
LJMP main

displaygray:
 USING 0
 PUSH ACC
 PUSH AR1
 MOV P1,#0FH      ;Select the DIP switches
 MOV R1,P1        ;Store pin data in R1
 MOV A,P1         ;Store pin data in Accumulator
 RR A             ;Rotate right Acc
 CLR ACC.3        
 XRL A,R1         ;XOR R1 with A -> Note 0^X = X (where X={1,0})
 SWAP A           ;Swap to higer nibble
 MOV P1,A         ;Write to LED pins
 POP AR1
 POP ACC

main:
Infi: LCALL displaygray
      SJMP Infi
	  
END