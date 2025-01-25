# Stack CPU for the Nexys A7 FPGA
A SystemVerilog implementation of a simple stack based CPU made for the Nexys A7 FPGA

Made as part of the "SystemVerilog and FPGA Programming" course at Portland State University, instructed by Roy Kravitz during Fall 2024. Uses reverse polish notation for arithmetic and logic operations.

Utilizes Clock IP as well as memory IP to load program instructions from a .coe file

## Example CPU program running on nexysA7 FPGA:
The current Instruction number is displayed on the right
Note that negative values are indicated by the "." on the seven segment display for the MSB being illuminated.
By default the display will show the current value on the top of the stack. Flipping the left most switch will swap the display to hexadecimal

https://github.com/user-attachments/assets/c915bb03-5c1a-43e0-8a53-18807ffeace3

Program memory used in example:
```
00000_0_0000010111 // PUSH_IMMEDIATE 23                  Result Stack: 23
00000_0_0000000011 // PUSH_IMMEDIATE 3                   Result Stack: 3 23
00000_0_0000001101 // PUSH_IMMEDIATE 13                  Result Stack: 13 3 23
00000_0_0000001000 // PUSH_IMMEDIATE 8                   Result Stack: 8 13 3 23
00000_0_1000001100 // PUSH_IMMEDIATE -500                Result Stack: -500 8 13 3 23
00000_0_0000001100 // PUSH_IMMEDIATE 12                  Result Stack: 12 -500 8 13 3 23
00000_0_0000100110 // PUSH_IMMEDIATE 38                  Result Stack: 38 12 -500 8 13 3 23
00001_0_0000000000 // ADD                   12 + 38      Result Stack: 50 -500 8 13 3 23
00100_0_0000000000 // DIV                   -500 / 50    Result Stack: -10 8 13 3 23
00000_0_0000000000 // PUSH_IMMEDIATE 0                   Result Stack: 0 -10 8 13 3 23
00011_0_0000000000 // MUL                   -10 * 0      Result Stack: 0 8 13 3 23
01000_0_0000000000 // INVERT                Bit flip     Result Stack: -1 8 13 3 23
00010_0_0000000000 // SUB                   8 - (-1)     Result Stack: 9 13 3 23
00101_0_0000000000 // MOD                   13 % 9       Result Stack: 4 3 23
00011_0_0000000000 // MUL                   3 * 4        Result Stack: 12 23
00111_0_0000000000 // OR                    23 OR 12     Result Stack: 31
00000_0_0100001111 // PUSH_IMMEDIATE 271                 Result Stack: 271 31	
00110_0_0000000000 // AND                   31 AND 271   Result Stack: 15
11111_0_0000000000 // HALT_CPU
```

## Instruction Information
Instruction Format: `<Opcode (5 bits)>`\_`0`\_`<Immediate Value/Data (11 bits)>`

| **Opcode**       | **Binary (5 bits)** | **Description**                                                                                           |
|------------------|---------------------|-----------------------------------------------------------------------------------------------------------|
| `PUSH_IMMEDIATE` | `00000`            | Push immediate value onto the top of the stack                                                            |
| `ADD`            | `00001`            | Pop top two stack elements, add them, and push the result                                                 |
| `SUB`            | `00010`            | Pop top two stack elements, subtract (second from top - top), and push the result                         |
| `MUL`            | `00011`            | Pop top two stack elements, multiply them, and push the result                                            |
| `DIV`            | `00100`            | Pop top two stack elements, divide (second from top ÷ top), and push the result                           |
| `MOD`            | `00101`            | Pop top two stack elements, take (second from top % top), and push the result                             |
| `AND`            | `00110`            | Pop top two stack elements and perform a bitwise AND, then push the result                                |
| `OR`             | `00111`            | Pop top two stack elements and perform a bitwise OR, then push the result                                 |
| `INVERT`         | `01000`            | Pop top of stack and perform a bitwise INVERT, then push the result                                       |
| `HALT_CPU`       | `11111`            | Halts the CPU until reset is asserted                                                                     |
