// Jose Mejias
// CS3B - Lab gve-3 - In struct or rules
// 12/6/2025
//
// **************************** Lab gve-3 - In struct or rules *********************************
// In this lab, we use our linked list implementation from lab gve-2, but each data field will
// now point to a dynamically allocated struct. The dataLT function will be reimplemented to now
// compare values stored in the structs pointed to by the node data field rather than the node
// data field itself.
// This program will read an unknown number of sensor data sets (name, id, reading)
// from a file, save them in a linked-list of dynamically allocated structs, output
// the list, delete the min and max sensor readings, output the list again, and
// finally free up all memory including dynamically allocated strings.
// *********************************************************************************************
//
// -------- Algorithm --------
// Open file, save fd
// Getline in groups of 3:
//		Name: 	 cstr
//		ID:		 int32/word
//		Reading: double/quad
// If getline does not return 0, malloc to create data struct
// Create node with node.data = sensor struct ( 20 bytes )
// Populate linked list with node, close file when finished
// Loop through linked list and print data struct for each node 
// Output nodes with min and max data.sensor.reading attributes
// Delete min and max nodes
// Print entire linked list (now with min/max removed)
// Output min/max nodes for updated linked list
// Free all memory
// End.

.EQU SYS_exit, 93 // exit() supervisor call code
// sensor struct "definition"
.EQU Sensor_name,    0 // char*/quad name string ptr offset
.EQU Sensor_ID,      8 // int32/word sensor ID offset
.EQU Sensor_reading,12 // double/quad sensor reading offset
.EQU Sensor_size,   20 // size of the struct (20 bytes)
// Linked list node struct "definition"
.EQU Node_data, 0    // quad data element offset
.EQU Node_next, 8    // quad linked list next pointer offset
.EQU Node_size, 16   // size of the linked list node (two quads)
// File modifiers
.EQU	O_RDONLY, 0
.EQU	O_WRONLY, 1
.EQU	O_RDWR,   0002
.EQU	O_CREAT,  0100
.EQU	S_RDWR,   0666
.EQU	AT_FDCWD, -100

.macro  openFile    fileName, flags	// Modified macro from Stephen Smith, Chapter 8 of "Programming with 64-bit ARM Assembly language"
		MOV         X0, #AT_FDCWD	// X0 needs directory file descriptor; Current working directory
        LDR         X1, =\fileName	// X1 needs file name string buffer / char array
        MOV         X2, #\flags		// X2 holds the flags (Truncate/Create/RDWR/etc)
		MOV		    X3, #S_RDWR		// RW access rights
        MOV	    	X8, #56			// X8 needs Sys_Call number for openat()
        SVC         0				// Make supervisor call
.endm

.macro	closeFile	fileDesc
// Calls close() with fileDesc
		MOV 		X0, \fileDesc	// Close needs file desc in X0
		MOV 		X8, #57			// SYS_CALL number for close()
		SVC	0						// Supervisor call to close file
.endm

.macro	printLine		stringBuff
// Prints stringBuff followed by newline
		LDR X0, =\stringBuff	// Load address of string buffer
		BL putstring			// print string to console
		LDR X0, =szEOL			// Load address of EOL
		BL putstring			// print newline
.endm

.macro readLine			storeBuff
// Read one line from file and stores it in storeBuff
	LDR X1, =\storeBuff	// string buffer for getline
	MOV X0, #0		// Copy 0 into register
	STR X0, [X1]	// Reset storeBuff: store 0 in address
	MOV X2, #32		// max length of buffer
	MOV X0, X9		// file descriptor in X0
	BL getline		// Call getline
	CMP X0, #0		// Check length of read from getline
	B.EQ endInput	// If we read 0 bytes, we are at EOF, end loop
	printLine \storeBuff	// debugging line
	LDR X0, =szData		// Load address of data we just read
.endm

.macro checkListEmpty	headStorage, endLabel
// Checks if head pointer inside headStorage is empty and branches to endLabel if so.
		LDR X0, =\headStorage	// Load address of head pointer storage
		LDR X0, [X0]			// Load value of head pointer: object pointer or NULL
		CMP X0, #0				// Check if head points to NULL
		B.EQ \endLabel			// If NULL, the list is empty, branch to end
.endm

.macro	printLinkedList		headPTR
// Given headPTR will output the entire linked list to console 
// Algo: Starting at head pointer, for each next object, convert it's data members to string and print to console
		MOV X9, \headPTR	// Copy head pointer to X0 to begin loop
		LDR X9, [X9]			// Load value of head pointer: object pointer
