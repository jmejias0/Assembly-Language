// Jose Mejias
// CS3B - Lab1-2 - assembly driver
// 08/28/2025
// Outputs test characters to the console using putch
// Algoritm/Pseudocode:
//	Input:
//	Processing:
//	Output:
//	Terminate program

.global _start	// Provide program starting address

_start:

	.text	// code section
	LDR	X0, =strTest1	// load X0 with pointer to test string
	BL 	putch		// call putch function
	LDR	X0, =strTest2	// load X0 with pointer to test string
	BL	putch		// call putch function
	LDR	X0, =strTest3	// load X0 with pointer to test string
	BL 	putch		// call funtion putch
	LDR	X0, =strTest4	// load X0 with pointer to test string
	BL	putch		// call funtion putch
	LDR	X0, =strTest5	// load X0 with pointer to test string
	BL	putch

	LDR	X0, =strEol	// load X0 with pointer to eol string
	BL	putch		// call putch funtion

	// Terminate the program

	MOV 	X0, #0		// set run code to 0, all good
	MOV 	X8, #93		// set service code to 93 for terminate
	SVC	0		// Call linux to terminate

	.data
strTest1:	.ascii	"A"
strTest2:	.ascii 	"a"
strTest3:	.ascii	"!"
strTest4:	.ascii	"@"
strTest5:	.ascii	"ZZZ"
strEol:		.ascii	"\n"


.end
