// Jose Mejias
// CS3B - lab6-1 - getstring
// 10/11/2025
////*****************************************************************************
//getstring
//  Function getstring: Will read a string of characters up to a specified length
//  from the console and save it in a specified buffer as a C-String (i.e. null
//  terminated).
//  
//  X0: Points to the first byte of the buffer to receive the string. This must
//      be preserved (i.e. X0 should still point to the buffer when this function
//      returns).
//  X1: The maximum length of the buffer pointed to by X0 (note this length
//      should account for the null termination of the read string (i.e. C-String)
//  LR: Must contain the return address (automatic when BL
//      is used for the call)
//  All AAPCS mandated registers are preserved.
//*****************************************************************************
// pseudocode/algorithm:
//	Input: Pointer X0, to the buffer where the string will be stored 
//	       X1, maximum buffer length (incuding null terminator)
//
// 	Processing: Save necessary registers (X19 and LR).
//		    Copy the buffer pointer (X0) into X19 for preservation.
//		    Set up the system call to read input from stdin:
//		    Store the maximum length (X1) into X2.
//		    Subtract 1 from X2 to reserve space for the null terminator.
//		    Use system call read (syscall #63) to read input from stdin into the buffer.
//		    Store the number of bytes read in X7.
//		    Process the input to check for a newline character:
//		    Iterate over the read bytes.
//		    If a newline (\n) is found, replace it with a null terminator (\0).
//		    If no newline is found, append a null terminator at the end of the string.
//		    Restore registers and return.
//
// 	Output: X0 remains pointing to the buffer.
//	       	The buffer contains the user-input string as a null-terminated C-string.

.global getstring

getstring:

	.text			      // code section

	MOV	X19, X0
        // Set up the Linux read syscall:
        MOV     X2, X1                // Copy maximum length into X2
        SUB     X2, X2, #1            // Subtract 1 to reserve space for null terminator
        MOV     X0, #0                // File descriptor 0 (stdin)
	MOV	X1, X19
        MOV     X8, #63               // Syscall number for read
        SVC     0                     // Call the read syscall
        // The number of bytes read is returned in X0. Save it in X7.
        MOV     X7, X0

        // Process the input to remove a newline if present
	MOV	X4, X19
        MOV     X3, X7                // X3 = number of bytes read

read_loop:

        CBZ     X3, newline	      // If no more bytes, branch to newline
        LDRB    W5, [X4]              // Load next character
        CMP     W5, #'\n'             // Compare with newline (ASCII '\n')
        B.EQ    newline		      // If newline, branch to newline_found
        ADD     X4, X4, #1            // Increment pointer
        SUBS    X3, X3, #1            // Decrement counter (and update flags)
        B       read_loop             // Continue loop

newline:

        MOV     W5, #0                // Prepare null terminator
        STRB    W5, [X4]              // Replace newline with null terminator
	B	restore_return

restore_return:

	MOV	X0, X19
        RET                           // Return to caller

.end	// end function, optional but good practice
