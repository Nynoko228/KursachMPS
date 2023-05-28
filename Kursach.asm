.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

DisplayPort = 2
DisplayPowerPort = 1
KbdPort = 0
NMax = 100

IntTable   SEGMENT use16 AT 0
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;Здесь размещаются описания переменных
DataHexArr db 10 dup(?) 
DataHexTabl db 10 dup(?)
DataTable dd 7 dup(?)
Res db 7 dup (?)
SelectedNumber DD ?
OldButton db    ?
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT use16 AT 00FFh
;Задайте необходимый размер стека
           dw    16 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
InitDataStart:
;Здесь размещаются описания констант



InitDataEnd:
InitData   ENDS

Code       SEGMENT use16
;Здесь размещаются описания констант

           ASSUME cs:Code,ds:Data,es:Data
		   
	HexArr DB 00h,01h,02h,03h,04h,05h,06h,07h,08h,09h
	HexTabl DB 3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh
	;Table DD 0500h, 010000h, 020000h, 050000h, 01000000h, 02000000h, 05000000h  
	Table DD 0500h, 010000h, 020000h, 050000h, 01000000h, 02000000h, 05000000h 
Initialization PROC
			xor ax, ax
			mov OldButton, al
	        mov Res, al
			mov Res+1, al
			mov Res+2, al
			mov Res+3, al
			mov Res+4, al
			mov Res+5, al
			mov byte ptr SelectedNumber, al
		    mov byte ptr SelectedNumber+1, al
			mov byte ptr SelectedNumber+2, al
			mov byte ptr SelectedNumber+3, al
			RET
Initialization ENDP

KeyRead    PROC  Near ;Чтение кнопок
           in    al, KbdPort
		   call VibrDestr
		   mov   ah, al
		   xor AL, OldButton
		   ;Mov OldButton, ah
		   AND AL, AH         
           RET
KeyRead    ENDP

AddSymbol  PROC  Near 
		   in al, KbdPort
		   cmp al, OldButton
		   je m1
		   mov OldButton, al
           cmp   al, 0ffh
           jz    m1   ;Если нет символов для добавления (не нажата ни одна из кнопок)
m2:       
		   inc   ah
           shr   al, 1
		   jc m2
		   dec ah
           
		   xor al, al
		   lea BX, Table
		   add al, ah
		   add al, ah
		   add al, ah
		   add al, ah
		   xlat
		   mov byte ptr SelectedNumber, al 
		   lea BX, Table+1
		   add al, ah
		   add al, ah
		   add al, ah
		   add al, ah
		   xlat
		   mov byte ptr SelectedNumber+1, al  
		   lea BX, Table+2
		   add al, ah
		   add al, ah
		   add al, ah
		   add al, ah
		   xlat
		   mov byte ptr SelectedNumber+2, al  
		   lea BX, Table+3
		   add al, ah
		   add al, ah
		   add al, ah
		   add al, ah
		   xlat
		   mov byte ptr SelectedNumber+3, al  		   
m1:		   RET           
AddSymbol    ENDP

AccumulationSumm PROC
			;mov dl, SelectedNumber
			cmp al, OldButton
			jz m7
			;cmp   al, 0ffh
			;jz m7
	
			xor al,al
			cmp word ptr SelectedNumber+2, 0
			JNZ M8
			cmp word ptr SelectedNumber, 0
			JZ M7

			
M8:			mov ax, word ptr Res
			ADD al, byte ptr SelectedNumber
			AAA
			mov word ptr Res, ax

			
			mov ax, word ptr Res+1
			ADD al, byte ptr SelectedNumber+1
			AAA
			mov word ptr Res+1, ax

			
			mov ax, word ptr Res+2
			ADD al, byte ptr SelectedNumber+2
			AAA
			mov word ptr Res+2, ax

			
			mov ax, word ptr Res+3
			ADD al, byte ptr SelectedNumber+3
			AAA
			mov word ptr Res+3, ax

			CMP Res+4, 09h
			JBE M7
			mov Res+4, 0h
			INC [Res+5]
m7:			mov bp, word ptr SelectedNumber
			and bp, 00FFh
			ret
AccumulationSumm ENDP


