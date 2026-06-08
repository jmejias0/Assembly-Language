// George Eaton
// CS3B - midterm assembly driver for fputstring
// 10/30/2025
// call fputstring to output a C-String to a file

.global _start // Provide program starting address

_start:

    .EQU STDOUT,     1  // standard output file descriptor
    .EQU SYS_exit,  93  // exit() supervisor call code

    .EQU AT_FDCWD, -100 // arg0 passed to openat indicating that
                        // the filename in arg1 is relative to 
                        // the current directory

    //
    // *** add your constants here ***
    //
    .EQU OPENAT, 56		// Sys call number for openat()
    .EQU RW_RW____, 0660	// Permissions: Owner read/write, Group read/write, others none
    .EQU TCRW, 01102	// Flags: Truncate, create if doesn't exist, read/write flags

    .text  // code section

    // test fputstring by outputting to the console
    LDR X0, =test1      // load X0 with pointer to test string
    MOV X1, #STDOUT     // load X1 with the standard out file descriptor
    BL fputstring       // call fputstring function.


    //
    // ***  put your code here to handle opening the output file (create 
    // ***  and truncate) and calling fputstring to output it to the file
    // ***  with the name szOutFileName label below. You do NOT need to check 
    // ***  if the file is opened successfully nor do any user input/output
    // ***  (e.g. prompting or messages). Remember to close the file.
    //
	
	// Open the file: openat( DirFileDescriptor , *filename[], flags , permissions ) -> X0 : File Descriptor
    MOV X0, AT_FDCWD 		// At current working director
    LDR X1, =szOutFileName	// open needs file name string in X1
    MOV X2, TCRW		// Flags: Truncate, Create if not, Read/Write
    MOV X3, RW_RW____		// Permissions: Owner read/write, Group read/write, others none
    MOV X8, OPENAT		// SYS_CALL: Openat()
    SVC 0			// Supervisor call

	// Now, we have a fd in X0. fputstring takes two parameters X0: output string | X1: fd
    MOV X1, X0		// Place fd where fputstring wants it
    LDR X0, =test1		// fputstring needs string to print
    BL fputstring		// call putstring
	
    // terminate the program

    MOV X0, #0          // set return code to 0, all good
    MOV X8, #SYS_exit   // set service code to 93 for terminate
    SVC 0               // Call Linux to exit


    .data   // data section
test1:          .asciz  "CS3B rocks!\n" // test C-String
szOutFileName:  .asciz  "output.txt"    // output file name


.end  // end of program, optional but good practice
