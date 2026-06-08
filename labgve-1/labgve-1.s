// Jose Mejias
// CS3B - labgve1
// 11/22/2025
// This function will emulate the concatenation operator in C++ 
// by allocating memory from the heap. Uses a helper 
// function/macro to copy one string to another. 
// Pseudocode/Algorithm:
//  Input: N/A
//  Processing: 
//	1. Measure how many characters it has each text piece
//	2. Adds its length to a running total size
//	3. Add 1 extra character to the total size fort the final
//	   end-of-string marker 
// 	4. ASk the Operating system for a block of memory on the heap
//	   with the total size
//	4a. If the memory request fails, skip the rest and show an error message
//	5. If the memory request works copy the text into a new memory
//	6. Copy the saparator right after the first text
//	7. Copy the second text right after the separator
//	8. All copies are done character by character untill the end of each text
//	9. Make suree the very end of the combined text has a single end-of-string marker
//  Output:
//	Print the original text while their lengths are measured
//	Print message "Mal (bad) loc (line-of-credit)
//	If memory could not be obteined, print message "Malloc Error!"
//***************************************************************************************
// For each string, get it's length and store it into the stack, next:
// 1. Get total length of all strings (making sure to include only one null)
// 2. Use total length in malloc to acquire heap address of that size (save pointer)
// 3. Sequentially store strings into allocated heap address pointer
// 4. Output string
//***************************************************************************************

.global _start // Provide program starting address

.macro StrCopy src, dst
1:
	LDRB    W3, [\src], #1   // load byte from src, increment
    	STRB    W3, [\dst], #1   // store byte to dst, increment
    	CMP     W3, #0           // if null byte, we're done
   	B.NE       1b		 // if not null, loop
	SUB \dst, \dst, #1	 // decrement ptr to override null on next call
.endm

_start:

	.EQU	SYS_exit, 93    // exit() supervisor call code
	.EQU	STDOUT, 1	// file descriptor for standard out/console	

	.text // code section

	MOV 	X9, #0		// This will hold the total size of our output string, init 0.

	// Obtain size
	LDR	X0, =szString1	// Load address of string
	MOV	X1, STDOUT	// Set file descriptor to STDOUT
	BL 	fputstring	// print (side effect: will save length in X2)
	ADD	X9, X9, X2	// Add allocation size for string2 into size accumulator (including null)
	LDR 	X0, =szEOL	// load address of newline
	MOV	X1, STDOUT	// Set file descriptor to STDOUT
	BL 	fputstring	// print new line

	LDR 	X0, =szSeparator // Load address of string
	MOV 	X1, STDOUT	// Set file descriptor to STDOUT
	BL 	fputstring	// print (side effect: will save length in X2)
	ADD 	X9, X9, X2	// Add allocation size for separator into size accumulator
	LDR 	X0, =szEOL	// load address of newline
	MOV	X1, STDOUT	// Set file descriptor to STDOUT
	BL 	fputstring	// print new line
	
	LDR 	X0, =szString2	// Load address of string
	MOV	X1, STDOUT	// Set file descriptor to STDOUT
	BL 	fputstring	// print (side effect: will save length in X2)
	ADD 	X9, X9, X2	// Add allocation size for string1 into size accumulator
	ADD 	X9, X9, #1	// +1 for null
	LDR 	X0, =szEOL	// load address of newline
	MOV	X1, STDOUT	// Set file descriptor to STDOUT
	BL 	fputstring	// print new line

	// Allocate memory inside heap
	MOV 	X0, X9		// Move length into X0
	BL 	malloc		// Call Malloc: returns heap address in X0
	CMP 	X0, #0		// Check pointer for successful return
	B.EQ 	errorMalloc	// Output error if unsuccessful and exit

	LDR 	X1, =pszStrPtr	// Load address of pointer storage
	STR 	X0, [X1]	// Store heap address in pointer storage

	// Concatenate
	LDR 	X1, =szString1	// Load address of string1
	StrCopy X1, X0		// Copy string into allocated pointer
	
	LDR 	X1, =szSeparator // Load address of separator string
	StrCopy X1, X0		// Copy string into allocated memory

	LDR 	X1, =szString2	// Load address of string2
	StrCopy X1, X0		// Copy string into allocated memory
	
	// Output new string
	LDR 	X0, =pszStrPtr	// Load allocated heap address poionter
	LDR 	X0, [X0]	// retrieve heap address
	MOV	X1, STDOUT	// Set file descriptor to STDOUT
	BL 	fputstring	// Output value

	LDR 	X0, =szEOL	// load address of newline
	MOV	X1, STDOUT	// Set file descriptor to STDOUT
	BL 	fputstring	// print new line

	// Free address
	LDR 	X0, =pszStrPtr	// Load allocated heap adderss pointer
	LDR 	X0, [X0]	// retrieve heap address
	BL 	free		// release the heap memory
	
	B 	terminateGVE1	// end program

errorMalloc:

	LDR 	X0, =szMallocErr	// Load address of malloc error message
	MOV	X1, STDOUT	// Set file descriptor to STDOUT
	BL 	fputstring		// Print error message

terminateGVE1:

    	// terminate the program
	MOV 	X0, #0 		// set return code to 0, all good
    	MOV 	X8, #SYS_exit   // set exit() supervisor call code
    	SVC 	0 		// call Linux to exit

	.data // data section

szString1:   .asciz "Mal (bad)"            // a C-String 
szSeparator: .asciz " "                    // a C-String separator that is just a space this time
szString2:   .asciz "loc (line-of-credit)" // another C-String 
pszStrPtr:   .quad  0                      // a pointer to a C-String for the output
szMallocErr: .asciz "Malloc Error!"	   // string buffer for malloc error message
szEOL:	     .asciz "\n"		   //newline

.end // end of program, optional but good practice
