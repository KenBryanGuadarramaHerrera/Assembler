;; c^2 = a^2 + b^2 - cos(C)*2*a*b
;; C is stored in ang

global _start

section .data
    a: dq 4.56   ;length of side a
    b: dq 7.89   ;length of side b
    ang: dq 1.5  ;opposite angle to side c (around 85.94 degrees)

section .bss
    c: resq 1    ;the result ‒ length of side c

section .text
    _start:

    fld    qword [a]   ;load a into st0
    fmul   st0, st0    ;st0 = a * a = a^2

    fld    qword [b]   ;load b into st0   (pushing the a^2 result up to st1)
    fmul   st0, st0    ;st0 = b * b = b^2,   st1 = a^2

    faddp              ;add and pop, leaving st0 = old_st0 * old_st1 = a^2 + b^2.  (st1 is freed / empty now)

    fld    qword [ang] ;load angle into st0.  (st1 = a^2 + b^2 which we'll leave alone until later)
    fcos               ;st0 = cos(ang)

    fmul   qword [a]   ;st0 = cos(ang) * a
    fmul   qword [b]   ;st0 = cos(ang) * a * b
    fadd   st0, st0    ;st0 = cos(ang) * a * b + cos(ang) * a * b = 2(cos(ang) * a * b)

    fsubp  st1, st0    ;st1 = st1 - st0 = (a^2 + b^2) - (2 * a * b * cos(ang))
                       ;and pop st0

    fsqrt              ;take square root of st0 = c

    fstp   qword [c]   ;store st0 in c and pop, leaving the x87 stack empty again ‒ and we're done!

    ; don't forget to make an exit system call for your OS,
    ; or execution will fall off the end and decode whatever garbage bytes are next.
    mov   eax, 1                ; __NR_exit
    xor   ebx, ebx
    int   0x80                  ; i386 Linux sys_exit(0)
    ;end program