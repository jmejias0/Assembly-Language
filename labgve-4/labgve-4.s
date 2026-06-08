// Jose Mejias
// CS3B - Lab 4 - Search con struct
// 12/12/2025
//
// **************************** Lab 4 - Search con struct *********************************
// In this lab, we modify our driver program from gve lab 3 to call `find` using a set 
// of sensor company names and outputs either the found record or an appropriate 
// "not found" message.
// ****************************************************************************************
//
// -------- Algorithm --------
// Read file
// Create structs
// Populate linked list
// Close file
// Call find for each company name
// If found: output "Found <record>\n" 
// Else: output "<name> not found\n"
// Free all memory
// End.
//
// Pseudocode/Algorihm:
//   Input: Text file gve-3input.txt
//   Processing: Build linked list
//		Open gve-3input.txt for reading.
//		While getline returns a non-zero length:
//		Read line 1 -> copy to nameBuffer.
//		Read line 2 -> convert to integer with cstr2int.
//		Read line 3 -> convert to double with cstr2dfp.
//		Call Sensor(name, id, reading, size) to allocate and fill a Sensor struct.
//		Call Node(sensorPtr) to create a node.
//		Insert node at head of list with addNode(head, node).
//		Close the file.
//		Print full list
//		Starting from head, for each node:
//		Use existing print logic (printLinkedList / printSensor) to show name, ID, reading.
//		Search by company name
//		For each search string in the list of four companies:
//		Call find(head, targetName).
//		find:
//		Set current = head.
//		While current is not NULL:
//		Get currentName = current->data->name.
//		If strcmp(currentName, targetName) == 0 ? return current.
//		Else current = current->next.
//		If loop ends, return NULL.
//		strcmp:
//		While *str1 == *str2 and neither is '\0':
//		Advance both pointers.
//		Return (unsigned char)*str1 - (unsigned char)*str2.
//		If find returned a node pointer:
//		Print "Found " and then the record using printSensor.
//		Else:
//		Print "<name> not found".
//		Free all memory
//		Walk the list:
//		For each node:
//		Call delSensor to free the Sensor (including its name string).
//		Free the node itself.
//		End program with return code 0.
// Output:
//		Console listing of all sensor records read from the file.
//		For each of the four company names, one line indicating:
//		"Found <record>" if a matching sensor is in the list, or
//		"<name> not found" if there is no match.



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

.macro	printLineReg	stringReg
// Slightly modified printLine to work with register parameters
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
//	printLine \storeBuff	// debugging line
	LDR X0, =szData		// Load address of data we just read
.endm

.macro	printLinkedList		headPTR
// Given headPTR will output the entire linked list to console 
// Algo: Starting at head pointer, for each next object, convert it's data members to string and print to console
		MOV X9, \headPTR	// Copy head pointer to X0 to begin loop
		LDR X9, [X9]			// Load value of head pointer: object pointer
		LDR X1, =pCurrNode		// Load address of current node storage
printNodeLoop\@:
		STR X9, [X1]			// Store current node into pointer storage
		ADD X0, X9, Node_data	// Move pointer to position of Node.data
		LDR X10, [X0]			// Get value stored in Node.data: Sensor object
		ADD X0, X10, Sensor_name	// Offset struct pointer to sensor.name field
		LDR X0, [X0]			// Load value of Sensor.name field: heap address that stores name in asciz
		printLineReg X0			// Print sensor.name

		MOV X0, #0				// Copy 0 into register
		LDR X1, =szData			// Load address of int string buffer
		STR X0, [X1]			// Clear szData
		ADD X1, X1, #8			// Move to next 8 bytes of szData
		STR X0, [X1]			// Clear next 8 bytes

		ADD X0, X10, Sensor_ID	// Offset struct pointer to sensor.id field
		LDR W0, [X0]			// Load value in sensor.ID field: Sensor.ID int32
		LDR X1, =szData			// Load string buffer large enough to hold converted value
		BL int2cstr				// Convert int X0 and store into string buffer X1
		printLine	szData		// print converted integer to console

		ADD X0, X10, Sensor_reading	// Offset pointer to sensor.reading field
		LDR D0, [X0]			// Load the value X0 into D0
		LDR X0, =formattingString	// printf needs formatting string
		BL printf				// Call printf(X0: formattingString address, D0: double to print)

		LDR X1, =pCurrNode		// Load pointer to current node
		LDR X0, [X1]			// Load value of current node storage: node object pointer
		ADD X0, X0, Node_next	// Offset pointer to position of Node.next
		LDR X9, [X0]			// Load value of Node.next pointer into register: Node.next
		CMP X9, #0				// Compare Node.next desination to NULL
		B.NE	printNodeLoop\@	// If Node.next is NULL, we are at the final node. End loop
