// Jose Mejias	
// CS3B - Lab4-1 - putstrig function
// 09/13/2025
// Function putstring: provided a pointer to a null terminated string X0,
// will output the string on the console
// Pseudocode/Algorithm:
//	Input: X0 - Pointer to a null terminated string (text we want to print)
//	Processing: -Save pointer to the string, so it is not lost
//		    -Save the return address to restore later
//		    -Call the String_length function with BL (X0 cotains string pointer) 
//		     Receive the length of the string in X0, then move it to X2 (X2 = length)
//		    -Restore the string pointer back into X0
//		    -Set up parametes to write system call
//	Output:  Write the string characters to the console

.global putstring

	.text	// code section

putstring:

	MOV	X8, X0		// Save string pointer X0 into X8
	MOV	X3, LR		// Save LR (link register) in X3

	BL	String_length	// Call String_legth to get the string length. BL(branch with link)
	MOV	X2, X0		// Store length in X2
	MOV	X0, X8		// Put back string pointer at X0

	MOV	X1, X0		// string to print
	MOV	X8, #64		// linux write system call
	MOV	X0, #1		// 1 = stdout
	SVC	0		// call linux to output the string
	
	MOV	LR, X3		// restore LR
	RET			// return from the function

.end	// end of function, good practice
	
