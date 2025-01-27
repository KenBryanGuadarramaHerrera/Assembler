section .data
	nl db 0xa 

section .bss
	a resd 1

section .text
Global _start
_start:
	xor eax, eax
	xor ebx, ebx

	mov eax, 10
	push a  ; function parameter
	push eax ; function parameter

	call store_sum
	add esp, 8

	mov ecx, a
	mov eax, 4
	mov ebx, 0
	mov edx, 4
	int 0x80

	mov ecx, nl
	mov eax, 4
	mov ebx, 0
	mov edx, 1
	int 0x80

	mov eax, 1
	xor ebx, ebx
	int 0x80

store_sum:
	enter 8, 0
	mov dword[ebp-8], 0 ; sum = 0 local variable
	mov dword[ebp-4], 1	; i = 1  local variable

	for_loop:
		mov eax, [ebp-4]
		cmp eax, [ebp+8]
		jg endloop

		add [ebp-8], eax
		inc dword[ebp-4]
		jmp for_loop
	endloop:
		mov ecx, [ebp + 12] ; ecx = a
		mov eax, [ebp-8] ; eax = sum
		mov [ecx], eax 
		leave
		ret
