; NASM32 command-line calculator
; Linux 32-bit system calls (int 0x80)
; Features: add, subtract, multiply, divide, two-digit input,
;           repeat loop, clear screen, and divide-by-zero protection.

BITS 32
GLOBAL _start

SECTION .data
    clear_seq       db 27, '[2J', 27, '[H'
    clear_len       equ $ - clear_seq

    menu            db '----------------------------------', 10
                    db '              MENU', 10
                    db '[A]dd', 10
                    db '[S]ubtract', 10
                    db '[M]ultiply', 10
                    db '[D]ivide', 10
                    db '----------------------------------', 10, 0
    choice_msg      db 'Enter your choice: ', 0
    first_msg       db 'Enter first number: ', 0
    second_msg      db 'Enter second number: ', 0
    sum_msg         db 'The sum is ', 0
    difference_msg  db 'The difference is ', 0
    product_msg     db 'The product is ', 0
    quotient_msg    db 'The quotient is ', 0
    remainder_msg   db 'The remainder is ', 0
    again_msg       db 10, 'Do you want to try again (Y/N): ', 0
    invalid_choice  db 10, 'Invalid choice. Please select A, S, M, or D.', 10, 0
    invalid_number  db 10, 'Please enter a valid number.', 10, 0
    divide_zero     db 10, 'Error: division by zero is not allowed.', 10, 0
    newline         db 10, 0
    goodbye         db 10, 'Program terminated. Goodbye!', 10, 0

SECTION .bss
    input_buffer    resb 64
    first_number    resd 1
    second_number   resd 1
    result          resd 1

SECTION .text

_start:
main_loop:
    call clear_screen
    mov esi, menu
    call print_string

    mov esi, choice_msg
    call print_string
    call read_line
    mov al, [input_buffer]
    or al, 32                 ; Convert uppercase ASCII to lowercase.

    cmp al, 'a'
    je do_add
    cmp al, 's'
    je do_subtract
    cmp al, 'm'
    je do_multiply
    cmp al, 'd'
    je do_divide

    mov esi, invalid_choice
    call print_string
    jmp ask_again

do_add:
    call get_two_numbers
    jc ask_again
    mov eax, [first_number]
    add eax, [second_number]
    mov [result], eax
    mov esi, sum_msg
    call print_string
    mov eax, [result]
    call print_int
    call print_newline
    jmp ask_again

do_subtract:
    call get_two_numbers
    jc ask_again
    mov eax, [first_number]
    sub eax, [second_number]
    mov [result], eax
    mov esi, difference_msg
    call print_string
    mov eax, [result]
    call print_int
    call print_newline
    jmp ask_again

do_multiply:
    call get_two_numbers
    jc ask_again
    mov eax, [first_number]
    imul eax, [second_number]
    mov [result], eax
    mov esi, product_msg
    call print_string
    mov eax, [result]
    call print_int
    call print_newline
    jmp ask_again

do_divide:
    call get_two_numbers
    jc ask_again
    cmp dword [second_number], 0
    je division_by_zero

    mov eax, [first_number]
    cdq                        ; Sign-extend EAX into EDX:EAX.
    idiv dword [second_number]
    mov [result], eax
    push edx                   ; Save remainder while printing quotient.
    mov esi, quotient_msg
    call print_string
    mov eax, [result]
    call print_int
    call print_newline
    mov esi, remainder_msg
    call print_string
    pop eax
    call print_int
    call print_newline
    jmp ask_again

division_by_zero:
    mov esi, divide_zero
    call print_string
    jmp ask_again

; Reads first and second integers. CF=1 means invalid input.
get_two_numbers:
    mov esi, first_msg
    call print_string
    call read_line
    mov esi, input_buffer
    call atoi
    jc number_error
    mov [first_number], eax

    mov esi, second_msg
    call print_string
    call read_line
    mov esi, input_buffer
    call atoi
    jc number_error
    mov [second_number], eax
    clc
    ret

number_error:
    mov esi, invalid_number
    call print_string
    stc
    ret

; Print a null-terminated string pointed to by ESI.
print_string:
    pushad
    mov edi, esi
    xor ecx, ecx
.find_end:
    cmp byte [edi + ecx], 0
    je .write
    inc ecx
    jmp .find_end
.write:
    mov eax, 4                 ; sys_write
    mov ebx, 1                 ; stdout
    mov edx, ecx
    mov ecx, edi
    int 0x80
    popad
    ret

print_newline:
    mov esi, newline
    jmp print_string

; Read up to 63 characters, then replace LF/CR with a null terminator.
read_line:
    pushad
    mov eax, 3                 ; sys_read
    mov ebx, 0                 ; stdin
    mov ecx, input_buffer
    mov edx, 63
    int 0x80
    mov edi, input_buffer
    add edi, eax
    mov byte [edi], 0
    mov edi, input_buffer
.scan:
    cmp byte [edi], 0
    je .done
    cmp byte [edi], 10
    je .terminate
    cmp byte [edi], 13
    je .terminate
    inc edi
    jmp .scan
.terminate:
    mov byte [edi], 0
.done:
    popad
    ret

; Convert a signed decimal string at ESI to EAX. CF=1 if invalid.
atoi:
    push ebx
    push ecx
    push edx
    push edi
    xor eax, eax
    xor ecx, ecx               ; ECX = negative flag
    mov bl, [esi]
    cmp bl, '-'
    jne .digits
    inc esi
    mov cl, 1
.digits:
    mov bl, [esi]
    cmp bl, 0
    je .finish
    cmp bl, '0'
    jb .bad
    cmp bl, '9'
    ja .bad
    imul eax, eax, 10
    movzx edx, bl
    sub edx, '0'
    add eax, edx
    inc esi
    jmp .digits
.finish:
    cmp ecx, 1
    jne .valid
    neg eax
.valid:
    clc
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
.bad:
    stc
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret

; Print signed integer in EAX.
print_int:
    pushad
    mov edi, input_buffer + 63
    mov byte [edi], 0
    dec edi
    cmp eax, 0
    jne .not_zero
    mov byte [edi], '0'
    mov esi, edi
    jmp .write
.not_zero:
    xor ebx, ebx
    cmp eax, 0
    jge .convert
    neg eax
    mov ebx, 1
.convert:
    mov ecx, 10
.next_digit:
    xor edx, edx
    div ecx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .next_digit
    cmp ebx, 1
    jne .positive
    mov byte [edi], '-'
    dec edi
.positive:
    inc edi
    mov esi, edi
.write:
    call print_string
    popad
    ret

clear_screen:
    mov esi, clear_seq
    jmp print_string

ask_again:
    mov esi, again_msg
    call print_string
    call read_line
    mov al, [input_buffer]
    or al, 32
    cmp al, 'y'
    je main_loop

    mov esi, goodbye
    call print_string
    mov eax, 1                 ; sys_exit
    xor ebx, ebx
    int 0x80
