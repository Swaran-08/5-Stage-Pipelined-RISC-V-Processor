# 5-Stage Pipelined RISC-V Processor

A **SystemVerilog** implementation of a 32-bit RISC-V processor using a classic five-stage pipeline. The processor divides instruction execution into Instruction Fetch, Instruction Decode, Execute, Memory Access, and Write Back stages, allowing multiple instructions to be in flight concurrently.

The design includes pipeline registers, an ALU, register-file access, instruction and data memories, forwarding, hazard handling, and branch/jump control. It was developed and functionally verified using **AMD Xilinx Vivado 2022.2**.

---

## Features

- 32-bit RISC-V processor design
- Five-stage pipeline: IF, ID, EX, MEM, and WB
- Program counter and instruction memory
- Instruction decode and control signal generation
- 32-entry register file with x0 hardwired to zero
- Arithmetic and logic unit (ALU)
- Immediate generation
- Data memory with load and store support
- Pipeline registers between stages
- Data forwarding for dependent instructions
- Hazard detection and handling
- Branch and jump control
- Pipeline flush handling for redirected control flow
- Directed SystemVerilog testbench-based verification
- RTL behavioral simulation using Vivado

---

## Processor Specifications

| Parameter | Description |
|---|---|
| Processor width | 32 bits |
| Architecture | RISC-V |
| Pipeline organization | 5 stages |
| Pipeline stages | IF, ID, EX, MEM, WB |
| Register file | 32 × 32-bit registers |
| Register x0 | Hardwired to zero |
| HDL | SystemVerilog |
| Simulation tool | AMD Xilinx Vivado 2022.2 |

---

## Repository Structure

```text
riscv_swaran/
│
├── README.md
│
├── src/
│   ├── core/
│   │   └── top_5_stage_pipeline.sv
│   │
│   ├── modules/
│   │   ├── alu.sv
│   │   ├── alu_control.sv
│   │   ├── control_unit.sv
│   │   ├── data_mem.sv
│   │   ├── immediate_generator.sv
│   │   ├── instr_mem.sv
│   │   ├── program_counter.sv
│   │   └── reg_file.sv
│   │
│   ├── pipeline/
│   │   ├── if_id_reg.sv
│   │   ├── id_ex_reg.sv
│   │   ├── ex_mem_reg.sv
│   │   └── mem_wb_reg.sv
│   │
│   └── hazards/
│       ├── forwarding_unit.sv
│       └── hazard_detection_unit.sv
│
├── sim/
│   ├── hex/
│   │   ├── program_branch.hex
│   │   ├── program_branch_hazard_reset.hex
│   │   ├── program_forwarding.hex
│   │   ├── program_load_alu_forwarding.hex
│   │   ├── program_load_store.hex
│   │   ├── program_load_store_edge_cases.hex
│   │   ├── program_pipeline_integration.hex
│   │   └── program_reset_x0.hex
│   │
│   └── tb/
│       ├── tb_top_5_stage_branch_hazard_reset.sv
│       ├── tb_top_5_stage_branch_verify.sv
│       ├── tb_top_5_stage_forwarding_verify.sv
│       ├── tb_top_5_stage_load_alu_forwarding_verify.sv
│       ├── tb_top_5_stage_load_store_edge_cases.sv
│       ├── tb_top_5_stage_load_store_verify.sv
│       ├── tb_top_5_stage_pipeline_integration.sv
│       └── tb_top_5_stage_reset_x0.sv
│
└── docs/
    └── verification/
        └── [Verification result images]
```

> Keep the source, testbench, and HEX filenames consistent with the files actually committed to the repository. The testbench is selected as the simulation top; the processor top module is instantiated as the DUT.

---

## Processor Architecture

The processor uses the following five-stage instruction pipeline:

```text
                 ┌─────────────────────┐
                 │ Instruction Fetch   │
                 │        IF           │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │      IF/ID Reg      │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Instruction Decode  │
                 │        ID           │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │      ID/EX Reg      │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │      Execute       │
                 │        EX          │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │      EX/MEM Reg     │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │   Memory Access    │
                 │        MEM         │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │      MEM/WB Reg     │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │    Write Back      │
                 │        WB          │
                 └─────────────────────┘

      Forwarding paths: EX/MEM and MEM/WB → Execute operands
      Hazard control: dependency detection and pipeline control
      Branch/jump redirect: PC update and wrong-path instruction handling
```

---

## Working

