.386
;������ ���� ��� � �����
RomSize    EQU   4096

SumPort = 0FDh ; 2
SumPowerPort = 0FEh ; 1
CntPort = 0FDh ; 2
CntPowerPort = 0FCh ; 3
KbdPort = 0F7h ; 0
IndPort = 0FBh ; 4
ControlPort = 0FEh

NMax = 30

IntTable   SEGMENT use16 AT 0
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;����� ࠧ������� ���ᠭ�� ��६�����
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
Buffer dw ?
Cnt DD ?
CntAll DD ?
CntBrak DD ?
Time DD ?
TimeEndFlag DB ?
Data       ENDS


;������ ����室��� ���� �⥪�
Stk        SEGMENT use16 AT 2000h
;������ ����室��� ࠧ��� �⥪�
           DW    16 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
InitDataStart:
;����� ࠧ������� ���ᠭ�� ����⠭�



InitDataEnd:
InitData   ENDS

Code       SEGMENT use16
;����� ࠧ������� ���ᠭ�� ����⠭�

           ASSUME cs:Code,ds:Data,es:Data
		   
	HexArr DB 00h,01h,02h,03h,04h,05h,06h,07h,08h,09h
	HexTabl DB 3Fh,0Ch,76h,5Eh,4Dh,5Bh,7Bh,0Eh,7Fh,5Fh
	;Table DD 0500h, 010000h, 020000h, 050000h, 01000000h, 02000000h, 05000000h  
	Table DD 0500h, 010000h, 020000h, 050000h, 01000000h, 02000000h, 05000000h 
	Err DB 73h, 27h, 27h, 3fh, 27h
	
Initialization PROC NEAR
			xor ax, ax
			mov StopFlag, 01h
			mov BrakFlag, 00h
			mov ErrorFlag, 00h
			mov SumFlag, 00h
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
			;mov DH, 1
			;push DX
			;mov AH, 1
			;push AX
			;xor ah, ah
			;push CX
			RET
Initialization ENDP

Simul PROC NEAR
			;mov 
			;pop cx
			;pop DX
			;push AX
			;mov AX, DX
			MOV CX, AX
			MOV AX, Buffer
			
			cmp StopFlag, 01h
			je Timer1
			cmp ErrorFlag, 01h
			je Timer1
			jmp Timer2
		
Timer0:	; ������
			SUB word ptr Time, 1
			SBB word ptr Time+2, 0
			MOV SI, word ptr Time
			OR SI, word ptr Time+2
			MOV TimeEndFlag, 0
			JNZ Timer1
			MOV TimeEndFlag, 0FFh
		
Timer2: 	;MOV AL,DH
			MOV AL,AH
			CMP TimeEndFlag, 0FFh
			JNZ Timer0
		
			Out IndPort, AL
			cmp AL, 80h
			jne Timer3
			mov SumFlag, 01h
Timer3:		;ROL DH, 1
			ROL AH, 1
			
			MOV word ptr Time, 0010h
			MOV word ptr Time+2, 0000h
			JMP Timer0	
Timer1: 	;MOV AL, DL
			MOV Buffer, AX
			MOV AX, CX
			;pop DX
			;push AX
			;mov AX, DX
			;xor DX, DX
			;mov AX, DX
			;push CX
			ret
Simul ENDP 

AddSymbol  	PROC  Near 
			xor ah, ah
			mov dx, ControlPort
			in al, dx		
			call VibrDestr
			xor ah, ah
			cmp al, OldCntrl
			jne m3 
			
m6:		   	cmp ErrorFlag, 01h
			je m1
			;cmp StopFlag, 00h
			;je m4
			jmp m4

		   
m3:        	mov OldCntrl, al
			cmp al, 0ffh
			je m6
			
m5:		   	inc   ah
			shr   al, 1
			jc m5
			dec ah
		   
			cmp ah, 02h
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
			je    m1   ;�᫨ ��� ᨬ����� ��� ���������� (�� ����� �� ���� �� ������)
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
AddSymbol  	ENDP

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


