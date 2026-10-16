# NASM32 Menu Calculator

**Name:** Laarnie B. Pervera  
**Subject:** Computer System and Architecture  
**Activity:** Laboratory Exercise 1

## Description

A menu-driven calculator written in 32-bit NASM Assembly. It uses procedures to read input, convert numbers, and display results.

## Features

- Addition, subtraction, multiplication, and division
- Supports two-digit positive inputs
- Displays negative subtraction results
- Displays the quotient and remainder for division
- Handles division by zero
- Clears the screen and returns to the menu when Y is entered
- Terminates when N is entered

## Compile and Run

Run these commands in a Linux terminal with NASM and GNU ld installed:

```bash
nasm -f elf32 calculator.asm -o calculator.o
ld -m elf_i386 calculator.o -o calculator
./calculator
```

## How to Use

1. Select A, S, M, or D.
2. Enter the first and second numbers.
3. View the result.
4. Enter Y to calculate again or N to exit.

## Test Cases

The activity report contains three test cases per operation, screenshots of the results, and an explanation of the program.