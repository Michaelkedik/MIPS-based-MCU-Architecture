# MIPS based MCU Architecture

In this project, I developed an MCU based on the MIPS architecture, incorporating Memory-Mapped I/O, a Basic Timer, and an Interrupt Controller.
The CPU uses a Single Cycle MIPS architecture and is capable of performing full instruction set of simple MIPS.
The design is located on Altera Board and the MIPS architecture is Harvard architecture in order to increase the throughput.
The architecture includes a MIPS ISA compatible CPU with data and program memory for hosting data and code.
The CPU have a standard MIPS register file. The top level and the MIPS core are structural. 
The figure below illustrates the design.

<img width="540" alt="image" src="https://github.com/Michaelkedik/MIPS-based-MCU-Architecture/assets/136968696/837e8cb1-fff2-49c5-8f2c-a32a4f1bea7e">

The GPIO is a simple decoder with buffer registers mapped to data address (Higher than data memory) that enables the CPU to output data to LEDs and 7-Segment and to read the Switches state.


## Description


The repositories in this project serve the following purposes:

**VHDL:** This repository contains VHDL codes for the top entity and components. These codes can be compiled using ModelSim and Quartus.

**DOC:** This repository contains project documentation and a README file that provides an explanation of the VHDL files' purpose.

**CODE:** This repository contains assembly code used for verifying the design's functionality.

**TB:** This repository contains Testbench files that were used for ModelSim verification of the design.

**SIM:** This repository contains ".do" files used for ModelSim simulation.

**QUARTUS:** This repository contains project files such as ".sof," SDC, and STP files, which are used for Quartus compilation and verification of the design.
