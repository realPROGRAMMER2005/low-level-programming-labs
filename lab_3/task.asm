text segment 'code'
    assume CS:text, DS:text, SS:text
    org 100h
main proc
    ; Проверка наличия параметра в командной строке
    mov SI, 80h           ; Длина командной строки в PSP
    mov AL, [SI]          ; Загружаем длину
    cmp AL, 20            ; Проверяем длину параметра (должно быть 20 символов)
    jbe sound             ; Если меньше или равно 0 (или меньше 20) - звуковой сигнал
    
    ; Анализ параметра командной строки
    mov SI, 82h           ; Начало параметра в PSP (пропускаем пробел)
    add SI, 4             ; Переходим к 5-му символу (индексация с 0)
    mov CX, 7             ; Обрабатываем 7 символов: 5,7,9,11,13,15,17
    mov BL, 0             ; Счетчик цифр (обнуляем)
    
analyze_loop:
    mov AL, [SI]          ; Загружаем текущий символ
    
    ; Проверяем, является ли символ цифрой (ASCII '0'-'9')
    cmp AL, '0'
    jb next_char          ; Если меньше '0' - не цифра
    cmp AL, '9'
    ja next_char          ; Если больше '9' - не цифра
    
    ; Если попали сюда - символ является цифрой
    inc BL                ; Увеличиваем счетчик цифр
    
next_char:
    add SI, 2             ; Переходим через один символ
    loop analyze_loop     ; Повторяем для всех символов
    
    ; Вывод результата
    call print_result
    jmp exit
    
sound:
    ; Генерация звукового сигнала
    call beep
    jmp exit
    
print_result proc
    ; Преобразование числа в BL в ASCII и вывод
    mov AL, BL
    mov AH, 0
    mov CL, 10
    div CL                ; AL = частное, AH = остаток
    
    ; Вывод десятков
    mov DL, AL
    add DL, '0'
    mov AH, 02h
    int 21h
    
    ; Вывод единиц  
    mov DL, AH
    add DL, '0'
    mov AH, 02h
    int 21h
    
    ; Вывод перевода строки
    mov DL, 0Dh
    int 21h
    mov DL, 0Ah
    int 21h
    
    ret
print_result endp

beep proc
    ; Генерация звукового сигнала
    cli                   ; Запрет аппаратных прерываний
    in AL, 61h            ; Вводим содержимое порта 61h
    mov CX, 2000          ; Установим длительность звукового сигнала
    
begin_sound:
    push CX               ; Сохраним счетчик цикла
    or AL, 00000010b      ; Установим бит 1 (включение динамика)
    out 61h, AL           ; Выведем в порт, включим динамик
    
    mov CX, 1000          ; Пауза включения
delay_on:
    loop delay_on
    
    and AL, 11111101b     ; Сбросим бит 1 (выключение динамика)
    out 61h, AL           ; Выведем в порт, выключим динамик
    
    mov CX, 1000          ; Пауза выключения
delay_off:
    loop delay_off
    
    pop CX                ; Восстановим счетчик цикла
    loop begin_sound
    
    sti                   ; Разрешение прерываний
    ret
beep endp

exit:
    mov AX, 4C00h         ; Завершение программы
    int 21h
main endp

text ends
end main