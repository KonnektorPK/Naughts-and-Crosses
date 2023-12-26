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
msg1 byte " -------------"                                          ; ����� ����                         
msg2 byte " | 1 | 2 | 3 |"
msg3 byte " | 4 | 5 | 6 |"
msg4 byte " | 7 | 8 | 9 |"
nextX byte "��������� ��� � -> "                                        ; ��������� ���
nextO byte "��������� ��� O -> "
msgGame byte "              ���� ��������-������ � �������              ", 0
msgInfo1 byte "����� ������ ������� ����� �� 1 �� 9", 0
msgInfo2 byte "������������ �� ���� �� ��� ����� ����� ��������� ���� X, ���� O", 0
incorrectly byte "����� ������� ����������! ��������� ����: "
victory byte "  ���� X = %d, O = %d", 0
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

msg      byte "���� �������� ������ �� ����������", 0
msgInfo  byte "������� ������ ���� - 2", 0
endl byte 13, 10                                                    ;������ �������� �� ������ �������



written     dd ?
coords      COORD <0, 10>
array       dd    10 dup(0)
a           dd    0                 
count       dd    0                                                 ;������� ����� 
pointsX     dd    0                                                 ;������� ����� ������ �� x
pointsO     dd    0                                                 ;������� ����� ������ �� o
buf         db    BSIZE dup(?)
stdout      dd    ?                                                 ; ���������� ��� �������� handle'a ������������ ������
cWritten    dd    ?                                                 ; ���������� ��� �������� ����� ���������� � ������� ��������
stdin       dd    ?
cRead       dd    ?
.code                                                               ; ���������� ������ ����
start:
invoke CharToOem, addr nextX, addr nextX                            ;������������ �������
invoke CharToOem, addr msgInfo1, addr msgInfo1
invoke CharToOem, addr msgInfo2, addr msgInfo2
invoke CharToOem, addr incorrectly, addr incorrectly


invoke AllocConsole
invoke GetStdHandle, STD_OUTPUT_HANDLE                              ; �������� handle ������������ ������ � �������
mov stdout, eax	                                                  ; ���������� ���������� ������ � ����������
invoke GetStdHandle, STD_INPUT_HANDLE                               ; �������� handle ������������ ������ � �������
mov stdin, eax                                                      ; ���������� ���������� ����� � ����������
                                           
cInt macro in, cR                                                   ;������� ������ � �����
    mov eax, offset buf                                       
    add eax, cR                                               
    sub eax, 2                                                
    mov byte ptr [eax], 0                                     
    invoke atol, addr buf                                           ; ��������� ���������� ����������� ������ � �����
    mov in, eax 
    endm
        
mult macro p1, p2, result                                           ;������� ��� ������������ ����� (�����1, �����2, ��������� ����������)
    mov eax, p1
    mov ebx, p2
    mul ebx
    mov result, eax
    endm
    
summ macro p1, p2, result                                           ;������ ��� ������������ �����
    mov eax, p1
    add eax, p2
    mov result, eax
    endm
    
pow macro p1, p2, result                                            ;result = p1 ^ p2
    LOCAL L1
    mov ebx, p1
    mov edx, p1                                                     ;���������� �������� p1 � p2
    mov ecx, p2
    dec ecx                                                         ;��������� ������� �� 1
    L1:                                                             ;���� ��� ��������� ����� �������� ���������� ���
        mult edx, ebx, eax                                          ;�������� ��������� �� ����� p1
        mov edx, eax                                                ;���������� ��������� � p1
        dec ecx                                                     ;��������� �������
        cmp ecx, 0                                                  ;����� ������� 0 ����������� ����
    jne L1
    mov result, eax
    endm
    
subt macro p1, p2, result                                           ;������ ��� ��������� ���� �����
    mov eax, p1
    sub eax, p2
    mov result, eax
    endm


coutNumber2 macro msg1, msg2, msg3                                         ;������ ��� ������ ������ � ������(%d, %d)
    invoke wsprintf, addr buf, addr msg1, msg2, msg3
    invoke WriteConsole, stdout, addr buf, sizeof buf, addr cWritten, 
    NULL                                                            ; ������� ���������� ������ buf �� �����
    endm   

