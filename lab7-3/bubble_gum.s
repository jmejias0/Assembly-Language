// Jose Mejias
// C23B - Lab7-3 - bubble_gum
// 11/01/2025
// Function that reads ip to 100 valid integers, sorts them in ascending order
// Pseudocode/Algorithm:
// 	Input:
// 	Prompt Input File name, enter by user
//	Prompt Output File name, enter by user
//	
//	Processing:
//	1. Open input file in read-only mode; if fail show error message and terminate
//	2. Open output file name in write mode, if fail show error an terminate
//	3. Read each line from input file until EOF or if the maximum length of array is reached
//	4. Convert each line from string to integer
//	5. Store integers sequentially in an array
//	6. When all lines are read, call bubble sort routine to sort the array
//	7. Write sorted integers into the output file provided by the user
//	8. Close input and output files
//
//	Output:
//	Sorted list of integers written to the specified output file
//	Error message if files cannot be opened
//	Error message if he input file exceeds the maximum number of entries

.global _start // Provide program starting address

.MACRO printEOL
	LDR X0, =szEOL	// load address into X0 for putstring
	BL putstring	// putstring: print newline
.ENDM

.MACRO printArray arr, arrLen, arrInc	// will print every value inside an array
	MOV X2, \arr			// Load X0 with ptr to first array value
	MOV X3, \arrLen			// X1 will serve as our array size and lcv bound
	MOV X4, #0			// X4 will be compared to arrSize and serve as lcv

printIndex:

	LDR W0, [X2]		// Load 8 bytes from pointer
	LDR X1, =szCurrentNum	// int2cstr needs buffer to hold value 
	BL int2cstr		// call int2cstr to convert array[i] to cstring
	
	MOV X0, X1		// putstring needs address of buffer to print
	BL putstring		// call putstring: output current number
	
	ADD X2, X2, \arrInc	// increment X2 pointer by type of array, byte:1, hword:2, word:4, quad:8
	printEOL		// print new line

	ADD X4, X4, #1		// increment lcv
	CMP X4, \arrLen		// Check if we have printed full array
	B.LT printIndex		// loop to print next value
.ENDM

_start:

	.EQU SYS_exit, 93 	// exit() supervisor call code
	.EQU MAX_ARR_SZ, 100	// Maximum array size to read and sort
	.EQU AT_FDCWD, -100	// At current working directory
	.EQU RW_RW_RW_, 0666	// Owner read-write, Group Read-write, Others Read-Write
	.EQU R__R_____, 0440	// Owner read / Group read / Others none
	.text // code section

bubbleFileInput:

	// Prompt user for file name
	LDR X0, =inFPrompt	// Load register with prompt
	BL putstring            // call putstring: print prompt

	LDR X0, =szInputFile 	// Load register with string buffer
    	MOV X1, #64		// Move max length for getsring
	BL getstring            // Call getstring

	// Call openat() function on Input File
	MOV X0, AT_FDCWD	// File descriptor at current working directory
	LDR X1, =szInputFile	// Filename
	MOV X2, #00000		// Read only flag
	MOV X3, R__R_____	// Permissions: Owner read / Group Read / Others none
	MOV X8, #56		// openat() SYS number
	SVC	0		// Supervisor call

	CMP X0, #0		// Check error code
	B.LT invalidFileIn	// If negative value, there was an error opening the file.

	// Save input file descriptor
	STR X0, [SP]		// Copy file descriptor for input file into X4


	// Prompt user for output file name
	LDR X0, =outFPrompt	// Load register with prompt
	BL putstring            // call putstring: print prompt

	LDR X0, =szOutFile 	// Load register with string buffer
    	MOV X1, #64		// Move max length for getsring
    	BL getstring            // Call getstring

	// Call openat() function on output File
	MOV X0, AT_FDCWD	// File descriptor at current working directory
	LDR X1, =szOutFile	// Filename
	MOV X2, #01102		// Read/Write, create, truncate flag
	MOV X3, RW_RW_RW_	// Permissions: Owner read-write / Group Read-write / Others read-write
	MOV X8, #56		// openat() SYS number
	SVC	0		// Supervisor call

	CMP X0, #0		// Check error code
	B.LT invalidFileOut	// If negative value, there was an error opening the file.

	// Save output file descriptor
	LDR X1, =fdOut		// load address of output file descriptor
	STR X0, [X1]		// store output file descriptor in memory

