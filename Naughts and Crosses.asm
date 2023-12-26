.386                                                          
.model flat, stdcall                                          
option casemap:none                                           
include c:\masm32\include\windows.inc                         
include c:\masm32\include\kernel32.inc                        
include c:\masm32\include\user32.inc                          
include c:\masm32\include\masm32.inc                        
includelib c:\masm32\lib\kernel32.lib                         
includelib c:\masm32\lib\user32.lib                           
includelib c:\masm32\lib\masm32.lib                           
.const
BSIZE       equ   100                                        
.data   

game byte "         GAME OVER           ", 0
msg1 byte " -------------"                                          ; вывод поля                         
msg2 byte " | 1 | 2 | 3 |"
msg3 byte " | 4 | 5 | 6 |"
msg4 byte " | 7 | 8 | 9 |"
nextX byte "следующий ход Х -> "                                        ; следующий ход
nextO byte "следующий ход O -> "
msgGame byte "              Игра крестики-нолики в консоли              ", 0
msgInfo1 byte "Чтобы играть вводите цифры от 1 до 9", 0
msgInfo2 byte "Взависимости от хода на это место будет поставлен либо X, либо O", 0
incorrectly byte "Цифра введена некоректно! Повторите ввод: "
victory byte "  Очки X = %d, O = %d", 0
winnerX byte "          Winner X          ", 0
winnerO byte "          Winner O          ", 0

game1 byte " ## ##     ##     ##   ##  ### ###            ## ##   ### ###  ### ###  ### ##  ", 0
game2 byte "##   ##     ##     ## ##    ##  ##           ##   ##   ##  ##   ##  ##   ##  ## ", 0
game3 byte "##        ## ##   # ### #   ##               ##   ##   ##  ##   ##       ##  ## ", 0
game4 byte "##  ###   ##  ##  ## # ##   ## ##            ##   ##   ##  ##   ## ##    ## ##  ", 0
game5 byte "##   ##   ## ###  ##   ##   ##               ##   ##   ### ##   ##       ## ##  ", 0
game6 byte "##   ##   ##  ##  ##   ##   ##  ##           ##   ##    ###     ##  ##   ##  ## ", 0
game7 byte " ## ##   ###  ##  ##   ##  ### ###            ## ##      ##    ### ###  #### ## ", 0

gameWinX1 byte "                W     W III N   N N   N EEEE RRRR       X   X", 0
gameWinX2 byte "                W     W  I  NN  N NN  N E    R   R       X X  ", 0
gameWinX3 byte "                W  W  W  I  N N N N N N EEE  RRRR         X  ", 0
gameWinX4 byte "                 W W W   I  N  NN N  NN E    R R         X X ", 0
gameWinX5 byte "                  W W   III N   N N   N EEEE R  RR      X   X", 0

gameWinO1 byte "                W     W III N   N N   N EEEE RRRR        OOO ", 0
gameWinO2 byte "                W     W  I  NN  N NN  N E    R   R      O   O ", 0
gameWinO3 byte "                W  W  W  I  N N N N N N EEE  RRRR       O   O", 0
gameWinO4 byte "                 W W W   I  N  NN N  NN E    R R        O   O", 0
gameWinO5 byte "                  W W   III N   N N   N EEEE R  RR       OOO ", 0

newGame1 byte " _   _  ______ __          __       _____            __  __  ______ ", 0
newGame2 byte "| \ | ||  ____|\ \        / /      / ____|    /\    |  \/  ||  ____|", 0
newGame3 byte "|  \| || |__    \ \  /\  / /      | |  __    /  \   | \  / || |__   ", 0
newGame4 byte "| . ` ||  __|    \ \/  \/ /       | | |_ |  / /\ \  | |\/| ||  __|  ", 0
newGame5 byte "| |\  || |____    \  /\  /        | |__| | / ____ \ | |  | || |____ ", 0
newGame6 byte "|_| \_||______|    \/  \/          \_____|/_/    \_\|_|  |_||______|", 0
newGame7 byte "                                                                ", 0

