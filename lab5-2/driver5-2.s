// George Eaton
// CS3B - lab5-2 assembly driver
// mm/dd/2024
// outputs test strings to the console using int2cstr

.global _start // Provide program starting address

_start:

    .text  // code section

    LDR X1, =szStrBuffer    // load X1 with pointer to string buffer
    LDR X0, =test1          // load X0 test variable address
    LDR X0, [X0]            // load X0 with test variable 64 bit value
    BL int2cstr             // call int2cstr function
    LDR X0, =szStrBuffer    // load X0 with pointer to string buffer
    BL putstring            // call putstring to output converted value
    LDR X0, =szEOL          // load X0 with pointer to string EOL
    BL putstring            // call putstring to output converted value

    LDR X1, =szStrBuffer    // load X1 with pointer to string buffer
    LDR X0, =test2          // load X0 test variable address
    LDR X0, [X0]            // load X0 with test variable 64 bit value
    BL int2cstr             // call int2cstr function
    LDR X0, =szStrBuffer    // load X0 with pointer to string buffer
    BL putstring            // call putstring to output converted value
    LDR X0, =szEOL          // load X0 with pointer to string EOL
    BL putstring            // call putstring to output converted value

    LDR X1, =szStrBuffer    // load X1 with pointer to string buffer
    LDR X0, =test3          // load X0 test variable address
    LDR X0, [X0]            // load X0 with test variable 64 bit value
    BL int2cstr             // call int2cstr function
    LDR X0, =szStrBuffer    // load X0 with pointer to string buffer
    BL putstring            // call putstring to output converted value
    LDR X0, =szEOL          // load X0 with pointer to string EOL
    BL putstring            // call putstring to output converted value

    LDR X1, =szStrBuffer    // load X1 with pointer to string buffer
    LDR X0, =test4          // load X0 test variable address
    LDR X0, [X0]            // load X0 with test variable 64 bit value
    BL int2cstr             // call int2cstr function
    LDR X0, =szStrBuffer    // load X0 with pointer to string buffer
    BL putstring            // call putstring to output converted value
    LDR X0, =szEOL          // load X0 with pointer to string EOL
    BL putstring            // call putstring to output converted value

    LDR X1, =szStrBuffer    // load X1 with pointer to string buffer
    LDR X0, =test5          // load X0 test variable address
    LDR X0, [X0]            // load X0 with test variable 64 bit value
    BL int2cstr             // call int2cstr function
    LDR X0, =szStrBuffer    // load X0 with pointer to string buffer
    BL putstring            // call putstring to output converted value
    LDR X0, =szEOL          // load X0 with pointer to string EOL
    BL putstring            // call putstring to output converted value

    LDR X1, =szStrBuffer    // load X1 with pointer to string buffer
    LDR X0, =test6          // load X0 test variable address
    LDR X0, [X0]            // load X0 with test variable 64 bit value
    BL int2cstr             // call int2cstr function
    LDR X0, =szStrBuffer    // load X0 with pointer to string buffer
    BL putstring            // call putstring to output converted value
    LDR X0, =szEOL          // load X0 with pointer to string EOL
    BL putstring            // call putstring to output converted value

    // terminate the program

    MOV X0, #0      // set return code to 0, all good
    MOV X8, #93     // set service code to 93 for terminate
    SVC 0           // Call Linux to terminate


    .data
szStrBuffer: .skip 24 // 24 to avoid any alignment issues
szEOL:       .asciz "\n"

// test integers
test1:  .quad   99
test2:  .quad   123456789
test3:  .quad   1
test4:  .quad   -1111
test5:  .quad   0
test6:  .quad -9223372036854775808   



.end  // end of program, optional but good practice
