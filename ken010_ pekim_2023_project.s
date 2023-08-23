/////////////////////////////////////
//                                 //
//   Project Submission            //
//                                 //
/////////////////////////////////////

// Partner1: Kendrick Nguyen, A16045878
// Partner2: Peter Kim, A17651145

////////////////////////
//                    //
//   Main             //
//                    //
////////////////////////

// You can modify the elements in the list 'a', the values attained by 'low' and 'high' to test your own cases.

LDA X0, a
MOV X7, X0							// For printing purposes only. Please try avoid using the register X7 in your implementation
ADDI X1, XZR, #2						// 'Low' value stored in X1
ADDI X2, XZR, #7						// 'High' value stored in X2 (0 and 5 are hypothetical numbers, you can put your test values)

BL QUICKSORT

ADDI X2, XZR, #0	   					// Initializing a counter for printing
ADDI X3, XZR, #10  						// For adding a newline after each number, again for printing purposes only
BL PRINTLIST

STOP

////////////////////////
//                    //
//   Swap	      //
//                    //
////////////////////////

SWAP: 
	//   input:
	//   X0: The address of (pointer to) the first value to be swapped
	//   X1: The address of (pointer to) the second value to be swapped
	
	SUBI SP, SP, #32					// Allocate stack frame
	STUR FP, [SP, #0]					// Store old frame pointer
	ADDI FP, SP, #24					// Move frame pointer
	STUR LR, [FP, #0]					// Store link register at new frame pointer

	STUR X19, [FP, #-8]					// Store previous X19 register for new X19 temp register
    	STUR X20, [FP, #-16]         				// Store previous X20 register for new X20 temp register

	LDUR X19, [X0, #0]					// Store first value into new X19 temp register
	LDUR X20, [X1, #0]					// Store second value into new X20 temp register

    	STUR X19, [X1, #0]					// Perform swap
	STUR X20, [X0, #0]

	LDUR X19, [FP, #-8]					// Restore previous X19 register value
    	LDUR X20, [FP, #-16]         				// Restore previous X20 register value

	LDUR LR, [FP, #0]           				// Restore link register
	LDUR FP, [FP, #-24]         				// Restore old frame pointer
	ADDI SP, SP, #32            				// Deallocate stack frame

	BR LR

////////////////////////
//                    //
//   Partition        //
//                    //
////////////////////////

PARTITION: 
	//   input:
	//   X0: The address of (pointer to) the first value of the unsorted array (this value does not depend on the values of 'low' and 'high')
    	//   X1: The value of 'low'
	//   X2: The value of 'high'
	//   X3: TPI, which is initialized as 'low-1' in Quicksort function
	//   X4: CI, which is initialized as 'low' in Quicksort function
	
	//   output:
	//   X0: the index of the 'pivot' in the sorted array
 	
	SUBI SP, SP, #64					// Allocate stack frame
	STUR FP, [SP, #0]					// Store old frame pointer
	ADDI FP, SP, #56					// Move frame pointer
	STUR LR, [FP, #0]					// Store link register at new frame pointer

	STUR X0, [FP, #-8]                  			// Store argument: address of (pointer to) the first value of array
	STUR X1, [FP, #-16]					// Store argument: 'low'
    	STUR X3, [FP, #-24]                 			// Store argument: `TPI`
    	STUR X4, [FP, #-32]                 			// Store argument: `CI`
    	STUR X19, [FP, #-40]                			// Store previous X19 register for new X19 temp register
    	STUR X20, [FP, #-48]         				// Store previous X20 register for new X20 temp register

	LSL X19, X2, #3            				// Evaluate 'high' in memory (multiply by eight-positions)
	ADD X19, X0, X19					// Get pointer to array[high]

	// Check if 'j' == 'high'
	CMP X4, X2
		B.NE PARTITION_SEARCH_PIVOT
		ADDI X20, X3, #1				// Evaluate 'i'+1
		LSL X20, X20, #3            			// Evaluate 'i'+1 in memory (multiply by eight-positions)
		ADD X0, X0, X20					// Set first argument in SWAP(a, b) to array[i+1]
		MOV X1, X19					// Set second argument in SWAP(a, b) to array[high]

		BL SWAP						// SWAP(array[i+1], array[high])

		ADDI X3, X3, #1					// Return 'i'+1
		BL RETURN_PIVOT

	PARTITION_SEARCH_PIVOT:

	// Check if array[j] <= 'pivot'
	LSL X20, X4, #3            				// Evaluate 'j' in memory (multiply by eight-positions)
	ADD X20, X20, X0					// Get pointer to array[j]
	LDUR X20, [X20, #0]					// Evaluate array[j]
	LDUR X19, [X19, #0]					// Evaluate array[high] or 'pivot'
	CMP X20, X19
		B.GT PARTITION_RECURSIVE
		ADDI X3, X3, #1					// i ← i + 1
		LSL X19, X3, #3					// Evaluate 'i' in memory (multiply by eight-positions)
        	LSL X20, X4, #3            			// Evaluate 'j' in memory (multiply by eight-positions)
	    	ADD X20, X20, X0				// Get pointer to array[j]
		ADD X0, X0, X19					// Set first argument in SWAP(a, b) to array[i]
		MOV X1, X20					// Set second argument in SWAP(a, b) to array[j]

		BL SWAP						// SWAP(array[i], array[high])

		LDUR X0, [FP, #-8]				// Restore argument: address of (pointer to) the first value of array
		LDUR X1, [FP, #-16]				// Restore argument: 'low'

	PARTITION_RECURSIVE:
		ADDI X4, X4, #1					// Set fifth argument in partition(a, low, high, TPI, CI) as 'j'+1

	BL PARTITION						// PARTITION(a, low, high, i, j+1)
        BL PARTITION_RESTORE            			// return;

    RETURN_PIVOT:
        MOV X0, X3                      			// Return pivot index

	PARTITION_RESTORE:
        LDUR X1, [FP, #-16]					// Restore argument: 'low'
        LDUR X3, [FP, #-24]             			// Restore argument: `TPI`
        LDUR X4, [FP, #-32]             			// Restore argument: `CI`
        LDUR X19, [FP, #-40]            			// Restore previous X19 register for new X19 temp register
        LDUR X20, [FP, #-48]            			// Restore previous X20 register for new X20 temp register

	LDUR LR, [FP, #0]           				// Restore link register
	LDUR FP, [FP, #-56]         				// Restore old frame pointer
	ADDI SP, SP, #64            				// Deallocate stack frame

	BR LR

////////////////////////
//                    //
//   Quicksort        //
//                    //
////////////////////////

QUICKSORT: 
	//   input:
	//   X0: The address of (pointer to) the first value of the unsorted array (this value does not depend on the values of 'low' and 'high')
    	//   X1: The value of 'low'
	//   X2: The value of 'high'

	SUBI SP, SP, #64					// Allocate stack frame
	STUR FP, [SP, #0]					// Store old frame pointer
	ADDI FP, SP, #56					// Move frame pointer
	STUR LR, [FP, #0]					// Store link register at new frame pointer

	STUR X0, [FP, #-8]                  			// Store argument: address of (pointer to) the first value of array
	STUR X1, [FP, #-16]					// Store argument: 'low'
	STUR X2, [FP, #-24]					// Store argument: 'high'
    	STUR X3, [FP, #-32]                			// Store previous X3 register for new X3 argument register
    	STUR X4, [FP, #-40]         				// Store previous X4 register for new X4 argument register
    	STUR X19, [FP, #-48]               			// Store previous X19 register for new X19 temp register
	
	// Check if if 'low' < 'high'
	CMP X1, X2
		B.GE QUICKSORT_RESTORE
		
		SUBI X3, X1, #1					// Set fourth argument in PARTITION(a, low, high, TPI, CI) to 'low'-1
		MOV X4, X1					// Set fifth argument in PARTITION(a, low, high, TPI, CI) to 'low'
		BL PARTITION					// PARTITION(a, low, high, low- 1, low)
		MOV X19, X0					// Save returned pivot index

		LDUR X0, [FP, #-8]				// Restore argument: address of (pointer to) the first value of array

		SUBI X2, X19, #1				// Set third argument in QUICKSORT(a, low, high) to 'pivot_position' - 1
		BL QUICKSORT					// QUICKSORT(a, low, pivot position-1)

		LDUR X2, [FP, #-24]				// Restore argument: 'high'

		ADDI X1, X19, #1				// Set second argument in QUICKSORT(a, low, high) to 'pivot_position' - 1
		BL QUICKSORT					// QUICKSORT(a, pivot position+1, high)

		LDUR X1, [FP, #-16]				// Restore argument: 'low'

	QUICKSORT_RESTORE:
		LDUR X0, [FP, #-8]              		// Restore argument: address of (pointer to) the first value of array
		LDUR X1, [FP, #-16]				// Restore argument: 'low'
		LDUR X2, [FP, #-24]				// Restore argument: 'high'
		LDUR X3, [FP, #-32]             		// Restore previous X3 register for new X3 argument register
		LDUR X4, [FP, #-40]        			// Restore previous X4 register for new X4 argument register
		LDUR X19, [FP, #-48]            		// Restore previous X19 register for new X19 temp register

		LDUR LR, [FP, #0]           			// Restore link register
		LDUR FP, [FP, #-56]         			// Restore old frame pointer
		ADDI SP, SP, #64            			// Deallocate stack frame

	BR LR

PRINTLIST:
// You can change the immediate value corresponding to the length of the array
    SUBIS XZR, X2, #21
    B.EQ PRINTLIST_LOOP_END
	MOV X1, X2
 	LSL X1, X1, #3
	ADD X4, X7, X1
    LDUR X1, [X4, #0]
    PUTINT X1
    PUTCHAR X3
    ADDI X2, X2, #1
    B PRINTLIST

PRINTLIST_LOOP_END:
    BR LR
