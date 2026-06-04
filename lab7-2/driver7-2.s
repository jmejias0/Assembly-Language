// Jose Mejias
// CS3B - Lab7-2 - driver7-2
// 10/25/2025
// Prompt the user to enter a file name, attempts to open the file
// given in read-only mode, and reads and print each line of the file 
// in the console. If the file can not be opened, it daplys an error message
// with the invalid file name
// Pseudocode/Algotihm:
// Input:
//	File name to open
// Processing:
//	1. Read filename into buffer szInputFile using getstring (max_len=64)
//	2. Try to ope file in read-only mode via openat
//		a. If open fails (return < 0)
//		- prints "fatal error: failed to open input file"
//		- prints the filename and newLine
//		b. If success open (return ?= 0)
//		- save file descriptor (fd) on the stack
//	3. Read/print loop:
//		Loop:
//		- load fd from stak
//		- call getline(fd, sxReadLine, maxLen=65)
//		- If return == 0 (EOF) : go to "terminate"
//			-Else:
//			print szReadLine
//			print newline
//	4. terminate: exit(0)
// Output:
//	- success path: each line of the file is printed
//	- Failure path: "Fatal error: failure to open input file " + filename + "\n"
// ***********************************************************************************

.global _start 		// Provide program starting address

.MACRO 	printEOL
	LDR 	X0, =szEOL	// load address into X0 for putstring
	BL 	putstring	// putstring: print newline
.ENDM

_start:

.EQU SYS_exit, 93 // exit() supervisor call code
.EQU AT_FDCWD, -100	// Current working directory
.EQU R__R_____, 0440//File perms: 100 (4) = Owner read || 100 (4) = Group read || 000 = others no perms

	.text // code section

	// Prompt user for file name
	LDR 	X0, =promptFile		// Load register with prompt
	BL 	putstring          	// call putstring: print prompt

	LDR 	X0, =szInputFile 	// Load register with string buffer
    	MOV 	X1, #64			// Move max length for getsring
 	BL 	getstring            	// Call getstring

	// Call openat() function on Input File
	MOV 	X0, AT_FDCWD		// File descriptor at current working directory
	LDR 	X1, =szInputFile	// Filename
	MOV 	X2, #00000		// Read only flag
	MOV 	X3, R__R_____		// Permissions: Owner read / Group Read / Others none
	MOV 	X8, #56			// openat() SYS number
	SVC	0			// Supervisor call

	CMP 	X0, #0			// Check error code
	B.LT 	invalidFileIn		// If negative value, there was an error opening the file.

	STR 	X0, [SP]		// Store file descriptor on the stack

// Call getline for each line in the file

fileReadLoop:

	LDR 	X0, [SP]		// Copy file descriptor from the stack
	LDR 	X1, =szReadLine	// getline needs pointer to buffer to read into
	MOV 	X2, #65			// getline needs max buffer length
	BL 	getline			// call getline

	CMP 	X0, #0			// if we have not read, we are at EOF
	B.EQ 	terminate		// if EOF, terminate

	LDR 	X0, =szReadLine	// putstring needs address at X0
	BL 	putstring		// print line of file
	printEOL			// print newline

	B 	fileReadLoop		// continue reading until EOF

invalidFileIn:

	LDR 	X0, =inFileError	// Load address of error message
	BL 	putstring		// print error message

	LDR 	X0, =szInputFile	// Load address of incorrect filename
	BL 	putstring		// print error file
	printEOL			// print newline
	B 	terminate		// end program
	
terminate:
	
    	// terminate the program
    	MOV 	X0, #0 			// set return code to 0, all good
    	MOV 	X8, #SYS_exit 		// set exit() supervisor call code
	SVC	0 			// call Linux to exit

	.data // data section

promptFile:	.asciz	"Enter input file name : "
szInputFile:	.skip	64	// String buffer for input file name
inFileError:	.asciz	"Fatal error: failed to open input file "
szReadLine:	.skip	65	// 64 max read, + 1 to account for null at the end
szEOL:		.asciz "\n"

.end // end of program, optional but good practice
