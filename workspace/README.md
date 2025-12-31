# RISC-V CPU Development Environment

This is a complete RISC-V CPU design development environment, containerized with Docker, including Neovim + LazyVim editor, Verilog simulation tools, and RISC-V cross-compilation toolchain.

## Quick Start

### 1. Build Docker Image

```bash
docker-compose build
```

### 2. Start Development Environment

```bash
# Using docker-compose (recommended)
docker-compose run --rm riscv-dev

# Or use docker directly
docker run -it --rm \
    -v $(pwd)/workspace:/workspace \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    riscv-cpu-dev:latest
```

### 3. Start Development

After entering the container:

```bash
# Open Neovim (LazyVim will automatically install plugins on first launch)
nvim .

# Or run simulation directly
make sim
```

## Neovim + LazyVim Hotkeys

Leader key is `<Space>`

### Verilog Development

| Hotkey | Function |
|--------|----------|
| `<Space>vs` | Run Verilog simulation (make sim) |
| `<Space>vw` | Open GTKWave waveform viewer |
| `<Space>vc` | Clean build files |

### RISC-V Development

| Hotkey | Function |
|--------|----------|
| `<Space>rc` | Compile RISC-V software |
| `<Space>rd` | View disassembly results |

### File Navigation

| Hotkey | Function |
|--------|----------|
| `<Space>e` | Open/close file tree |
| `<Space>ff` | Search files |
| `<Space>fg` | Global search (grep) |
| `<Space>fr` | Search RTL files |
| `<Space>ft` | Search Testbench files |

### Common LazyVim Hotkeys

| Hotkey | Function |
|--------|----------|
| `<Space>gg` | Open LazyGit |
| `<Space>cf` | Format code |
| `<Space>cr` | Rename symbol |
| `gd` | Jump to definition |
| `gr` | Find references |
| `K` | Show documentation |

## Directory Structure

```
workspace/
├── rtl/                # Verilog RTL source code
│   ├── alu.v          # ALU module
│   └── register_file.v # Register file
├── tb/                 # Testbench files
│   └── tb_alu.v       # ALU test
├── sim/                # Simulation output
│   └── wave.vcd       # Waveform file
├── sw/                 # RISC-V software
│   ├── test.S         # Test program
│   └── link.ld        # Linker script
└── Makefile           # Build script
```

## Common Commands

### Verilog Simulation

```bash
# Compile all RTL and testbench
iverilog -o sim/out rtl/*.v tb/*.v

# Run simulation
vvp sim/out

# View waveform
gtkwave sim/wave.vcd &
```

### RISC-V Compilation

```bash
# Compile assembly language
riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -o sw/test.o sw/test.S

# Link
riscv32-unknown-elf-ld -T sw/link.ld -o sw/test.elf sw/test.o

# Generate hexadecimal (for Verilog $readmemh)
riscv32-unknown-elf-objcopy -O verilog sw/test.elf sw/test.hex

# Disassemble (for debugging)
riscv32-unknown-elf-objdump -d sw/test.elf > sw/test.dump
```

### Makefile Commands

```bash
make sim        # Compile and run simulation
make wave       # Open GTKWave
make compile_sw # Compile RISC-V test program
make clean      # Clean
make help       # Show help
```

## Included Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **Neovim** | 0.10.2 | Editor |
| **LazyVim** | latest | Neovim configuration framework |
| Icarus Verilog | 12.x | Verilog compilation/simulation |
| Verilator | 5.x | High-speed simulation |
| GTKWave | 3.3.x | Waveform viewer |
| RISC-V GCC | 13.2.0 | Cross compiler |
| cocotb | latest | Python testbench |
| ripgrep | latest | Fast search |
| fd | latest | Fast file finder |
| lazygit | latest | Git TUI |

## X11 Forwarding Configuration (GTKWave)

### Linux

```bash
xhost +local:docker
```

### macOS (using XQuartz)

```bash
xhost +localhost
export DISPLAY=host.docker.internal:0
```

### Windows (using VcXsrv)

1. Install VcXsrv
2. Start XLaunch, select "Multiple windows" and "Disable access control"
3. Set `DISPLAY=host.docker.internal:0`

## Next Steps

1. **Complete Pipeline CPU Design**
   - Add IF/ID/EX/MEM/WB stage registers
   - Implement Hazard Detection Unit
   - Implement Forwarding Unit

2. **Extend Instruction Set**
   - Add Load/Store instructions
   - Add Branch instructions
   - Add CSR instructions (optional)

3. **Add Peripherals**
   - UART
   - Timer
   - GPIO

## Reference Resources

- [RISC-V Specifications](https://riscv.org/specifications/)
- [Patterson & Hennessy - Computer Organization and Design (RISC-V Edition)](https://www.elsevier.com/books/computer-organization-and-design-risc-v-edition/patterson/978-0-12-812275-4)
- [One Student One Chip Program](https://ysyx.oscc.cc/)
