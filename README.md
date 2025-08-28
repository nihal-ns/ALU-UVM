<img width="1609" height="737" alt="image" src="https://github.com/user-attachments/assets/79c5df7c-dc33-425c-afef-ac546c12029e" /># ALU-UVM
<img width="922" height="740" alt="image" src="https://github.com/user-attachments/assets/501ce0ac-2391-4c36-8171-610f8c1d96c4" />

UVM Verification Environment for a Configurable ALU

A robust and reusable UVM-based testbench designed to verify the functionality of a configurable 8-bit Arithmetic Logic Unit (ALU).
Table of Contents

    Overview

    ALU Features

    Verification Environment Architecture

    How to Run Simulation

    Test Scenarios

    Project Structure

    Verification Results & Bug Report

Overview

This project provides a comprehensive UVM (Universal Verification Methodology) environment for verifying a configurable 8-bit ALU. The ALU is a core digital component capable of performing a variety of arithmetic and logical operations. The testbench is built to be reusable and scalable, employing constrained-random stimulus generation, self-checking mechanisms, and functional coverage to ensure the DUT's correctness.
ALU Features

    Parameterized Operands: Supports 8-bit operands (OPA, OPB) by default.

    Dual-Mode Operation:

        Arithmetic Mode: Addition, Subtraction (with/without carry), Increment, Decrement, Compare, and Multiplication.

        Logical Mode: AND, OR, NAND, NOR, XOR, XNOR, NOT, Shift, and Rotate operations.

    Split Transactions: Capable of handling operands that arrive in separate clock cycles, with a 16-cycle timeout mechanism for error handling.

    Status Flags: Generates key status flags including Carry-Out, Overflow, Error, and comparator flags (Greater, Equal, Less).

Verification Environment Architecture

The testbench follows a standard UVM architecture, ensuring modularity and reusability. It includes an active agent for driving stimulus and a passive agent for monitoring, along with a scoreboard for checking and a subscriber for coverage collection.
How to Run Simulation

The included makefile simplifies the process of compiling and running simulations.

Prerequisites:

    A SystemVerilog simulator that supports UVM (e.g., Mentor Questa/ModelSim, Synopsys VCS, Cadence Xcelium).

Commands:

    Compile the environment:

    make compile

    Run a standard simulation:

    make simulate
    # or
    make all

    Run with high verbosity:

    make h

    Run with debug verbosity:

    make d

    Clean up simulation files:

    make clean

To run a specific test, modify the run_test("<test_name>"); line in top.sv.
Test Scenarios

The environment includes several pre-defined tests to target different aspects of the ALU's functionality:

    custom_test: A user-defined test for specific scenarios.

    arith_test: Focuses on all arithmetic operations.

    logical_test: Focuses on all logical operations.

    error_test: Intentionally creates error conditions to test the DUT's error flags.

    flag_test: Specifically targets corner cases for COUT, OFLOW, and comparator flags.

    split_test: Tests the 16-cycle split-operand and timeout functionality.

    regress_test: A regression test that runs all the above sequences.

Project Structure

ALU-UVM/                                                                                                                
├── design.sv                # The ALU RTL design (DUT)                                                                 
├── top.sv                   # Top-level module connecting DUT and Testbench                                            
├── alu_interface.sv         # Interface for DUT-Testbench connection                                                   
├── alu_pkg.sv               # Package including all testbench components                                               
├── alu_sequence.sv          # UVM sequences for stimulus generation                                                    
├── alu_driver.sv            # UVM driver                                                                               
├── alu_monitor.sv           # UVM monitors (active and passive)                                                        
├── alu_agent.sv             # UVM agents (active and passive)                                                          
├── alu_scoreboard.sv        # UVM scoreboard with predictive model                                                     
├── alu_coverage.sv          # UVM subscriber for functional coverage                                                   
├── alu_env.sv               # Top-level UVM environment                                                                
├── test.sv                  # UVM test classes                                                                         
├── defines.sv               # Global definitions and macros                                                            
├── makefile                 # Makefile for easy compilation and simulation                                             
└── docs/                                                                                                               
    └── ALU Verification Plan.docx # Detailed verification plan document                                                

Verification Results & Bug Report

The verification process successfully identified several critical bugs in the DUT. A comprehensive bug report detailing these findings can be found in the project documentation. The report covers functional errors, state-dependency issues, and incorrect error handling.
