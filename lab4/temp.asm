org 000h
ljmp delay5

using 0


delay:	 push ar3
         push ar4
         mov r3,#1
loop2:	 mov r4,#255
loop1:	 djnz r4, loop1
		 djnz r3,loop2
		 pop ar4
		 pop ar3
		 ret
;---------------------5secdelay------------------------------------------------------------
delay5:
      push ar3
	  push ar4
      mov r3,#100
	  looper1:
	  mov r4,#200
	  looper2:
	  lcall delay
	  djnz r4,looper2
	  djnz r3,looper1
	  pop ar4
	  pop ar3
	  ret
	  
end
	