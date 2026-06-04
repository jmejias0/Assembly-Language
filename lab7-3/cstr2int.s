// Jose Mejias
// CS3B - lab5-3 - cstr2int
// 10/04/2025
// uses a driver to call functions to convert the c-string into an integer
// pseudocode/algorithm:
//	input: A null-terminated string (C-string) representing an integer, 
//             passed as a pointer (address of the string).
//
//	processing: initialize variables
//		    result = 0 (Stores the final integer result, initialized to 0).
//		    negativeFlag = 0 (Indicates whether the number is negative, initialized to 0).
//		    multiplier = 10 (Constant used for multiplying during conversion).
//		    Check for negative sign:
//		    Load the first character of the string.
// 		    If the first character is '-':i
//		    Set negativeFlag = 1 (Mark the number as negative).
//		    Move the pointer to the next character.
//		    Convert characters to integer:
//		    While the current character is not the null terminator:
//		    Load the next character from the string.
//	     	    If the character is a valid digit (between '0' and '9'):
//		    Convert the character to its corresponding integer (subtract '0' from the 
//		    ASCII value).
//		    Multiply result by 10 and add the converted digit.
//		    If the character is not a valid digit:
//		    Return 0 (Indicating invalid input or overflow).
//    		    Check for overflow:
//		    Before updating the result, check for overflow by multiplying the current result 
//		    by 10 and adding the new digit.
//		    If the result after the operation is less than the previous result (indicating 
//		    an overflow), return 0.
//		    Handle sign:
//		    If negativeFlag is set (i.e., the number is negative):
//		    If the result is -9223372036854775808, check for overflow.
//		    If the result exceeds this value, return 0 (Indicating overflow).
//		    Otherwise, negate the result to make it negative.
//		    Return the result:
//		    Return the final computed integer (either positive or negative depending 
//		    on the flag).
//                  
//	output: An integer corresponding to the converted value of the input string, 
//		or 0 in case of invalid input or overflow.

.global cstr2int

cstr2int:

    	MOV     X2, #0          // X2 will store the result (initialized to 0)
    	MOV     X6, #0          // X6 used as a "negative flag", 0 = positive, 1 = negative 
    	MOV     X7, #10         // X7 holds constant 10
	LDRB    W1, [X0]        // Load first character

	CMP     W1, #'-'         // Check if first character is '-'
	B.EQ    negative_case   // If it is, branch to negative case
	B	convert_loop


negative_case:

	MOV     X6, #1          // Mark as negative
	ADD     X0, X0, #1      // Move to the next character

convert_loop:

	LDRB    W1, [X0], #1   // Load next character and move pointer
	CBZ     W1, apply_sign  // If null terminator, process the result

	// Convert ASCII digit to integer
	SUB     W3, W1, #'0'    // W3 = current digit (0 - 9)
	CMP     W3, #9          // Ensure it's a valid digit
	B.HI	overflow        // If not, handle overflow

	CMP	X6, #1		// Check if X6 is negative ( X6 = 1)
	B.EQ	negative_path	// If X6 is equal to 1 negative go to negative_path

	// Overflow detection before multiplying	
	MOV     X4, X2          // Copy current result to X4 for checking
 	MUL     X4, X4, X7      // Multiply by 10
	ADD     X4, X4, X3      // Add new digit
	
	// Check overflow conditions
	CMP     X4, X2          // If X4 < X2, overflow has occurred	
	B.LT   overflow

	// Store the new valid result
	MOV     X2, X4		// save new ivalid result 
	B       convert_loop    // Continue loop

negative_path:

	MOV	X4, X2		// copy current result in X4
	MUL	X4, X4, X7	// Multiply the result by 10 (X7)
	SUB	X4, X4, X3	// Subtract the digit, accumulating negative
	CMP	X4, X2		// If X4 > X2, overflow has ocurred 
	B.GT	overflow
	MOV	X2, X4		// save the new valid result
	B	convert_loop	// repeat loop for next character

apply_sign:

	MOV	X0, X2		// move final result into X0  

	// Clear overflow flag (V = 0)
	MOV	X1, #0		// Store 0 into X1
	ADDS	X1, X1, #0	// Add 0 + 0, resets the condition flag
    	RET			// return to caller

overflow:

    	MOV     X0, #0          // Return 0 on overflow

	// Force overflow flag (V = 1)
	MOV	X1, #0		// Store 0 into X1
	ADDS	X1, X1, #-1	// Add 0 + (-1), triggers overflow flag
    	RET			// return to caller

.end	// end of function, good practice
