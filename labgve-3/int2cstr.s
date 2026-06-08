// int2cstr.s
// CS3B - Lab5-2 - int2cstr
// 09/27/2025
// Converts a signed integer into a null-terminated C-string
// Stores the result in the buffer provided in X1
// Uses only X0 - X8 as per course requirement
// pseudocode/algortitm:
//	input: signed integer n (store in registe X0)
//	       pointer buffer to prre-allocate memory (store in register X1)
//
//	Processing: Copy what it's in register X0 into register X2 for modification.
//		    If number (X2) is equal to 0 store character '0' at buffer
//		    append a null terminator (\'0') to the buffer and exit function.
//		    Initialize pointer (X6) that points the begenning of the digit.
//		    If number (X2) is negative store character '-' in buffer.
// 		    Increase buffer pointer, set X6 to current buffer pointer. 
//		    Convert number to its absolute value.
//		    Implement while loop (X2 >= 0) get the reminder using unsigned division, 
//		    multiplication and subtraction, then convert the reminder into
//		    ASCII using addition (adding '0'), then update X2 with quotient.
//		    Digits in reverse, use two pointers to swap order.
//		    Append null terminator to the current buffer pointer.
//
//	Output:	Null terminated string representation of the original signed integer
//
//	dividen: 	X2
//	divisor:	X7
//	quotient: 	X8
//	reminder: 	X5

.global int2cstr

int2cstr:

	.text	// code section
	
	MOV	X2, X0		// Copy input number to X2
	MOV 	X3, X1 		// current output buffer pointer
	MOV 	X4, #0 		// Counter for digits
	MOV	X7, #10		// set divisor to 10

	CMP	X2, #0		// compare value of X2 with zero
	B.EQ	its_zero	// go to its_zero if it is zero
	
	MOV	 X6, X3		// X6 will point to first digit


convert:
	
	CMP	X2, #0		// check if number is positive
	B.GE	loop		// if positive skip
	
	//handle negative sign
	MOV	X4, '-'		// store '-' character 		
	STRB	W4, [X3], #1	// store and advance buffer
	MOV	X6, X3		// update digit dubstring start pointer
	NEG	X2, X2		// convert umber to positive

loop:

	UDIV	X8, X2, X7	// X2 % X7 = quotient, quotient stored in X8
	MUL	X5, X8, X7	// quotient (x8) * 10 and store in X5
	SUB 	X5, X2, X5	// dividend - (quotient * 10)
	ADD	W5, W5, '0'	// convert reminder to ASCII	
	STRB	W5, [X3], #1	// store digit at buffer position
	MOV 	X2, X8 		// update X2 with quotient
	CBNZ 	X2, loop	// if X2 is zero, finish conversion

	SUB	X7, X3, #1	// X7 = pointer to last digit

swap:

	CMP 	X6, X7 		// Check if pointers crossed
	B.GE 	done 		// If so, we're done

	LDRB 	W4, [X6] 	// Load first character
	LDRB 	W5, [X7] 	// Load last character
	STRB 	W5, [X6] 	// Swap
	STRB 	W4, [X7] 	// Swap
	ADD 	X6, X6, #1 	// Move forward
	SUB	X7, X7, #1	// move backward
	B 	swap	 	// Continue reversing

done:

	MOV	W4, #0
	STRB	W4, [X3]
	RET			// return from the function

its_zero:

	MOV	W4, '0'		// Load ASCII value for '0' into W4
	STRB	W4, [X3], #1	// store '0' into adrees X3, then increment by 1
	MOV	w4, #0		// load 0 into register X4 to represent null terminator
	STRB	W4, [X3]	// store null terminator at the current address in X3
	RET			// return from the function

.end	// end of function, good practice
