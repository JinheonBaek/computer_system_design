#include "uart_regs.h"
#include "uart_init.s"
#include "uart_print.s"

#define csd_LED_ADDR 0x41200000

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
.global csd_entry
csd_reset:
main:

	// init uart
	uart_init

	// init menu (print menu)
	uart_print

	// init variables
	ldr r0, =uart_TX_RX_FIFO0
	ldr r1, =uart_Channel_sts_reg0
	ldr r2, =csd_LED_ADDR

	// set which led is on during iteration
	mov r5, #0x1

forever:
	// check empty: bit#1 is Rx FIFO empty or not (1: empty, 0: not empty)
	ldr r3, [r1]
	and r3, r3, #1<<1
	cmp r3, #0			// if equal, Rx FIFO is not empty (zero flag is 1, not empty)

	// read data and transmit it back to sender
	ldreq r4, [r0]
	streq r4, [r0]

	// carriage return / line feed / null
	moveq r8, #0x0D
	streqb r8, [r0]
	moveq r8, #0x0A
	streqb r8, [r0]
	moveq r8, #0x00
	streqb r8, [r0]

	// print_menu
	stmfd sp!, {r0-r4}	// before call uart_print, using stack to save reusable variables
	uart_print
	ldmfd sp!, {r0-r4}	// after call uart_print, loading variables from stack

	// Duration control
	stmfd sp!, {r0-r2}	// before call csd_main, using stack to save reusable variables
	mov r0, r4			// before function call, set parameter
	bl csd_main
	ldmfd sp!, {r0-r2}	// after call csd_main, loading variables from stack

	// LED control
	strb r5, [r2]				// Turn on next LED
	lsl r5, r5, #1				// logical shift left by 1
	cmp r5, #0x100				// compare
	moveq r5, #0x1				// reset LED if compare condition is true

	b forever

.data
.align 4
csd_irq:
	b .
