
ENTRY(Reset_Handler)

MEMORY {
    /* 0x0800_0000 - 0x0804_0000 */
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 256K
    /* 0x2000_0000 - 0x2000_2000 */
    RAM (xrw)  : ORIGIN = 0x20000000, LENGTH =  48K
}

/* TODO Template */
/* .data + .bss               12K */
__STACK_SIZE = 0x00001800; /*  6K */
__HEAP_SIZE  = 0x00007800; /* 30K */

SECTIONS {
    .isr_vector : {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } >FLASH

    .text : {
        . = ALIGN(4);

        *(.text)
        *(.text*)

        KEEP(*(.init))  /* crti.o */
        KEEP(*(.fini))  /* crtn.o */

        *(.glue_7)      /* glue arm to thumb code */
        *(.glue_7t)     /* glue thumb to arm code */
        *(.eh_frame)    /* exception handling code */

        . = ALIGN(4);
        *(.rodata)
        *(.rodata*)

        /* https://github.com/NevermindZZT/letter-shell */
        . = ALIGN(4);
        _shell_command_start = .;
        KEEP(*(shellCommand))
        _shell_command_end = .;

        . = ALIGN(4);
    } >FLASH

    _etext = LOADADDR(.data);
    .data : {
        . = ALIGN(4);
        __data_start__ = .;

        *(vtable)
        *(.data)
        *(.data*)

        . = ALIGN(4);
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
        . = ALIGN(4);
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);
        . = ALIGN(4);
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);

        . = ALIGN(4);
        __data_end__ = .;
    } >RAM AT>FLASH

    .bss : {
        . = ALIGN(4);
        __bss_start__ = .;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } >RAM

    .heap (COPY) : {
        . = ALIGN(8);
        __end__ = .;
        PROVIDE(end = .);
        . = . + __HEAP_SIZE;
        . = ALIGN(8);
        __HeapLimit = .;
    } > RAM
    
    
    .stack (ORIGIN(RAM) + LENGTH(RAM) - __STACK_SIZE) (COPY) : {
        . = ALIGN(8);
        __StackLimit = .;
        . = . + __STACK_SIZE;
        . = ALIGN(8);
        __StackTop = .;
    } > RAM
    PROVIDE(__stack = __StackTop);
    ASSERT(__StackLimit >= __HeapLimit, "region RAM overflowed with stack")
}
