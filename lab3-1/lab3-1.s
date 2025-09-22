// Jose Mejias
// CS3B - Lab 3-1 - 123 ABC GDB
// 9/6/2025
// Uses a supervisor to load addresses and a value into registers and check it using gdb
// Algorithm/Pseudocode:
//	Input: Input two strings (strSzMsg1 and strSzMsg2) and one hexacimal word (i32x)
//	Processing: load address of first string into register 1
//		    load address of second string into register 2
//		    load address of hexadecimal word into register 3
//		    load value of register 2 into register 3
//	Output: N/A

.global _start		// Provide program starting address

_start:

	.EQU	SYS_exit, 93	// exit supervisor call code

	.text	// code section

	LDR	X0, =szMsg1	// load address of strMSzMsg into X0
	LDR 	X1, =szMsg2	// load addres of strSzMsg into X1
	LDR	X2, =i32x	// load addres of strI32x into X2
	LDR	X3, [X2]	// load the word at i32x into X3

	MOV	X0, #0		// Set return code to 0
	MOV	X8, SYS_exit	// Set exit() supervisor call code
	SVC	0		// Call linux to exit

	.data
szMsg1:	.asciz "Oh that things could be\n"
szMsg2:	.asciz "as they once were."
i32x:	.word 0x1234ABCD

.end	// end of program, optional but good practice 
