;; SPDX-License: GPL-2

;; ****************************************
;; *** @author: Eduardo Pozos Huerta	***
;; *** @file: main.asm					***
;; *** @date: 25/03/2025				***
;; ****************************************

;; *************************
;; *** Set object format ***
;; *************************

format elf64

;; *******************************
;; *** Enable ISC for security ***
;; *******************************

use64

;; *************************************
;; *** Visible labels for the linker ***
;; *************************************

public sum
public minus
public mult
public divs

;; **********************
;; *** Import headers ***
;; **********************

;; ************************
;; *** Program sections ***
;; ************************

section '_CODE' executable align 8

	align 8
	sum:
		push	rbp			;; Guardamos el valor del puntero base
		lea		rbp, [rsp]	;; Hacemos quel rbp apunte a donde rsp de forma eficiente
		sub		rsp, $10	;; Reservamos 16 bytes en la pila

		mov		qword [rbp - $08], rdi	;; Guardamos el primer parámetro en la pila
		mov		qword [rbp - $10], rsi	;; Guardamos el segundo parámetro en la pila
		
		mov		rax, qword [rbp - $08]	;; Accedemos a la pila consiguiendo el valor del primer parámetro
										;; y lo almacenamos en el registro acumulador

		mov		rdx, qword [rbp - $10]	;; Se aplica el mismo proceso de rax con rdx (registro de datos)
		
		add		rax, rdx	;; Sumamos el valor en rdx con el de rax y el resultado se almacena en rax

		add		rsp, $10	;; Liberamos la pila reservada
		pop		rbp			;; Restablecemos el valor del puntero base

		ret	;; Accedemos a la pila para obtener la dirección de retorno

	align 8
	minus:
		push	rbp
		lea		rbp, [rsp]
		sub		rsp, $10

		mov		qword [rbp - $08], rdi
		mov		qword [rbp - $10], rsi

		mov		rax, qword [rbp - $08]
		mov		rdx, qword [rbp - $10]

		sub		rax, rdx

		add		rsp, $10
		pop		rbp

		ret

	align 8
	mult:
		push	rbp
		lea		rbp, [rsp]
		sub		rsp, $08

		mov		qword [rbp - $08], rsi

		mov		rax, rdi
		xor		rdx, rdx
		imul	rax, qword [rbp - $08]

		add		rsp, $08
		pop		rbp

		ret

	align 8
	divs:
		test	rsi, rsi
		jz		.error

		xor		rdx, rdx
		mov		rax, rdi
		idiv	rsi

		ret

	.error:
		
		mov		rax, $01
		mov		rdi, $01
		lea		rsi, [msg.error.divs]
		mov		rdx, msg.error.divs.length
		syscall
		
		ret
		

section '_RODATA'
	msg:
		.error.divs: db "Zero division", $0D, $0A, $00
		.error.divs.length = $ - .error.divs