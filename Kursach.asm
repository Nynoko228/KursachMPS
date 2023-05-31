.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   4096

SumPort = 0FDh ; 2
SumPowerPort = 0FEh ; 1
CntPort = 0FDh ; 2
CntPowerPort = 0FCh ; 3
KbdPort = 0F7h ; 0
IndPort = 0FBh ; 4
ControlPort = 0FEh ; 1

NMax = 50

IntTable   SEGMENT use16 AT 0
;Здесь размещаются адреса обработчиков прерываний
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;Здесь размещаются описания переменных
DataHexArr db 10 dup(?) 
DataHexTabl db 10 dup(?)
DataTable dd 7 dup(?)
ErrTable db 5 dup (?)
Res db 6 dup (?)
SelectedNumber DD ?
OldButton db    ?
OldCntrl db    ?
StopFlag db ?
BrakFlag db ?
ErrorFlag db ?
SumFlag db ?
SbrosFlag db ?
Buffer dw ?
Cnt DD ?
CntAll DD ?
CntBrak DD ?
Time DD ?
TimeEndFlag DB ?
Data       ENDS


;Задайте необходимый адрес стека
Stk        SEGMENT use16 AT 2000h
;Задайте необходимый размер стека
           DW    16 dup (?)
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
	Table DD 0500h, 010000h, 020000h, 050000h, 01000000h, 02000000h, 05000000h 
	Err DB 27h, 3fh, 27h, 27h, 73h
	
Initialization PROC NEAR
			xor ax, ax
			mov StopFlag, 01h
			mov BrakFlag, 00h
			mov ErrorFlag, 00h
			mov SumFlag, 00h
			mov SbrosFlag, 00h
			mov word ptr Cnt, ax
			mov word ptr Cnt+2, ax
			mov word ptr CntAll, ax
			mov word ptr CntAll+2, ax
			mov word ptr CntBrak, ax
			mov word ptr CntBrak+2, ax
			mov OldButton, al
			mov OldCntrl, al
	        mov word ptr Res, ax
			mov word ptr Res+2, ax
			mov word ptr Res+4, ax
			mov word ptr SelectedNumber, ax
			mov word ptr SelectedNumber+2, ax
			mov TimeEndFlag, 0FFh
			mov Buffer, 0100h
			mov ax, Buffer
			mov al, ah
			out IndPort, al
			xor ax, ax
			RET
Initialization ENDP

Simul PROC NEAR
			MOV CX, AX
			MOV AX, Buffer
			
			cmp StopFlag, 01h
			je Timer1
			cmp ErrorFlag, 01h
			je Timer1
			jmp Timer2
		
Timer0:	; Таймер
			SUB word ptr Time, 1
			SBB word ptr Time+2, 0
			MOV SI, word ptr Time
			OR SI, word ptr Time+2
			MOV TimeEndFlag, 0
			JNZ Timer1
			MOV TimeEndFlag, 0FFh
		
Timer2:		MOV AL,AH
			CMP TimeEndFlag, 0FFh
			JNZ Timer0
		
			Out IndPort, AL
			cmp AL, 80h
			jne Timer3
			mov SumFlag, 01h
Timer3:		ROL AH, 1
			
			MOV word ptr Time, 0050h
			MOV word ptr Time+2, 0000h
			JMP Timer0	
Timer1: 	MOV Buffer, AX
			MOV AX, CX
			ret
Simul ENDP 

ReadInput  	PROC  Near 
			xor ah, ah
			mov dx, ControlPort
			in al, dx		
			call VibrDestr
			xor ah, ah
			cmp al, OldCntrl
			jne m3 
			
m6:		   	; Пишу кнопку сброса снизу
			cmp SbrosFlag, 01h
			je m1
			cmp ErrorFlag, 01h
			je m1
			
			jmp m4

		   
m3:        	mov OldCntrl, al
			cmp al, 0ffh
			je m6
			
m5:		   	inc   ah
			shr   al, 1
			jc m5
			dec ah
			
			cmp ah, 03h
			jne NoSbros
			mov SbrosFlag, 01h
NoSbros:	cmp ah, 02h
			jb m11
			xor BrakFlag, 01h
			xor ah, ah
			jmp m6
		   
m11:	   	mov StopFlag, ah
			xor ah, ah
			jmp m6
		   
m4:		   	mov dx, KbdPort
			in al, dx		
			call VibrDestr
			xor ah, ah
			cmp al, OldButton
			je m1
			mov OldButton, al
			cmp   al, 0ffh
			je    m1   ;Если нет символов для добавления (не нажата ни одна из кнопок)
