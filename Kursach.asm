.386
;������ ���� ��� � �����
RomSize    EQU   4096

DisplayPort = 2
DisplayPowerPort = 1
KbdPort = 0
NMax = 100

IntTable   SEGMENT use16 AT 0
;����� ࠧ������� ���� ��ࠡ��稪�� ���뢠���
IntTable   ENDS

Data       SEGMENT use16 AT 40h
;����� ࠧ������� ���ᠭ�� ��६�����
DataHexArr db 10 dup(?) 
DataHexTabl db 10 dup(?)
DataTable dd 7 dup(?)
Res db 7 dup (?)
SelectedNumber DD ?
OldButton db    ?
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT use16 AT 00FFh
;������ ����室��� ࠧ��� �⥪�
           dw    16 dup (?)
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

KeyRead    PROC  Near ;�⥭�� ������
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
           jz    m1   ;�᫨ ��� ᨬ����� ��� ���������� (�� ����� �� ���� �� ������)
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
            mov   al,ah               ;⥯��� � al ����� ���
            xlat
		    not al		   ;⠡��筮� �८�ࠧ������ ���襩 ����
            out   DisplayPort, al    ;�뢮��� �� ���訩 ��������
            mov   al, 01h            
            out   DisplayPowerPort, al    ;�������� ���訩 ��������    
            mov   al,00h             
            out   DisplayPowerPort, al    ;��ᨬ ��������
		    mov   ah, Res+1       ;����㦠�� � ॣ�����
            mov   al, ah              ;⥪�饥 ���祭�� �㬬�                 
            xlat
		    not al         ;⠡��筮� �८�ࠧ������ ����襩 ����
            out   DisplayPort, al    ;�뢮��� �� ����訩 ��������            
            mov   al, 02h            
            out   DisplayPowerPort, al    ;�������� ����訩 ��������
            mov   al,00h
            out   DisplayPowerPort, al    ;��ᨬ ��������
		    mov   ah, Res+2       ;����㦠�� � ॣ�����
            mov   al, ah              ;⥪�饥 ���祭�� �㬬�                 
            xlat
		    not al         ;⠡��筮� �८�ࠧ������ ����襩 ����
            out   DisplayPort, al    ;�뢮��� �� ����訩 ��������            
            mov   al, 04h            
            out   DisplayPowerPort, al    ;�������� ����訩 ��������
            mov   al,00h
            out   DisplayPowerPort, al    ;��ᨬ ��������
		    mov   ah, Res+3       ;����㦠�� � ॣ�����
            mov   al, ah              ;⥪�饥 ���祭�� �㬬�                 
            xlat
		    not al         ;⠡��筮� �८�ࠧ������ ����襩 ����
            out   DisplayPort, al    ;�뢮��� �� ����訩 ��������            
            mov   al, 08h            
            out   DisplayPowerPort, al    ;�������� ����訩 ��������
            mov   al,00h
            out   DisplayPowerPort, al    ;��ᨬ ��������
		    mov   ah, Res+4       ;����㦠�� � ॣ�����
            mov   al, ah              ;⥪�饥 ���祭�� �㬬�                 
            xlat
		    not al         ;⠡��筮� �८�ࠧ������ ����襩 ����
            out   DisplayPort, al    ;�뢮��� �� ����訩 ��������            
            mov   al, 020h            
            out   DisplayPowerPort, al    ;�������� ����訩 ��������
            mov   al,00h
            out   DisplayPowerPort, al    ;��ᨬ ��������
			mov   ah, Res+5       ;����㦠�� � ॣ�����
            mov   al, ah              ;⥪�饥 ���祭�� �㬬�                 
            xlat
		    not al         ;⠡��筮� �८�ࠧ������ ����襩 ����
            out   DisplayPort, al    ;�뢮��� �� ����訩 ��������            
            mov   al, 010h            
            out   DisplayPowerPort, al    ;�������� ����訩 ��������
            mov   al,00h
            out   DisplayPowerPort, al    ;��ᨬ ��������
		    xor ah, ah
            ret
SumOut     ENDP

CopyArr PROC
			MOV CX, 10 ;����㧪� ����稪� 横���
			LEA BX, HexArr ;����㧪� ���� ���ᨢ� ���
			LEA BP, HexTabl ;����㧪� ���� ⠡���� �८�ࠧ������
			LEA DI, DataHexArr ;����㧪� ���� ���ᨢ� ��� � ᥣ���� ������
			LEA SI, DataHexTabl ;����㧪� ���� ⠡���� �८�ࠧ������ � ᥣ���� ������
M0:
			MOV AL, CS:[BX] ;�⥭�� ���� �� ���ᨢ� � ��������
			MOV [DI], AL ;������ ���� � ᥣ���� ������/DataHexArr
			INC BX ;����䨪��� ���� HexArr
			INC DI ;����䨪��� ���� DataHexArr
			LOOP M0
			
			MOV CX, 10 ;����㧪� ����稪� 横���
M1:
			MOV AH, CS:[BP] ;�⥭�� ����᪮�� ��ࠧ� �� ⠡���� �८�ࠧ������
			MOV [SI], AH ;������ ����᪮�� ��ࠧ� � ᥣ���� ������/DataHexTabl
			INC BP ;����䨪��� ���� HexTabl
			INC SI ;����䨪��� ���� DataHexTabl
			LOOP M1
			xor bp,bp
			
			MOV CX, 14 ;����㧪� ����稪� 横���
			LEA BP, Table ;����㧪� ���� ⠡���� �८�ࠧ������
			LEA SI, DataTable ;����㧪� ���� ⠡���� �८�ࠧ������ � ᥣ���� ������
M2:
			MOV AH, CS:[BP] ;�⥭�� ����᪮�� ��ࠧ� �� ⠡���� �८�ࠧ������
			MOV [SI], AH ;������ ����᪮�� ��ࠧ� � ᥣ���� ������/DataTable
			MOV AL, CS:[BP+1] ;�⥭�� ����᪮�� ��ࠧ� �� ⠡���� �८�ࠧ������
			MOV [SI+1], AL ;������ ����᪮�� ��ࠧ� � ᥣ���� ������/DataTable
			INC BP ;����䨪��� ���� Table
			INC SI ;����䨪��� ���� DataTable
			INC BP ;����䨪��� ���� Table
			INC SI ;����䨪��� ���� DataTable
			LOOP M2
			xor bp,bp
			ret
CopyArr ENDP

VibrDestr  PROC  NEAR
VD1:        mov   ah,al       ;���࠭���� ��室���� ���ﭨ�
            mov   bh,0        ;���� ����稪� ����७��
VD2:        in    al,dx       ;���� ⥪�饣� ���ﭨ�
            cmp   ah,al       ;����饥 ���ﭨ�=��室����?
            jne   VD1         ;���室, �᫨ ���
            inc   bh          ;���६��� ����稪� ����७��
            cmp   bh,NMax     ;����� �ॡ����?
            jne   VD2         ;���室, �᫨ ���
            mov   al,ah       ;����⠭������� ���⮯�������� ������
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
;����� ࠧ��頥��� ��� �ணࠬ��


;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((InitDataEnd-InitDataStart+15) AND 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END		Start
