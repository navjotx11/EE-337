org 000H
ljmp main

matMult:

using 0
push acc
push b
push ar0
push ar1
mov r2,#60H
row1:        ;code to find first row of C
 mov r0,#50H  
 mov r1,#55H
 mov a,@r0
 mov b,@r1
 lcall multrc
 push ar0
 push acc
 mov a,r2
 mov r0,a
 pop acc
 mov @r0,a
 pop ar0
 inc r2
 inc r1
 mov a,@r0
 mov b,@r1
 lcall multrc
 push ar0
 push acc
 mov a,r2
 mov r0,a
 pop acc
 mov @r0,a
 pop ar0
 inc r2
 
row2:
 mov r0,#52H  
 mov r1,#55H
 mov a,@r0
 mov b,@r1
 lcall multrc
 push ar0
 push acc
 mov a,r2
 mov r0,a
 pop acc
 mov @r0,a
 pop ar0
 inc r2
 inc r1
 mov a,@r0
 mov b,@r1
 lcall multrc
 push ar0
 push acc
 mov a,r2
 mov r0,a
 pop acc
 mov @r0,a
 pop ar0
 
 pop ar1
 pop ar0
 pop b
 pop acc
  
multrc:                  ;Subroutine to multiply row and column and store restult in Register A
push ar0
push ar1
mul ab
inc r0
inc r1
inc r1
push acc
mov a,@r0
mov b,@r1
mul ab                   ;Lower byte is stored in A
pop ar3
add a,r3
pop ar1
pop ar0
ret
 


main:
 mov SP,#0CFH
 mov 50h,#01
 mov 51h,#00
 mov 52h,#00
 mov 53h,#00
 mov 55h,#01
 mov 56h,#02
 mov 57h,#03
 mov 58h,#04
 
 lcall matMult

stop: sjmp stop
end