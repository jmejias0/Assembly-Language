// Jose Mejias
// CS3B - Lab7-3 - sort_bubble
// 11/01/2025
// Pseudocode/Algorithm:
// 	Input: N/A
//
//	Processing:
//	1. Pointer to integer array of 64-bit elements 
//	2. Array size in bytes (size = length * 8)
//	3. Save pointer and initialize i = 0 (outer index) and j = 0 (inner index) and swapped = true
//	4. While i <= size and swapped = true (outer loop)
//		4a. set swapped = false
//		4b. set j = 0 and bound = size -1
//	5. while j < bound (inner loop)
//		5a. set a = arr[j] and b = arr[j+8]
//		5b. if a > b -> swap arr[j] and arr[j+8] -> set swapped = true
//		5c. set j += 8
//	6. i += 8
//
//	Output:N/A 
// X0 - integer array
// X1 - array SIZE (size = length * type) or i lcv. KEEP IN MIND THIS IS QUAD, so type = 8

.global sort_bubble // Provide program starting address

sort_bubble:

	.EQU SYS_exit, 93 // exit() supervisor call code

	.text // code section

	//  In the following documentation we refer to i and j as indicies, but in reality they are pointer
	// iterators. So while they are shown to be decremented/incremented by 1 in the comments, in 
	// actuality our code will decrement/increment them by 8 since we are working with a quad-type array.

	// Save pointers and set up control variables
	STR X0, [SP, #-16]!	// Allocate and store pointer to integer array into the stack
	MOV X2, #0		// range_boundary, i, i <= ARR_SIZE
	MOV X3, #0		// range of swaps, j, j <= ARR_SIZE - i
	MOV X4, X1		// X4 will serve as our i bound: ARR_SIZE
	MOV X8, #0		// X8 will serve as our swap flag. If we finish an entire inner loop w/o swapping, the list is sorted.

// This represents the outer for-loop
range_boundary:

	CMP X2, X4			// Compare i to it's end condition
	B.GT endBubbleSort		// if i <= ARR_SIZE, continue loop
	CMP X8, #0			// Check if we swapped on the last iteration
	B.NE endBubbleSort		// If we did not swap, then the list is sorted. End loop

	// Set up our inner loop, the one that will be swapping
	MOV X3, #0			// Reset j inner loop lcv
	SUB X5, X4, X2			// X5 will serve as our j bound: ARR_SIZE(X4) - i(X2)
	ADD X2, X2, #8			// Increment i to prepare for next check of our outer end condition
	MOV X8, #-1			// Reset swapped flag to false. 

// This represents the inner for-loop
swap_range:

	CMP X3, X5			// compare j with it's bound
	B.GE range_boundary		// if j <= ARR_SIZE - i, continue loop, else end loop and iterate outer loop

	LDR X6, [SP]			// X6 will represent arr[j], copy pointer to arr[0]	
	ADD X6, X6, X3			// arr[j] = &(arr[0]) + j

	MOV X7, X6			// X7 will represent arr[j+1], copoy pointer to arr[j]
	ADD X7, X7, #8			// arr[j+1] = &(arr[j]) + 1

	LDR X6, [X6]			// Move value of arr[j] into register
	LDR X7, [X7]			// Move value of arr[j+1] into register

	ADD X3, X3, #8			// iterate j

	// Inner loop logic
	CMP X6, X7			// conditional: arr[j] < arr[j+1]
	B.LE swap_range			// if(arr[j] > arr[j+1]) continue, if a[j] <= a[j+1]: move to next loop iteration

	SUB X3, X3, #8			// Subtract j for addressing since we didn't loop
	// set up addresses
	LDR X6, [SP]			// X6 will represent arr[j], copy pointer to arr[0]	
	ADD X6, X6, X3			// arr[j] = &(arr[0]) + j
	MOV X7, X6			// X7 will represent arr[j+1], copoy pointer to arr[j]
	ADD X7, X7, #8			// arr[j+1] = &(arr[j]) + 1
	
	// Set up values
	LDR X0, [X7]			// copy arr[j+1] value into X0 temp register
	LDR X1, [X6]			// copy arr[j] value into X1: temp = arr[j]
	
	// Swap values
	STR X0, [X6]			// Move value to arr[j] from arr[j+1]: arr[j] = arr[j+1]
	STR X1, [X7]			// Move temp value that is stored in X1 to arr[j+1]: arr[j+1] = temp
	
	MOV X8, #0			// swapped = true

	// Next iteration of inner loop
	ADD X3, X3, #8			// iterate j
	B swap_range

endBubbleSort:
	LDR X0, [SP], #16		// Reset pointer of quad array and deallocate stack
	RET				// Return to caller

.end // end of program, optional but good practice