// convert file with list of cstring values into quad array of integer numbers
	LDR X15, =rgiArrNum	// Load address of our array
fileReadLoop:
	// Call get line for each line in file, until max size
	LDR X4, =cArrNum	// Load address for array length
	LDR X4, [X4]		// Load value for array length
	CMP X4, MAX_ARR_SZ	// Compare current read amount to max array size
	B.GE tooManyEntries	// If we have surpassed the max array size, print warning and ignore rest of file
	
	LDR X0, [SP]		// Copy file descriptor from the stack
	LDR X1, =szCurrentNum	// getline needs pointer to buffer to read into
	MOV X2, #65		// getline needs max buffer length
	BL getline		// call getline

	LDR X0, =szCurrentNum	// load address of current read num
	LDR X0, [X0]		// Load value of current read
	CMP X0, #0		// if we have read 0, we are at EOF
	B.EQ sort_list		// if EOF, end read
	

	// Convert line into quad integer
	LDR X0, =szCurrentNum	// cstr2int needs pointer to string buffer
	BL cstr2int		// cstr2int call: converts string X0 to int X1
	LDR X1, =i64CurrentNum	// buffer to hold converted value
	STR X0, [X1]		// copy converted value into buffer

	// Store converted integer into quad array and increment BY 8 (since quad)
	LDR X1, =i64CurrentNum	// Load address of our quad size integer
	LDR X1, [X1]		// Load the value from the address of our integer
	STR X1, [X15], #8	// Store quad int into quad array, increment pointer to next position


// DEBUGGING BLOCK:
		// AT THIS POINT WE SHOULD HAVE A VALID QUAD INTEGER INSIDE i64CURRENTNUM.
		//	A VALID CSTRING REPRESENTATION INSIDE szCurrentNum.
		//	AN ARRAY rgiArrNum WITH X4 AMOUNT OF ENTRIES.
//	LDR X0, =szCurrentNum	// putstring needs string buffer in X0
//	BL putstring			// print the number that was just read from the file
//	printEOL				// print newline
// END DEBUGGING BLOCK

	// Loop: call getline for each line in the file
	LDR X0, =cArrNum	// Load address of the count
	LDR X0, [X0]		// Load value of the count
	ADD X0, X0, #1		// Increment count
	LDR X1, =cArrNum	// Load address of count for store
	STR W0, [X1]		// Store count

	B fileReadLoop	// Loop

sort_list:

	LDR X0, =rgiArrNum	// Load address of array of quad integers
	LDR X1, =cArrNum	// Load address of array count (length)
	LDR X1, [X1]		// Load value of array count (length)
	SUB X1, X1, #1		// -1 length to account for EOF
	MOV X2, #8		// Mul needs integer register
	MUL X1, X1, X2		// convert length to size, size = lenth * type
	
	BL sort_bubble		// call bubble sort on our list


	// Now that our list is sorted, output to file
	LDR X15, =rgiArrNum	// Load address of array into X15
	MOV X2, #8		// Quad array, so our iterator should increment by 8
	MOV X14, #0		// X14 will be compared to arrSize and serve as lcv
	
	LDR X0, =maxFlag	// Load address of max flag
	LDR X0, [X0]		// Load value of max flag
	CMP X0, #0		// If we did not reach max entries, continue to output
	B.EQ output_sorted	// output sorted if maxFlag unactive. Else output 1 less because of EOF
	MOV X14, #1		// Account for no EOF when we have max entries

output_sorted:

	LDR W0, [X15], #8	// Load 8 bytes from pointer, increment quad ptr
	LDR X1, =szCurrentNum	// int2cstr needs buffer to hold value 
	BL int2cstr		// call int2cstr to convert array[i] to cstring
	
	LDR X0, =szCurrentNum	// Load address of current num for putstring
	LDR X1, =fdOut		// Load address of file descriptor for output file
	LDR X1, [X1]		// fputstring needs file descriptor in X1, load value from address
	BL fputstring		// call fputstring: output current number to output file
	LDR X0, =szEOL		// load address of newline
	LDR X1, =fdOut		// Load address of file descriptor for output file
	LDR X1, [X1]		// fputstring needs file descriptor in X1, load value from address
	BL fputstring		// print new line

	ADD X14, X14, #1	// increment lcv
	LDR X3, =cArrNum	// Load address of our count
	LDR X3, [X3]		// Load value of our count
	CMP X14, X3		// Check if we have printed full array
	B.LT output_sorted	// loop to print next value

	// Close output file
	LDR X0, =fdOut		// Load address of file desriptor for output file
	LDR X0, [X0]		// Move value of file descriptor from address into register
	MOV X8, #57		// Sys call number for close
	SVC 0			// Supervisor call

	B terminateBubble	//exit

