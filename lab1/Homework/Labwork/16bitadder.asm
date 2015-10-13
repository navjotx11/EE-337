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

;-- remember the no.s are given in 2's complement form
;-- take care when you set carry/borrow.
;-- store the result at appropriate locations.
	
;---------------------------------------------------------;
;this function adds and stores result in appropriate location
ADDER_16BIT:
    
	MOV A,61H
	ADD A,71H
	MOV 64H,A           ;LSB of Result
	CLR A
	;ADDC A,#00H         ;Add A+CY+Data
	MOV 66H,A
	MOV A,60H
	ADDC A,70H          ; <- Used at appropriate location for PSW;;;;;;;;;;;;;;;;
	MOV 63H,A           ;MSB of Result
	JB PSW.2,RETURN     ;Check if OV
	RET
	
RETURN:	
	MOV 62H,#01H        ;Discard or Accept Results
	RET
	
INIT:
	;-- store the numbers to be added/subtracted at appropriate location
	MOV 60H,#0FFH    ;MSB of N1
	MOV 61H,#0FFH    ;LSB of N1
	MOV 70H,#80H    ;MSB of N2
	MOV 71H,#00H    ;LSB of N2
	MOV R0,#60H     ;Store Locations of N1
	MOV R1,#70H     ;Store Locations of N2
	RET


ORG 0100H
MAIN:
	ACALL INIT
	ACALL ADDER_16BIT

STOP: 
    SJMP STOP
END

; NOTE WHEN TO USE PSW.OV VALUE..... IT TAKES THE OV VALUE ONLY FOR THE PREV. ADDITION
; See Updation of PSW.OV Bit