m2:       
			inc   ah
			shr   al, 1
			jc m2
			dec ah
           
			xor al, al
			lea BX, Table
			shl ah, 2
			add al, ah
			xlat
			mov byte ptr SelectedNumber, al 
			lea BX, Table+1
			add al, ah
			xlat
			mov byte ptr SelectedNumber+1, al  
			lea BX, Table+2
			add al, ah
			xlat
			mov byte ptr SelectedNumber+2, al  
			lea BX, Table+3
			add al, ah
			xlat
			mov byte ptr SelectedNumber+3, al  		   
m1:		   	RET           
ReadInput  	ENDP

AddCntAll  	PROC Near
			cmp byte ptr CntAll+2, 01h
			jne Cnt1
			mov ErrorFlag, 01h
			mov StopFlag, 01h
Cnt1:		mov ax, word ptr CntAll
			inc ax
			AAA
			mov word ptr CntAll, ax
			CMP byte ptr CntAll+1, 09h
			JBE CntRet 
			mov byte ptr CntAll+1, 00h
			mov byte ptr CntAll+2, 01h
CntRet:		ret
AddCntAll  	ENDP

AccumulationSumm PROC Near
			cmp SbrosFlag, 01h
			je M7
			cmp ErrorFlag, 01h
			je M7
		    cmp StopFlag, 01h
			je M7
			cmp SumFlag, 00h
			je M7
			
			xor ax,ax
			cmp BrakFlag, 01h
			je M10
			cmp word ptr SelectedNumber+2, 0
			JNZ M8
			cmp word ptr SelectedNumber, 0
			JZ M7

		
M8:			call AddCntAll
			mov ax, word ptr Cnt
			inc ax
			AAA
			mov word ptr Cnt, ax
			CMP byte ptr Cnt+1, 09h
			JBE M9 
			mov byte ptr Cnt+1, 00h
			mov byte ptr Cnt+2, 01h
			
M9:			mov SumFlag, 00h
			mov ax, word ptr Res
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
			JMP M7
			
M10:		call AddCntAll
			mov SumFlag, 00h
			mov ax, word ptr CntBrak
			inc ax
			AAA
			mov word ptr CntBrak, ax
			CMP byte ptr CntBrak+1, 09h
			JBE M7 
			mov byte ptr CntBrak+1, 00h
			mov byte ptr CntBrak+2, 01h
			
M7:			mov bp, word ptr SelectedNumber
			and bp, 00FFh
			ret
AccumulationSumm ENDP


SumOut     PROC NEAR  			;Выводим сумму на индикаторы
			cmp ErrorFlag, 01h
			je SumOutRet
			
			xor cx, cx
			mov cl, 01h
            lea   bx, DataHexTabl 
			lea SI, Res
SumOut1:	mov ah, [SI]
			mov al, ah
			xlat
			not al					;табличное преобразование
			out SumPort, al			;выводим на индикатор
			mov al, cl
			out SumPowerPort, al	;зажигаем индикатор
			mov al,00h
			out SumPowerPort, al	;гасим индикатор
			shl cl, 1
			inc SI
			cmp cl, 20h
			jbe SumOut1
		    xor ah, ah
			xor cx, cx
SumOutRet:  ret
SumOut      ENDP

CntOut 	    PROC NEAR
			xor cx, cx
			mov cl, 01h
			lea   bx, DataHexTabl
			lea SI, byte ptr Cnt
CntOut1:	mov ah, [SI]
			mov al, ah
			xlat
			not al				;табличное преобразование
			out CntPort, al		;выводим на индикатор
			mov al, cl
			out CntPowerPort, al	;зажигаем индикатор 
			mov al,00h
			out CntPowerPort, al	;гасим индикатор
			shl cl, 1
			inc SI
			cmp cl, 04h
			jbe CntOut1
			xor ah, ah
			xor cx, cx
			
			mov cl, 08h
			lea   bx, DataHexTabl
			lea SI, byte ptr CntBrak
CntOut2:	mov ah, [SI]
			mov al, ah
			xlat
			not al					;табличное преобразование
			out CntPort, al			;выводим на индикатор
			mov al, cl
			out CntPowerPort, al	;зажигаем индикатор 
			mov al,00h
			out CntPowerPort, al	;гасим индикатор
			shl cl, 1
			inc SI
			cmp cl, 20h
			jbe CntOut2
			xor ah, ah
			xor cx, cx
			ret
CntOut 	   ENDP

