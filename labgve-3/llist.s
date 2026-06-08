// Jose Mejias
// CS3B - labgve-3 - llist.s
// 11/6/2025
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
// ***************************************************************

// sensor struct "definition"
.EQU Sensor_name,    0 // char*/quad name string ptr offset
.EQU Sensor_ID,      8 // int32/word sensor ID offset
.EQU Sensor_reading,12 // double/quad sensor reading offset
.EQU Sensor_size,   20 // size of the struct (20 bytes)
// Linked list node struct "definition"
.EQU Node_data, 0    // quad data element offset
.EQU Node_next, 8    // quad linked list next pointer offset
.EQU Node_size, 16   // size of the linked list node (two quads)

.global node

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
//*******************************************************************

.global addNode	// function starting address

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
// **********************************************************************

.global delNode		//function starting address

delNode:

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
// *******************************************************************

.global findMinNode

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
// *******************************************************************

.global findMaxNode

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

.end // end of program, optional but good practice

