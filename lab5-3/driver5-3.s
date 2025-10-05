// Jose Mejias
// CS3B - lab5-3 - assembly driver
// 10/04/2025
// output the tested c-strings to the console using cstr2int

.global _start

_start:

	.text  // Code section

	// Test 1: "99"
   	LDR    	X0, =test1  	// Load the address of test1 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the address of the newline string into X0.
	BL 	putstring      	// Output the newline.

	// Test 2: "123456789"
   	LDR    	X0, =test2  	// Load the address of test2 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the address of the newline string into X0.
	BL 	putstring      	// Output the newline.

	// Test 3: "1"
   	LDR    	X0, =test3  	// Load the address of test3 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the address of the newline string into X0.
	BL 	putstring      	// Output the newline.

	// Test 4: "-1111"
   	LDR    	X0, =test4  	// Load the address of test4 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the address of the newline string into X0.
	BL 	putstring      	// Output the newline.
	
	// Test 5: "0"
	LDR    	X0, =test5  	// Load the address of test5 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the addres
	BL	putstring	// Output the newline
	
	// Test 6: "-9223372036854775808"
	LDR    	X0, =test6  	// Load the address of test6 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the address of the newline string into X0.
	BL 	putstring      	// Output the newline.
	
	// Test 7: "-9223372036854775809"
	LDR    	X0, =test7  	// Load the address of test7 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the address of the newline string into X0.
	BL 	putstring      	// Output the newline.
	
	// Test 8: "9223372036854775807"
	LDR    	X0, =test8  	// Load the address of test8 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the address of the newline string into X0.
	BL 	putstring      	// Output the newline.
	
	// Test 9: "9223372036854775808"
	LDR    	X0, =test9  	// Load the address of test9 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the address of the newline string into X0.
	BL 	putstring      	// Output the newline.
	
	// Test 10: "9223372036845775809"
	LDR    	X0, =test10  	// Load the address of test10 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the address of the newline string into X0.
	BL 	putstring      	// Output the newline.
	
	// Test 11: "999999999999999999999"
	LDR    	X0, =test11  	// Load the address of test11 into X0.
   	BL 	cstr2int	// call cstr2int to convert the string to integer
	LDR 	X1, =buffer    	// Load the address of the conversion buffer into X1.
	BL 	int2cstr       	// Convert the integer in X0 back into a C-string.
	LDR 	X0, =buffer    	// Load the address of the converted string (buffer) into X0.
	BL 	putstring      	// Output the converted string.
	LDR 	X0, =newline   	// Load the address of the newline string into X0.
	BL 	putstring     	// Output the newline.

	// terminate the program
	MOV	X0, #0		// set return code to 0, all good
	MOV 	X8, #93       	// Syscall number 93 is exit.
	SVC	0             	// call linux to terminate.

	 // Data section
	.data
// test c-string
test1:  .asciz "99"
test2:  .asciz "123456789"
test3:  .asciz "1"
test4:  .asciz "-1111"
test5:  .asciz "0"
test6:  .asciz "-9223372036854775808"
test7:  .asciz "-9223372036854775809"  // Should overflow
test8:  .asciz "9223372036854775807"
test9:  .asciz "9223372036854775808"   // Should overflow
test10: .asciz "9223372036854775809"   // Should overflow
test11: .asciz "9999999999999999999"   // Should overflow

buffer: .skip 32  // Avoid alignment issues.
newline: .asciz	"\n"	// Newline string.

.end	// end of function, optional but good practice
