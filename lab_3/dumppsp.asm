text segment 'code'
    assume CS:text, DS:text, SS:text
    org 100h
main proc
    ; Вывод содержимого PSP для отладки
    mov SI, 80h
    mov CX, 16
debug_psp:
    mov DL, [SI]
    mov AH, 02h
    int 21h
    inc SI
    loop debug_psp
    ; Вывод перевода строки
    mov DL, 0Dh
    int 21h
    mov DL, 0Ah
    int 21h

    ; Проверка длины командной строки
    mov SI, 80h
    mov AL, [SI]
    cmp AL, 0
    je sound
    cmp AL, 20
    jne exit

    ; Анализ параметра
    mov SI, 82h
    add SI, 4
    mov CX, 7
    mov BL, 0

analyze_loop:
    mov AL, [SI]
    ; Отладочный вывод текущего символа
    mov DL, AL
    mov AH, 02h
    int 21h
    ; Проверка на цифру
    cmp AL, '0'
    jb next_char
    cmp AL, '9'
    ja next_char
    inc BL
next_char:
    add SI, 2
    loop analyze_loop

    ; Вывод перевода строки
    mov DL, 0Dh
    int 21h
    mov DL, 0Ah
    int 21h

    call print_result
    jmp exit

sound:
    call beep
    jmp exit

print_result proc
    mov AL, BL
    mov AH, 0
    mov CL, 10
    div CL
    mov DL, AL
    add DL, '0'
    mov AH, 02h
    int 21h
    mov DL, AH
    add DL, '0'
    int 21h
    mov DL, 0Dh
    int 21h
    mov DL, 0Ah
    int 21h
    ret
print_result endp

beep proc
    cli
    in AL, 61h
    mov CX, 2000
begin_sound:
    push CX
    or AL, 00000010b
    out 61h, AL
    mov CX, 1000
delay_on:
    loop delay_on
    and AL, 11111101b
    out 61h, AL
    mov CX, 1000
delay_off:
    loop delay_off
    pop CX
    loop begin_sound
    sti
    ret
beep endp

exit:
    mov AX, 4C00h
    int 21h
main endp
text ends
end main