#include "uart_regs.h"

.macro debug_macro
	// save register from r0 to r12 to stack
	stmfd sp!, {r0-r12}

	/////////////////////////////////////////////////////////////////////
	/// stmfd ~ msr 까지 존재하는 이유										/////
	///	1) cpsr 을 안전하게 보관하기 위해										/////
	/// 2) 이렇게 안하면 reg_push 를 할 때 특정 register 가 cpsr value 를 담고 있게 된다.	/////
	/// 따라서 cpsr value 를 macro_reg_space 에 보관한 다음,					/////
	/// r0-r12 register 값을 macro 시작 전처럼 유지한다.						/////
	/////////////////////////////////////////////////////////////////////

	// for safely save cpsr, use macro_reg_space
	stmfd sp!, {r0-r1}			// save register from r0 to r1 to stack
	mrs r0, cpsr				// r0 register for cpsr value
	ldr r1, =macro_reg_space	// r1 register for address of macro_reg_space

	stmia r1!, {r0}				// save cpsr value to macro_reg_space
	ldmfd sp!, {r0-r1}			// re-load r0, r1 register values from stack

    bl reg_push

	ldr r1, =macro_reg_space
	ldmia r1, {r0}				// load cpsr value to r0 register from macro_reg_space
    msr cpsr, r0				// save cpsr value to cpsr register

    // load register from r0 ro r12
    ldmfd sp!, {r0-r12}
.endm

// push all registers (r0-r15 and CPSR) to stack
reg_push:

	// save r1 register value to stack for using that register to store address of macro_reg_space
	stmfd sp!, {r1}
	ldr r1, =macro_reg_space

	// store r0 register value
	stmia r1!, {r0}			// r0 value to macro_reg_space
	mov r0, r1				// move address of macro_reg_space from r1 register to r0
	ldmfd sp!, {r1}			// load r1 register value from stack

	// store r1-r15 register value
	stmia r0!, {r1-r15}		// store r1 to r15 register in macro_reg_space

	// store cpsr register value
	mrs r1, cpsr			// load cpsr register value to r1 register
	stmia r0!, {r1}			// store cpsre register in macro_reg_space

	// loop reg_pop_one 17 times (r0-r15, cpsr register)
	ldr r0, =macro_reg_space	// init macro_reg_space to r0 register again
	mov r1, #17

	// init address of buffer & channel status register
	ldr r3, =uart_TX_RX_FIFO0
	ldr r4, =uart_Channel_sts_reg0

	// carriage return / line feed / null
	mov r5, #0x0D
	str r5, [r3]
	mov r5, #0x0A
	str r5, [r3]
	mov r5, #0x00
	str r5, [r3]

// pop register from stack one by one
reg_pop_one:
	// sub iteration variable to 1
	sub r1, r1, #1

	// load register value from macro_reg_space
	ldmia r0!, {r2}

	// set interation of print function to print register to tera-term
	mov r5, #8

	// for print cpsr in the tera-term
	cmp r1, #0
	bne not_cpsr
	moveq r6, #0x63
	streq r6, [r3]			// c
	moveq r6, #0x70
	streq r6, [r3]			// p
	moveq r6, #0x73
	streq r6, [r3]			// s
	moveq r6, #0x72
	streq r6, [r3]			// r
	moveq r6, #0x3D
	streq r6, [r3]			// =

	// print nzcv flag with bracket
	mov r6, #0x28
	str r6, [r3]			// (

	// N or n
	and r6, r2, #0x80000000
	cmp r6, #0x80000000
	moveq r6, #0x4E
	streq r6, [r3]			// N
	movne r6, #0x6E
	strne r6, [r3]			// n

	// Z or z
	and r6, r2, #0x40000000
	cmp r6, #0x40000000
	moveq r6, #0x5A
	streq r6, [r3]			// Z
	movne r6, #0x7A
	strne r6, [r3]			// z

	// C or c
	and r6, r2, #0x20000000
	cmp r6, #0x20000000
	moveq r6, #0x43
	streq r6, [r3]			// C
	movne r6, #0x63
	strne r6, [r3]			// c

	// V or v
	and r6, r2, #0x10000000
	cmp r6, #0x10000000
	moveq r6, #0x56
	streq r6, [r3]			// V
	movne r6, #0x76
	strne r6, [r3]			// v

	mov r6, #0x29
	str r6, [r3]			// )


	b print

	// for print rX= in the tera-term
	not_cpsr:
	mov r6, #0x72
	str r6, [r3]			// r
	rsbs r6, r1, #6
	addmi r6, r6, #58		// numeric value ( ~ 9)
	addpl r6, r6, #97		// alphabet value (10 ~ 15) represented as a 0x form
	str r6, [r3]			// X (variable, numeric or alphabet char)
	mov r6, #0x3D
	str r6, [r3]			// =

	// print register to tera-term through Tx FIFO
	print:
		// sub iteration variable to 1
		sub r5, r5, #1

		// check to see if the Tx FIFO is empty
		TRANSMIT_loop:
			ldr r6, [r4]
			and r6, r6, #0x8
			cmp r6, #0x8
			bne TRANSMIT_loop

		// print one-by-one
		mov r6, #0xF0000000
		and r7, r2, r6
		lsr r7, r7, #28

		// specify numeric or alphabet value
		subs r7, r7, #10
		addmi r7, r7, #58		// in numberic value case
		addpl r7, r7, #65		// in alphabet value case
		str r7, [r3]

		lsl r2, r2, #0x4		// logical shift left to print next byte

		// if iteration dose end, carriage return / line feed / null, return to prior routine (reg_pop_one)
		cmp r5, #0
		bne print

		moveq r8, #0x0D
		streqb r8, [r3]
		moveq r8, #0x0A
		streqb r8, [r3]
		moveq r8, #0x00
		streqb r8, [r3]

	// if iteration end, return to original routine (at the point call macro program)
    cmp r1, #0
    moveq pc, lr

	//	if iteration does not end, return to reg_pop_one
	b reg_pop_one


macro_reg_space:	.space 1024