printNodeLoop\@:
		ADD X0, X9, Node_data	// Move pointer to position of Node.data
		LDR X10, [X0]			// Get value stored in Node.data: Sensor object
		ADD X0, X10, Sensor_name	// Offset struct pointer to sensor.name field
//		printLine X0			// Print sensor.name
		LDR X0, [X0]
		BL putstring
		LDR X0, =szEOL
		BL putstring

		MOV X0, #0				// Copy 0 into register
		LDR X1, =szData			// Load address of int string buffer
		STR X0, [X1]			// Clear szData
		ADD X0, X10, Sensor_ID	// Offset struct pointer to sensor.id field
		BL int2cstr				// Convert int X0 and store into string buffer X1
		printLine	szData		// print converted integer to console

		ADD X0, X10, Sensor_reading	// Offset pointer to sensor.reading field
		LDR D0, [X0]			// Load the value X0 into D0
		LDR X0, =formattingString	// printf needs formatting string
		BL printf				// Call printf(X0: formattingString address, D0: double to print)

		MOV X0, X9				// Copy node object pointer to X0
		ADD X0, X0, Node_next	// Offset pointer to position of Node.next
		LDR X9, [X0]			// Load value of Node.next pointer into register: Node.next
		CMP X9, #0				// Compare Node.next desination to NULL
		B.NE	printNodeLoop\@	// If Node.next is NULL, we are at the final node. End loop
.endm

.global _start // Provide program starting address

_start:

	.text	// code section

	openFile	szInputFN, O_RDWR	// Open input file with read-write perms
	MOV X9, X0	// Save file descriptor
	
readFileLoop:
// Read struct
	// Read and store name
	readLine szData		// Read line 1: Sensor name
	LDR X1, =szSensName	// Load address of Sensor_name storage
	STR X0, [X1]		// Store data we just read into storage
	
	// Read and store ID
	readLine szData		// Read line 2: Sensor ID
	BL cstr2int			// converts szData(ID) in X0 from cstring to quad int
	LDR X1, =i32ID		// Load address of Sensor_ID storage
	STR X0, [X1]		// Store converted ID (data) to storage
	
	// Read and store Reading
	readLine szData		// Read line 3: Sensor Reading
	BL cstr2dfp			// Convert szData(Reading) in X0 from cstring to doubleFP
	LDR X1, =dReading	// Load address of Sensor.Reading storage
	STR D0, [X1]		// Store double into storage

// Create Struct
	LDR X2, =szSensName	// Load address of name storage
	LDR X0, [X2]		// Load value of name in X0

	LDR X2, =i32ID		// Load address of ID storage
	LDR W1, [X2]		// Load value of ID into W1
	
	LDR X2, =dReading	// Load address of reading
	LDR D2, [X2]		// Load value of reading into D2

// Create Node
	BL Sensor	// Call Sensor* Sensor(const char *name, word ID, double reading, word size) 
	BL node		// Call Node* Node(quad data) with the returned Sensor* in X0
	MOV X1, X0			// Copy Node pointer returned in X0 to X1
	LDR X0, =pHeadptr	// Load address of head pointer
	BL addNode	// Call Node* addNode(Node* head, Node* node)

// Reset storage containers
	MOV X0, #0			// Move immediate value 0 into X0
	LDR X1, =szSensName // Load address of name storage
	STR X0, [X1]		// Store 0 into buffer (clear)
	LDR X1, =i32ID		// Load address of ID storage
	STR X0, [X1]		// Store 0 into buffer (clear)
	LDR X1, =dReading	// Load adderss of reading storage
	MOV X2, #0			// Move immediate value 0 into register
	FMOV D0, X2			// Move immediate value double 0 into register
	STR D0, [X1]		// Store 0.0 into buffer (clear)

	B readFileLoop		// Loop to read next struct

endInput:
	closeFile	X9		// close file stream for input file
	LDR X0, =pHeadptr	// Load address of head pointer storage
	printLinkedList	X0	// Print linked list starting from head pointer
	printLine	szSection	// Print section separator

    // terminate the program
    MOV X0, #0 // set return code to 0, all good
    MOV X8, #SYS_exit // set exit() supervisor call code
    SVC 0 // call Linux to exit
    
	.data
	