SumOut     PROC NEAR
			cmp ErrorFlag, 01h
			je SumOutRet
            lea   bx, DataHexTabl 
            mov   ah, Res
            mov   al,ah               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   SumPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 01h            
            out   SumPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   SumPowerPort, al    ;��ᨬ ��������
		    mov   ah, Res+1       ;����㦠�� � ॣ�����
            mov   al, ah              ;⥪�饥 ���祭�� �㬬�                 
            xlat
		    not al         ;⠡��筮� �८�ࠧ������ ����襩 ����
            out   SumPort, al    ;�뢮��� �� ����訩 ��������            
            mov   al, 02h            
            out   SumPowerPort, al    ;�������� ����訩 ��������
            mov   al,00h
            out   SumPowerPort, al    ;��ᨬ ��������
		    mov   ah, Res+2       ;����㦠�� � ॣ�����
            mov   al, ah              ;⥪�饥 ���祭�� �㬬�                 
            xlat
		    not al         ;⠡��筮� �८�ࠧ������ ����襩 ����
            out   SumPort, al    ;�뢮��� �� ����訩 ��������            
            mov   al, 04h            
            out   SumPowerPort, al    ;�������� ����訩 ��������
            mov   al,00h
            out   SumPowerPort, al    ;��ᨬ ��������
		    mov   ah, Res+3       ;����㦠�� � ॣ�����
            mov   al, ah              ;⥪�饥 ���祭�� �㬬�                 
            xlat
		    not al         ;⠡��筮� �८�ࠧ������ ����襩 ����
            out   SumPort, al    ;�뢮��� �� ����訩 ��������            
            mov   al, 08h            
            out   SumPowerPort, al    ;�������� ����訩 ��������
            mov   al,00h
            out   SumPowerPort, al    ;��ᨬ ��������
		    mov   ah, Res+4       ;����㦠�� � ॣ�����
            mov   al, ah              ;⥪�饥 ���祭�� �㬬�                 
            xlat
		    not al         ;⠡��筮� �८�ࠧ������ ����襩 ����
            out   SumPort, al    ;�뢮��� �� ����訩 ��������            
            mov   al, 010h            
            out   SumPowerPort, al    ;�������� ����訩 ��������
            mov   al,00h
            out   SumPowerPort, al    ;��ᨬ ��������
			mov   ah, Res+5       ;����㦠�� � ॣ�����
            mov   al, ah              ;⥪�饥 ���祭�� �㬬�                 
            xlat
		    not al         ;⠡��筮� �८�ࠧ������ ����襩 ����
            out   SumPort, al    ;�뢮��� �� ����訩 ��������            
            mov   al, 020h            
            out   SumPowerPort, al    ;�������� ����訩 ��������
            mov   al,00h
            out   SumPowerPort, al    ;��ᨬ ��������
		    xor ah, ah
SumOutRet:  ret
SumOut      ENDP

CntOut 	    PROC NEAR
			lea   bx, DataHexTabl
			mov   ah, byte ptr Cnt
			mov   al,ah               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   CntPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 01h            
            out   CntPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   CntPowerPort, al    ;��ᨬ ��������
			
			mov   ah, byte ptr Cnt+1
			mov   al,ah               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   CntPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 02h            
            out   CntPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   CntPowerPort, al    ;��ᨬ ��������
			
			mov   ah, byte ptr Cnt+2
			mov   al,ah               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   CntPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 04h            
            out   CntPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   CntPowerPort, al    ;��ᨬ ��������
			
			lea   bx, DataHexTabl
			mov   ah, byte ptr CntBrak
			mov   al,ah               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   CntPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 08h            
            out   CntPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   CntPowerPort, al    ;��ᨬ ��������
			
			mov   ah, byte ptr CntBrak+1
			mov   al,ah               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   CntPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 10h            
            out   CntPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   CntPowerPort, al    ;��ᨬ ��������
			
			mov   ah, byte ptr CntBrak+2
			mov   al,ah               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   CntPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 20h            
            out   CntPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   CntPowerPort, al    ;��ᨬ ��������
			
			
			xor ah, ah
			ret
CntOut 	   ENDP

ErrorOut Proc Near
			cmp ErrorFlag, 00h
			je ErrorRet
			
			xor al, al
			lea   bx, ErrTable
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   SumPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 20h            
            out   SumPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   SumPowerPort, al    ;��ᨬ ��������
			
			
			mov   al,1               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   SumPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 10h            
            out   SumPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   SumPowerPort, al    ;��ᨬ ��������
			
			
			mov   al,2               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   SumPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 08h            
            out   SumPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   SumPowerPort, al    ;��ᨬ ��������
			
			mov   al,3               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   SumPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 04h            
            out   SumPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   SumPowerPort, al    ;��ᨬ ��������
			
			mov   al,4               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   SumPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 02h            
            out   SumPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   SumPowerPort, al    ;��ᨬ ��������
