// Jose Mejias
// CS3B - labgve-2 - dataLT.s
// 11/29/2025
// ****************** HELPER FUNCTION : dataLT ********************
// Function definition: bool dataLT(quad data1, quad data2)
//	 returns non-zero if data1 < data2, else returns 0
// Parameters:
//		X0: data1 (quad type int)
//		X1: data2 (quad type int)
// Return:
//		X0: 0 if data1<data2, else 1
// Algorithm:
//		Compare values
//		Set X0 accordingly
//		End
// ***************************************************************

.global dataLT

dataLT:

	STR X2, [SP, #-16]!	// Save X2 in the stack in case it's being used before function call
	MOV X2, #0		// Initialize return value to 0
	CMP X0, X1		// Compare data values
	B.GE end_dataLT	// If data1 < data2, return 0
	MOV X2, #1		// Else, return nonzero
	
end_dataLT:

	MOV X0, X2		// Set X0 to prepare for return
	LDR X2, [SP], #16	// Restore X2 to it's original value
	RET				// Return to caller
	
.end	// end of function, optional but good practice