szEOL:		.asciz	"\n"				// new line character 
szInputFN:	.asciz	"gve-3input.txt"	// input file name
pHeadptr:	.quad 0		// Buffer to store heap address of list head pointer
szData:		.skip 32	// string buffer to hold line of data read from file
szSensName:	.skip 32	// string buffer to hold sensor name from file
i32ID:		.word 0		// int32 word to hold converted string for ID
dReading:	.double 0.0	// double to hold sensor Reading
szSection:	.asciz	"======================= Function End =======================\n"// Section separator
formattingString:	.asciz		"%.20f\n"	// For printf
	

// ************************************** Sensor Struct Functions **************************************


// **************** HELPER FUNCTION : CREATE SENSOR *****************
// Description: 
//	  Dynamically creates a struct:
//		Struct Sensor {
//			char* 	  name;
//			int32   	ID;
//			double reading;
//		}
// Function header:
//    Sensor* Sensor(const char *name, word ID, double reading, word size) 
//		X0: char[] name (stringptr)
//		X1/W1: int ID (word)
//		D2: double reading
//		X3/W3: size (word) -- size of the sensor struct
// Returns:
//		A pointer to a sensor struct in X0.
// Algorithm:
//		Save data in X0-2 to the stack before calling naughty malloc
//		Call Malloc with size W3, save pointer to heap address
//		Offset sensorObjPtr by Sensor_name
//		Store name (X0) in updated pointer position
//		Offset sensorObjPtr by Sensor_ID
//		Store ID (X/W2) in updated pointer position
//		Offset sensorObjPtr by Sensor.Reading
//		Store Reading (X2) in updated pointer position
//		Return sensorObjPtr
Sensor:
	STR LR, [SP, #-16]!		// Save LR to prepare for malloc call
	STR X0, [SP, #-16]!		// Save name to the stack
	STR X1, [SP, #-16]!		// Save ID to stack
	STR D2, [SP, #-16]!		// Save reading to stack

	MOV X0, #Sensor_size		// Copy the size of sensor struct to X0 for malloc
	BL malloc		// Call malloc
	MOV X19, X0		// Save pointer starting position

	LDR D0, [SP], #16		// Load Reading from stack
	MOV X2, #Sensor_reading	// Move offset for Sensor.Reading to X2
	ADD X1, X19, X2			// Offset placement ptr to position of Sensor.Reading
	STR D0, [X1]			// Store double float reading in position of Sensor.Reading

	LDR X0, [SP], #16		// Load ID from stack
	MOV X2, #Sensor_ID		// Move offset for Sensor_ID to X2
	ADD X1, X19, X2			// Offset placement ptr to position of Sensor_ID
	STR X0, [X1]			// Store name in position of Sensor_ID

	LDR X0, [SP]			// Load name from stack, but do not pop
	BL String_length		// Get the length of the string
	ADD X0, X0, #1			// Add 1 to length for null terminator, store in X0
	BL malloc				// malloc memory to store string
	LDR X1, [SP], #16		// pop and load name from stack
	BL strcpy				// char *strcpy(char *dest, const char *src): Copy name into heap address

	MOV X2, #Sensor_name	// Move offset for Sensor_name to X2
	ADD X1, X19, X2			// Offset placement ptr to position of Sensor_name
	STR X0, [X1]			// Store namePtr we just made into position of Sensor_name

	MOV X0, X19				// Move struct pointer to X0 to prepare for return
	LDR LR, [SP], #16		// Restore LR to prepare for return
	RET						// Return to caller	



// ****************** HELPER FUNCTION : Delete Sensor ********************
//	Description: deletes struct, will free name for name field and struct.
//	Function Definition: void delSensor(Sensor* sensorPtr)
//	Parameters:
//		X0: Pointer to Struct Sensor object
// 	Algorithm:
//		Save struct pointer before calling naughty free
//		Offset pointer to Sensor_name field
//		Load value inside Sensor_name: heap address that stores a string
//		Free heap address for name storage
//		Reload struct pointer
//		Free heap adderss for struct
//NOTE: This function makes calls to free(), which modifies the following registers:
//		X0, X1, X3, X4, X5, X6, X7, X8, X12, X13, X16, X17.
//		Caller should save any important data before calling this function.
delSensor:
	STR LR, [SP, #-16]!		// Save LR

	MOV X2, X0				// Save struct pointer
	MOV X1, #Sensor_name	// Move offset for Sensor_name
	ADD X0, X2, X1			// Offset struct pointer to position of Sensor_name
	LDR X0, [X0]			// Load value of Sensor_name: heap address that stores name string
	BL free					// free memory for name

	MOV X0, X2				// Reload struct pointer
	BL free					// free memory for struct

	LDR LR, [SP], #16	// Restore LR
	RET					// Return to caller

// ************************************** END Sensor Struct Functions **************************************


