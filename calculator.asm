BITS 32
GLOBAL _start

SECTION .data
    cls db 27, '[2J', 27, '[H', 0

    menu db '----------------------------------',10
         db '              MENU',10
         db '[A]dd',10
         db '[S]ubtract',10
         db '[M]ultiply',10
         db '[D]ivide',10
         db '----------------------------------',10,0

    choice db 'Enter your choice: ',0
    first db 'Enter first number: ',0
    second db 'Enter second number: ',0
    sum db 'The sum is ',0
    diff db 'The difference is ',0
    product db 'The product is ',0
    quotient db 'The quotient is ',0
    remainder db 'The remainder is ',0
    again db 10,'Do you want to try again (Y/N): ',0
    zero_error db 'Error: cannot divide by zero.',10,0
    newline db 10,0
    goodbye db 10,'Program terminated.',10,0

SECTION .bss
    input resb 64
    output resb 16
    num1 resd 1
    num2 resd 1

SECTION .text

_start:

menu_loop:
    mov esi, cls
    call print

    mov esi, menu
    call print

    mov esi, choice
    call print
    call read

    mov al, [input]
    or al, 32

    cmp al, 'a'
    je addition

    cmp al, 's'
    je subtraction

    cmp al, 'm'
    je multiplication

    cmp al, 'd'
    je division

    jmp ask_again


addition:
    call get_numbers

    mov eax, [num1]
    add eax, [num2]
    mov [num1], eax

    mov esi, sum
    call print

    mov eax, [num1]
    call print_number

    jmp ask_again


subtraction:
    call get_numbers

    mov eax, [num1]
    sub eax, [num2]
    mov [num1], eax

    mov esi, diff
    call print

    mov eax, [num1]
    call print_number

    jmp ask_again


multiplication:
    call get_numbers

    mov eax, [num1]
    imul eax, [num2]
    mov [num1], eax

    mov esi, product
    call print

    mov eax, [num1]
    call print_number

    jmp ask_again


division:
    call get_numbers

    cmp dword [num2], 0
    je divide_error

    mov eax, [num1]
    cdq
    idiv dword [num2]

    mov [num1], eax
    push edx

    mov esi, quotient
    call print

    mov eax, [num1]
    call print_number

    mov esi, remainder
    call print

    pop eax
    call print_number

    jmp ask_again


divide_error:
    mov esi, zero_error
    call print
    jmp ask_again


get_numbers:
    mov esi, first
    call print
    call read

    mov esi, input
    call to_number
    mov [num1], eax

    mov esi, second
    call print
    call read

    mov esi, input
    call to_number
    mov [num2], eax

    ret


ask_again:
    mov esi, again
    call print
    call read

    mov al, [input]
    or al, 32

    cmp al, 'y'
    je menu_loop

    mov esi, goodbye
    call print

    mov eax, 1
    xor ebx, ebx
    int 80h


; ---------------------------------
; Print a null-terminated string
; Address of string must be in ESI
; ---------------------------------

print:
    push esi
    xor edx, edx

count:
    cmp byte [esi + edx], 0
    je write

    inc edx
    jmp count

write:
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    int 80h

    pop esi
    ret


; ---------------------------------
; Read keyboard input
; ---------------------------------

read:
    mov eax, 3
    xor ebx, ebx
    mov ecx, input
    mov edx, 63
    int 80h

    mov edi, input
    add edi, eax
    mov byte [edi], 0

    mov edi, input

remove_newline:
    cmp byte [edi], 10
    je finish_read

    cmp byte [edi], 0
    je finish_read

    inc edi
    jmp remove_newline

finish_read:
    mov byte [edi], 0
    ret


; ---------------------------------
; Convert ASCII number to integer
; ---------------------------------

to_number:
    xor eax, eax

convert:
    movzx ebx, byte [esi]

    cmp bl, 0
    je converted

    sub ebx, '0'
    imul eax, 10
    add eax, ebx

    inc esi
    jmp convert

converted:
    ret


; ---------------------------------
; Print signed integer in EAX
; ---------------------------------

print_number:
    mov edi, output + 15
    mov byte [edi], 0
    dec edi

    test eax, eax
    jnz not_zero

    mov byte [edi], '0'
    mov esi, edi
    jmp show_number


not_zero:
    xor ebx, ebx

    cmp eax, 0
    jge convert_number

    neg eax
    mov ebx, 1


convert_number:
    mov ecx, 10

next_digit:
    xor edx, edx
    div ecx

    add dl, '0'
    mov [edi], dl
    dec edi

    test eax, eax
    jnz next_digit

    cmp ebx, 1
    jne positive

    mov byte [edi], '-'
    dec edi


positive:
    inc edi
    mov esi, edi


show_number:
    call print

    mov esi, newline
    call print

    ret