1. **Instruction Fetch (IF):** The program counter supplies the address of the instruction to be fetched from instruction memory.
2. **Instruction Decode (ID):** The instruction is decoded, source registers are read, the immediate is generated, and control signals are produced.
3. **Execute (EX):** The ALU performs arithmetic/logical operations, calculates memory addresses, and evaluates branch conditions.
4. **Memory Access (MEM):** Load instructions read from data memory and store instructions write to data memory.
5. **Write Back (WB):** The selected result is written to the destination register when register write is enabled.
6. **Pipeline registers:** The IF/ID, ID/EX, EX/MEM, and MEM/WB registers carry instruction data and control signals between stages.

---

## Pipeline Control

### Data Forwarding

When an instruction depends on the result of an earlier instruction, forwarding provides the required operand from a later pipeline stage without waiting for the register file update. The directed verification includes dependent ALU operations and load-related dependencies.

### Hazard Detection

A load instruction may produce its data later than an ALU instruction. The hazard detection and pipeline control logic handles tested load-use scenarios so dependent instructions receive the expected operand.

### Branch and Jump Handling

Branch and jump instructions can redirect execution to a different PC. Branch-related tests check the supported branch conditions, control-flow behavior, and selected wrong-path effects.

---

## Verification

The processor was checked using **8 directed verification testbenches** in Vivado behavioral simulation. Each testbench targets a specific group of processor behaviors.

| No. | Verification Test | Purpose |
|---:|---|---|
| 1 | Branch Instruction Verification | Checks branch conditions, taken/not-taken behavior, and branch-related control flow |
| 2 | Branch, Hazard, JALR and Reset Verification | Checks branch scenarios together with a load-use branch hazard, JALR target/alignment scenario, and reset/restart behavior |
| 3 | Load/Store and Load-Use Hazard Verification | Checks load/store operation, dependent instruction behavior, and register/memory results |
| 4 | ALU Data Forwarding Verification | Checks dependent ALU instructions and forwarded operands |
| 5 | Load-to-ALU Forwarding Verification | Checks use of loaded data by a following ALU instruction |
| 6 | Load/Store Edge Case Verification | Checks byte, halfword, and word accesses, signed/unsigned loads, and memory byte values |
| 7 | Pipeline Integration Verification | Checks multiple pipeline behaviors together, including data dependencies, load/store interactions, control flow, and memory results |
| 8 | Reset and x0 Register Verification | Checks reset/restart behavior and that x0 remains zero |

**Reported result: all 8 individual verification testbenches passed.**

The tests contain multiple register and memory checks. A single aggregate count of unique assertions is not listed because checks differ between testbenches and some scenarios overlap.

### Selected Verified Results

- **Load/store and load-use:** verified `x1 = 42`, `x2 = 42`, and dependent result `x3 = 43`; checked memory bytes.
- **ALU forwarding:** verified dependent arithmetic results including `x1 = 10`, `x2 = 15`, `x3 = 18`, `x4 = 7`, `x5 = 9`, `x6 = 16`, and `x7 = 26`.
- **Load-to-ALU forwarding:** verified `x1 = 42` and `x2 = 47`.
- **Load/store edge cases:** checked signed and unsigned byte/halfword loads, word loads, and little-endian memory contents.
- **Pipeline integration:** checked dependent operations and memory results across a set of combined instruction scenarios.
- **Reset and x0:** checked `x0 = 0` and expected register values after reset/restart.

> **Verification scope:** These are directed simulation tests for the scenarios listed above. They do not constitute exhaustive RV32I compliance, formal verification, or proof of all possible instruction combinations.

---

## Verification Results

Verification result images are organized in `docs/verification/`. Each image documents the simulation output for its corresponding testbench.

Suggested image headings:

- Branch Instruction Verification
- Branch, Hazard, JALR and Reset Verification
- Load/Store and Load-Use Hazard Verification
- ALU Data Forwarding Verification
- Load/Store Edge Case Verification
- Pipeline Integration Verification
- Reset and x0 Register Verification

---

## Simulation

The RTL design and testbenches were simulated using **AMD Xilinx Vivado 2022.2**.

To run a verification test:

1. Add the RTL source files to **Design Sources**.
2. Add the selected testbench to **Simulation Sources**.
3. Make the corresponding HEX program available to instruction memory.
4. Set the instruction memory `PROGRAM_FILE` parameter/path to the selected HEX file.
5. Set the desired testbench module as the simulation top.
6. Run **Behavioral Simulation**.
7. Check the simulation transcript for the testbench's PASS/FAIL messages.

Run each directed testbench with its corresponding instruction HEX file.

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
