// Jose Mejias
// CS3B - Lab7-1 - PuddyTat /
// 10/18/2025
// Concatenates two files into a third, either appending to or overwriting the third.
// Pseudocode/Algorithm:
// Input:
//   - First input filename  (string, <= 64 chars)
//   - Second input filename (string, <= 64 chars)
//   - Output filename       (string, <= 64 chars)
//   - Append selection      ('Y'/'y' to append, any other key to overwrite)
//
// Processing:
//   1. Prompt user for both input filenames, output filename, and append mode.
//   2. Attempt to open both input files in READ-ONLY mode.
//      • If either fails → print: "Fatal error: failed to open input file <filename>" and exit.
//   3. Check append mode:
//      • If 'Y' or 'y' → open output in APPEND mode (create if needed).
//      • Else          → open output in TRUNCATE mode (overwrite).
//      • If output open fails → print: "Fatal error: failed to open output file <filename>" and exit.
//   4. Read contents of Input File 1 and write to Output File.
//   5. Read contents of Input File 2 and write to Output File.
//   6. Close all open file descriptors.
//
// Output:
//   - On success: Output file contains Input1 + Input2 (append or overwrite).
//   - On failure: Prints fatal error message with the invalid filename and exits

.global _start // Provide program starting address

_start:

	.EQU SYS_exit, 93 // exit() supervisor call code
	.EQU AT_FDCWD, -100	// current working directory file descriptor for File IO
	.EQU A_C_RW, 02102	// 02 = Read/Write access |+| 0000 = Create file if it doesn't exist |+| 02000 = Append mode
	.EQU T_C_RW, 01101	// 02 = Read/Write access |+| 0100 = Create file if it doesn't exist |+| 01000 = Truncate mode
	.EQU RW_RW____, 0660//File perms: 110 (6) = Owner readwrite || 110 (6) = Group readwrite || 000 = others no perms

.MACRO	PromptAndRead promptReg, readReg, readSize
	MOV	X0, \promptReg		// Load address of prompt message
	BL 	putstring            // call putstring: print prompt

	MOV 	X0, \readReg    	// Copy address of string buffer for file name
	LDR 	X0, [X0]			// Load address of string buffer
    	MOV 	X1, \readSize       // Copy File name max length for getstring
	//LDR X1, [X1]			// Load address of max length
    	BL 	getstring            // Call getstring

.ENDM

.MACRO 	fileErrIn ifn
	LDR 	X0, =inFileError	// Load address of error message
	BL 	putstring			// print error message

	MOV 	X0, \ifn			// Load address of incorrect filename
	LDR 	X0, [X0]			// Load copied address
	BL 	putstring			// print error file

.ENDM

.MACRO 	fileErrOut ofn
	LDR 	X0, =outFileError	// Load address of error message
	BL 	putstring			// print error message

	MOV 	X0, \ofn			// Load inccorect output filename
	BL 	putstring			// print incorrect file name

.ENDM

.MACRO 	openFile fn, flags
	MOV 	X0, #AT_FDCWD		// current working directory
	MOV 	X1, \fn				// file name
	MOV 	X2, \flags			// Open file with flags.
	MOV 	X3, #RW_RW____		//owner read/write, group read/write, other nothing
	MOV 	X8, #56 			// supervisor call to openat()
	SVC 	0					// Supervisor call

.ENDM

.MACRO readWriteToFile fromDesc, outFileDesc, writeBuffer

	// Read from input file
	MOV 	X0, \fromDesc        // Input file descriptor
    	MOV 	X1, \writeBuffer     // Buffer address
    	MOV 	X2, #4096            // Buffer size
    	MOV 	X8, #63              // read() syscall number
    	SVC 	0					 // Supervisor call

	// Output into outfile
	MOV 	X2, X0		// Number of bytes read/to write	
	MOV 	X0, \outFileDesc	// Output file desc
	MOV 	X1, \writeBuffer	// Buffer address
	MOV 	X8, #64         	// write() syscall number
	SVC 	0			// Supervisor call

