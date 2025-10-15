STACKSG     SEGMENT PARA STACK
    DB 64 DUP(?)
STACKSG     ENDS

DATASG      SEGMENT PARA 'DATA'
    MySTR     DB 21, 0, 21 DUP(?)
    MSG1      DB 'Enter the string: ', '$'
    MSG2      DB 0Dh, 0Ah, 'Result: ', 0Dh, 0Ah, '$'
    SPACE     DB ' $'
DATASG      ENDS

CODESG      SEGMENT PARA 'CODE'
    ASSUME  CS:CODESG, DS:DATASG, SS:STACKSG

ENTRY   PROC FAR
        PUSH DS
        SUB AX, AX
        PUSH AX
        MOV AX, DATASG
        MOV DS, AX
        
        MOV AH, 09h
        LEA DX, MSG1
        INT 21h
        
        MOV AH, 0Ah
        LEA DX, MySTR
        INT 21h
        
        MOV BL, MySTR+1
        CMP BL, 20
        JB  Exit
        
        MOV AH, 09h
        LEA DX, MSG2
        INT 21h
        
        LEA SI, MySTR+2
        ADD SI, 4
        MOV CX, 7
        
ProcessLoop:
        MOV AL, [SI]
        CALL PrintHex
        
        PUSH AX
        MOV AH, 09h
        LEA DX, SPACE
        INT 21h
        POP AX
        
        ADD SI, 2
        LOOP ProcessLoop
        
Exit:
        MOV AH, 4Ch
        INT 21h
        RET
ENTRY   ENDP

PrintHex PROC
        PUSH CX
        PUSH AX
        
        MOV CL, 4
        SHR AL, CL
        CALL PrintDigit
        
        POP AX
        PUSH AX
        AND AL, 0Fh
        CALL PrintDigit
        
        POP AX
        POP CX
        RET
PrintHex ENDP

PrintDigit PROC
        CMP AL, 9
        JLE IsDigit
        
        ADD AL, 'A' - 10
        JMP PrintChar
        
IsDigit:
        ADD AL, '0'
        
PrintChar:
        MOV DL, AL
        MOV AH, 02h
        INT 21h
        
        RET
PrintDigit ENDP

CODESG ENDS
END ENTRY