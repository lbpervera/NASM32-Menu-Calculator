# NASM32 Menu Calculator

## Program features

- `A` adds two numbers.
- `S` subtracts the second number from the first.
- `M` multiplies two numbers.
- `D` performs integer division and displays both quotient and remainder.
- Accepts one-digit and two-digit values, including negative values.
- Clears the terminal before returning to the menu.
- Repeats when the user enters `Y`; terminates for any response other than `Y`.
- Prevents division by zero.

## Build and run on Linux

```bash
nasm -f elf32 calculator.asm -o calculator.o
ld -m elf_i386 calculator.o -o calculator
./calculator
```

If your computer uses Windows NASM32, assemble the file using the 32-bit linker supplied by your class environment. The source uses Linux `int 0x80` system calls, so it must be run in Linux, WSL, or the Linux environment provided by your instructor.

## How the program works

1. `_start` calls `clear_screen`, prints the menu, and reads the user's operation.
2. The selected letter jumps to one of four procedures: `do_add`, `do_subtract`, `do_multiply`, or `do_divide`.
3. `get_two_numbers` displays both prompts. `read_line` stores keyboard input in `input_buffer`, while `atoi` converts the ASCII digits into an integer.
4. The selected operation uses the values stored in `first_number` and `second_number`. The answer is stored in `result`.
5. `print_int` converts the binary integer result back to decimal characters and displays it.
6. Division uses `idiv`. The quotient is placed in `EAX` and the remainder in `EDX`, so the program prints both values.
7. `ask_again` reads `Y` or `N`. `Y` jumps to `main_loop`, which clears the screen and displays the menu again. Any other answer ends the program.

## Important registers

| Register | Use |
|---|---|
| `EAX` | Arithmetic result, system-call number, and integer conversion result |
| `EBX` | File descriptor or temporary sign flag |
| `ECX` | Buffer address, divisor, or digit counter |
| `EDX` | Number of bytes, division remainder, or temporary digit |
| `ESI` | Address of a string or input buffer |
| `EDI` | Buffer scanning and output position |

## Suggested test cases for screenshots

Take one screenshot for each row. The screenshots should show the selected operation, both inputs, the result, and the `Do you want to try again (Y/N)` prompt.

### Addition — 3 tests

| Test | Choice | First | Second | Expected output |
|---|---|---:|---:|---|
| A1 | A | 2 | 3 | `The sum is 5` |
| A2 | A | 12 | 34 | `The sum is 46` |
| A3 | A | -8 | 15 | `The sum is 7` |

### Subtraction — 3 tests

| Test | Choice | First | Second | Expected output |
|---|---|---:|---:|---|
| S1 | S | 9 | 4 | `The difference is 5` |
| S2 | S | 45 | 18 | `The difference is 27` |
| S3 | S | 12 | 25 | `The difference is -13` |

### Multiplication — 3 tests

| Test | Choice | First | Second | Expected output |
|---|---|---:|---:|---|
| M1 | M | 4 | 5 | `The product is 20` |
| M2 | M | 12 | 11 | `The product is 132` |
| M3 | M | -6 | 7 | `The product is -42` |

### Division — 3 tests

| Test | Choice | First | Second | Expected output |
|---|---|---:|---:|---|
| D1 | D | 8 | 2 | `The quotient is 4`, `The remainder is 0` |
| D2 | D | 25 | 4 | `The quotient is 6`, `The remainder is 1` |
| D3 | D | 99 | 10 | `The quotient is 9`, `The remainder is 9` |

### Optional error-handling screenshot

Test `D`, first number `10`, second number `0`. The program should display:

```text
Error: division by zero is not allowed.
```

## Submission checklist

- Submit `calculator.asm`.
- Include the explanation in `README.md` or copy it into your documentation.
- Include 12 screenshots: 3 addition, 3 subtraction, 3 multiplication, and 3 division.
- Include the optional division-by-zero screenshot for extra evidence of validation.
