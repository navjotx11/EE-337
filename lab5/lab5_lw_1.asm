;using timer 0

org 00h
ljmp main

delay:
using 0
push acc
push ar0
mov r0,#81H         ;Indirect read from memory location 81H
mov a,@r0
cpl a
add a,#01
mov TL0,a
inc r0              ;Carry flag is not affected by INC
mov a,@r0
cpl a
addc a,#00H
mov TH0,a
;2's complement of the 16bit no. is now stored in T0
mov TMOD,#01
setb TR0             ;Enable timer 0
count:
jnb TF0,count
clr TR0              ;Stop timer
clr TF0              ;Clear overflow bit
pop ar0
pop acc
ret

main:
using 0
mov r0,#81H
mov @r0,#0Ah
inc r0
mov @r0,#00h        ;Delay corresponding to 3EFFh would be generated
;mov p1,#0F0h
blink:              ;To show on LED
mov p1,#10000000B
lcall delay 
mov p1,#00000000B
lcall delay
sjmp blink
stop: sjmp stop

end