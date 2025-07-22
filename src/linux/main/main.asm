;; SPDX-License: GPL-2

;; ****************************************
;; *** @author: Eduardo Pozos Huerta	***
;; *** @file: main.asm					***
;; *** @date: 25/03/2025				***
;; ****************************************

;; *****************************
;; *** Establecer el formato ***
;; ***	del código objeto	 ***
;; *****************************

format elf64

;; ************************************
;; *** Seleccionar el conjunto ISC	***
;; *** por seguridad de no usar		***
;; *** instrucciones no existentes	***
;; ************************************

use64

;; *****************************************
;; *** Etiquetas visibles para el linker ***
;; *****************************************

public main


;; **************************
;; *** Importar cabeceras ***
;; **************************
										;; ********************************
include "stdc/stdio.inc"	;; *** Definiciones externas	***
include "stdc/stdlib.inc"	;; *** de las funciones e		***
include "stdc/string.inc"	;; *** implementación de macros ***
										;; ********************************
;; ******************************
;; *** Secciones del programa ***
;; ******************************

section '.text' executable align 8

	align 8
	main:

	;; **************************************
	;; *** Establecer el marco de la pila ***
	;; **************************************

		push	rbp
		lea		rbp, [rsp]
		sub		rsp, $10

	;; **********************
	;; *** Primer mensaje ***
	;; **********************
	
		lea		rdi, [msg.loading]
		call	plt puts

		lea		rdi, [ts.one.sec]
		call	time

	;; ***********************
	;; *** Segundo mensaje ***
	;; ***********************

		lea		rdi, [msg.loading.finish]
		call	plt puts

		lea		rdi, [ts.one.sec]
		call	time

	;; **********************
	;; *** Tercer mensaje ***
	;; **********************

		lea		rdi, [msg.loading.init.calc]
		call	plt puts

		lea		rdi, [ts.two.sec]
		call	time


	;; **********************
	;; *** Cuartto mensaje ***
	;; **********************

		lea		rdi, [msg.loading.finish]
		call	plt puts

		lea		rdi, [ts.one.sec]
		call	time

	;; ***********************
	;; *** Bucle principal ***
	;; ***********************

	align 8
	.main_loop:

	;; **************************************************
	;; *** Imprimir opciones de operación disponibles ***
	;; **************************************************

		lea		rdi, [msg.options]
		mov		rsi, msg.options.length
		call	write

	;; *********************************
	;; *** Indicaciones del programa ***
	;; *********************************

		lea		rdi, [msg.message]
		mov		rsi, msg.message.length
		call	write

	;; **************************
	;; *** Leer la indicación ***
	;; **************************

		lea		rdi, [buffer.two]
		mov		rsi, $40
		call	read

	;; ****************************
	;; *** Convertirlo a número ***
	;; ****************************

		lea		rdi, [buffer.two]
		call	plt atoi

		cdq

		mov		qword [buffer.two], rax	;; Guardamos el número en memoria

	;; *************************************************
	;; *** Verificamos si existe la opción ingresada ***
	;; *************************************************

		cmp		al, $09
		ja		.dont_option

		cmp		al, $01
		jl		.dont_option

		jmp		.main_loop.option

	;; ******************
	;; *** Cálculamos ***
	;; ******************

	align 8
	.main_loop.option:

	;; ****************************************
	;; *** Verificar si el programa terminó ***
	;; ****************************************

		cmp		al, $09
		je		.done

	;; ********************************
	;; *** Obtener el primer número ***
	;; ********************************

		lea		rdi, qword [msg.number.one]
		mov		rsi, msg.number.one.length
		call	write

		lea		rdi, qword [buffer.sixty_four]
		mov		rsi, $40
		call	read

		lea		rdi, qword [buffer.sixty_four]
		call	plt atoi

		cdq
		
		mov		qword [rbp - $10], rax

	;; *********************************
	;; *** Obtener el segundo número ***
	;; *********************************

		lea		rdi, qword [msg.number.two]
		mov		rsi, msg.number.two.length
		call	write

		lea		rdi, qword [buffer.sixty_four]
		mov		rsi, $40
		call	read

		lea		rdi, [buffer.sixty_four]
		call	plt atoi

		cdq

		mov		rdi, qword [rbp - $10]
		mov		rsi, rax
		mov		rax, qword [buffer.two]
		jmp		calc

	;; *********************************
	;; *** Finalización del programa ***
	;; *********************************

	align	8
	.done:

		lea		rdi, qword [msg.done]
		mov		rsi, msg.done.length
		call	write

		mov		rax, $3C
		xor		rdi, rdi
		syscall

	;; *************************
	;; *** Manejo de errores ***
	;; *************************

	align 8
	.dont_option:
		lea		rdi, [msg.error.option]
		mov		rsi, msg.error.option.length
		call	write
		jmp		.main_loop

