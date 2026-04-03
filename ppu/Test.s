	.file	"Test.c"
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__SREG__ = 0x3f
__tmp_reg__ = 0
__zero_reg__ = 1
	.text
.global	__vector_11
	.type	__vector_11, @function
__vector_11:
	__gcc_isr 1
/* prologue: Signal */
/* frame size = 0 */
/* stack size = 0...4 */
.L__stack_usage = 0 + __gcc_isr.n_pushed
	in r24,0x5
	com r24
	out 0x5,r24
/* epilogue start */
	__gcc_isr 2
	reti
	__gcc_isr 0,r24
	.size	__vector_11, .-__vector_11
	.section	.text.startup,"ax",@progbits
.global	main
	.type	main, @function
main:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	ldi r24,lo8(2)
	out 0x4,r24
	ldi r18,lo8(8)
	ldi r19,lo8(61)
	sts 136+1,r19
	sts 136,r18
	ldi r25,lo8(13)
	sts 129,r25
	sts 111,r24
/* #APP */
 ;  17 "Test.c" 1
	sei
 ;  0 "" 2
/* #NOAPP */
.L3:
	rjmp .L3
	.size	main, .-main
	.ident	"GCC: (GNU) 15.2.0"
