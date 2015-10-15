
; Setup code at reset vector of 8051 to jump to our main task 
org 0
ljmp main		


;=========================================
readNibble:
;=========================================
; Routine to read in Port lines P1.3 - P1.0 as a sngle nibble
; Returns the nibble in lower 4 bits of the register A
;
; Ensure that the internal port latches are set high already 
; prior to calling this routine
;=========================================

	MOV A,P1			; read port lines P1.3 - P1.0 where slide switches are connected
	ANL A,#0FH			; retain lower nibble and mask off upper one

	RET					; Return to caller with nibble in A

	  

		
;=========================================
main:
;=========================================
	; Port initialisation
	MOV P1,#0Fh			; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read

	; read nibble from port
	LCALL readNibble		; read nibble using subroutine
	MOV 50H,A				; save nibble read in location 50H

	; end of job
	STOP: JMP STOP		

;=========================================
; End of program file
END