msg      byte "Игра крестики нолики на ассемблере", 0
msgInfo  byte "Тишунин Кирилл ПМИб - 2", 0
endl byte 13, 10                                                    ;символ перевода на другую сторону



written     dd ?
coords      COORD <0, 10>
array       dd    10 dup(0)
a           dd    0                 
count       dd    0                                                 ;счетчик ходов 
pointsX     dd    0                                                 ;подсчет очков игрока за x
pointsO     dd    0                                                 ;подсчет очков игрока за o
buf         db    BSIZE dup(?)
stdout      dd    ?                                                 ; переменная для хранения handle'a стандартного вывода
cWritten    dd    ?                                                 ; переменная для хранения числа выведенных в консоль символов
stdin       dd    ?
cRead       dd    ?
.code                                                               ; начинается секция кода
start:
invoke CharToOem, addr nextX, addr nextX                            ;русифицируем консоль
invoke CharToOem, addr msgInfo1, addr msgInfo1
invoke CharToOem, addr msgInfo2, addr msgInfo2
invoke CharToOem, addr incorrectly, addr incorrectly


invoke AllocConsole
invoke GetStdHandle, STD_OUTPUT_HANDLE                              ; получаем handle стандартного вывода в консоль
mov stdout, eax	                                                  ; записываем дескриптор вывода в переменную
invoke GetStdHandle, STD_INPUT_HANDLE                               ; получаем handle стандартного вывода в консоль
mov stdin, eax                                                      ; записываем дескриптор ввода в переменную
                                           
cInt macro in, cR                                                   ;перевод строки в число
    mov eax, offset buf                                       
    add eax, cR                                               
    sub eax, 2                                                
    mov byte ptr [eax], 0                                     
    invoke atol, addr buf                                           ; переводим содержимое символьного буфера в число
    mov in, eax 
    endm
        
mult macro p1, p2, result                                           ;функиця для перемножения чисел (число1, число2, результат вычислений)
    mov eax, p1
    mov ebx, p2
    mul ebx
    mov result, eax
    endm
    
summ macro p1, p2, result                                           ;макрос для суммирования чисел
    mov eax, p1
    add eax, p2
    mov result, eax
    endm
    
pow macro p1, p2, result                                            ;result = p1 ^ p2
    LOCAL L1
    mov ebx, p1
    mov edx, p1                                                     ;запоминаем значения p1 и p2
    mov ecx, p2
    dec ecx                                                         ;уменьшаем степень на 1
    L1:                                                             ;цикл для умножения числа заданное количество раз
        mult edx, ebx, eax                                          ;умножаем результат на число p1
        mov edx, eax                                                ;записываем результат в p1
        dec ecx                                                     ;уменьшаем счетчик
        cmp ecx, 0                                                  ;когда счетчик 0 заканчиваем цикл
    jne L1
    mov result, eax
    endm
    
subt macro p1, p2, result                                           ;макрос для вычитания двух чисел
    mov eax, p1
    sub eax, p2
    mov result, eax
    endm


coutNumber2 macro msg1, msg2, msg3                                         ;макрос для вывода текста с числом(%d, %d)
    invoke wsprintf, addr buf, addr msg1, msg2, msg3
    invoke WriteConsole, stdout, addr buf, sizeof buf, addr cWritten, 
    NULL                                                            ; выводим содержимое буфера buf на экран
    endm   

coutNumber macro msg1, msg2                                         ;макрос для вывода текста с числом(%d)
    invoke wsprintf, addr buf, addr msg1, msg2
    invoke WriteConsole, stdout, addr buf, sizeof buf, addr cWritten, 
    NULL                                                            ; выводим содержимое буфера buf на экран
    endm 
      
cout macro TextConsoleOutputCP                                      ;макрос для вывода текста 
    invoke WriteConsoleA,			
    stdout,	
    ADDR TextConsoleOutputCP,	
    SIZEOF TextConsoleOutputCP,	
    ADDR cWritten,
    NULL
    endm
    
