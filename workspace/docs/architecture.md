# RISC-V 5-Stage Pipeline CPU Architecture Design

## Overall Architecture Diagram

```
                            ┌─────────────────────────────────────────────────────────────────┐
                            │                        Hazard Unit                               │
                            │              (Stall, Flush, Forwarding Control)                  │
                            └──────┬──────────────┬──────────────┬──────────────┬─────────────┘
                                   │              │              │              │
    ┌──────────┐    ┌──────────┐   │  ┌──────────┐│  ┌──────────┐│  ┌──────────┐│  ┌──────────┐
    │          │    │  IF/ID   │   │  │  ID/EX   ││  │  EX/MEM  ││  │  MEM/WB  ││  │          │
    │    IF    │───▶│ Pipeline │───┼─▶│ Pipeline │┼─▶│ Pipeline │┼─▶│ Pipeline │┼─▶│    WB    │
    │  Stage   │    │   Reg    │   │  │   Reg    ││  │   Reg    ││  │   Reg    ││  │  Stage   │
    │          │    │          │   │  │          ││  │          ││  │          ││  │          │
    └────┬─────┘    └──────────┘   │  └──────────┘│  └──────────┘│  └──────────┘│  └────┬─────┘
         │                         │              │              │              │       │
         │                    ┌────┴────┐    ┌────┴────┐    ┌────┴────┐              │
         │                    │   ID    │    │   EX    │    │   MEM   │              │
         │                    │  Stage  │    │  Stage  │    │  Stage  │              │
         │                    │         │    │         │    │         │              │
         │                    │ Decoder │    │   ALU   │    │  D-Mem  │              │
         │                    │ RegFile │    │ Branch  │    │         │              │
         │                    └─────────┘    └─────────┘    └─────────┘              │
         │                                                                           │
         └───────────────────── Forwarding Path ────────────────────────────────────┘
```

## Pipeline Stages

### 1. IF (Instruction Fetch)
- Fetch instruction from instruction memory
- PC + 4 calculate next instruction address
- Handle branch/jump targets

### 2. ID (Instruction Decode)
- Decode instruction
- Read registers
- Immediate extension
- Generate control signals

### 3. EX (Execute)
- ALU operation
- Branch condition calculation
- Branch target address calculation

### 4. MEM (Memory Access)
- Load/Store access data memory

### 5. WB (Write Back)
- Write result back to register

## Module List

### Core Modules
| File | Module | Description |
|------|--------|-------------|
| `cpu_top.v` | cpu_top | Top-level module |
| `pc.v` | program_counter | Program counter |
| `imem.v` | instruction_memory | Instruction memory |
| `decoder.v` | decoder | Instruction decoder |
| `register_file.v` | register_file | Register file (completed) |
| `imm_gen.v` | immediate_generator | Immediate generator |
| `alu.v` | alu | Arithmetic logic unit (completed) |
| `branch_unit.v` | branch_unit | Branch determination unit |
| `dmem.v` | data_memory | Data memory |
| `control.v` | control_unit | Main control unit |

### Pipeline Registers
| File | Module | Description |
|------|--------|-------------|
| `if_id_reg.v` | if_id_reg | IF/ID stage register |
| `id_ex_reg.v` | id_ex_reg | ID/EX stage register |
| `ex_mem_reg.v` | ex_mem_reg | EX/MEM stage register |
| `mem_wb_reg.v` | mem_wb_reg | MEM/WB stage register |

### Hazard Handling
| File | Module | Description |
|------|--------|-------------|
| `hazard_unit.v` | hazard_unit | Hazard detection |
| `forwarding_unit.v` | forwarding_unit | Forwarding control |

## Supported Instructions (RV32I)

### R-type (Register)
```
ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
```

### I-type (Immediate)
```
ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI
LB, LH, LW, LBU, LHU (Load)
JALR
```

### S-type (Store)
```
SB, SH, SW
```

### B-type (Branch)
```
BEQ, BNE, BLT, BGE, BLTU, BGEU
```

### U-type (Upper Immediate)
```
LUI, AUIPC
```

### J-type (Jump)
```
JAL
```

## Hazard Handling Strategy

### Data Hazard
1. **Forwarding**: EX/MEM → EX, MEM/WB → EX
2. **Stall**: Load-use hazard (insert bubble)

### Control Hazard
1. **Static prediction**: Assume not taken (predict not taken)
2. **Flush**: Clear IF/ID, ID/EX when branch taken

## Memory Mapping

```
0x0000_0000 - 0x0000_FFFF : Instruction Memory (64KB)
0x0001_0000 - 0x0001_FFFF : Data Memory (64KB)
```
