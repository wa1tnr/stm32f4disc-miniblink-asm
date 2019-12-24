# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

	.cpu cortex-m4
	.syntax unified
	.thumb

.section .text
	.org 0
	
	.word 0x20002000	/* stack top address */
	.word _start		/* 1 Reset */
	.word hang		/* 2 NMI */
	.word hang		/* 3 HardFault */
	.word hang		/* 4 MemManage */
	
.thumb_func
.global _start
_start:
	# Enable the GPIOD clock
	ldr	r3, =0x40023830 @ : RCC 40023800 ;  @  : RCC_AHB1ENR RCC 30 + ;
	ldr	r2, [r3]
	orr	r2, #4 @ @ : SETUPLED RCC @ 4 OR RCC_AHB1ENR ! ( GPIOCEN )
	str	r2, [r3]
	
	# Configure pin D6 for output
@ ldr	r3, =0x40020C00
	ldr	r3, =0x40020800 @ : GPIOC 40020800 ;
	ldr	r2, [r3]
@ GPIOC_MODER bit 2 set for PORTC_1:
	orr	r2, r2, #0x4 @ orr	r2, r2, #0x1000000 @ six zeros
	str	r2, [r3]
	
	# Load the address and content for the GPIO output register

@ GPIOC_ODR offset 0x14
	ldr     r3, =0x40020814 @ ldr     r3, =0x40020C14
	ldr	r2, [r3]
	
_loop:
	# Toggle the LED on pin D6
	@     4096    2048 1024 512 256  128 64 32 16    8 4 2 1
	eor	r2, #2 @ eor	r2, #4096
	str	r2, [r3]
	
	# Delay loop
	mov	r4, #0xFF000
_delay:
	nop
	subs	r4, #1
	bne	_delay
	
	# Repeat forever
	b	_loop

.thumb_func
hang:   b hang

.end