newList macro                                                       ;переход на следующую страницу
    LOCAL L1
    mov ebx, 21
    L1:
        cout endl
        dec ebx
    jne L1
    endm

print macro                                                         ;вывод начального поля
    cout msg1
    cout endl
    cout msg2
    cout endl

    cout msg1
    cout endl
    cout msg3
    cout endl

    cout msg1
    cout endl
    cout msg4
    cout endl

    cout msg1
    cout endl
    cout endl
endm 

changeX macro Text, Number
    mov esi, offset Text                                            ; загружаем адрес строки
    add esi, Number                                                 ; переходим к символу (первый символ имеет смещение 0)
    mov al, 'X'                                                     ; заменяем символ на 'X'
    mov [esi], al
endm
changeO macro Text, Number
    mov esi, offset Text                                            ; загружаем адрес строки
    add esi, Number                                                 ; переходим к символу (первый символ имеет смещение 0)
    mov al, 'O'                                                     ; заменяем символ на 'O'
    mov [esi], al
endm

ChangeFieldX macro temp                                             ;проверка куда ставить крестик
    LOCAL flag_1                                                    ;локальная метка чтобы использовать макрос повторно
    LOCAL flag_2                                                    
    LOCAL flag_3
    LOCAL flag_4
    LOCAL flag_5
    LOCAL flag_6
    LOCAL flag_7
    LOCAL flag_8
    LOCAL flag_9
    LOCAL exit
    
    cmp temp, 1                                                     ;если число равно 1 то переходи к флагу flag_1, далее аналогично
    jz flag_1
    cmp temp, 2
    jz flag_2
    cmp temp, 3
    jz flag_3
    cmp temp, 4
    jz flag_4
    cmp temp, 5
    jz flag_5
    cmp temp, 6
    jz flag_6
    cmp temp, 7
    jz flag_7
    cmp temp, 8
    jz flag_8
    cmp temp, 9
    jz flag_9

    flag_1: changeX msg2, 3                                         ;вызываем макрос для замены числа на X
            inc count
            jmp exit                                                ;вызодим из макроса, далее аналогично
    flag_2: changeX msg2, 7
            inc count
            jmp exit
    flag_3: changeX msg2, 11
            inc count
            jmp exit
    flag_4: changeX msg3, 3
            inc count
            jmp exit
    flag_5: changeX msg3, 7
            inc count
            jmp exit
    flag_6: changeX msg3, 11
            inc count
            jmp exit
    flag_7: changeX msg4, 3
            inc count
            jmp exit
    flag_8: changeX msg4, 7
            inc count
            jmp exit
    flag_9: changeX msg4, 11
            inc count
            jmp exit
    exit:
endm

ChangeFieldO macro temp                                             ;тоже самое для О
    LOCAL flag_1
    LOCAL flag_2
    LOCAL flag_3
    LOCAL flag_4
    LOCAL flag_5
    LOCAL flag_6
    LOCAL flag_7
    LOCAL flag_8
    LOCAL flag_9
    LOCAL exit
    
    cmp temp, 1
    jz flag_1
    cmp temp, 2
    jz flag_2
    cmp temp, 3
    jz flag_3
    cmp temp, 4
    jz flag_4
    cmp temp, 5
    jz flag_5
    cmp temp, 6
    jz flag_6
    cmp temp, 7
    jz flag_7
    cmp temp, 8
    jz flag_8
    cmp temp, 9
    jz flag_9

    flag_1: changeO msg2, 3
            inc count
            jmp exit
    flag_2: changeO msg2, 7
            inc count
            jmp exit
    flag_3: changeO msg2, 11
            inc count
            jmp exit
    flag_4: changeO msg3, 3
            inc count
            jmp exit
    flag_5: changeO msg3, 7
            inc count
            jmp exit
    flag_6: changeO msg3, 11
            inc count
            jmp exit
    flag_7: changeO msg4, 3
            inc count
            jmp exit
    flag_8: changeO msg4, 7
            inc count
            jmp exit
    flag_9: changeO msg4, 11
            inc count
            jmp exit
    exit:
