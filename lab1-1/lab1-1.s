// Jose Mejias
// CS3B - lab1-1 - HelloWorld
// 8/21/1025
// Uses system call to print a message to the console
// Algorithm/Pseudocode:
//	Input: N/A
//	Processing: Pass paramter to the register, eg. output wanted
//	Output: Print the string message "Hello CS3B!" on the console

.global _start	// Provide program starting address

// Setup the parameters to print message and then call Linux to do it.

_start:

	MOV	X0, #1		// 1 = StdOut
	LDR	X1, =strMessage	// string to print
	MOV	X2, #12		// Lenght of the string
	MOV	X8, #64		// Linux write system call
	SVC	0		// Call linux to output the string

// Setup parameters to exit the program 
// and then call Linux to do it.
	MOV	X0, #0		// Use 0 return code
	MOV	X8, #93		// Service code 93 terminates
	SVC	0

	.data
strMessage:	.ascii	"Hello CS3B!\n"

.end		// end of program, optional but good practice
