
.align 8
// Our interrupt vector table
csd_entry:
	b csd_reset
	b .
	b .
	b csd_prefetch_abort
	b csd_data_abort
	b .
	b csd_irq
	b .
.global main
csd_reset:
main:

	// Set VBAR (Vector Base Address Register) to my own interrupt vectors
    ldr     r0, =csd_entry
    mcr     p15, 0, r0, c12, c0, 0

	// read SCTLR (System Control Register) to r0
	mrc	p15, 0, r0, c1, c0, 0

	// read SCR (Secure Configuration Register) to r1
	mrc p15, 0, r1, c1, c1, 0

	// read TTBCR (Translation Table Base Control Register) to r2
	mrc p15, 0, r2, c2, c0, 2

	// read TTBR0 to r3
	mrc p15, 0, r3, c2, c0, 0

	// read DACR (Domain Access Control Register) to r4
	mrc p15, 0, r4, c3, c0, 0

	/* Disable MMU, if enabled */
	mrc	p15, 0, r0, c1, c0, 0		/* read CP15 register 1 */
	bic	r0, r0, #0x1			/* clear bit 0 */
	mcr	p15, 0, r0, c1, c0, 0		/* write value back */

    /* Begin: store some words to the three 4KB page */
    mov r0, #0x400000
    mov r1, #0x400000
    add r1, r1, #0x3000

    mov r2, #0x0
    sub r2, r2, #0x200

for:
	nop
    str r2, [r0], #4
    add r2, r2, #0x1
    cmp r0, r1
    bne for
    /* End */

	// Figure 2.
	ldr	r0,=csd_MMUTable	   /* Load MMU translation table base */
	orr	r0, r0, #0x5B			/* Outer-cacheable, WB */
	mcr	15, 0, r0, c2, c0, 0		/* TTBR0 */

	/* Enable mmu, icahce and dcache */
	// read SCTLR (System Control Register) to r0
	mrc	p15, 0, r0, c1, c0, 0
	bic r0, r0, #(1<<12)  // I-bit = I$ disable
	bic r0, r0, #(1<<2)   // C-bit = $ disable
	orr r0, r0, #(1<<0)   // M-bit = MMU enable
	mcr	p15, 0, r0, c1, c0, 0	/* Enable cache and MMU */
	dsb					        /* dsb	allow the MMU to start up */
	isb					        /* isb	flush prefetch buffer */

	// read SCTLR (System Control Register) to r0
	mrc	p15, 0, r0, c1, c0, 0

	mov r0, #0x100000
	mov r1, #0x200000
	ldr r6, [r0]   /* read from 0x10_0000 to see if it reads from 0x20_0000 */
	ldr r7, [r1]   /* read from 0x20_0000 to see if it reads from 0x40_0000 */

	/* Disable MMU, if enabled */
	mrc	p15, 0, r0, c1, c0, 0		/* read CP15 register 1 */
	bic	r0, r0, #0x1			/* clear bit 0 */
	mcr	p15, 0, r0, c1, c0, 0		/* write value back */


	// Figure 3.
	ldr	r0,=csd_MMUTable2	   /* Load MMU translation table base */
	orr	r0, r0, #0x5B			/* Outer-cacheable, WB */
	mcr	15, 0, r0, c2, c0, 0		/* TTBR0 */

	/* Enable mmu, icahce and dcache */
	// read SCTLR (System Control Register) to r0
	mrc	p15, 0, r0, c1, c0, 0
	bic r0, r0, #(1<<12)  // I-bit = I$ disable
	bic r0, r0, #(1<<2)   // C-bit = $ disable
	orr r0, r0, #(1<<0)   // M-bit = MMU enable
	mcr	p15, 0, r0, c1, c0, 0	/* Enable cache and MMU */
	dsb					        /* dsb	allow the MMU to start up */
	isb					        /* isb	flush prefetch buffer */

	// read SCTLR (System Control Register) to r0
	mrc	p15, 0, r0, c1, c0, 0

	mov r0, #0x100000
	mov r1, #0x200000
	ldr r6, [r0]   /* read from 0x10_0000 to see if it reads from 0x20_0000 */
	ldr r7, [r1]   /* read from 0x20_0000 to see if it reads from 0x40_0000 */


	/* Disable MMU, if enabled */
	mrc	p15, 0, r0, c1, c0, 0		/* read CP15 register 1 */
	bic	r0, r0, #0x1			/* clear bit 0 */
	mcr	p15, 0, r0, c1, c0, 0		/* write value back */


forever:
	nop
	b forever

// Normal Interrupt Service Routine
csd_irq:
	b .

csd_prefetch_abort:
	mrc p15, 0, r10, c6, c0, 2  // read IFAR to r10
	mrc p15, 0, r11, c5, c0, 1  // read IFSR to r11
	b .

csd_data_abort:
	mrc p15, 0, r10, c6, c0, 0  // read DFAR to r10
	mrc p15, 0, r11, c5, c0, 0  // read DFSR to r11
	b .
