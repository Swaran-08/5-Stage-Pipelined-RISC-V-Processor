# 5-Stage Pipelined RISC-V Processor

A **SystemVerilog** implementation of a 32-bit RISC-V processor using a classic 5-stage pipelined architecture. The processor divides instruction execution into Instruction Fetch, Instruction Decode, Execute, Memory Access, and Write Back stages, allowing multiple instructions to be processed concurrently. The design includes pipeline registers, ALU operations, register-file access, data forwarding, hazard handling, branch control, and load/store operations. The project was implemented and functionally verified using **AMD Xilinx Vivado 2022.2**.

---

## Features

- 32-Bit RISC-V Processor
- 5-Stage Pipeline Architecture (IF, ID, EX, MEM, WB)
- Program Counter and Instruction Memory
- Instruction Decode and Control Signal Generation
- 32-Register Register File
- Arithmetic and Logic Unit (ALU)
- Immediate Generation
- Data Memory with Load and Store Support
- Pipeline Registers Between Stages
- Data Forwarding for Operand Dependencies
- Hazard Detection and Handling
- Branch and Jump Control
- Pipeline Flush Handling for Redirected Control Flow
- Directed SystemVerilog Testbench-Based Verification
- RTL Simulation using AMD Xilinx Vivado

---

## Processor Specifications

| Parameter | Description |
|---|---|
| Processor Width | 32 Bits |
| Architecture | RISC-V |
| Pipeline Organization | 5 Stages |
| Pipeline Stages | IF, ID, EX, MEM, WB |
| Register File | 32 × 32-Bit Registers |
| Register x0 | Hardwired to Zero |
| Instruction Memory | Instruction storage / program initialization |
| Data Memory | Load and store data |
| HDL | SystemVerilog |
| Simulation Tool | AMD Xilinx Vivado 2022.2 |

---

## Architecture

The processor is organized as a five-stage pipeline. Pipeline registers carry instruction information, operand values, control signals, and intermediate results from one stage to the next.

```text
          ┌─────────────────────┐
          │ Instruction Fetch  │
          │        (IF)        │
          └──────────┬──────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │     IF/ID Register  │
          └──────────┬──────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │ Instruction Decode  │
          │        (ID)        │
          └──────────┬──────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │     ID/EX Register  │
          └──────────┬──────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │      Execute       │
          │        (EX)        │
          └──────────┬──────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │     EX/MEM Register │
          └──────────┬──────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │   Memory Access    │
          │       (MEM)        │
          └──────────┬──────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │     MEM/WB Register │
          └──────────┬──────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │     Write Back     │
          │        (WB)        │
          └─────────────────────┘
```

### Pipeline Dataflow

```text
PC ──► Instruction Memory ──► IF/ID ──► Decode / Register File
                                             │
                                             ▼
                                           ID/EX
                                             │
                                             ▼
                                      ALU / Branch Unit
                                             │
                                             ▼
                                           EX/MEM
                                             │
                                             ▼
                                       Data Memory
                                             │
                                             ▼
                                           MEM/WB
                                             │
                                             ▼
                                      Register Writeback

Forwarding paths: EX/MEM and MEM/WB ──► Execute operands
Hazard control: detects dependencies and controls stalls/flushes
Branch/jump redirect: updates the PC and removes wrong-path instructions
```

---

## Working

1. The **Program Counter (PC)** supplies the address of the instruction to be fetched.
2. Instruction memory returns the instruction, which is captured along with its PC in the IF/ID pipeline register.
3. The **Instruction Decode (ID)** stage identifies the instruction operation, reads source registers, generates the immediate value, and produces control information.
4. The **Execute (EX)** stage performs ALU operations, calculates effective addresses for memory instructions, and evaluates branch conditions.
5. The **Memory Access (MEM)** stage reads from or writes to data memory for load and store instructions.
6. The **Write Back (WB)** stage selects the result and writes it to the destination register when required.
7. Pipeline registers preserve each instruction's data and control information as it advances through the stages.

