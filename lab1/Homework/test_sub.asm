ORG 00H
LJMP MAIN

DO:
 MOV A,#80H
 SUBB A,#01H
 MOV 61H,A
 JB PSW.2,RETURN
 RET
 
RETURN:
 MOV 60H,# 01H
 RET 

MAIN:
 LCALL DO  
  