.endm

.macro searchForName	searchName
// Using head pointer, will search through the linked list
// for <searchName> and return the result
		LDR X0, =pHeadptr		// Load address of list head pointer
		LDR X0, [X0]			// Load value of head pointer storage: head pointer
		LDR X1, =\searchName	// Load address of search query
		BL find					// Call Node* find(Node *head, const char *targetName)
		CMP X0, #0				// compare find return value with NULL (0)
		B.NE 1f					// If not null, output found name message
		
		// If null, output not found message
		LDR X0, =\searchName		// Load address of name
		BL putstring			// Output name to console
		printLine	szNotFound	// Print not found message followed by new line
		B 2f					// end macro
1:
		LDR X0, =szFound		// Load address of found message
		BL putstring			// output message to console
		printLine \searchName	// Print name followed by new line
2:
.endm

.macro	deleteLinkedList	headPTR
// Given headPTR will delete and free the memory of the entire linked list
// Algo: For each node in list, save next object, free memory for current object until next->NULL.
		LDR X0, [X0]			// Load the value inside head pointer: First node object
		MOV X9, X0				// Copy pointer to node object into register
freeListLoop\@:
		ADD X9, X9, Node_next	// Move pointer to position of Node.next
		LDR X9, [X9]			// Load/Save value of Node.next before it gets freed: Next object
		STR X0, [SP, #-16]!		// Store node address in stack
		ADD X0, X0, Node_data	// Offset pointer to position of Node.data
		LDR X0, [X0]			// Load value of Node pointer: Node.data (Sensor struct)
		BL delSensor			// Call delSensor to free memory for struct
		LDR X0, [SP], #16		// Restore X0 to node pointer
		BL free					// free memory of current node
		MOV X0, X9				// Copy pointer to next object to register
		CMP X0, #0				// Compare next object to NULL (0)
		B.NE freeListLoop\@		// If next object is not null, loop
.endm

.global _start // Provide program starting address

_start:

	.text

	openFile	szInputFN, O_RDWR	// Open input file with read-write perms
	MOV X9, X0	// Save file descriptor
	
readFileLoop:
// Read struct
	// Read and store name
	readLine szData		// Read line 1: Sensor name
	LDR X1, =szData		// Move current read line into X1
	LDR X0, =szSensName	// Load address of Sensor_name storage
	BL strcpy			// call *strcpy(char *dest, const char *src): Copy line into name storage
	LDR X0, =szSensName	// Check if copied correctly
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
	LDR X0, =szSensName	// Load address of name storage

	LDR X2, =i32ID		// Load address of ID storage
	LDR W1, [X2]		// Load value of ID into W1
	
	LDR X2, =dReading	// Load address of reading
	LDR D2, [X2]		// Load value of reading into D2

	MOV X3, #Sensor_size	// Set size for sensor
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
	closeFile	X9				// close file stream for input file
	LDR X0, =pHeadptr	// Load adress of head pointer in X0
	printLinkedList	X0	// Print linked list starting from head pointer
	printLine	szSection		// Print section separator

// Search list and print found/not found messages
	searchForName szCompany1	// search list for name of company 1
	searchForName szCompany2	// search list for name of company 2
	searchForName szCompany3	// search list for name of company 3
	searchForName szCompany4	// search list for name of company 4

// Free all memory in linked list
	LDR X0, =pHeadptr			// Load address of head pointer storage
	deleteLinkedList pHeadptr	// free memory of linked list

    // terminate the program
    MOV X0, #0 // set return code to 0, all good
    MOV X8, #SYS_exit // set exit() supervisor call code
    SVC 0 // call Linux to exit

// ************************************** Lab 4 Functions **************************************

// **************** HELPER FUNCTION : FIND *******************
// Description:
//	This function searches through a linked list and
//	returns a pointer to the node that matches the
//	search query.
// Function definition:
//	Node* find(Node *head, const char *targetName)
//		X0: list head pointer
//		X1: Target name (string buffer)
// Algorithm:
//		Save current node
//		Read Node.data
//		If Node.data.name == target name: return current node
//		Else: update current node to currentNode.next
//		Loop until current node is NULL
find:
	LDR X2, =pCurrNode		// Load address of current node
	STR X0, [X2]			// Update current node
	CMP X0, #0				// Compare Node.next to NULL (0)
	B.EQ endFind			// If Node.next is NULL, end loop
	ADD X0, X0, #Node_data	// Offset node ptr to node.data position
	LDR X0, [X0]			// Load value of node.data: Sensor ptr

	ADD X0, X0, #Sensor_name	// Offset sensor ptr to position of Sensor.name
	LDR X0, [X0]			// Load value of Sensor.name: *char name
	STR X1, [SP, #-16]!		// Store X1 to prepare for strcmp call
	STR LR, [SP, #-16]!		// Store LR to prepare for strcmp call
	BL strcmp				// Call int strcmp(*Sensor.name, *targetName)
	LDR LR, [SP], #16		// Restore LR
	LDR X1, [SP], #16       // Restore X1
	CMP X0, #0				// strcmp will return 0 if the two strings are equal
	B.EQ endFind			// If two strings are equal, return
	
	LDR X0, =pCurrNode		// Load address of current node pointer
	LDR X0, [X0]			// Load value: pointer to current node
	ADD X0, X0, #Node_next	// Offset node pointer to position of Node.next
	LDR X0, [X0]			// Load value of node pointer: Node.next
	B find					// Loop until found or Node.next = NULL
endFind:
	LDR X0, =pCurrNode		// Load address of current node storage
	LDR X0, [X0]			// Load value of current node storage: current node pointer
	RET				// Return with pointer to node containing target name or NULL



// **************** HELPER FUNCTION : STRCMP *******************
// Description:
// This function will compare two strings and return 0 if the
// two strings are equal, and a nonzero value otherwise. The
// nonzero value will be positive or negative depending on the
// alphabetical order of the two inputs
// Function definition:
//	int strcmp(const char *str1, const char *str2)
//		X0: pointer to string buffer
//		X1: pointer to string buffer
//	Returns:
//		W0: Zero if strings are equal, nonzero otherwise
//	(str1 < str2 returns negative, str1 > str2 returns positive)
// Algorithm:
//		Compare str1[i] to str2[i]
//		Loop until str1[i] != str2[i] OR we reach end of one string
//		Return str1[i] - str2[i]
//	Modified Registers: X0, X1, W2, W3
strcmp:
	LDRB W2, [X0], #1		// Load leading char from string 1, increment ptr
	LDRB W3, [X1], #1		// Load leading char from string 2, increment ptr

	CMP W2, W3				// Compare the two chars
	B.NE endCMP				// If the chars are not equal, end compare

	CMP W2, #0				// Check if we are at null terminator (end of string)
	B.EQ endCMP				// If we are at the end of string, end loop

	B strcmp				// LOOP: while (*str1 != '\0' && *str2 != '\0' && *str1 == *str2)

endCMP:
	SUB W0, W2, W3			// return (unsigned char)*str1 - (unsigned char)*str2;
	RET						// Return to caller
// ************************************ End Lab 4 Functions ************************************

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
	STR W1, [SP, #-16]!		// Save ID to stack
	STR D2, [SP, #-16]!		// Save reading to stack

	MOV X0, X3		// Copy the size of sensor struct to X0 for malloc
	BL malloc		// Call malloc
	LDR X4, =pSensptr	// Load address of sensptr
	STR X0, [X4]		// Save pointer starting position in address, in case future functions modify registers
	MOV X4, X0		// Save pointer starting position

	LDR D0, [SP], #16		// Load Reading from stack
	MOV X2, #Sensor_reading	// Move offset for Sensor.Reading to X2
	ADD X1, X4, X2			// Offset placement ptr to position of Sensor.Reading
	STR D0, [X1]			// Store double float reading in position of Sensor.Reading

	LDR W0, [SP], #16		// Load ID from stack
	MOV X2, #Sensor_ID		// Move offset for Sensor_ID to X2
	ADD X1, X4, X2			// Offset placement ptr to position of Sensor_ID
	STR W0, [X1]			// Store name in position of Sensor_ID

	LDR X0, [SP]			// Load name from stack, but do not pop
	BL String_length		// Get the length of the string
	ADD X0, X0, #1			// Add 1 to length for null terminator, store in X0
	BL malloc				// malloc memory to store string
	LDR X1, [SP], #16		// pop and load name from stack
	BL strcpy				// char *strcpy(char *dest, const char *src): Copy name into heap address

	MOV X2, #Sensor_name	// Move offset for Sensor_name to X2
	LDR X4, =pSensptr		// Load address of sens pointer, 3 previous functions before modified
	LDR X4, [X4]			// Load value of sens storage pointer: Sensor object placement pointer
	ADD X1, X4, X2			// Offset placement ptr to position of Sensor_name
	STR X0, [X1]			// Store namePtr we just made into position of Sensor_name

	MOV X0, X4				// Move struct pointer to X0 to prepare for return
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

	STR X0, [SP, #-16]!		// Save struct pointer
	ADD X0, X0, #Sensor_name			// Offset struct pointer to position of Sensor_name
	LDR X0, [X0]			// Load value of Sensor_name: heap address that stores name string
	BL free					// free memory for name

	LDR X0, [SP], #16		// Reload struct pointer
	BL free					// free memory for struct

	LDR LR, [SP], #16	// Restore LR
	RET					// Return to caller



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



// ************************************** END Sensor Struct Functions **************************************




// ************************************** Linked List/Node Functions ***************************************

// **************** HELPER FUNCTION : CREATE NODE *****************
// creates a Node and sets data element to data, next to null
//	Function Header: Node* Node(quad data)
//		X0: Must have a quad type integer
//	Returns: pointer to a node in X0
// Algorithm:
//	Save data in register
//	Call malloc with size Node.size, save pointer in X0
//	Store data heap pointer
//	Use Node.next to offset store position to Node.next pointer
//	Store nullptr(0) into Node.next
//	Reset pointer and return
node:	// provide function starting address
	STR X0, [SP, #-16]!		// Save target data into stack
	STR LR, [SP, #-16]!		// Save LR to prepare for malloc call

	MOV X0, Node_size	// Allocate memory for node	
	BL malloc			// Call malloc to designate space for our node
	LDR LR, [SP], #16	// Restore LR
	MOV X2, X0			// Copy node pointer

	ADD X0, X2, Node_data	// offset pointer to point to the position of data
	LDR X1, [SP], #16	// Load data from stack
	STR X1, [X0]		// Store data into address

	MOV X1, #0			// NULL = 0
	ADD X0, X2, Node_next	// offset pointer to position of Node.next variable
	STR X1, [X0]		// store null into Node.next

	// Reset pointer to original position
	MOV X0, X2			// Reset pointer to start of node object for return
	RET					// Return to caller



// ****************** HELPER FUNCTION : ADD NODE ********************
// Adds Node node to front/head of linked-list,returns updated head
//	Function Header: Node* addNode(Node* head, Node* node)
//		X0: Pointer to list head
//		X1: Pointer to target object
//	Returns: updated pointer to head in X0
// Algorithm:
//	Offset node pointer to position of Node_next variable
//	Dereference node pointer and save value into register, this is our Node_next pointer
//	Copy value of head into the value of Node_next pointer
//	Reset node pointer to point to Node object
//	Copy pointer to Node object into head
//	Return updated head in X0.
//.global addNode	// function starting address
addNode:
	ADD X1, X1, Node_next	// Offset node pointer to position of Node_next variable
	LDR X2, [X0]			// Load the destination of head
	STR X2, [X1]			// Copy destination of head into value of Node.next

	SUB X1, X1, Node_next	// Undo offset so X1 points to target object
	STR X1, [X0]			// Store Node object as the destination of head ptr
	RET						// return to caller; X0 has updated head



// ****************** HELPER FUNCTION : Delete Node ********************
// deletes Node node, returns head, updated if applicable
//  Function definition: Node* delNode(Node* head, Node* node) 
// Parameters:
//      X0: pointer to list head
//      X1: pointer to target object
// Return:
//      X0: pointer to list head (updated if needed)
// Algorithm:
//     Part 1
//          Check if head points to target object
//          If true: jump to deleteFirst block —>
//   	 —> offset node pointer by Node.next offset
//          Set head value to Node.next
//          Set Node.next to null
//			Free heap of target
//          Return updated head
//     Part 2 
//			Else, Loop: 
//				search linked list until currentObject.next == target object
//     		set currentObject.next pointer to target object.next
//			set target object.next to null
//			Free heap memory of target object
//			Return head
//.global delNode		//function starting address
delNode:
//.text	// code section
	LDR X3, [X0]	// Load value of head pointer from heap address, X0 now holds a pointer to the first object
	CMP X1, X3		// Check if head points to target object
	B.EQ removeNode	// if pointing to the same object, skip list search and update head
	
	MOV X3, X0		// Move address of head pointer, X0 is now our search pointer
searchListDel:
	CMP X0, #0		// Check if our search pointer is pointing to null
	B.EQ endDelNode	// If null: Node object does not exist inside list, return

	LDR X0, [X0]	// Load value of next pointer: obtain object pointer
	ADD X0, X0, Node_next	// offset pointer to position of current object's node.next
	LDR X2, [X0]	// Load value of Node.next: pointer to next object

	CMP X1, X2		// Compare currentObject.next to target object
	B.NE searchListDel	// If next != object, loop until found
// At this point we are past the loop, X1 holds pointer to target
// object, X0 holds the position of CurrentObject.next or head if skipped search
removeNode:
	ADD X1, X1, Node_next	// Offset target object ptr to position of target_object.next
	LDR X2, [X1]	// Load value of target_object.next: Pointer to next object
	STR X2, [X0]	// Update Current.next/head to the object inside target_object.next
	MOV X2, #0		// Set X2 to NULL (0)
	STR X2, [X1]	// Store NULL into target_object.next, optional but good practice

endDelNode: // Free memory for node and return
	SUB X1, X1, Node_next	// Undo offset so pointer is at the beginning of heap address
	MOV X0, X1		// Free needs heap address in X0
	STR X3, [SP, #-16]!	// Store X3 into stack since free modifies it
	STR LR, [SP, #-16]!	// Store LR into stack to prepare for function call
	BL free			// release the heap memory
	LDR LR, [SP], #16	// Restore LR
	LDR X3, [SP], #16	// Restore X3

	MOV X0, X3		// Return head in X0
	RET				// Return to caller





// **************** HELPER FUNCTION : findMinNode ******************
// Function definition: Node* findMinNode(Node* head)
//	finds Node with minimum data value using helper dataLT
// Parameters:
//		X0: List head pointer
// Return:
//		X0: pointer to Node object with min value
// Algorithm:
//		Set initial min to head.data
//		For each node, if dataLT == 0:
//			set current_min to node.data
//			set return pointer to Node object
//		Return
findMinNode:
	LDR X0, [X0]	// Load value of head pointer from heap address, X0 now holds a pointer to the first object
	MOV X2, X0		// Copy the pointer to X2, this will be our comparison value pointer
	MOV X3, X0		// Copy the pointer to our current min to X3, this our return value
	LDR X4, [X0]	// Load value of pointer into X4, this will be our minvalue
	LDR X1, [X0]	// Load value of pointer into X1, this will be our comparison value (for now it's the same)

searchListMin:
	MOV X0, X4		// Copy X4 to X0 to prepare for dataLT call
	STR LR, [SP, #-16]!	// Store LR into stack to prepare for function call
	BL dataLT		// dataLT returns 0 if data1 < data2, nonzero otherwise
	LDR LR, [SP], #16	// Restore LR
	CMP X0, #0		// Check dataLT return value
	B.EQ searchMinContinue	// If zero, do not change min and continue search
	MOV X3, X2		// Update pointer to minimum value node
	MOV X4, X1		// Update minimum value
searchMinContinue:
	ADD X2, X2, Node_next	// Offset comparison pointer to position of next node pointer
	LDR X2, [X2]			// Load pointer to next object
	CMP X2, #0				// Check if node.next is NULL (0)
	B.EQ findMinEnd			// If node.next is NULL, end
	ADD X1, X2, Node_data	// Offset comparison pointer to data field in struct
	LDR X1, [X1]			// Load value of data field
	B searchListMin			// Loop
findMinEnd:
	MOV X0, X3		// Return pointer to minimum node in X0
	RET				// Return to caller





// **************** HELPER FUNCTION : findMaxNode ******************
// Function definition: Node* findMaxNode(Node* head)
//	finds Node with minimum data value using helper dataLT
// Parameters:
//		X0: List head pointer
// Return:
//		X0: pointer to Node object with max value
// Algorithm:
//		Set initial max to head.data
//		For each node, if dataLT != 0:
//			set current_max to node.data
//			set return pointer to Node object
//		Return
findMaxNode:
	LDR X0, [X0]	// Load value of head pointer from heap address, X0 now holds a pointer to the first object
	MOV X2, X0		// Copy the pointer to X2, this will be our comparison value pointer
	MOV X3, X0		// Copy the pointer to our current max to X3, this our return value
	LDR X4, [X0]	// Load value of pointer into X0, this will be our maxvalue
	LDR X1, [X0]	// Load value of pointer into X1, this will be our comparison value (for now it's the same)

searchListMax:
	MOV X0, X4		// Copy X4 to X0 to prepare for dataLT call
	STR LR, [SP, #-16]!	// Store LR into stack to prepare for function call
	BL dataLT		// dataLT returns 0 if data1 < data2, nonzero otherwise
	LDR LR, [SP], #16	// Restore LR
	CMP X0, #0		// Check dataLT return value
	B.NE searchMaxContinue	// If non zero value, do not update max and continue search
	MOV X3, X2		// Update pointer to minimum value node
	MOV X4, X1		// Update minimum value
searchMaxContinue:
	ADD X2, X2, Node_next	// Offset comparison pointer to position of next node pointer
	LDR X2, [X2]			// Load pointer to next object
	CMP X2, #0				// Check if node.next is NULL (0)
	B.EQ findMaxEnd			// If node.next is NULL, end
	ADD X1, X2, Node_data	// Offset comparison pointer to data field in struct
	LDR X1, [X1]			// Load value of data field
	B searchListMax			// Loop
findMaxEnd:
	MOV X0, X3		// Return pointer to maximum node in X0
	RET				// Return to caller

// ************************************** END Linked List/Node Functions ***************************************


	.data
szEOL:		.asciz	"\n"				// new line character 
szInputFN:	.asciz	"gve-3input.txt"	// input file name
pHeadptr:	.quad 0		// Buffer to store heap address of list head pointer
pSensptr:	.quad 0		// Buffer to store heap address of current sensor struct
pCurrNode:	.quad 0		// Buffer to store heap address of current node
szData:		.skip 32	// string buffer to hold line of data read from file
szSensName:	.skip 32	// string buffer to hold sensor name from file
i32ID:		.word 0		// int32 word to hold converted string for ID
dReading:	.double 0.0	// double to hold sensor Reading
szSection:	.asciz	"======================= End List =======================\n"// Section separator
formattingString:	.asciz		"%.20f\n"	// For printf
szCompany1: .asciz	"Honeywell International"
szCompany2: .asciz	"Bosch Sensortec"
szCompany3: .asciz	"Eaton"
szCompany4: .asciz	"EcoBee"
szFound:	.asciz	"Found "
szNotFound:	.asciz	" not found"

.end	// end of function, optional but good practice
