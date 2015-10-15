;--------------------PROGRAM TO FIND ASCII OF BYTE WHERE HIGHER ;NIBBLE IS IN A AND LOWER NIBBLE IS IN B----------------- ;--------------------------------------------
ORG 0
LJMP MAIN

;---------------SUBROUTINE TO CONVERT BYTE TO ASCII---------------------------------------------
ORG 200h
ASCIICONV: MOV R2,A
ANL A,#0Fh
MOV R3,A
SUBB A,#09h  ;CHECK IF NIBBLE IS DIGIT OR ALPHABET
JNC ALPHA

MOV A,R3
ADD A,#30h   ;ADD 30H TO CONV HEX TO ASCII
MOV B,A
JMP NEXT

ALPHA: MOV A,R3  ;ADD 37H TO CONVERT ALPHABET TO ASCII
ADD A,#37h
MOV B,A

NEXT:MOV A,R2
ANL A,#0F0h          ;CHECK HIGHER NIBBLE IS DIGIT OR ALPHABET
SWAP A
MOV R3,A
SUBB A,#09h
JNC ALPHA2 

MOV A,R3			;DIGIT TO ASCII
ADD A,#30h
RET

ALPHA2:MOV A,R3
ADD A,#37h          ;ALPHABET TO ASCII
RET


;------------------MAIN PROGRAM---------------------------------------------------------------------------------------
ORG 400h
MAIN: MOV A,#0ffh
LCALL ASCIICONV
HERE:SJMP HERE
END