SumOut     PROC NEAR
            lea   bx, DataHexTabl 
            mov   ah, Res
            mov   al,ah               ;теперь в al старшая цифра
            xlat
		    not al		   ;табличное преобразование старшей цифры
            out   DisplayPort, al    ;выводим на страший индикатор
            mov   al, 01h            
            out   DisplayPowerPort, al    ;зажигаем старший индикатор    
            mov   al,00h             
            out   DisplayPowerPort, al    ;гасим индикатор
		    mov   ah, Res+1       ;загружаем в регистры
            mov   al, ah              ;текущее значение суммы                 
            xlat
		    not al         ;табличное преобразование младшей цифры
            out   DisplayPort, al    ;Выводим на младший индикатор            
            mov   al, 02h            
            out   DisplayPowerPort, al    ;зажигаем младший индикатор
            mov   al,00h
            out   DisplayPowerPort, al    ;гасим индикатор
		    mov   ah, Res+2       ;загружаем в регистры
            mov   al, ah              ;текущее значение суммы                 
            xlat
		    not al         ;табличное преобразование младшей цифры
            out   DisplayPort, al    ;Выводим на младший индикатор            
            mov   al, 04h            
            out   DisplayPowerPort, al    ;зажигаем младший индикатор
            mov   al,00h
            out   DisplayPowerPort, al    ;гасим индикатор
		    mov   ah, Res+3       ;загружаем в регистры
            mov   al, ah              ;текущее значение суммы                 
            xlat
		    not al         ;табличное преобразование младшей цифры
            out   DisplayPort, al    ;Выводим на младший индикатор            
            mov   al, 08h            
            out   DisplayPowerPort, al    ;зажигаем младший индикатор
            mov   al,00h
            out   DisplayPowerPort, al    ;гасим индикатор
		    mov   ah, Res+4       ;загружаем в регистры
            mov   al, ah              ;текущее значение суммы                 
            xlat
		    not al         ;табличное преобразование младшей цифры
            out   DisplayPort, al    ;Выводим на младший индикатор            
            mov   al, 020h            
            out   DisplayPowerPort, al    ;зажигаем младший индикатор
            mov   al,00h
            out   DisplayPowerPort, al    ;гасим индикатор
			mov   ah, Res+5       ;загружаем в регистры
            mov   al, ah              ;текущее значение суммы                 
            xlat
		    not al         ;табличное преобразование младшей цифры
            out   DisplayPort, al    ;Выводим на младший индикатор            
            mov   al, 010h            
            out   DisplayPowerPort, al    ;зажигаем младший индикатор
            mov   al,00h
            out   DisplayPowerPort, al    ;гасим индикатор
		    xor ah, ah
            ret
SumOut     ENDP

CopyArr PROC
			MOV CX, 10 ;Загрузка счётчика циклов
			LEA BX, HexArr ;Загрузка адреса массива цифр
			LEA BP, HexTabl ;Загрузка адреса таблицы преобразования
			LEA DI, DataHexArr ;Загрузка адреса массива цифр в сегменте данных
			LEA SI, DataHexTabl ;Загрузка адреса таблицы преобразования в сегменте данных
M0:
			MOV AL, CS:[BX] ;Чтение цифры из массива в аккумулятор
			MOV [DI], AL ;Запись цифры в сегмент данных/DataHexArr
			INC BX ;Модификация адреса HexArr
			INC DI ;Модификация адреса DataHexArr
			LOOP M0
			
			MOV CX, 10 ;Загрузка счётчика циклов
M1:
			MOV AH, CS:[BP] ;Чтение графического образа из таблицы преобразования
			MOV [SI], AH ;Запись графического образа в сегмент данных/DataHexTabl
			INC BP ;Модификация адреса HexTabl
			INC SI ;Модификация адреса DataHexTabl
			LOOP M1
			xor bp,bp
			
			MOV CX, 14 ;Загрузка счётчика циклов
			LEA BP, Table ;Загрузка адреса таблицы преобразования
			LEA SI, DataTable ;Загрузка адреса таблицы преобразования в сегменте данных
M2:
			MOV AH, CS:[BP] ;Чтение графического образа из таблицы преобразования
			MOV [SI], AH ;Запись графического образа в сегмент данных/DataTable
			MOV AL, CS:[BP+1] ;Чтение графического образа из таблицы преобразования
			MOV [SI+1], AL ;Запись графического образа в сегмент данных/DataTable
			INC BP ;Модификация адреса Table
			INC SI ;Модификация адреса DataTable
			INC BP ;Модификация адреса Table
			INC SI ;Модификация адреса DataTable
			LOOP M2
			xor bp,bp
			ret
CopyArr ENDP

VibrDestr  PROC  NEAR
VD1:        mov   ah,al       ;Сохранение исходного состояния
            mov   bh,0        ;Сброс счётчика повторений
VD2:        in    al,dx       ;Ввод текущего состояния
            cmp   ah,al       ;Текущее состояние=исходному?
            jne   VD1         ;Переход, если нет
            inc   bh          ;Инкремент счётчика повторений
            cmp   bh,NMax     ;Конец дребезга?
            jne   VD2         ;Переход, если нет
            mov   al,ah       ;Восстановление местоположения данных
            ret
VibrDestr  ENDP

Start:
           mov   ax,Data
           mov   ds,ax
           mov   es,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
		   
		   call Initialization
		   call CopyArr
		   
MainLoop:  ;call KeyRead
		   call AddSymbol
		   call AccumulationSumm
		   call SumOut
		   
		   jmp MainLoop
;Здесь размещается код программы


;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END		Start
