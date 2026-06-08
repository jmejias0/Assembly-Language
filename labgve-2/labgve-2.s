// Jose Mejias
// CS3B - Lab gve-2 - Linkme
// 11/29/25
// **************************** Lab gve-2 - Linkme *********************************
// This program will read an unknown number of quad integers from a file, save them
// in a linked-list, output the numbers stored in the linked-list to the console,
// delete the min and max values from the linked-list, output the numbers stored in
// the linked-list again to the console, and finally free up all memory.
// *********************************************************************************
//	Algorithm:
//		 Open the file, save file descriptor
//		 For each line in the file, call getline()
//		 Convert string to int with cstr2int
// 		 With the converted integer as data, create a node
//		 Add node to linked list
//		 Close file
//		 Loop through linked list and print data for each node
//		 find and remove the two nodes with maximum and minimum value
//		 Loop and print linked list again
//		 Clear all the memory of linked list, end

.EQU 	Node_data, 0    // quad data element offset
.EQU 	Node_next, 8    // quad linked list next pointer offset
.EQU 	Node_size, 16   // size of the linked list node (two quads)
.EQU	O_RDONLY, 0
.EQU	O_WRONLY, 1
.EQU	O_RDWR,   0002
.EQU	O_CREAT,  0100
.EQU	S_RDWR,   0666
.EQU	AT_FDCWD, -100
.EQU 	SYS_exit, 93 // exit() supervisor call code

.macro  openFile    fileName, flags	// Modified macro from Stephen Smith, Chapter 8 of "Programming with 64-bit ARM Assembly language"
	MOV	X0, #AT_FDCWD	// X0 needs directory file descriptor; Current working directory
        LDR     X1, =\fileName	// X1 needs file name string buffer / char array
        MOV     X2, #\flags	// X2 holds the flags (Truncate/Create/RDWR/etc)
	MOV	X3, #S_RDWR	// RW access rights
        MOV	X8, #56		// X8 needs Sys_Call number for openat()
        SVC     0		// Make supervisor call
.endm

.macro	closeFile	fileDesc
// Calls close() with fileDesc
	MOV 	X0, \fileDesc	// Close needs file desc in X0
	MOV 	X8, #57		// SYS_CALL number for close()
	SVC	0		// Supervisor call to close file
.endm

.macro checkListEmpty	headStorage, endLabel
// Checks if head pointer inside headStorage is empty and branches to endLabel if so.
	LDR X0, =\headStorage	// Load address of head pointer storage
	LDR X0, [X0]		// Load value of storage: head pointer
	LDR X0, [X0]		// Load value of head pointer: object pointer or NULL
	CMP X0, #0		// Check if head points to NULL
	B.EQ \endLabel		// If NULL, the list is empty, branch to end
.endm

.macro	printLine		stringBuff
// Prints stringBuff followed by newline
	LDR X0, =\stringBuff	// Load address of string buffer
	BL putstring		// print string to console
	LDR X0, =szEOL		// Load address of EOL
	BL putstring		// print newline
.endm

.macro	printLinkedList		headPTR
// Given headPTR will output the entire linked list to console 
// Algo: Starting at head pointer, for each next object, convert it's data member to string and print to console
	MOV X9, \headPTR	// Copy head pointer to X0 to begin loop
	LDR X9, [X9]		// Load value of head pointer: object pointer
1:
	MOV X0, #0		// Copy 0 into register
	LDR X1, =szInt		// Load address of int string buffer
	STR X0, [X1]		// Clear szInt
	ADD X0, X9, #Node_data	// Move pointer to position of Node.data
	LDR X0, [X0]		// Get value stored in Node.data: quad int data
	BL int2cstr		// Convert int X0 and store into string buffer X1

	printLine	szInt	// print converted integer to console

	MOV X0, X9		// Copy node object pointer to X0
	ADD X0, X0, #Node_next	// Offset pointer to position of Node.next
	LDR X9, [X0]		// Load value of Node.next pointer into register: Node.next
	CMP X9, #0		// Compare Node.next desination to NULL
	B.NE	1b		// If Node.next is NULL, we are at the final node. End loop
.endm

.macro	deleteLinkedList	headPTR
	LDR X9, [\headPTR]      // X9 = primer nodo (Node* head)
    	CMP X9, #0
    	B.EQ 2f                 // lista vacía, nada que liberar

1:  
    	ADD X10, X9, Node_next  // &current->next
    	LDR X11, [X10]          // X11 = next

    	MOV X0, X9              // free(current)
    	BL free

    	MOV X9, X11             // current = next
    	CMP X9, #0
    	B.NE 1b                 // mientras haya nodos, sigue

2:
.endm

.global _start // Provide program starting address