ErrorOut Proc Near
			cmp ErrorFlag, 00h
			je ErrorRet
			
			xor al, al
			xor bl, bl
			
			lea bx, ErrTable
			;xor bl, bl
			xor dl, dl
			mov cl, 02h
			
ErrorOut1:	mov al, dl
            xlat
		    not al				 ;табличное преобразование
            out   SumPort, al    ;выводим на индикатор
            mov   al, cl            
            out   SumPowerPort, al    ;зажигаем индикатор    
            mov   al,00h             
            out   SumPowerPort, al    ;гасим индикатор
			shl cl, 1
			inc dl
			cmp cl, 20h
			jbe ErrorOut1
			xor ah, ah
			xor cx, cx
			xor dl, dl
			
ErrorRet:	ret
ErrorOut ENDP

Sbros PROC NEAR
			cmp SbrosFlag, 00h
			je SbrosRet
			call Initialization
			
SbrosRet:	ret
Sbros ENDP

VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;Сохранение исходного состояния
           mov   ch,0        ;Сброс счётчика повторений
VD2:       in    al,dx       ;Ввод текущего состояния
           cmp   ah,al       ;Текущее состояние=исходному?
           jne   VD1         ;Переход, если нет
           inc   ch          ;Инкремент счётчика повторений
           cmp   ch,NMax     ;Конец дребезга?
           jne   VD2         ;Переход, если нет
           mov   al,ah       ;Восстановление местоположения данных
           ret
VibrDestr  ENDP

CopyArr PROC NEAR
			MOV CX, 10 ;Загрузка счётчика циклов
			LEA BX, HexArr ;Загрузка адреса массива цифр
			LEA BP, HexTabl ;Загрузка адреса таблицы преобразования
			LEA DI, DataHexArr ;Загрузка адреса массива цифр в сегменте данных
			LEA SI, DataHexTabl ;Загрузка адреса таблицы преобразования в сегменте данных
CopyArr0:
			MOV AL, CS:[BX] ;Чтение цифры из массива в аккумулятор
			MOV [DI], AL ;Запись цифры в сегмент данных/DataHexArr
			INC BX ;Модификация адреса HexArr
			INC DI ;Модификация адреса DataHexArr
			LOOP CopyArr0
			
			MOV CX, 10 ;Загрузка счётчика циклов
CopyArr1:
			MOV AH, CS:[BP] ;Чтение графического образа из таблицы преобразования
			MOV [SI], AH ;Запись графического образа в сегмент данных/DataHexTabl
			INC BP ;Модификация адреса HexTabl
			INC SI ;Модификация адреса DataHexTabl
			LOOP CopyArr1
			
			MOV CX, 14 ;Загрузка счётчика циклов
			LEA BP, Table ;Загрузка адреса таблицы преобразования
			LEA SI, DataTable ;Загрузка адреса таблицы преобразования в сегменте данных
CopyArr2:
			MOV AH, CS:[BP] ;Чтение графического образа из таблицы преобразования
			MOV [SI], AH ;Запись графического образа в сегмент данных/DataTable
			MOV AL, CS:[BP+1] ;Чтение графического образа из таблицы преобразования
			MOV [SI+1], AL ;Запись графического образа в сегмент данных/DataTable
			INC BP ;Модификация адреса Table
			INC SI ;Модификация адреса DataTable
			INC BP ;Модификация адреса Table
			INC SI ;Модификация адреса DataTable
			LOOP CopyArr2
			
			MOV CX, 4 ;Загрузка счётчика циклов
			LEA BP, Err ;Загрузка адреса таблицы преобразования
			LEA SI, ErrTable ;Загрузка адреса таблицы преобразования в сегменте данных
CopyArr3:
			MOV AH, CS:[BP] ;Чтение графического образа из таблицы преобразования
			MOV [SI], AH ;Запись графического образа в сегмент данных/DataTable
			MOV AL, CS:[BP+1] ;Чтение графического образа из таблицы преобразования
			MOV [SI+1], AL ;Запись графического образа в сегмент данных/DataTable
			INC BP ;Модификация адреса Err
			INC SI ;Модификация адреса ErrTable
			LOOP CopyArr3
			xor bp,bp
			xor cx, cx
			ret
CopyArr ENDP

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
			call ReadInput
			call Simul
			call AccumulationSumm
			call SumOut
			call CntOut
			call ErrorOut
			call Sbros
			jmp MainLoop
;Здесь размещается код программы


;В следующей строке необходимо указать смещение стартовой точки
			org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
			ASSUME cs:NOTHING
			jmp   Far Ptr Start
Code       	ENDS
END		Start