;; ************************************************
;; *** Subrutinas que hacen llamadas el sistema ***
;; ************************************************
	
	;; ******************************************************
	;; *** Subrutina para imprimir carácteres por consola ***
	;; ******************************************************

	align 8
	write:
		mov		rax, $001	;; Indicamos el servicio del sistema (write)
		mov		rdx, rsi	;; Pasamos la longitud
		mov		rsi, rdi	;; Obtenemos la dirección de memoria
		mov		rdi, rax	;; Indicamos la salida (stdout)
		syscall				;; Llamamos al sistema
		ret					;; Retorno

	;; ****************************************************
	;; *** Subrutina para obtener un string por consola ***
	;; ****************************************************

	align 8
	read:
		mov		rdx, rsi	;; Longitud del buffer
		mov		rsi, rdi	;; Dirección de memoria del buffer
		xor		rax, rax	;; Servicio del sistema (read)
		xor		rdi, rdi	;; Entrada de datos (stdin)
		syscall				;; Llamada al sistema
		ret					;; Retorno

	;; **************************************************
	;; *** Subrutina para pausar un tiempo el sistema ***
	;; **************************************************

	align 8
	time:
		mov		rax, $23	;; Número del servicio
		xor		rsi, rsi	;; El remaining no es necesario
		syscall				;; Llamada al sistema
		ret					;; Retorno de la llamada

;; ********************************
;; *** Subrutina de calculadora ***
;; ********************************
	
	align 8
	calc:
		
	;; ***************************************************
	;; *** Verificámos que cálculo fue el seleccionado ***
	;; ***************************************************

		cmp		al, $01
		je		.sum

		cmp		al, $02
		je		.minus

		cmp		al, $03
		je		.signed.mult

		cmp		al, $04
		je		.signed.divs

		cmp		al, $05
		je		.signed.module

		cmp		al, $06
		je		.unsigned.mult

		cmp		al, $07
		je		.unsigned.mult

		cmp		al, $08
		je		.unsigned.mult

	;; ****************************************
	;; *** En el caso que el programa falle	***
	;; *** por alguna extraña razón externa	***
	;; *** 		manejamos el error			***
	;; ****************************************

		lea		rdi, qword [msg.error.calc]
		mov		rsi, msg.error.calc.length
		call	write

		lea		rdi, qword [ts.two.sec]
		call	time

		jmp		main

;; ************************************
;; *** Operaciones de finalización	***
;; ***			del cálculo			***
;; ************************************

	.done.signed:
		lea		rdi, qword [msg.printf.format.signed]
		mov		rsi, rax
		xor		eax, eax
		call	plt printf

		lea		rdi, qword [ts.two.sec]
		call	time

		jmp		main.main_loop

	.done.unsigned:
		lea		rdi, qword [msg.printf.format.unsigned]
		mov		rsi, rax
		xor		eax, eax
		call	plt printf

		lea		rdi, qword [ts.two.sec]
		call	time

		jmp		main.main_loop


