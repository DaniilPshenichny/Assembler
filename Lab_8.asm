.model small  
.stack 100h
.data

isEmpty dw 0

data_size dw $-data             ; ����� ������ ������

.code
old_int dd 0                    ;����� ������� �����������

new_handler proc far

    cli                           ;��������� ����������
    pushf                          
    push ax                       
    in al, 21h                    ;������ ����� ������� 
    and al, 10111111b             ;��������� ���������� ����������
    out 21h, al                   ;���������� ����� �������
    pop ax
    call dword ptr cs:[old_int]   ;�������� ������ ����������
    pusha                         ;�������� � ���� �������� ������ ����������

    push ds 
    push es
    
    mov ax, @data
    mov es, ax
    mov ax, 0B800h
    mov ds, ax
        
    xor si, si
        
mainLoop1:
    cmp si, 4000                 ; ���������� ������ � ��������� ���������
    je continue                  ; ���� ��� �������, �� ��� ������� ������ ��� ����
    
    inc si
    
    mov al, ds:[si]              ; ��������� � al ������ � ������� ������ ds:[si]
    cmp al, 4
    je colorPrev
    
afterColorPrev:    
    
    inc si                       ;����������� SI �� 2, �.�. ���������� ��������      
    jmp mainLoop1
    
colorPrev:
    
    mov ds:[si], 7
    jmp afterColorPrev   
  
continue: 
 
    xor si, si                   ; DS:SI ����� ��������� �� �����
    
mainLoop:
    cmp si, 4000                 ; ���������� ������ � ��������� ���������
    je letsColorIt               ; ���� ��� �������, �� ��� ������� ������ ��� ����

    mov al, ds:[si]              ; ��������� � al ������ � ������� ������ ds:[si]

    cmp al, '('
    je addToStack1

    cmp al, '{'
    je addToStack2

    cmp al, '['
    je addToStack3

    cmp al, ')'
    je closeBracket

    cmp al, '}'
    je closeBracket

    cmp al, ']'
    je closeBracket

afterAddToStackAndOrCloseBracket:
    
    inc si                       ;����������� SI �� 2, �.�. ���������� ��������      
    inc si
    jmp mainLoop

addToStack1:
    
    push si                      ; ��������� ����������
    mov al, ')'
    push ax                      ; ��������� ������
    
    mov bx, isEmpty              ;
    inc bx                       ; ��������� ������� ������ �� 1
    mov isEmpty, bx              ;

    jmp afterAddToStackAndOrCloseBracket

addToStack2:
    
    push si                      ; ��������� ����������
    mov al, '}'
    push ax                      ; ��������� ������
    
    mov bx, isEmpty              ;
    inc bx                       ; ��������� ������� ������ �� 1
    mov isEmpty, bx              ;

    jmp afterAddToStackAndOrCloseBracket   

addToStack3:
    
    push si                      ; ��������� ����������
    mov al, ']'
    push ax                      ; ��������� ������
    
    mov bx, isEmpty              ;
    inc bx                       ; ��������� ������� ������ �� 1
    mov isEmpty, bx              ;

    jmp afterAddToStackAndOrCloseBracket     

closeBracket:

    mov bx, isEmpty              ; 
    cmp bx, 0                    ; ���� ����������� ������ ���
    je colorCloseBracket         ; �� ������ ����������� ������ ��� ���� => ������������ � ������� ������

    pop bx                       ; ��������� ������ ��������� ������
    cmp bl, al                   ; ���������� ������ ��������� ����������� ������
    jne resetStack               ; ���� ������� ������ �� �������, �� ���������� ������, ����������� �� �����, ������� � ���� � ������ ������� ������ � ������� ����

    mov bx, isEmpty              ; 
    dec bx                       ; � ��������� ������ ��������� ���������� �������� �� 1
    mov isEmpty, bx              ; 

    pop bx                       ; ������� �� ����� ���������� ����������� ������

    jmp afterAddToStackAndOrCloseBracket

resetStack:

    push bx                      ; ���������� ������� ������ ����������� ������

    inc si                       ;
    mov ds:[si], 4               ; �������� ���� ������ �� �������
    dec si                       ;

    push si 					 ; ��������� ���������� ������� ������

    cmp al, ')'					 ; ���� ��� �� ����������� ������� ������
	jne otherBrackets			 ; �� ������� �� �����, �� ������� �� ������� ��� ���������� ��� �������� ������ ����������� (')' - 1 = '(')

	sub al, 1					 ; � ��������� ������ ������ � ����������� ������� �������
	jmp pushMe					 ; ������� �� �����, ��� �������� � ������

otherBrackets:

	sub al, 2					 ; ']' - 2 = '['

pushMe:

    push ax				         ; ��������� ������ ���� ������

    mov bx, isEmpty              ;
    inc bx                       ; ��������� ������� ������ �� 1
    mov isEmpty, bx              ;

    jmp afterAddToStackAndOrCloseBracket

colorCloseBracket:
	
    inc si                       ;
    mov ds:[si], 4               ; �������� ���� ������ �� �������
    dec si                       ;  

    jmp afterAddToStackAndOrCloseBracket

letsColorIt:
    
    mov bx, isEmpty

colorLoop:

    cmp bx, 0
    je end_handler

    pop si                       ; �������� ���������� ����������� ������������� ������ �� �����
    pop si

    inc si                       ; ����� �� ������� �������
    mov ds:[si], 4               ; �������� ���� ������ �� �������

    dec bx

    jmp colorLoop
 
end_handler:
    
    mov isEmpty, bx

    pop es 
    pop ds

    popa   
    sti                           ;��������� ����������
    iret                          ;������� ��������� IP �� �����, ����� CS, � � ����� ������� ������ (������� �� �������� ����� ��� popf)

new_handler endp

start:

    mov ax, @data
    mov ds, ax
    
    mov ah, 35h                     ;������� ���������� ������� ����������
    mov al, 09h
    int 21h                         ;�� ������ ES:BX - ����� ����������� ����������
    mov word ptr cs:[old_int], bx   ;���������� ��� ����������
    mov word ptr cs:[old_int+2], es
    mov ah, 25h                     ;������� ��������� ������ �����������
    mov al, 09h                     ;����� ����������
    push cs                         ;������������� ����� ���������� ���������� 09h
    pop ds                          ;�������� � DS CS (�������������� ������� ��� ������ ������ �����������)
    mov dx, offset new_handler      ;�������� ������ �����������
    int 21h                         ;DS:DX - ����� ������ �����������
    
    mov ah, 31h                     ;�������, ������� ��������� ��������� �����������
    mov al, 00h                     ;��� ������
    mov dx, (code_size / 16) + (data_size / 16) + 16 + 16 + 2 ;(������ � 16-������� ���������) = ������ ���� + ������ ������ + ������ ������ + ������ PSP + 1 �������� ��� ���������� code_size, data_size     
    int 21h 
    
code_size dw $-code                 ; ����� ������ ����
end start p