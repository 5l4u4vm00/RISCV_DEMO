/* RISC-V CPU Linker Script */
/* Define memory layout */

OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    /* Instruction memory: starting at 0x00000000, size 64KB */
    IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K

    /* Data memory: starting at 0x00010000, size 64KB */
    DMEM (rwx) : ORIGIN = 0x00010000, LENGTH = 64K
}

SECTIONS
{
    /* Code segment */
    .text : {
        *(.text.init)    /* Initialization code (_start) */
        *(.text)         /* General code */
        *(.text.*)
    } > IMEM

    /* Read-only data segment */
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    } > IMEM

    /* Initialized data segment */
    .data : {
        *(.data)
        *(.data.*)
    } > DMEM

    /* BSS segment (uninitialized data) */
    .bss : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        __bss_end = .;
    } > DMEM

    /* Stack pointer initial position */
    _stack_top = ORIGIN(DMEM) + LENGTH(DMEM);
}
