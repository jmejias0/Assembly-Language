// Jose Mejias
// CS3B - lab5-1 - GDB Stories
// 09/20/2025
// 
// Algorithm/Pseudocode:
//	Input: N/A
//	Processing:  load variables addresses into register X0 
//                   load values into register X1 (1. integer, 2. char and 3. integer)
//		     store the value of register X1 into register 0 
//		     then chacters will contain those values passed
//		     set a pointer that points to a string to pass the string value
//		     into another register, so makes a copy of the string 
//	Output: N/A
//	Terminate the program (.end)

.global _start	// Provide program starting address

_start:

	.EQU	SYS_exit, 93	// Provide program starting address
	
	.text			// code section
	
	LDR	X0, =bA		// load address of bA into x0
	MOV	X1, #155	// Move immediate value #155 into register X1
	STR	W1, [X0]	// store value of X0 into X1

	LDR	X0, =chInit	// load address of chInit into X0
	MOV	X1, #'j'	// Move immediate value 'j' into register X1
	STRB	W1, [X0]	// store value of X0 into W1

	LDR	X0, =u16Hi	// load address of u16Hi into X0
	MOV	X1, #88		// Move immediate value #88 into register X1
	STRH	W1, [X0]	// store value of X0 into W1

	LDR	X0, =wAlt	// load first element of array into X0 
	MOV	X1, #16		// move immediate value #16 ino X1
	STR	W1, [X0]	// store value of X0 into W1

	MOV	X1, #-1		// move immediate value of #-1 into X1
	STR	W1, [X0, #4]	// load second element of array

	MOV	X1, #-2		// move immedate value of #-2 into X1
	STR	W1, [X0, #8]	// load third element of array 

	LDR	X0, =dbBig	// load address of dbBing into X0
	LDR	X1, =0x54E75B07	// load lower 4 bytes of dbBing into X1
	STR	W1, [X0]	// store value of X0 into W1	

	LDR	X1, =0x3A72F36D	// load upper 4 bytesi of dbBing into X1
	STR	W1, [X0, #4]	// store value of X0 into W1

	LDR 	X1, =szMsg1	// set the pointer to 50

	LDR	X1, =szMsg1Input	// get the string input 

copy_loop:

	LDRB	W2, [X1], #1	// load byte and increment by 1
	STRB	W2, [X0], #1	// store byte into destination
	CMP	X2, #0		// Check if it is 0
	B.NE	copy_loop	// if it is not equal, go back to loop
	
	MOV	X0, #0		// use 0 return code 
	MOV	X8, SYS_exit	// set exit() supervisor call
	SVC	0		// call linux to terminate

	.data
bA:	.byte	1
chInit: .skip	1
u16Hi:	.hword	0
wAlt:	.word	0, 0, 0
dbBig:	.quad	0
szMsg1:	.skip	50

szMsg1Input:	.asciz "Sally says she sells sea shells"

.end	// end of program, optional but good practice
