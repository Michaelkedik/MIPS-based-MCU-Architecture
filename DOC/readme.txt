1)Top- The top entity, Synchronizes the MIPS, GPIO and the BUS
2)MIPS - The CPU, Synchronizes all the other components of the CPU
3)IFETCH - Get the instruction and advance the PC according to the relevant adress
4)IDECODE - Decode the instruction and read and write from the register file
5)DMEMORY- Read or write from the data memory
6)EXECUTE- Performs all the logic or arithmetic actions
7)CONTROL - Produces the control signals that are needed for the instructions to be executed
8)GPIO - General IO Component, Synchronizes all the IO Components
9)BidirPin - Used as data bus
10)Timer - Basic timer used for interrupts and to generate PWM signal using output compare mode
11)INTCTL - Interrupt controller, responsible for handling the interrupts
12)Hex - Decoder for the HEX outputs
13)D_latch - a simple D_latch, used in the INTCTL
