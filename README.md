# MIPS based MCU Architecture

In this project, I developed an MCU based on the MIPS architecture, incorporating Memory-Mapped I/O, a Basic Timer, and an Interrupt Controller.
The CPU uses a Single Cycle MIPS architecture and is capable of performing full instruction set of simple MIPS.
The design is located on Altera Board and the MIPS architecture is Harvard architecture in order to increase the throughput.
The architecture includes a MIPS ISA compatible CPU with data and program memory for hosting data and code.
The CPU have a standard MIPS register file. The top level and the MIPS core are structural. 
The figure below illustrates the design.

<img width="540" alt="image" src="https://github.com/Michaelkedik/MIPS-based-MCU-Architecture/assets/136968696/837e8cb1-fff2-49c5-8f2c-a32a4f1bea7e">

The GPIO is a simple decoder with buffer registers mapped to data address (Higher than data memory) that enables the CPU to output data to LEDs and 7-Segment and to read the Switches state.
The Data Address Space is 32-bit WORD aligned where the address word is 0 ... 0 A11 ... A0 with partial mapping that contains Data Memory and Memory Mapped I/O.
The figure below illustrates the design.

<img width="587" alt="image" src="https://github.com/Michaelkedik/MIPS-based-MCU-Architecture/assets/136968696/3083c61a-39bc-4e72-8d52-b9b1ad8c3064">

sadasdasda

<img width="343" alt="image" src="https://github.com/Michaelkedik/MIPS-based-MCU-Architecture/assets/136968696/88cd7c88-506c-472c-922c-26f82ac0792b">

dasdasdasdas

<img width="322" alt="image" src="https://github.com/Michaelkedik/MIPS-based-MCU-Architecture/assets/136968696/65eac7dd-d102-43a5-a889-0fec9067a02e">



## Description


The repositories in this project serve the following purposes:

**VHDL:** This repository contains VHDL codes for the top entity and components. These codes can be compiled using ModelSim and Quartus via change of basic parameters.

**DOC:** This repository contains project documentation and a README file that provides an explanation of the VHDL files' purpose.

**CODE:** This repository contains assembly code used for verifying the design's functionality.

**TB:** This repository contains Testbench files that were used for ModelSim verification of the design.

**SIM:** This repository contains ".do" files used for ModelSim simulation.

**QUARTUS:** This repository contains project files such as ".sof," SDC, and STP files, which are used for Quartus compilation and verification of the design.