.ENDM

	.text // code section
	
	// Get ipnut filename 1, check if valid and open
	LDR 	X0, =promptFile1	// Load register with prompt
	
	//PromptAndRead X0, X1, X2	//Prompt and read input macro

	BL 	putstring       // call putstring: print prompt
	
	LDR 	X0, =szFileName1 	// Load register with string buffer
    	MOV 	X1, #64		// Move max length for getsring
    	BL 	getstring       // Call getstring
	MOV 	X2, #00000	// set read only flags

	//openFile X1, X3	// Check if filename is valid and open with Read only
	MOV 	X0, #AT_FDCWD	// current working directory
	LDR 	X1, =szFileName1	// file name
	//LDR X2, \flags	// Open file with flags.
	
	MOV 	X3, #RW_RW____	//owner read/write, group read/write, other nothing
	MOV 	X8, #56 	// supervisor call to openat()
	SVC 	0		// Supervisor call

	CMP 	X0, #0		// Check error code
	B.LT 	invalidFileIn1	// If negative value, there was an error opening the file.
	MOV 	X19, X0		// Save file descripter for input file 1

	// Get input filename 2
	LDR 	X0, =promptFile2	// Load address of prompt message
	//PromptAndRead X0, X1, X2	//Prompt and read input macro

	BL 	putstring        // call putstring: print prompt
	
	LDR 	X0, =szFileName2 // Load register with string buffer
    	MOV 	X1, #64		// Move max length for getsring
    	BL 	getstring       // Call getstring

	MOV 	X2, #00000	// set read only flags
	//openFile X1, X3	// Check if filename is valid and open with Read only
	MOV 	X0, #AT_FDCWD	// current working directory
	LDR 	X1, =szFileName2	// file name
	//LDR X2, \flags	// Open file with flags.
	
	MOV 	X3, #RW_RW____	//owner read/write, group read/write, other nothing
	MOV 	X8, #56 	// supervisor call to openat()
	SVC 	0		// Supervisor call
	CMP 	X0, #0		// Check error code
	B.LT 	invalidFileIn2	// If negative value, there was an error opening the file.
	MOV 	X20, X0		// Save file descripter for input file 1
	
	CMP 	X0, #0		// Check error code
	B.LT 	invalidFileIn2	// If negative value, there was an error opening the file.
	MOV 	X20, X0		// Save file descripter for input file 2

	// Get output filename
	LDR 	X0, =promptOutFile	// Load address of prompt message
	LDR 	X1, =szOutFile		// Load register with string buffer
	//PromptAndRead X0, X1, X2	//Prompt and read input macro

	BL 	putstring       // call putstring: print prompt
	
	LDR 	X0, =szOutFile 	// Load register with string buffer
    	MOV 	X1, #64		// Move max length for getsring
    	BL 	getstring       // Call getstring


	// Prompt the mode: Read/Append
	LDR 	X0, =promptAppend	// Load address of prompt message
	//PromptAndRead X0, X1, X2	//Prompt and read input macro

	BL 	putstring       // call putstring: print prompt
	
	LDR 	X0, =czAppendCheck 	// Load register with string buffer
    	MOV 	X1, #64		// Move max length for getsring
    	BL 	getstring       // Call getstring

	CMP 	X0, #'Y'	// If the user answered Y
	B.EQ 	appendFile	// Jump to append mode
	
	CMP 	X0, #'y'	// If the user answered y
	B.EQ 	appendFile	// Jump to append mode
	
	MOV 	X3, #T_C_RW	// Flags: Truncate, Create, Read/write
	//openFile X1, X3	// Open file with specified flags
	
	MOV 	X0, #AT_FDCWD	// current working directory
	LDR 	X1, =szOutFile	// file name
	MOV 	X2, #T_C_RW	// Open file with flags.
	MOV 	X3, #RW_RW____	//owner read/write, group read/write, other nothing
	MOV 	X8, #56 	// supervisor call to openat()
	SVC 	0		// Supervisor call
	
	CMP 	X0, #0		// Check error code
	B.LT 	invalidFileOut	// if negative, tehre was an error opening the file
	MOV 	X18, X0		// Save file descripter for output file

	B 	readFileInput	// Start reading from file

appendFile:
	
	MOV 	X3, #A_C_RW	// Flags: Append, Create, Read/write
	//openFile X1, X3	// Open file with specified flags
	MOV 	X0, #AT_FDCWD	// current working directory
	LDR 	X1, =szOutFile	// file name
	MOV 	X2, #A_C_RW	// Open file with flags.
	MOV 	X3, #RW_RW____	//owner read/write, group read/write, other nothing
	MOV 	X8, #56		// supervisor call to openat()
	SVC 	0		// Supervisor call
	
	CMP 	X0, #0		// Check error code
	B.LT 	invalidFileOut	// if negative, tehre was an error opening the file
	MOV 	X18, X0		// Save file descriptor for output file

