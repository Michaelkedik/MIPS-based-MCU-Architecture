# Scalar Pipelined MIPS CPU Architecture

In this project I designed a Scalar Pipelined MIPS CPU that was executed on an altera board.
The CPU Core is capable of performing a variety of instructions from a given MIPS instruction set.
The architecture includes a MIPS ISA compatible CPU with data and program memory for hosting data and code and a standard MIPS register file. 
The top level and the MIPS core are structural and a single clock is used in the design.
In addition, the architecture includes hazard detection unit, forwarding unit, flushing and a single delay slot support.  
The figure below illustrates the design.  

    

<img width="492" alt="image" src="https://github.com/Michaelkedik/Scalar-Pipelined-MIPS-CPU/assets/136968696/f658c3fe-47dd-4d49-8cbe-ff1a08bdd170">




## Description


The repositories in this project serve the following purposes:

**VHDL:** This repository contains VHDL codes for the top entity and components. These codes can be compiled using ModelSim and Quartus.

**DOC:** This repository contains project documentation and a README file that provides an explanation of the VHDL files' purpose.

**CODE:** This repository contains assembly code used for verifying the design's functionality.

**TB:** This repository contains Testbench files that were used for ModelSim verification of the design.

**SIM:** This repository contains ".do" files used for ModelSim simulation.

**QUARTUS:** This repository contains project files such as ".sof," SDC, and STP files, which are used for Quartus compilation and verification of the design.
