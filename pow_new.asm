section .data
	nl db 0xa 
	msg1 db "El resultado es: "
	len1 equ $-msg1
section .bss
	a resb 2
	b resb 2
	result resb 4

section .text
global _start
_start:
	
	read_number:
	mov eax, 3
	mov ebx, 1
	mov ecx, a
	mov edx, 2	
	int 0x80

	read_pow:
	mov eax, 3
	mov ebx, 1
	mov ecx, b
	mov edx, 2	
	int 0x80

	movzx eax, byte[a]
	sub eax, '0'
	movzx ebx, byte[b]
	sub ebx, '0'
	push eax
	push ebx
	call pow
	add esp, 8
	
	call print
	call print_nl

	mov eax, 1
	mov ebx, 0
	int 0x80

	print:
	push eax
	mov esi, result ; se obtiene dirección de almacenamiento

	mov eax, 4
	mov ebx, 0
	mov ecx, msg1
	mov edx, len1
	int 0x80

	pop eax
    call int_to_str
    
    mov ecx, eax
	mov eax, 4
	mov ebx, 0
	mov edx, 4
	int 0x80
	ret

	print_nl:
		mov eax, 4
		mov ebx, 0
		mov ecx, nl
		mov edx, 1
		int 0x80
		ret	

	pow:
		push ebp
		mov ebp, esp

		mov ecx, [ebp + 8] ; ecx = a
		mov ebx, [ebp + 12] ; ebx = b
		mov eax, 1
	
		while:
		cmp ecx, 0
		je endwhile
		imul ebx
		dec ecx
		jmp while
	
		endwhile:
		mov esp, ebp
		pop ebp
		ret

	int_to_str:
        push ebp
        mov ebp, esp
        add esi, 4 
        mov byte[esi], 0
        mov ebx, 10 
        .next_digit:
            xor edx, edx 
            div ebx 
            add dl, '0' 
            dec esi 
            mov[esi], dl
            cmp eax, 0 
            jnz .next_digit
            mov eax, esi
        mov esp, ebp
        pop ebp
        ret