endm

CheckO macro                                                        ;анализ побед
    LOCAL flag1
    LOCAL flag2
    LOCAL flag3
    LOCAL flag4
    LOCAL flag5
    LOCAL flag6
    LOCAL flag7
    LOCAL flag8
    LOCAL exit

flag1:                                                              ;если в массиве флагов есть 1 на первой(значит там стоит O) позиции то идем дальше
    cmp array[1 * type array], 2                                    ;иначе переходим к следующей аналогичной проверке
    jnz flag2   
    cmp array[2 * type array], 2                                    ;если все три условия истины, то переходим на метку winO 
    jnz flag2
    cmp array[3 * type array], 2
    jnz flag2
    jmp winO                                                        ;если на месте флагов 1, 2, 3 стоят единицы, то выиграл O переходим к метке winO
flag2: 
    cmp array[1 * type array], 2
    jnz flag3
    cmp array[4 * type array], 2
    jnz flag3
    cmp array[7 * type array], 2
    jnz flag3
    jmp winO
flag3: 
    cmp array[1 * type array], 2
    jnz flag4
    cmp array[5 * type array], 2
    jnz flag4
    cmp array[9 * type array], 2
    jnz flag4
    jmp winO
flag4: 
    cmp array[2 * type array], 2
    jnz flag5
    cmp array[5 * type array], 2
    jnz flag5
    cmp array[8 * type array], 2
    jnz flag5
    jmp winO
flag5: 
    cmp array[3 * type array], 2
    jnz flag6
    cmp array[5 * type array], 2
    jnz flag6
    cmp array[7 * type array], 2
    jnz flag6
    jmp winO
flag6: 
    cmp array[3 * type array], 2
    jnz flag7
    cmp array[6 * type array], 2
    jnz flag7
    cmp array[9 * type array], 2
    jnz flag7
    jmp winO
flag7: 
    cmp array[4 * type array], 2
    jnz flag8
    cmp array[5 * type array], 2
    jnz flag8
    cmp array[6 * type array], 2
    jnz flag8
    jmp winO
flag8: 
    cmp array[7 * type array], 2
    jnz exit
    cmp array[8 * type array], 2
    jnz exit
    cmp array[9 * type array], 2
    jnz exit
    jmp winO

    exit:  
    cmp count, 9
    jge new_game
endm

CheckX macro                                                        ;для X аналогично
    LOCAL flag1
    LOCAL flag2
    LOCAL flag3
    LOCAL flag4
    LOCAL flag5
    LOCAL flag6
    LOCAL flag7
    LOCAL flag8
    LOCAL exit
flag1:
    cmp array[1 * type array], 1
    jnz flag2
    cmp array[2 * type array], 1
    jnz flag2
    cmp array[3 * type array], 1
    jnz flag2
    jmp winX

flag2: 
    cmp array[1 * type array], 1
    jnz flag3
    cmp array[4 * type array], 1
    jnz flag3
    cmp array[7 * type array], 1
    jnz flag3
    jmp winX
flag3: 
    cmp array[1 * type array], 1
    jnz flag4
    cmp array[5 * type array], 1
    jnz flag4
    cmp array[9 * type array], 1
    jnz flag4
    jmp winX
flag4: 
    cmp array[2 * type array], 1
    jnz flag5
    cmp array[5 * type array], 1
    jnz flag5
    cmp array[8 * type array], 1
    jnz flag5
    jmp winX
flag5: 
    cmp array[3 * type array], 1
    jnz flag6
    cmp array[5 * type array], 1
    jnz flag6
    cmp array[7 * type array], 1
    jnz flag6
    jmp winX
