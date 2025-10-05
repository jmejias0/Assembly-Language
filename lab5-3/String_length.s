// Jose Mejias
// CS3B - lab4-1 - String_length
// 9/13/2025
// Provided a pointer to a null terminated string in X0,
// will return the string's length in X0
// Pseudocode/Algoritm:
//	Input: N/A
//	Processing: initialize register X2 to 0 (counter)
//				load content of X0 into W1
//				Compare if W1 is 0, if it is, jump to done
//				increment X2 by 1 and move to next character
//				repeat until is finis
//				done:
//	              		   move the content of X2 (counter) into X0
//	Output: N/A

.global String_length

	.text	// code section

String_length:

	MOV X2, #0	// initialize lenght counter

loop:
	LDRB	W1, [X0]	// load a byte
	CMP 	W1, #0		// compare byte with eith0
	B.EQ	done		// if zero, it is done
	ADD	X2, X2, #1	// increment counter
	ADD	X0, X0, #1	// move to next character
	B	loop		// keep doing until finish

done:
	MOV	X0, X2		// Move length in X2 to X0, return value
	RET			// return from the function

.end		// end of function, good practice