ErrorRet:	ret
ErrorOut ENDP

VibrDestr  PROC  NEAR
VD1:       mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
           mov   bh,0        ;���� ����稪� ����७��
VD2:       in    al,dx       ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al       ;����饥 ���ﭨ�=��室����?
           jne   VD1         ;���室, �᫨ ���
           inc   bh          ;���६��� ����稪� ����७��
           cmp   bh,NMax     ;����� �ॡ����?
           jne   VD2         ;���室, �᫨ ���
           mov   al,ah       ;����⠭������� ���⮯�������� ������
           ret
VibrDestr  ENDP

CopyArr PROC NEAR
			MOV CX, 10 ;����㧪� ����稪� 横���
			LEA BX, HexArr ;����㧪� ���� ���ᨢ� ���
			LEA BP, HexTabl ;����㧪� ���� ⠡���� �८�ࠧ������
			LEA DI, DataHexArr ;����㧪� ���� ���ᨢ� ��� � ᥣ���� ������
			LEA SI, DataHexTabl ;����㧪� ���� ⠡���� �८�ࠧ������ � ᥣ���� ������
CopyArr0:
			MOV AL, CS:[BX] ;�⥭�� ���� �� ���ᨢ� � ��������
			MOV [DI], AL ;������ ���� � ᥣ���� ������/DataHexArr
			INC BX ;����䨪��� ���� HexArr
			INC DI ;����䨪��� ���� DataHexArr
			LOOP CopyArr0
			
			MOV CX, 10 ;����㧪� ����稪� 横���
CopyArr1:
			MOV AH, CS:[BP] ;�⥭�� ����᪮�� ��ࠧ� �� ⠡���� �८�ࠧ������
			MOV [SI], AH ;������ ����᪮�� ��ࠧ� � ᥣ���� ������/DataHexTabl
			INC BP ;����䨪��� ���� HexTabl
			INC SI ;����䨪��� ���� DataHexTabl
			LOOP CopyArr1
			
			MOV CX, 14 ;����㧪� ����稪� 横���
			LEA BP, Table ;����㧪� ���� ⠡���� �८�ࠧ������
			LEA SI, DataTable ;����㧪� ���� ⠡���� �८�ࠧ������ � ᥣ���� ������
CopyArr2:
			MOV AH, CS:[BP] ;�⥭�� ����᪮�� ��ࠧ� �� ⠡���� �८�ࠧ������
			MOV [SI], AH ;������ ����᪮�� ��ࠧ� � ᥣ���� ������/DataTable
			MOV AL, CS:[BP+1] ;�⥭�� ����᪮�� ��ࠧ� �� ⠡���� �८�ࠧ������
			MOV [SI+1], AL ;������ ����᪮�� ��ࠧ� � ᥣ���� ������/DataTable
			INC BP ;����䨪��� ���� Table
			INC SI ;����䨪��� ���� DataTable
			INC BP ;����䨪��� ���� Table
			INC SI ;����䨪��� ���� DataTable
			LOOP CopyArr2
			
			MOV CX, 4 ;����㧪� ����稪� 横���
			LEA BP, Err ;����㧪� ���� ⠡���� �८�ࠧ������
			LEA SI, ErrTable ;����㧪� ���� ⠡���� �८�ࠧ������ � ᥣ���� ������
CopyArr3:
			MOV AH, CS:[BP] ;�⥭�� ����᪮�� ��ࠧ� �� ⠡���� �८�ࠧ������
			MOV [SI], AH ;������ ����᪮�� ��ࠧ� � ᥣ���� ������/DataTable
			MOV AL, CS:[BP+1] ;�⥭�� ����᪮�� ��ࠧ� �� ⠡���� �८�ࠧ������
			MOV [SI+1], AL ;������ ����᪮�� ��ࠧ� � ᥣ���� ������/DataTable
			INC BP ;����䨪��� ���� Err
			INC SI ;����䨪��� ���� ErrTable
			LOOP CopyArr3
			xor bp,bp
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
			call AddSymbol
			call Simul
			call AccumulationSumm
			call SumOut
			call CntOut
			call ErrorOut
			jmp MainLoop
;����� ࠧ��頥��� ��� �ணࠬ��


;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
			org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
			ASSUME cs:NOTHING
			jmp   Far Ptr Start
Code       	ENDS
END		Start