invalidFileIn:

	LDR X0, =inFError	// Load address of error message
	BL putstring		// print error message

	LDR X0, =szInputFile	// Load address of incorrect filename
	BL putstring		// print error file
	printEOL		// print newline
	B terminateBubble	// end program

invalidFileOut:

	LDR X0, =outFError	// Load address of error message
	BL putstring		// print error message

	LDR X0, =szOutFile	// Load address of incorrect filename
	BL putstring		// print error file
	
	B terminateBubble	// end program

tooManyEntries:

	LDR X0, =maxFlag	// Load adderss of max flag
	MOV X1, #1		// Flag value for max flag
	STR X1, [X0]		// Store active flag value in flag address

	LDR X0, =exceedWarning1	// Load first part of the message
	BL putstring		// print warning part 1

	MOV X0, MAX_ARR_SZ	// Load address of max array size
	LDR X1, =szMAX_SZ	// Load address of string representation for MAX_SZ
	BL int2cstr		// Convert MAX_ARR_SZ to cstring so we can print
	LDR X0, =szMAX_SZ	// Move converted value into X0 for putstring
	BL putstring		// warning 1 + size print

	LDR X0, =exceedWarning2	// Load address of second part of warning
	BL putstring		// warning1 + size + warning2 print
	
	LDR X0, =szInputFile	// Load address of filename with error
	BL putstring		// display filename with error

	LDR X0, =exceedAction	// Load address of action taken from excess entries
	BL putstring		// print final part of warning	
	printEOL		// print new line

	LDR X1, =cArrNum	// Load count address
	LDR X0, [X1]		// Load value of count
	ADD X0, X0, #1		// Increment to negate decrement due to accounting for EOL
	STR X0, [X1]		// Store new count value
	B sort_list		// Ignore the rest of the file and sort list

terminateBubble:

	// close files
	LDR X0, =fdOut		// Load address of file desriptor for output file
	LDR X0, [X0]		// Move value of file descriptor from address into register
	MOV X8, #57		// Sys call number for close
	SVC 0			// Supervisor call

	LDR X0, [SP]		// file desc for input file
	MOV X8, #57		// SyS call number for close()
	SVC 0			// Supervisor call
	
    	// terminate the program
    	MOV X0, #0 // set return code to 0, all good
    	MOV X8, #SYS_exit // set exit() supervisor call code
    	SVC 0 // call Linux to exit

	.data // data section

szEOL:		.asciz	"\n"
inFPrompt:	.asciz	"Enter input file name  :"
outFPrompt:	.asciz	"Enter output file name :"
inFError:	.asciz	"Fatal error: failed to open input file "
outFError:	.asciz	"Fatal error: failed to open output file "
exceedWarning1:	.asciz	"Warning: more than "
exceedWarning2:	.asciz	" entries found in input file "
exceedAction:	.asciz	". Ignoring additional entries."
szInputFile:	.skip	64	// Array to hold string file name
szOutFile:	.skip	64	// Array to hold string out file name
szMAX_SZ:	.skip	16	// String array to hold string conversion of max_arr_sz
rgiArrNum:	.skip	MAX_ARR_SZ * 8	// an array of size MAX_ARR_SZ that holds quad integers
szCurrentNum:	.skip	64	// String array to hold the current number read from the file in ascii form
i64CurrentNum:	.quad	0	// Quad buffer to hold current converted value
fdOut:		.quad 	0	// Quad to hold the output file descriptor
cArrNum:	.quad	0	// quad to hold the count of our array
maxFlag:	.quad	0	// flag to check if we hit maximum entries

.end // end of program, optional but good pra