;; ******************************
;; *** Operaciones soportadas ***
;; ******************************

	;; *****************************
	;; *** Operaciones con signo ***
	;; *****************************

	.sum:
		mov		rax, rdi
		add		rax, rsi

		jmp		.done.signed

	.minus:
		mov		rax, rdi
		sub		rax, rsi
		
		jmp		.done.signed

	.signed.mult:
		xor		rdx, rdx
		imul	rdi, rsi
		
		mov		rax, rdi
		xor		rdx, rdx
		
		jmp		.done.signed

	.signed.divs:
		xor		rdx, rdx
		mov		rax, rdi
		
		idiv	rsi
		xor		rdx, rdx
		
		jmp		.done.signed

	.signed.module:
		xor		rdx, rdx
		mov		rax, rdi
		idiv	rsi
		
		mov		rax, rdx
		
		jmp		.done.signed

	;; *****************************
	;; *** Operaciones sin signo ***
	;; *****************************

	.unsigned.mult:
		xor		rdx, rdx
		mov		rax, rdi
		
		mul		rsi
		xor		rdx, rdx
		
		jmp		.done.unsigned

	.unsigned.divs:
		xor		rdx, rdx
		mov		rax, rdi
		
		div		rsi
		xor		rdx, rdx
		
		jmp		.done.unsigned

	.unsigned.module:
		xor		rdx, rdx
		mov		rax, rdi
		
		div		rsi
		mov		rax, rdx
		
		jmp		.done.unsigned

;; ************************
;; *** Buffers de datos ***
;; ************************


section '.bss' writeable

	buffer:
		.two:			rq $08
		.sixty_four:	rq $08

;; *******************************
;; *** Varoles de solo lectura ***
;; *******************************

section '.rodata'
	
	;; ************************************************
	;; *** Valores para pausar el sistema un tiempo ***
	;; ************************************************

	ts:
		.one.sec:	dq $001
		.one.nsec:	dq $000

		.two.sec:	dq $002
		.two.nsec:	dq $000

	;; ***************************
	;; *** Mensajes a imprimir ***
	;; ***************************

	msg: 

		;; ******************
		;; *** Especiales ***
		;; ******************

		.void:	db $0D, $0A

		.done:	db "terminando programa", $0D, $0A
		.done.length = $ - .done

		;; ***************
		;; *** Errores ***
		;; ***************

		.error.option:	db "No existe esa opción", $0D, $0A, $00
		.error.option.length = $ - .error.option

		.error.calc:	db "Cálculo fallido", $0D, $0A
						db "Es peligroso continuar la operación", $0D, $0A
						db "Reiniciando programa", $0D, $0A
		.error.calc.length = $ - .error.calc

		;; **********************************************
		;; *** Mensajes en lo que "carga" el programa ***
		;; **********************************************

		.loading:			db "Cargando calculadora", $00
		.loading.init.calc:	db "Inicializando sistema de cálculos", $00
		.loading.finish:	db "Proceso terminado", $0D, $0A, $00

		;; *****************************************
		;; *** Mensajes para el ingreso de datos ***
		;; *****************************************

		.number:
		.number.one:	db "Ingrese el primer número: "
		.number.one.length = $ - .number.one

		.number.two:	db "Ingrese el segundo número: "
		.number.two.length = $ - .number.two

		;; *********************************************
		;; *** Mensaje para seleccionar la operación ***
		;; *********************************************

		.message: db "Selecciones la operación que quiera hacer: "
		.message.length = $ - .message

		;; *****************************
		;; *** Opciones de operación ***
		;; *****************************

		.options:
		.options.sum:				db "1) Suma", $0D, $0A
		.options.minus:				db "2) Resta", $0D, $0A
		
		.options.signed.mult:		db "3) Multiplicación con signo", $0D, $0A
		.options.signed.divs:		db "4) División con signo", $0D, $0A
		.options.signed.module:		db "5) Modulo con signo", $0D, $0A
		
		.options.unsigned.mult:		db "6) Multiplicación sin signo", $0D, $0A
		.options.unsigned.divs:		db "7) División sin signo", $0D, $0A
		.options.unsigned.module:	db "8) Modulo sin signo", $0D, $0A
		
		.options.end:				db "9) Salir del programa", $0D, $0A, $0D, $0A

		.options.length = $ - .options

		;; **************************
		;; *** Formatos de printf ***
		;; **************************

		.printf.format.signed:		db $0D, $0A, "Resultado: %lld", $0D, $0A, $0D, $0A, $00
		.printf.format.unsigned:	db $0D, $0A, "Resultado: %llu", $0D, $0A, $0D, $0A, $00