// George Eaton
// CS3B - lab1-2 C driver
// mm/dd/2024
// outputs each character of a string to the console using putch

#include <stdio.h>

extern void putch(char *); // our function putch. Note that parameters are
                           // passed to the assembly function using X0 thru
                           // X7 in order, so in this case the char pointer will
                           // be passed to putch in X0.

int main()
{

    char *aString = "AaBbCcDd1234567890!@#$%^&*=+\"'<>?\n";

    while (*aString != '\0')
        putch(aString++);

    return(0);

}
