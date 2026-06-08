// Jose Mejias
// CS3B - labgve-3 dataLT.s
// 12/6/2025
// ****************** HELPER FUNCTION : dataLT ********************
// Function definition: bool dataLT(Sensor* sptr1, Sensor* sptr2)
// Parameters:
//		X0: Pointer to Struct Sensor1
//		X1: Pointer to Struct Sensor2
// Return:
//		X0: Non-zero if S1.reading < S2.reading, else 0
// Algorithm:
//		Offset pointers to Sensor_reading
//		Load values
//		Comparison: S1.reading < S2.reading?
//		Return: 1 if true, 0 otherwise 
// *****************************************************************
// sensor struct "definition"
.EQU Sensor_name,    0 // char*/quad name string ptr offset
.EQU Sensor_ID,      8 // int32/word sensor ID offset
.EQU Sensor_reading,12 // double/quad sensor reading offset
.EQU Sensor_size,   20 // size of the struct (20 bytes)
// Linked list node struct "definition"
.EQU Node_data, 0    // quad data element offset
.EQU Node_next, 8    // quad linked list next pointer offset
.EQU Node_size, 16   // size of the linked list node (two quads)

.global dataLT

dataLT:
	MOV X2, #Sensor_reading		// Copy immediate value sensor.reading offset into register
	ADD X0, X0, X2				// Offset sensor pointer to sensor.reading position
	LDR X0, [X0]				// Load value inside pointer: sensor.reading

	ADD X1, X1, X2				// Offset sensor pointer to sensor.reading position
	LDR X1, [X1]				// Load value inside pointer: sensor.reading

	MOV X2, #1					// Return value
	CMP X0, X1					// Compare reading values
	B.LT endDataLT				// if less than, end and return 1
	MOV X2, #0					// if not less than, return 0
endDataLT:
	MOV X0, X2		// Move return value to X0
	RET				// Return to caller