coutNumber macro msg1, msg2                                         ;������ ��� ������ ������ � ������(%d)
    invoke wsprintf, addr buf, addr msg1, msg2
    invoke WriteConsole, stdout, addr buf, sizeof buf, addr cWritten, 
    NULL                                                            ; ������� ���������� ������ buf �� �����
    endm 
      
cout macro TextConsoleOutputCP                                      ;������ ��� ������ ������ 
    invoke WriteConsoleA,			
    stdout,	
    ADDR TextConsoleOutputCP,	
    SIZEOF TextConsoleOutputCP,	
    ADDR cWritten,
    NULL
    endm
    
newList macro                                                       ;������� �� ��������� ��������
    LOCAL L1
    mov ebx, 21
    L1:
        cout endl
        dec ebx
    jne L1
    endm

print macro                                                         ;����� ���������� ����
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
    mov esi, offset Text                                            ; ��������� ����� ������
    add esi, Number                                                 ; ��������� � ������� (������ ������ ����� �������� 0)
    mov al, 'X'                                                     ; �������� ������ �� 'X'
    mov [esi], al
endm
changeO macro Text, Number
    mov esi, offset Text                                            ; ��������� ����� ������
    add esi, Number                                                 ; ��������� � ������� (������ ������ ����� �������� 0)
    mov al, 'O'                                                     ; �������� ������ �� 'O'
    mov [esi], al
endm

ChangeFieldX macro temp                                             ;�������� ���� ������� �������
    LOCAL flag_1                                                    ;��������� ����� ����� ������������ ������ ��������
    LOCAL flag_2                                                    
    LOCAL flag_3
    LOCAL flag_4
    LOCAL flag_5
    LOCAL flag_6
    LOCAL flag_7
    LOCAL flag_8
    LOCAL flag_9
    LOCAL exit
    
    cmp temp, 1                                                     ;���� ����� ����� 1 �� �������� � ����� flag_1, ����� ����������
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

    flag_1: changeX msg2, 3                                         ;�������� ������ ��� ������ ����� �� X
            inc count
            jmp exit                                                ;������� �� �������, ����� ����������
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

ChangeFieldO macro temp                                             ;���� ����� ��� �
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

CheckO macro                                                        ;������ �����
    LOCAL flag1
    LOCAL flag2
    LOCAL flag3
    LOCAL flag4
    LOCAL flag5
    LOCAL flag6
    LOCAL flag7
    LOCAL flag8
    LOCAL exit

flag1:                                                              ;���� � ������� ������ ���� 1 �� ������(������ ��� ����� O) ������� �� ���� ������
    cmp array[1 * type array], 2                                    ;����� ��������� � ��������� ����������� ��������
    jnz flag2   
    cmp array[2 * type array], 2                                    ;���� ��� ��� ������� ������, �� ��������� �� ����� winO 
    jnz flag2
    cmp array[3 * type array], 2
    jnz flag2
    jmp winO                                                        ;���� �� ����� ������ 1, 2, 3 ����� �������, �� ������� O ��������� � ����� winO
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

CheckX macro                                                        ;��� X ����������
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


reset macro                                                         ;������� �������� ����
    LOCAL L
    mov ecx, 0
    L:                                                              ;������ ������ ��������� 0
        mov array[ecx * type array], 0
        inc ecx
        cmp ecx, 10
    jne L

    mov esi, offset msg2                                            ;���� ��������� �������
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
cout endl                                                           ; ������� �������
    invoke FillConsoleOutputCharacter, stdout, ' ', 120*40, 0,  addr written        
endm