_start:

	.text // code section
	
	MOV X0, #Node_size	// copy node size into X0
	BL malloc		// allocate Node_size bytes of heap memory
	MOV X1, #0		// Copy NULL (0) into X1
	STR X1, [X0]		// Initialize heap address to NULL, this is our head
	
	LDR X1, =pointerHead		// Load address of head pointer
	STR X0, [X1]		// Store address of head into head pointer

	openFile	szInputFN, O_RDWR	// Open input file with read-write perms
	MOV X9, X0		// Save file descriptor

inputReadLoop:

	// Read one line from file
	LDR X1, =szInt	// string buffer for getline
	MOV X0, #0	// Copy 0 into register
	STR X0, [X1]	// Reset szInt: store 0 in address
	MOV X2, #8	// max length of buffer
	MOV X0, X9	// file descriptor in X0
	BL getline	// Call getline

	CMP X0, #0	// Check length of read from getline
	B.EQ endInput	// If we read 0 bytes, we are at EOF, end loop
// Convert string line to int
	LDR X0, =szInt	// cstr2int needs null terminated string in X0
	BL cstr2int	// cstr2int: convert string input line to quad int

	LDR X1, =iData	// Load address of quad buffer
	STR X0, [X1]	// Store returned converted int in X0 into quad buffer
// Create node and add object to linked list
	BL node		// Call helper function: Node* Node(X0:quad data)

	MOV X1, X0	// Move pointer of node to add into X1
	LDR X0, =pointerHead	// Load address of head pointer storage buffer
	LDR X0, [X0]	// Load heap address of head pointer
	BL addNode	// Call helper function: Node* addNode(Node* head, Node* node)

	LDR X0, =cListLen	// Load address of list length
	LDRB W1, [X0]	// Load value of list length
	ADD W1, W1, #1	// Increment list length
	STRB W1, [X0]	// Store updated list length

	B inputReadLoop	// Loop to read next line of input

endInput:

// Close input file and print linked list
	closeFile	X9	// close file stream for input file
	checkListEmpty	pointerHead, endLinkMe	// If list is empty, nothing to print
	LDR X0, =pointerHead	// Load address of head pointer storage
	LDR X0, [X0]		// Load head pointer
	printLinkedList	X0	// Print linked list starting from head pointer
	printLine	szSection	// Print section separator
// Find and delete minimum node
	LDR X0, =pointerHead	// Load address of head pointer storage
	LDR X0, [X0]		// Load value of storage: head pointer heap address
	BL findMinNode		// findMinNode: Returns pointer in X0 to node with minimum value

	MOV X1, X0		// Copy pointer to minimum object to X1
	LDR X0, =pointerHead	// Load address of head pointer storage
	LDR X0, [X0]		// Load value of storage: head pointer heap address
	BL	delNode		// Delete node with minimum value
	LDR X1, =pointerHead	// Load address of head pointer storage
	STR X0, [X1]		// delNode possibly changed head, store new head pointer
	//printLinkedList X0	// Print linked list starting from head pointer
	//printLine szSection	// Print section separator
// Find and delete maximum node, print new list
	LDR X0, =pointerHead	// Load address of head pointer storage
	LDR X0, [X0]		// Load value of storage: head pointer heap address
	BL findMaxNode		// findMinNode: Returns pointer in X0 to node with minimum value

	MOV X1, X0		// Copy pointer to minimum object to X1
	LDR X0, =pointerHead	// Load address of head pointer storage
	LDR X0, [X0]		// Load value of storage: head pointer heap address
	BL delNode		// Delete node with minimum value
	LDR X1, =pointerHead	// Load address of head pointer storage
	STR X0, [X1]		// delNode possibly changed head, store new head pointer
	printLinkedList X0	// Print linked list starting from head pointer
	printLine szSection	// Print section separator

endLinkMe:

	LDR X0, =pointerHead		// Load storage address of head pointer
	LDR X0, [X0]		// Load value of storage: head pointer heap address
	deleteLinkedList X0	// free all memory of linked list
	LDR X0, =pointerHead	// Load storage address of head pointer
	LDR X0, [X0]		// Load value of storage: head pointer heap address
	BL free			// Free memory of head pointer
    	// terminate the program
    	MOV X0, #0 		// set return code to 0, all good
    	MOV X8, #SYS_exit 	// set exit() supervisor call code
    	SVC 0 			// call Linux to exit
    
		.data // data section

pointerHead:	.quad 0	// Buffer to store heap address of list head pointer
szEOL:		.asciz	"\n"				// new line character 
szInputFN:	.asciz	"gve-2input.txt"	// input file name
szInt:		.skip 8	// string buffer to hold line from file
iData:		.quad 0	// quad to hold int data for node object
cListLen:	.word 0	// counter to hold the length of the list, for debugging
szSection:	.asciz	"======================= Function End =======================\n"// Section separator

.end	// end of function, optional but good practice
