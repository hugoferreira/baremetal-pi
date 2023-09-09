SECTIONS
{
    /* Set starting address to 0x80000 */
    . = 0x80000;
    
    /* Keep the .text.boot section and include general .text sections */
    .text : {
        KEEP(*(.text.boot))
        *(.text)
    }

    .data : { *(.data) }
    .rodata : { *(.rodata) }

    /* Uninitialized Data Section */
    .bss (NOLOAD) : {
        /* Align to 16 bytes */
        . = ALIGN(16);
        /* Start and end markers for the .bss section */
        __bss_start = .;
        *(.bss)
        __bss_end = .;
    }

    /* End of memory marker */
    _end = .;
}