readFileInput:

	// Allocate buffer on the stack
    	SUB 	SP, SP, #4096  // Allocate 4KB buffer on stack
    	MOV 	X21, SP        // X21 points to our buffer

	//readWriteToFile X19, X18, X21	// Read from input file 1 (X19), output to out file (X18), using buffer (X21)  
	// Read from input file
    	MOV 	X0, X19        	// Input file descriptor
    	MOV 	X1, X21     	// Buffer address
    	MOV 	X2, #4096       // Buffer size
    	MOV 	X8, #63         // read() syscall number
    	SVC 	0		// Supervisor call

	// Output into outfile
	MOV 	X2, X0		// Number of bytes read/to write	
	MOV 	X0, X18		// Output file desc
	MOV 	X1, X21		// Buffer address
	MOV 	X8, #64     	// write() syscall number
	SVC 	0		// Supervisor call  

	//readWriteToFile X20, X18, X21	// Read from input file 2 (X20), output to out file (X18), using buffer (X21)    
	// Read from input file
    	MOV 	X0, X20        	// Input file descriptor
    	MOV 	X1, X21     	// Buffer address
    	MOV 	X2, #4096       // Buffer size
    	MOV 	X8, #63         // read() syscall number
    	SVC 	0		// Supervisor call

	// Output into outfile
	MOV 	X2, X0		// Number of bytes read/to write	
	MOV 	X0, X18		// Output file desc
	MOV 	X1, X21		// Buffer address
	MOV 	X8, #64         // write() syscall number
	SVC 	0		// Supervisor call  

	// Deallocate buffer
    	ADD 	SP, SP, #4096   // Release buffer space
    	B 	terminate

invalidFileIn2:

	//fileErrIn X1		// output error message for input file
	LDR 	X0, =inFileError	// Load address of error message
	BL 	putstring		// print error message

	LDR 	X0, =szFileName2	// Load address of incorrect filename
	BL 	putstring		// print error file

	LDR	X0, =newLine
	BL	putstring

	B terminate		// end program

invalidFileIn1:

	//fileErrIn X1		// output error message for input file
	LDR 	X0, =inFileError	// Load address of error message
	BL 	putstring		// print error message

	LDR 	X0, =szFileName1	// Load address of incorrect filename
	BL 	putstring		// print error file

	LDR	X0, =newLine
	BL 	putstring

	B terminate		// end program
	

invalidFileOut:

	//fileErrOut X1		// output error message for output file
	LDR 	X0, =outFileError	// Load address of error message
	BL 	putstring		// print error message

	LDR 	X0, =szOutFile	// Load address of incorrect filename
	BL 	putstring		// print error file
	
	LDR	X0, =newLine
	BL	putstring

	B	terminate	// end program

terminate:

    	// close all files and terminate the program
    	MOV 	X0, X19		// file desc
    	MOV 	X8, #57		// SVC close
    	SVC 	0		// superviser call
    
    	MOV 	X0, X20		// file desc
    	MOV 	X8, #57		// SVC close
    	SVC 	0		// superviser call
    
    	MOV 	X0, X18		// file desc
    	MOV 	X8, #57		// SVC close
    	SVC 	0		// superviser call
    
    	MOV 	X0, #0 		// set return code to 0, all good
    	MOV 	X8, #SYS_exit 	// set exit() supervisor call code
    	SVC 	0 		// call Linux to exit

	.data // data section

promptFile1: 	.asciz	"Enter first input file name : "
promptFile2:	.asciz 	"Enter second input file name: "
promptOutFile:	.asciz	"Enter output file name      : "
promptAppend:	.asciz	"Append to the output? [Y/N] : "
inFileError:	.asciz	"Fatal error: failed to open input file "
outFileError:	.asciz	"Fatal error: failed to open output file "
czAppendCheck:	.skip	64	// char buffer for Y/N input
szFileName1:	.skip 	64	// String buffer for input file 1
szFileName2:	.skip 	64	// String buffer for input file 2
szOutFile:	.skip	64	// String Buffer for output file
newLine:	.asciz	"\n"

.end	 // end of program, optional but good pra
