
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

// case A: turn on both (1) and (2): prefetch abort at "dsb"
// case B: turn on only (2): data abort at "ldr r6, [r0]  // read from 0x10_0000"

// ---------------------- (1) start --------------------------
// Its behavior:
// If $ and TLBs are invalidated and SW-exception handling is turned on,
// debugger hangs when executing dsb (right after MMU enable).
//
// My thought:
// If you let it go with entering F5 and suspend CPU
// then, it keeps executing the prefetch abort vector (because it can't find the translation info.?)
// so I guess it is an expected result...
// You should have at least a page with interrupt vector table already mapped.

/*
	// Invalidate caches and TLBs (from Boot.S)
	mov	r0,#0				// r0 = 0
	mcr	p15, 0, r0, c8, c7, 0		// invalidate TLBs
	mcr	p15, 0, r0, c7, c5, 0		// invalidate icache
	mcr	p15, 0, r0, c7, c5, 6		// Invalidate branch predictor array
*/
// ---------------------- (1) end --------------------------

    /* Begin: store some words to the start of each 1MB section */
	mov r0, #0x100000
	mov r1, #0x200000
	mov r2, #0x400000

	mov r3, #0x11
	mov r4, #0x22
	mov r5, #0x44

	str r3, [r0]
	str r4, [r1]
	str r5, [r2]

	ldr r10, [r0]
	ldr r11, [r1]
	ldr r12, [r2]
    /* End */

	ldr	r0,=csd_MMUTable	   /* Load MMU translation table base */
	orr	r0, r0, #0x5B			/* Outer-cacheable, WB */
	mcr	15, 0, r0, c2, c0, 0		/* TTBR0 */

// ---------------------- (2) start --------------------------
/*
    // Play with HW page walk or SW handling of TLB miss
	// Page Table Walk by HW or SW (PD1, PD0)
	// TTBCR (Translation Table Base Control Register) PD1, PD0
	mrc p15, 0, r2, c2, c0, 2
	orr r2, r2, #(1<<5)   // Set PD1 to 1 = TLB miss handling by SW
	orr r2, r2, #(1<<4)   // Set PD0 to 1 = TLB miss handling by SW
	mcr p15, 0, r2, c2, c0, 2
*/
// ---------------------- (2) end --------------------------

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
