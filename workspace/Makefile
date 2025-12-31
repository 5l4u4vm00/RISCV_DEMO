# RISC-V CPU Project Makefile
# ============================

# Tool configuration
IVERILOG = iverilog
VVP = vvp
VERILATOR = verilator
GTKWAVE = gtkwave

# RISC-V toolchain
RISCV_PREFIX = riscv32-unknown-elf-
CC = $(RISCV_PREFIX)gcc
AS = $(RISCV_PREFIX)as
LD = $(RISCV_PREFIX)ld
OBJDUMP = $(RISCV_PREFIX)objdump
OBJCOPY = $(RISCV_PREFIX)objcopy

# Directory configuration
RTL_DIR = rtl
TB_DIR = tb
SIM_DIR = sim
SW_DIR = sw

# RTL files (add your modules in order)
RTL_FILES = $(wildcard $(RTL_DIR)/*.v)
TB_FILES = $(wildcard $(TB_DIR)/*.v)

# Default targets
.PHONY: all clean sim sim_alu wave compile_sw help

all: sim

# ============================
# Verilog Simulation - Complete CPU Test
# ============================

# Compile CPU Testbench
$(SIM_DIR)/cpu_tb: $(RTL_FILES) $(TB_DIR)/tb_cpu.v
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) -o $@ -I$(RTL_DIR) -DSIM $(RTL_FILES) $(TB_DIR)/tb_cpu.v

# Run CPU simulation
sim: $(SIM_DIR)/cpu_tb
	cd $(SIM_DIR) && $(VVP) cpu_tb

# ============================
# Verilog Simulation - ALU Unit Test
# ============================

$(SIM_DIR)/alu_tb: $(RTL_DIR)/alu.v $(TB_DIR)/tb_alu.v
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) -o $@ -I$(RTL_DIR) $(RTL_DIR)/alu.v $(TB_DIR)/tb_alu.v

sim_alu: $(SIM_DIR)/alu_tb
	cd $(SIM_DIR) && $(VVP) alu_tb

# ============================
# Waveform Viewer
# ============================

wave:
	$(GTKWAVE) $(SIM_DIR)/wave.vcd &

# ============================
# Verilator Simulation (faster)
# ============================

verilate:
	@mkdir -p $(SIM_DIR)/verilator
	$(VERILATOR) --cc --exe --build \
		-I$(RTL_DIR) \
		--Mdir $(SIM_DIR)/verilator \
		$(RTL_DIR)/cpu_top.v \
		$(TB_DIR)/verilator_tb.cpp

# ============================
# RISC-V Software Compilation
# ============================

# Compile assembly language
$(SW_DIR)/%.o: $(SW_DIR)/%.S
	$(AS) -march=rv32i -mabi=ilp32 -o $@ $<

# Link
$(SW_DIR)/%.elf: $(SW_DIR)/%.o $(SW_DIR)/link.ld
	$(LD) -T $(SW_DIR)/link.ld -o $@ $<

# Generate binary
$(SW_DIR)/%.bin: $(SW_DIR)/%.elf
	$(OBJCOPY) -O binary $< $@

# Generate hexadecimal (for Verilog $readmemh)
$(SW_DIR)/%.hex: $(SW_DIR)/%.elf
	$(OBJCOPY) -O verilog $< $@

# Disassemble (for debugging)
$(SW_DIR)/%.dump: $(SW_DIR)/%.elf
	$(OBJDUMP) -d $< > $@

compile_sw: $(SW_DIR)/test.hex $(SW_DIR)/test.dump

# ============================
# Clean
# ============================

clean:
	rm -rf $(SIM_DIR)/*
	rm -f $(SW_DIR)/*.o $(SW_DIR)/*.elf $(SW_DIR)/*.bin $(SW_DIR)/*.hex $(SW_DIR)/*.dump

# ============================
# Help
# ============================

help:
	@echo "RISC-V CPU Development Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make sim        - Compile and run complete CPU simulation"
	@echo "  make sim_alu    - Run ALU unit test"
	@echo "  make wave       - Open GTKWave to view waveforms"
	@echo "  make verilate   - Compile with Verilator (faster)"
	@echo "  make compile_sw - Compile RISC-V test program"
	@echo "  make clean      - Clean generated files"
	@echo "  make help       - Show this help"