---

## Pipeline Control

### Data Forwarding

When an instruction depends on the result of an earlier instruction, forwarding can provide the required value directly from a later pipeline stage instead of waiting for the register file to be updated.

The design verification includes dependent ALU operations, load-to-ALU forwarding, and load-to-store forwarding.

### Hazard Detection

A load instruction may produce its data later than an ALU instruction. When a following instruction depends on that loaded value, hazard control must ensure the dependent instruction receives the correct operand.

The load-use behavior was checked using directed instruction sequences.

### Branch and Jump Handling

Branch and jump instructions may redirect instruction execution to a different PC. Instructions fetched from the wrong path must not incorrectly update the processor state.

The branch-related verification includes branch conditions and checks for redirected control flow and wrong-path effects.

---

## Verification

The processor was verified using **7 individual directed verification suites** with SystemVerilog testbenches in Vivado behavioral simulation.

| No. | Verification Test | Coverage / Purpose | Result |
|---:|---|---|---|
| 1 | Branch Instruction Verification | Branch conditions and branch-related control flow | PASS |
| 2 | Load/Store and Load-Use Hazard | Load/store operation, dependent instruction behavior, and memory/register results | PASS |
| 3 | ALU Forwarding | Dependent ALU operations and forwarded operands | PASS |
| 4 | Load-to-ALU Forwarding | Use of loaded data by a following ALU operation | PASS |
| 5 | Load/Store Edge Cases | Byte, halfword, and word access; signed and unsigned loads; memory byte checks | PASS |
| 6 | Combined Pipeline Verification | Load-to-store forwarding, load-use scenario, ALU dependencies, branch flushing, and memory checks | PASS |
| 7 | Reset and x0 Verification | Reset/restart behavior and protection of register x0 | PASS |

**Total: 7 verification suites passed.**

The suites contain multiple individual register and memory assertions. Their aggregate number of unique assertions is not reported here as a single total, because the checks vary between testbenches and some scenarios overlap.

### Selected Verified Results

- Load/store and load-use test: `x1 = 42`, `x2 = 42`, and dependent result `x3 = 43`.
- ALU forwarding test: verified dependent arithmetic results including `x1 = 10`, `x2 = 15`, `x3 = 18`, `x4 = 7`, `x5 = 9`, `x6 = 16`, and `x7 = 26`.
- Load-to-ALU forwarding test: verified `x1 = 42` and `x2 = 47`.
- Load/store edge-case test: verified signed and unsigned byte/halfword loads, word loads, and little-endian memory bytes.
- Combined pipeline test: verified load-to-store forwarding, ALU dependencies, branch flushing, and memory contents.
- Reset and x0 test: verified `x0 = 0` and expected register values after restart.

> Verification scope: these are directed simulation tests for the listed scenarios. They do not constitute exhaustive RV32I compliance, formal verification, or proof of all possible instruction combinations.

---

## Simulation

The design and testbenches were simulated using **AMD Xilinx Vivado 2022.2**.

To run a verification test:

1. Add the RTL design files to **Design Sources**.
2. Add the required testbench and its corresponding instruction hex file to **Simulation Sources**.
3. Set the instruction memory `PROGRAM_FILE` parameter/path to the selected hex file.
4. Set the desired testbench module as the simulation top.
5. Run **Behavioral Simulation**.
6. Check the simulation transcript for the testbench's PASS/FAIL messages.

Each directed testbench should be run with its corresponding program hex file.

---

## Tools Used

- SystemVerilog
- AMD Xilinx Vivado 2022.2
- Vivado Simulator

---

## Future Enhancements

- Broader RV32I instruction and corner-case verification
- Randomized instruction testing and scoreboard-based checking
- Running a suitable RISC-V ISA test suite
- Synthesis and timing analysis
- FPGA implementation and hardware demonstration

---

## Author

**Peesu SwaranjithReddy**

B.Tech – Electronics and Communication Engineering

National Institute of Technology Rourkela
