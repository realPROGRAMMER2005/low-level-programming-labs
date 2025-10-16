text segment 'code'
    assume CS:text, DS:text, SS:text
    org 100h
start proc
    ; Проверка наличия параметра в командной строке
    mov SI, 80h           ; Длина командной строки в PSP
    mov CL, [SI]          ; Загружаем длину
    cmp CL, 0             ; Если длина = 0, нет параметра
    je beep_sound         ; Переход к звуковому сигналу
    
    ; Пропуск пробелов после имени программы
    inc SI                ; Переходим к началу строки параметров
    mov CH, 0             ; Очищаем старший байт CX
    
skip_spaces:
    cmp CL, 0             ; Проверяем, не кончилась ли строка
    je beep_sound         ; Если кончилась - звуковой сигнал
    mov AL, [SI]          ; Загружаем символ
    cmp AL, ' '           ; Пропускаем пробелы
    jne check_length
    inc SI
    dec CL
    jmp skip_spaces

check_length:
    ; Проверка длины параметра (должно быть ровно 20 символов)
    cmp CL, 20
    jne exit_program      ; Если не 20 символов - завершаем
    
    ; Анализ символов с 5 по 18 через 1
    mov CX, 7             ; Количество итераций: (18-5)/2 + 1 = 7
    mov DI, SI            ; Сохраняем начало строки
    add DI, 4             ; Начинаем с 5-го символа (индекс 4)
    mov BL, 0             ; Счетчик цифр
    
analyze_loop:
    mov AL, [DI]          ; Загружаем символ
    
    ; Проверка, является ли символ цифрой
    cmp AL, '0'
    jb not_digit
    cmp AL, '9'
    ja not_digit
    
    ; Если цифра - увеличиваем счетчик
    inc BL
    
not_digit:
    add DI, 2             ; Переходим через 1 символ
    loop analyze_loop
    
    ; Вывод результата
    mov AH, 09h
    lea DX, result_msg
    int 21h
    
    ; Преобразование числа в ASCII и вывод
    mov AL, BL
    mov AH, 0
    call print_number
    
    ; Завершение программы
    jmp exit_program

beep_sound:
    ; Звуковой сигнал через порт динамика
    call beep
    jmp exit_program

exit_program:
    ; Завершение программы
    mov AX, 4C00h
    int 21h
start endp

; Процедура для вывода числа (0-9)
print_number proc
    add AL, '0'            ; Преобразуем число в ASCII
    mov DL, AL
    mov AH, 02h
    int 21h
    ret
print_number endp

; Процедура генерации звукового сигнала
beep proc
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

; Определения данных
result_msg DB 'Number of digits (positions 5-18 step 2): $'

text ends
end start