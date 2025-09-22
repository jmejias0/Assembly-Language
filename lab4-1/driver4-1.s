// George Eaton
// CS3B - lab4-1 assembly driver
// mm/dd/2024
// outputs test strings to the console using putstring

.global _start // Provide program starting address

_start:

    .text  // code section
    // to check String_length at this point in the course,
    // you'll have to use GDB and break points to examine
    // your output register for each of the test cases
    LDR X0, =test1      // load X0 with pointer to test string
    BL String_length    // call String_length function
    LDR X0, =test2      // load X0 with pointer to test string
    BL String_length    // call String_length function
    LDR X0, =test3      // load X0 with pointer to test string
    BL String_length    // call String_length function
    LDR X0, =test4      // load X0 with pointer to test string
    BL String_length    // call String_length function
    LDR X0, =test5      // load X0 with pointer to test string
    BL String_length    // call String_length function


    // check that we can output the strings correctly
    // note that since putstring calls String_length, you need
    // to check that above first
    LDR X0, =test1      // load X0 with pointer to test string
    BL putstring        // call putstring function
    LDR X0, =test2      // load X0 with pointer to test string
    BL putstring        // call putstring function
    LDR X0, =test3      // load X0 with pointer to test string
    BL putstring        // call putstring function
    LDR X0, =test4      // load X0 with pointer to test string
    BL putstring        // call putstring function
    LDR X0, =test5      // load X0 with pointer to test string
    BL putstring        // call putstring function



    // terminate the program

    MOV X0, #0      // set return code to 0, all good
    MOV X8, #93     // set service code to 93 for terminate
    SVC 0           // Call Linux to terminate


    .data
test1:  .asciz   "Hello World!\n"
test2:  .asciz   "George"
test3:  .asciz   "!\n"
test4:  .asciz   "@\n"
test5:  .asciz   "Good job so far!\n"


.end  // end of program, optional but good practice