flag6: 
    cmp array[3 * type array], 1
    jnz flag7
    cmp array[6 * type array], 1
    jnz flag7
    cmp array[9 * type array], 1
    jnz flag7
    jmp winX
flag7: 
    cmp array[4 * type array], 1
    jnz flag8
    cmp array[5 * type array], 1
    jnz flag8
    cmp array[6 * type array], 1
    jnz flag8
    jmp winX
flag8: 
    cmp array[7 * type array], 1
    jnz exit
    cmp array[8 * type array], 1
    jnz exit
    cmp array[9 * type array], 1
    jnz exit
    jmp winX

    exit:  
    cmp count, 9
    jge new_game
endm


reset macro                                                         ;очистка игрового поля
    LOCAL L
    mov ecx, 0
    L:                                                              ;массив флагов заполняем 0
        mov array[ecx * type array], 0
        inc ecx
        cmp ecx, 10
    jne L

    mov esi, offset msg2                                            ;поле заполняем цифрами
    add esi, 3                                             
    mov al, '1'                                                     
    mov [esi], al
    mov esi, offset msg2                                          
    add esi, 7                                             
    mov al, '2'                                                     
    mov [esi], al
    mov esi, offset msg2                                          
    add esi, 11                                             
    mov al, '3'                                                     
    mov [esi], al
    mov esi, offset msg3                                          
    add esi, 3                                             
    mov al, '4'                                                     
    mov [esi], al
    mov esi, offset msg3                                          
    add esi, 7                                             
    mov al, '5'                                                     
    mov [esi], al
    mov esi, offset msg3                                          
    add esi, 11                                             
    mov al, '6'                                                     
    mov [esi], al
    mov esi, offset msg4                                          
    add esi, 3                                             
    mov al, '7'                                                     
    mov [esi], al
    mov esi, offset msg4                                          
    add esi, 7                                             
    mov al, '8'                                                     
    mov [esi], al
    mov esi, offset msg4                                          
    add esi, 11                                             
    mov al, '9'                                                     
    mov [esi], al
endm


clear macro
cout endl                                                           ; очистка консоли
    invoke FillConsoleOutputCharacter, stdout, ' ', 120*40, 0,  addr written        
endm

GAMEOVER macro                                                      ;вывод сообщения
    cout game1
    cout endl
    cout game2
    cout endl
    cout game3
    cout endl
    cout game4
    cout endl
    cout game5
    cout endl
    cout game6
    cout endl
    cout game7
endm
newGame macro
    cout newGame1
    cout endl
    cout newGame2
    cout endl
    cout newGame3
    cout endl
    cout newGame4
    cout endl
    cout newGame5
    cout endl
    cout newGame6
    cout endl
    cout newGame7
    cout endl
endm

GameWinX macro
    cout gameWinX1
    cout endl
    cout gameWinX2
    cout endl
    cout gameWinX3
    cout endl
    cout gameWinX4
    cout endl
    cout gameWinX5
    cout endl
endm

GameWinO macro
    cout gameWinO1
    cout endl
    cout gameWinO2
    cout endl
    cout gameWinO3
    cout endl
    cout gameWinO4
    cout endl
    cout gameWinO5
    cout endl
endm

                                        ;основной цикл программы

