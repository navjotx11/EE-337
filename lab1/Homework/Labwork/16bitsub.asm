ORG 0000H
LJMP MAIN

;R0 and R1 should contain the address of two no.s
;location given by R0:- 	MSB of 1st no.
;location given by R0+1:-	LSB of 1st no.
;location given by R1:- 	MSB of 1st no.
;location given by R1+1:-	LSB of 1st no.
;location given by R0+2:- 	CARRY	
;location given by R0+3:-	MSB OF ANS	
;location given by R0+4:- 	LSB OF ANS

;---------------------------------------------------------;
;this function adds and stores result in appropriate location
ORG 0100H

ADDER_16BIT:
    CLR C
	MOV A,61H
	SUBB A,71H
	MOV 64H,A  ;Store Result LSB
	MOV A,60H
	SUBB A,70H
	MOV 63H,A
	JB PSW.2,RETURN
	RET
    
	;-- perform the addition/subtraction of 2 16-bit no.s
	;-- you may use subroutine wrtten for addition of 2 8-bit no.s
	;-- remember the no.s are given in 2's complement form
	
	
	;-- take care when you set carry/borrow.
	
	;-- store the result at appropriate locations.
	
	RETURN:	
	MOV 62H,#01H ;-- pop the registers
	RET

INIT:
	;-- store the numbers to be added/subtracted at appropriate location
	MOV 60H,#7FH    ;MSB of N1
	MOV 61H,#0FFH    ;LSB of N1
	MOV 70H,#00H    ;MSB of N2
	MOV 71H,#02H    ;LSB of N2
	RET



MAIN:
	ACALL INIT
	ACALL ADDER_16BIT

END


