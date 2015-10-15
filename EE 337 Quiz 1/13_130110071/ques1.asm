org 000h
ljmp main

;Assuming given array is A[0],A[1],...,A[4]

findSmallest:
using 0
push acc
push b                ;For the second smallest number
push ar0              ;Used for traversal
push ar1              ;For the storing the smallest number
push ar2              ;Variable for counting
push 60H              ;Store location to which the smallest number is pointing
mov r1,50H            ;Take the starting location as the smallest number
mov 60H,#50H          ;As smallest number is chosen to be at 50H
mov b,50H             ;Take the starting location as the second smallest number
mov r2,#04            ;As location 50H is already stored, we need to compare only 4 nos. 
mov r0,#51H           ;r0 would be used to traverse the array
loop:
  mov a,@r0
  lcall compare1          ;compare1 will modify the value of r1 accordingly
  lcall compare2          ;comapre2 will modify the value of r2 accordingly
  inc r0                  ;point to next memory location
  djnz r2,loop
;push acc
mov a,60H
clr c
subb a,#50H
jz do1               
mov 55H,r1                ;Register r1 now stores the smallest number  
mov 56H,b                 ;Register B stores the second smallest number 
pop 60H        
pop ar2
pop ar1
pop ar0
pop b
pop acc
ret
do1:
push ar1
mov 55H,r1 
mov 56H,b
pop 60H        
pop ar2
pop ar1
pop ar0
pop b
pop acc
ret

compare1:              ;Subroutine to compare nos. in registers A and R1, store smaller in R1
  clr c
  push b
  mov b,r1
  cjne a,b,check1      ;if they are not equal, check which one is greater
  pop b
  ret
  check1:
    jc newsmall1       ;if carry is set, i.e r1>a, r1 should be modified
	pop b
	ret                ;reached if r1 already stores the smaller number
	newsmall1:
	  mov r1,a         ;New smallest number found
	  mov 60H,r0       ;Change location of smallest number
	  pop b
	  ret

compare2:              ;Subroutine to find the second smallest number at each step
   clr c
   cjne a,b,check2     ;if they are not equal, check which one is greater
   ret
   check2:
     jc check21        ;if carry is set, i.e b>a , b may have to be modified
	 ret
     check21:
	   clr c
	   push acc
	   push b
	   mov a,r0        ;Store values of R0 in A and 60H in B (for CJNE to work)
	   mov b,60h
	   cjne a,b, changeb  ;If the smallest number is also stored in same location, don't modify
	   pop b
	   pop acc
	   ret
	   changeb:          ;Subroutine is called if smallest number is not at this memory location
	    pop b            ;Hence, second smallest number is stored here
        pop acc		 
	    mov b,a          ;New second smallest number found
		ret
	    
	   
main:
;Assuming we are given five numbers
mov 50h,#01
mov 51h,#02
mov 52h,#03
mov 53h,#04
mov 54h,#05
lcall findSmallest

stop: sjmp stop

end
	
	; NOTE : an error occurs when the smallest value is the first smallest value itself