# An approximate equivalent to the following C code:
# 
# uint16_t a, b, d, c;
# a = 1; b = 1; d = 0;
# for (;;) {
#    	d = a + b;
# 		out (d);
# 		a = b; b = d;
# 		c = 0xffff;
# 		while ((c & 0xff00) != 0) { --c; }
# }
#

.data 
	a0, a1, b0, b1, d0, d1, c0, c1: byte
	
.code 
	ld.c 1
	st	a0
	st 	b0
	ld.c 0 
	st 	a1
	st 	b1
	st 	d0
	st	d1
loop: 
	ld	a0
	add	b0
	st	d0
	out	0
	ld	a1
	adc b1
	st	d1
	out 1
	ld 	b0
	st 	a0
	ld	b1
	st 	a1
	ld 	d0
	st	b0
	ld	d1
	st	b1 
	
sleep:
	ld.c 255
	st	c0
	st	c1

sleep_loop:
	ld.c 1
	sub	c0
	st	c0
	ld.c 0
	subc c1
	st	c1
	jnz sleep_loop
	
	jmp loop
 