GAMEOVER macro                                                      ;����� ���������
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

                                        ;�������� ���� ���������

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
print                                                               ;����� �� ����� ����
L2:                                                                 ;�����
    cout nextX                                                      ;����� ��������� ��� ����� ���������
    invoke ReadConsole, stdin, ADDR buf, BSIZE, ADDR cRead, NULL    ;�������� �������� ������� ���� ������������   
    cInt a, cRead                                                   ;����������� ��� � �����
    cmp a, 9                                                        ;���� ����� ������ 9
    jg incorrectlyNumberX                                           ;��������� �� ����� ������������ ����
    cmp a, 1                                                        ;���� ����� ������ 1
    jl incorrectlyNumberX                                           ;��������� �� ����� ������������ ����
    ChangeFieldX a                                                  ;������ ��� ��������� � � ��������� ������ �� ����
    invoke SetConsoleCursorPosition, stdout, 0                      ;������ ������ � 0, 0
    clear                                                           ;������� �������
    newGame                                                         ;����� ��������� newgame
    cout endl                                                       ;������� �� ��������� ������
    coutNumber2 victory, pointsX, pointsO                           ;����� ����� �������
    cout endl                                                       ;������� �� ��������� ������
    cout endl                                                       ;������� �� ��������� ������
    print                                                           ;����� �������� ����
    mov ecx, a                                                      ;���������� ���� � ������ ����� ����� ��� ��� �
    mov array[ecx * type array], 1                                  ;���������� ���� � ������ ����� ����� ��� ��� �   
    CheckX                                                          ;�������� ������� �� �
    L3:
    cout nextO                                                      ;����� ��������� ��� ����� ����� �
    invoke ReadConsole, stdin, ADDR buf, BSIZE, ADDR cRead, NULL    ;�������� �������� ������� ���� ������������   
    cInt a, cRead                                                   ;��������� ������ � �����
    cmp a, 9                                                        ;���� ����� ������ 9
    jg incorrectlyNumberO                                           ;������������ ����
    cmp a, 1                                                        ;���� ����� ������ 1
    jl incorrectlyNumberO                                           ;������������ ����                                       
    ChangeFieldO a                                                  ;���������� �������� � ������� ����
    invoke SetConsoleCursorPosition, stdout, 0                      ;������ ������ � 0, 0
    clear                                                           ;������� �������
    newGame                                                         ;����� ��������� newgame
    cout endl                                                       ;������� �� ����� ������
    coutNumber2 victory, pointsX, pointsO                           ;����� ����� �������
    cout endl                                                       ;������� �� ����� ������
    cout endl                                                       ;������� �� ����� ������
    print                                                           ;������������ ������� ����
    mov ecx, a                                                      ;���������� ���� � ������ ����� ����� ��� ��� �
    mov array[ecx * type array], 2                                  ;    
    CheckO                                                          ;�������� ������� �� O

jmp L2                                                              ;����� ��� ���������� �����

winX:                                                               ;���� ���� ���������� ���������, �� jmp �� ��� �����    
mov count, 0
cout endl
cout endl
cout endl
clear
mov eax, 1Ah;
invoke SetConsoleTextAttribute, stdout, eax
GameWinX
cout endl                                                           ;����� ��������� ��� ������� X
mov eax, 1Ch;
invoke SetConsoleTextAttribute, stdout, eax
GAMEOVER
mov eax, 1Fh;
invoke SetConsoleTextAttribute, stdout, eax
cout endl
cout endl
cout endl
cout endl
inc pointsX                                                         ;���������� ���������� ����� �
new_game:
reset                                                               ;������� ���� � ������� ������     
mov count, 0                                                      
print
jmp L2                                                              ;������������ � ����

winO:                                                               ;���� ���� ���������� ���������, �� jmp �� ��� �����  
mov count, 0 
cout endl
cout endl
cout endl 
clear
mov eax, 1Ah;
invoke SetConsoleTextAttribute, stdout, eax
GameWinO                                                            ;����� ��������� ��� ������� X
cout endl
mov eax, 1Ch;
invoke SetConsoleTextAttribute, stdout, eax
GAMEOVER
mov eax, 1Fh;
invoke SetConsoleTextAttribute, stdout, eax
cout endl
cout endl
cout endl
inc pointsO                                                         ;���������� ���������� ����� �
reset                                                               ;������� ���� � ������� ������                                                            
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
invoke ExitProcess, 0                                               ; ��������� �������
end start