;---- configurations ---------------------------------------------------
[bits 32] ;output format is 32-bit code
cpu 386   ;assemble instructions up to the 386 instruction set only

;---- section unintialized data ----------------------------------------
section .bss noexec write align=4

single_sum:         resd 1
single_sub:         resd 1
single_mul:         resd 1
single_div:         resd 1
single2double:      resq 1
double_sum:         resq 1

;---- section read/write data ------------------------------------------
section .data noexec write align=4

;---- section read-only data -------------------------------------------
section .rodata noexec nowrite align=4

single_value1:      dd 12.34
single_value2:      dd 102.35
single_value3:      dd -52.02

double_value1:      dq 12.34
double_value2:      dq 102.35
double_value3:      dq -52.02

extended_value1:    dt 12.34
extended_value2:    dt 102.35
extended_value3:    dt -52.02

string_1_begin:
    db "example_11: "                             
    db "single_value1 is more than single_value2" 
    db 0aH                                        
    db 00H                                        
string_1_end:

string_2_begin:
    db "example_11: "                             
    db "single_value1 is less than single_value2" 
    db 0aH                                        
    db 00H                                        
string_2_end:

string_3_begin:
    db "example_11: "                             
    db "single_value1 is equal to single_value2"  
    db 0aH                                        
    db 00H                                        
string_3_end:

string_4_begin:
    db "example_11 ERROR! "                       
    db "st0 and source are undefined!"            
    db 0aH                                        
    db 00H                                        
string_4_end:

;---- section instruction codes ----------------------------------------
section .text exec nowrite align=16

global _start:function
_start:

.example_1:
; Coloca valores de precision simple en el stack del FPU
    finit                        ;reinicia los registros del FPU
    fld    dword [single_value1] ;push 12.34 al stack del fpu 
    fld    dword [single_value2] ;push 102.35 al stack del fpu
    fld    dword [single_value3] ;push -52.02 al stack del fpu

.example_2:
; Coloca valores de precision doble en el stack del FPU
    finit                        ;reinicia los registros del FPU
    fld    qword [double_value1] ;push 12.34 al stack del fpu 
    fld    qword [double_value2] ;push 102.35 al stack del fpu 
    fld    qword [double_value3] ;push -52.02 al stack del fpu 

.example_3:
; Coloca valores de precision doble en el stack del FPU
    finit                          ;reinicia los registros del FPU
    fld    tword [extended_value1] ;push value 12.34 to fpu stack
    fld    tword [extended_value2] ;push value 102.35 to fpu stack
    fld    tword [extended_value3] ;push value -52.02 to fpu stack

.example_4:
; Operación suma (simple + simple)
    finit                        
    fld    dword [single_value1] 
    fld    dword [single_value2] 
    fadd                         ;st0 := st1 + st0
    fstp   dword [single_sum]    ;almacena el resultado en la memoria

.example_5:
; Operación suma (simple + simple + simple)
    finit                        
    fld    dword [single_value1] 
    fld    dword [single_value2] 
    fadd                         ;st0 := st1 + st0
    fld    dword [single_value3] 
    fadd                         ;st0 := st1 + st0
    fstp   dword [single_sum]    ;almacena el resultado en la memoria

.example_6:
;Operacion suma (simple + doble + extendido) 
    finit                          
    fld    dword [single_value1]   
    fld    qword [double_value2]   
    fadd                           ;st0 := st1 + st0
    fld    tword [extended_value3] 
    fadd                           ;st0 := st1 + st0
    fstp   qword [double_sum]      ;almacena el resultado en la memoria

.example_7:
;Operacion resta (simple - simple)
    finit                        
    fld    dword [single_value1] 
    fld    dword [single_value2] 
    fsub                         ;st0 := st1 - st0
    fstp   dword [single_sub]    ;almacena el resultado en la memoria

.example_8:
;Operacion multiplicacion
    finit                        
    fld    dword [single_value1] 
    fld    dword [single_value2] 
    fmul                         ;st0 := st1 * st0
    fstp   dword [single_mul]    

.example_9:
;Operacion division (simple/simple)
    finit                        
    fld    dword [single_value1] 
    fld    dword [single_value2] 
    fdiv                         ;st0 := st1 / st0
    fstp   dword [single_div]    

.example_10:
;Pasar un valor de simple a doble
    finit                        
    fld    dword [single_value1] 
    fstp   qword [single2double] ;almacena el resultado doble en la memoria

.example_11:
;Compara numeros dos numeros flotantes y determina el mayor
    finit                         
    fld    dword [single_value2]  
    fld    dword [single_value1]  
    fcom   st0, st1               ;compara st0 con st1
    fstsw  ax                     ;ax := registro de estado del fpu

    and    eax, 0100011100000000B ;toma solo las banderas(bits) de condiciones
    cmp    eax, 0000000000000000B ;es st0 > source ?
    je     .example_11_greater
    cmp    eax, 0000000100000000B ;es st0 < source ?
    je     .example_11_less
    cmp    eax, 0100000000000000B ;es st0 = source ?
    je     .example_11_equal
    jmp    .example_11_error      ;else, st0 or source son indefinidos

.example_11_greater:
    mov    ecx, string_1_begin                  
    mov    edx, (string_1_end - string_1_begin) 
    jmp    .example_11_write

.example_11_less:
    mov    ecx, string_2_begin                  
    mov    edx, (string_2_end - string_2_begin) 
    jmp    .example_11_write

.example_11_equal:
    mov    ecx, string_3_begin                  
    mov    edx, (string_3_end - string_3_begin) 
    jmp    .example_11_write

.example_11_error:
    mov    ecx, string_4_begin                  
    mov    edx, (string_4_end - string_4_begin) 

.example_11_write:
    mov    eax, 04H 
    mov    ebx, 01H
    int    80H

.exit:
    mov    eax, 01H 
    mov    ebx, 00H 
    int    80H