# SMP8
An implementation of a simple 8-bit microprocessor for UNLV CpE 300L Digital Systems Architecture and Design final project.
## Overview
For the CpE 300L final project, a simple 8-bit microprocessor (SMP8) was designed and tested. The SMP8 is an 8-bit microprocessor (instructions and data are 8-bit lengths). SMP8 has one 8-bit general purpose register, R, and an 8-bit Accumulator Register, AC. The result of the arithmetic operation is to be automatically loaded into the AC register. One of the operands in two-operand arithmetic/logic instructions (ADD, SUB, XOR, OR, AND) is continuously supplied from AC, and another comes from the R register. There is a 1-bit flip flop which is the Xero-flag (Z). It is set to 1 when the result of any arithmetic or logic instruction is 0 and vice versa. A program counter (PC) also forms the instruction address. Both data and instruction memories are 16 x 1-byte memories. 

Conditional branch instructions are JMPZ (if FlagZ = 1) and JMPNZ (if FlagZ = 0). The unconditional branch is JUMP, Memory Load, and Store are implemented with Accumulator: LDAC reads from Data Memory to AC, and STAC writes from AC into Data Memory. There is only one type of memory addressing: direct (absolute). There are two instructions to move data to and from the Accumulator: MVAC (From AC to R) and MOVR (from R to AC). Increment (INAC) and NOT are performed on the operand that comes from the AC register and the result goes back to the accumulator. Clear Accumulator (CLAC) sets Accumulator to 0 and NOP does nothing (void).
## Components
Software:
- [Intel Quartus Prime](https://www.intel.com/content/www/us/en/products/details/fpga/development-tools/quartus-prime.html)
- [Visual Studio Code](https://code.visualstudio.com/)

Hardware:
- [Altera DE2-115 Development and Education Board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=139&No=502&PartNo=2)