invoke MessageBox, 0, addr msg, addr msgInfo, MB_OK  
cout endl
cout msgGame
cout endl
cout endl
cout msgInfo1
cout endl
cout msgInfo2
cout endl
newGame
print                                                               ;вывод на экран поля
L2:                                                                 ;метка
    cout nextX                                                      ;вывод сообщение кто ходит следующим
    invoke ReadConsole, stdin, ADDR buf, BSIZE, ADDR cRead, NULL    ;получаем значение которое ввел пользователь   
    cInt a, cRead                                                   ;преобразуем его в число
    cmp a, 9                                                        ;если число больше 9
    jg incorrectlyNumberX                                           ;переходим на метку некорректный ввод
    cmp a, 1                                                        ;если число меньше 1
    jl incorrectlyNumberX                                           ;переходим на метку некорректный ввод
    ChangeFieldX a                                                  ;макрос для отрисовки Х в командной строке на поле
    invoke SetConsoleCursorPosition, stdout, 0                      ;ставим курсор в 0, 0
    clear                                                           ;очищаем консоль
    newGame                                                         ;вывод сообщения newgame
    cout endl                                                       ;переход на следующую строку
    coutNumber2 victory, pointsX, pointsO                           ;вывод счета игроков
    cout endl                                                       ;переход на следующую строку
    cout endl                                                       ;переход на слудующую строку
    print                                                           ;вывод игрового поля
    mov ecx, a                                                      ;записываем флаг в массив чтобы знать что там Х
    mov array[ecx * type array], 1                                  ;записываем флаг в массив чтобы знать что там Х   
    CheckX                                                          ;проверка выиграл ли Х
    L3:
    cout nextO                                                      ;вывод сообщение что ходит игрок О
    invoke ReadConsole, stdin, ADDR buf, BSIZE, ADDR cRead, NULL    ;получаем значение которое ввел пользователь   
    cInt a, cRead                                                   ;переводим строку в число
    cmp a, 9                                                        ;если число больше 9
    jg incorrectlyNumberO                                           ;некорректный ввод
    cmp a, 1                                                        ;если число меньше 1
    jl incorrectlyNumberO                                           ;некорректный ввод                                       
    ChangeFieldO a                                                  ;записываем значения в игровое поле
    invoke SetConsoleCursorPosition, stdout, 0                      ;ставим курсор в 0, 0
    clear                                                           ;очищаем консоль
    newGame                                                         ;вывод сообщения newgame
    cout endl                                                       ;переход на новую строку
    coutNumber2 victory, pointsX, pointsO                           ;вывод счета игроков
    cout endl                                                       ;переход на новую строку
    cout endl                                                       ;переход на новую строку
    print                                                           ;отрисовываем игровое поле
    mov ecx, a                                                      ;записываем флаг в массив чтобы знать что там О
    mov array[ecx * type array], 2                                  ;    
    CheckO                                                          ;проверка выиграл ли O

jmp L2                                                              ;метка для повторения ходов

winX:                                                               ;если есть выигрышная стратегия, то jmp на эту ветку    
mov count, 0
cout endl
cout endl
cout endl
clear
mov eax, 1Ah;
invoke SetConsoleTextAttribute, stdout, eax
GameWinX
cout endl                                                           ;вывод сообщения что выиграл X
mov eax, 1Ch;
invoke SetConsoleTextAttribute, stdout, eax
GAMEOVER
mov eax, 1Fh;
invoke SetConsoleTextAttribute, stdout, eax
cout endl
cout endl
cout endl
cout endl
inc pointsX                                                         ;увеличение количества очков Х
new_game:
reset                                                               ;очистка поля и массива флагов     
mov count, 0                                                      
print
jmp L2                                                              ;возвращаемся в цикл

winO:                                                               ;если есть выигрышная стратегия, то jmp на эту ветку  
mov count, 0 
cout endl
cout endl
cout endl 
clear
mov eax, 1Ah;
invoke SetConsoleTextAttribute, stdout, eax
GameWinO                                                            ;вывод сообщения что выиграл X
cout endl
mov eax, 1Ch;
invoke SetConsoleTextAttribute, stdout, eax
GAMEOVER
mov eax, 1Fh;
invoke SetConsoleTextAttribute, stdout, eax
cout endl
cout endl
cout endl
inc pointsO                                                         ;увеличение количества очков Х
reset                                                               ;очистка поля и массива флагов                                                            
print
jmp L2


incorrectlyNumberX:
cout incorrectly
cout endl;
jmp L2;

incorrectlyNumberO:
cout incorrectly
cout endl;
jmp L3

invoke  Sleep, 100000
invoke ExitProcess, 0                                               ; завершаем процесс
end start