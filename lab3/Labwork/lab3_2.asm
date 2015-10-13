; Program for Problem 2.2 and 2.3
; Program for readNibble and display on LED

ORG 000H
LJMP main

delay:                        ;Total Delay Provided is D/2 seconds
   USING 0                    ;where D is stored in location 4FH
   PUSH AR4
   PUSH AR1
   PUSH AR2
   PUSH AR3
   PUSH ACC
   MOV R4,4FH                 
   LOOP:
   MOV R3,#10                 
   BACK2:                             ;Module Provides delay of 0.5 sec
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

readNibble:              ; Function to read a nibble
   PUSH ACC
   PUSH 4FH
   MOV P1,#0F0H          ;Turn ON all LEDs
   MOV 4FH,#0AH          ;5sec delay
   LCALL delay
   MOV P1,#00H
   MOV P1,#0FH           ;Activate switches to read
   MOV A,P1              ;Read switch
   ANL A,#0FH            ;Mask off LED pins
   MOV 4FH,#02H          ;1sec delay
   LCALL delay
   MOV 4EH,A             ;Store nibble in location 4EH
   SWAP A
   MOV P1,A
   MOV 4FH,#0AH          ;5sec delay
   LCALL delay       
   MOV P1,#00H
   MOV P1,#0FH           ;Activate switches to read
   MOV A,P1
   CJNE A,#00H, readNibble ;If Bit read is not zero, repeat again
   POP 4FH
   POP ACC
   RET  

packNibbles:                   ;Function to store a byte at 4FH
   PUSH ACC
   PUSH AR0
   LCALL readNibble            ;Read MSN
   MOV A,4EH                   ;Store MSN in MSN of 4EH     
   SWAP A       
   LCALL readNibble            ;Read LSN
   MOV R0,4EH                 
   ADD A,R0        
   MOV 4FH,A                   ;Store read byte (MSN+LSN) in 4FH
   POP AR0
   POP ACC
   RET

readValues:
   PUSH AR0
   PUSH AR1
   MOV R0,50H                  ;Read value of K
   MOV R1,51H                  ;Read pointer P
   loop1:                      ;Keep reading K bytes
    LCALL packNibbles        
	MOV @R1,4FH
	INC R1
	DJNZ R0,loop1
   POP AR1
   POP AR0
   RET

displayValues:
   PUSH AR0
   PUSH AR1
   PUSH ACC
   PUSH 4FH
   MOV R0,50H                   ;Read value of K
   MOV R1,51H                   ;Read pointer P
   MOV P1,#0FH
   MOV A,P1
   ANL A,#0FH                   ;Mask off LED ports
   PUSH ACC
   CLR C
   SUBB A,R0
   ANL A,#80H
   CJNE A,#80H,stopled          ;A should be storing a non-positive number
   POP ACC
   do:
   ADD A,R1
   DEC A
   MOV R1,A
   MOV A,@R1
   PUSH ACC                     ;Stores value of pointed location
   ANL A,#0F0H                  ;Take MSB
   MOV P1,A
   MOV 4FH,#04H                 ;2sec delay
   LCALL delay
   POP ACC
   ANL A,#0FH                   ;Take LSB
   SWAP A
   MOV P1,A
   MOV 4FH,#04H                 ;2sec delay
   LCALL delay
   POP 4FH
   POP ACC
   POP AR1
   POP AR0
   SJMP displayValues           ;Start displaying the value number in array stored
    stopled:
	 POP ACC
	 CLR C
	 SUBB A,R0
	 JZ dothis                   ;Jump if number on switches =k
     MOV P1,#01010000B
	 POP 4FH
	 POP ACC
	 POP AR1
	 POP AR0
	 RET
	  dothis:                    ;Module executed if number on switches = k
	  MOV P1,#0FH              
	  MOV A,P1
	  ANL A,#0FH
	  LCALL do
	  
shuffleBits:
   PUSH AR0
   PUSH AR1
   PUSH AR2
   PUSH B         ;To store value of B
   PUSH ACC
   MOV R2,50H       ;Store number = N
   MOV R1,51H       ;Store Pointer P (pointer to A)
   MOV R0,51H
   MOV B,52H
   PUSH AR1
   MOV A,R1
   ADD A,50H
   MOV R1,A        ;R1 now points to location after last of array A
   MOV A,@R0
   MOV @R1,A
   POP AR1
   INC R0           ;= P' ,leads P by 1 unit
   ; Array A now has an additional element A[0] after A[K-1]
   loop2:
    MOV A,@R0
	XRL A,@R1
	PUSH AR0
	MOV R0,B
	MOV @R0,A
	POP AR0
	INC R0
	INC R1
	INC B
	DJNZ R2,loop2
   POP ACC
   POP B
   POP AR2
   POP AR1
   POP AR0
   RET
	
  

;======================MAIN====================

MAIN:
MOV SP,#0CFH;-----------------------Initialize STACK POINTER
MOV 50H,#03H;------------------------Set value of K
MOV 51H,#60H;------------------------Array A start location
MOV 4FH,#00H;------------------------Clear location 4FH
LCALL readValues
MOV 50H,#03H;------------------------Value of K
MOV 51H,#60H;------------------------Array A start location
MOV 52H,#70H;------------------------Array B start location
LCALL shuffleBits
MOV 50H,#03H;------------------------Value of K
MOV 51H,#70H;------------------------Array B start Location
   MOV P1,#10100000B      ;Denotes that shiftBits subroutine has completed, provide a value
   MOV 4FH,#06H
   LCALL delay
LCALL displayValues;----------------Display the last four bits of elements on LEDs
here: SJMP here;---------------------WHILE loop(Infinite Loop)
END
