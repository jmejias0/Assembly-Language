// Jose Mejias
// CS3B - lab6-1 - driver6-1
// 10/11/2025
// output string entered by the user, it request input three times to check
// behavior/reaction of the buffer.

.global	_start

_start:

	.EQU	SYS_exit, 93	// exit supervisor call

	.text			// code section
	
	// test1
	LDR	X0, =buffer	// load the address of the buffer in X0
	MOV	X1, #32		// set X1 to 32, buffer size including space for null
	BL	getstring	// load string 
	BL	putstring	// output the string
	LDR	X0, =newline	// load the address of new line into X0
	BL	putstring	// output the new line
	
	//test2
	LDR	X0, =buffer	// load the address of the buffer in X0
	MOV	X1, #32		// set X1 to 32, buffer size including space for null
	BL	getstring	// load string 
	BL	putstring	// output the string
	LDR	X0, =newline	// load the address of new line into X0
	BL	putstring	// output the new line

	//test3
	LDR	X0, =buffer	// load the address of the buffer in X0
	MOV	X1, #32		// set X1 to 32, buffer size including space for null
	BL	getstring	// load string
	BL	putstring	// output the String
	LDR	X0, =newline	// load the address of new line into X0
	BL	putstring	// output the new line
	

	// terminate the program
	MOV	X0, #0		// set return code to 0, all good
	MOV	X8, SYS_exit	// Syscall #93 is exit
	SVC	0		// call linux to terminate

	.data

test1:	.byte	114
test2:	.byte	15
test3:	.byte	16

buffer:	.skip	32	// avoid aligment issues
newline: .asciz "\n"	// new line string

.end	// end of program, optional but good practice
