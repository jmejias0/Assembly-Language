// Jose Mejias
// CS3B - Lab1-2 - Putch function
// 08/28/2025
// Function putch: Set up the parameters to print the char
// then call linux to do it.
// Pseudocode/Algorithm:
// 	Input: N/A
// 	Processing: Pass a character holded in X1 to the buffer
// 	Output: Print the character passed into the console
//***********************************************************
// Registers
// 	X0: Contains the character that is pass it to register X1
// 	and then contains #1 to output character passed to the console
// 	X1: Holds the character that is going to be  printed
// 	X2: Have the lenghts of the character wanted to print
// 	X8: Linux call to output string
//***********************************************************

.global putch

	.text	// code section
putch:

	MOV X1, X0 	// Load char parameter from X0 to X1
	MOV X0, #1 	// 1 = stdOut
	MOV X2, #1	// Length of output char
	MOV X8, #64 	// Linux write system call
	SVC 0 		// Call linux to output the string
	
	RET // Return from the function

.end	// end of function, optional but good practice
