#include "uart_regs.h"
#include "uart_init.s"
#include "debug_macro.s"

#define csd_LED_ADDR	0x41200000

.extern csd_main

.align 8

// Our interrupt vector table
csd_entry:
	b csd_reset
	b .
	b .
	b .
	b .
	b .
	b csd_irq
	b .

.global main
csd_reset:
main:

	uart_init

	mov r0, #32			// init outer loop count value
	mov r1, #0			// init inner loop count value

	debug_macro			// after init count value, run debug_macro

	ldr r2, =Input_data		// init pointer of Input_data that on the left side when comparing two values
	ldr r3, =Input_data		// init pointer of Input_data that on the right side when comparing two values

	debug_macro			// after set pointer of Input_data, run debug_macro

	eor r4, r4, r4		// init compared value that on the left side
	eor r5, r5, r5		// init compared value that on the right side

	debug_macro			// after init compared value (equals to 0), run debug_macro

outer:
	subs r0, r0, #1		// r0 = r0 - 1 & update nzcv flags (to check sorting is end)
	debug_macro			// after update nzcv flags (to check sotring is end), run debug_macro
	beq save			// if r0 equals 0, sorting is end

	eor r1, r1, r1		// init inner loop count before enter inner loop

	ldr r2, =Input_data		// init pointer of Input_data that on the left side when comparing two values
	ldr r3, =Input_data		// init pointer of Input_data that on the right side when comparing two values
	add r3, r3, #4			// init pointer of Input_data that on the right side when comparing two values

inner:
	cmp r0, r1		// check r0 = r1 & update nzcv flags (to check inner loop is end)
	beq outer		// if two values are same, inner loop is end

	add r1, r1, #1	// update inner loop count value by adding 1

	ldr r4, [r2], #4	// load Input data on the left side
	ldr r5, [r3], #4	// load Input data on the right side

	cmp r4, r5			// compare loaded two values
	blgt swap			// if left side value is greater than right side value, swap two values

	debug_macro

	b inner

swap:
	str r4, [r3, #-4]
	str r5, [r2, #-4]
	mov pc, lr

save:
	ldr r0, =Input_data
	ldr r1, =Output_data
	debug_macro				// after init Input_data & Output_data, run debug_macro

	ldmia r0!, {r2-r9}
	debug_macro				// after saving first 8 bits in memory, run debug_macro
	stmia r1!, {r2-r9}

	ldmia r0!, {r2-r9}
	debug_macro				// after saving second 8 bits in memory, run debug_macro
	stmia r1!, {r2-r9}

	ldmia r0!, {r2-r9}
	debug_macro				// after saving third 8 bits in memory, run debug_macro
	stmia r1!, {r2-r9}

	ldmia r0!, {r2-r9}
	debug_macro				// after saving forth 8 bits in memory, run debug_macro
	stmia r1!, {r2-r9}

forever:
	nop
	b forever


.data
.align 4
Input_data:
	.word  2, 0, -7, -1, 3, 8, -4, 10
	.word -9, -16, 15, 13, 1, 4, -3, 14
	.word -8, -10, -15, 6, -13, -5, 9, 12
	.word -11, -14, -6, 11, 5, 7, -2, -12

Output_data:
	.word 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0

// Normal Interrupt Service Routine
csd_irq:
	b .
