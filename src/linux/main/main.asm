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
include "include/linux/stdc/stdio.inc"	;; *** Definiciones externas	***
include "include/linux/stdc/stdlib.inc"	;; *** de las funciones e		***
include "include/linux/stdc/string.inc"	;; *** implementación de macros ***
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
		mov		rsi, $01
		call	read

	;; ****************************
	;; *** Convertirlo a número ***
	;; ****************************

		lea		rdi, [buffer.two]
		call	plt atoi

		mov		word [buffer.two], ax	;; Guardamos el número en memoria

	;; *************************************************
	;; *** Verificamos si existe la opción ingresada ***
	;; *************************************************

		cmp		ax, $08
		ja		.dont_option

		cmp		ax, $00
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

		cmp		ax, $08
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
		
		cwde
		cdqe
		
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

		cdqe

		mov		rdi, qword [rbp - $10]
		mov		rsi, rax
		mov		ax, word [buffer.two]
		call	calc

		jmp		.main_loop

	;; *********************************
	;; *** Finalización del programa ***
	;; *********************************

	.done:

		mov		rax, $3C
		xor		rdi, rdi
		syscall

	;; *************************
	;; *** Manejo de errores ***
	;; *************************

	.dont_option:
		lea		rdi, [msg.error.option]
		mov		rsi, msg.error.option.length
		call	write
		jmp		.done

;; ************************************************
;; *** Subrutinas que hacen llamadas el sistema ***
;; ************************************************
	
	;; ******************************************************
	;; *** Subrutina para imprimir carácteres por consola ***
	;; ******************************************************

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

	time:
		mov		rax, $23
		xor		rsi, rsi
		syscall
		ret

;; ********************************
;; *** Subrutina de calculadora ***
;; ********************************

	calc:
		
		test	ax, ax
		jz		.sum

		cmp		ax, $01
		je		.minus

		cmp		ax, $02
		je		.signed.mult

		cmp		ax, $03
		je		.signed.divs

		cmp		ax, $04
		je		.signed.module

		cmp		ax, $05
		je		.unsigned.mult

		cmp		ax, $06
		je		.unsigned.mult

		cmp		ax, $07
		je		.unsigned.mult

	.done:
		ret

	.sum:
		mov		rax, rdi
		add		rax, rsi

		jmp		.done

	.minus:
		mov		rax, rdi
		sub		rax, rsi
		jmp		.done

	.signed.mult:
		xor		rdx, rdx
		imul	rdi, rsi
		
		mov		rax, rdi
		xor		rdx, rdx
		
		jmp		.done

	.signed.divs:
		xor		rdx, rdx
		mov		rax, rdi
		
		idiv	rsi
		xor		rdx, rdx
		
		jmp		.done

	.signed.module:
		xor		rdx, rdx
		mov		rax, rdi
		idiv	rsi
		mov		rax, rdx
		jmp		.done


	.unsigned.mult:
		xor		rdx, rdx
		mov		rax, rdi
		
		mul		rsi
		xor		rdx, rdx
		
		jmp		.done

	.unsigned.divs:
		xor		rdx, rdx
		mov		rax, rdi
		
		div		rsi
		xor		rdx, rdx
		
		jmp		.done

	.unsigned.module:
		xor		rdx, rdx
		mov		rax, rdi
		
		div		rsi
		mov		rax, rdx
		
		jmp		.done

;; ************************
;; *** Buffers de datos ***
;; ************************


section '.bss' writeable

	buffer:
		.two:			rw $01
		.sixty_four:	rb $40

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

		;; **********************
		;; *** Salto de línea ***
		;; **********************

		.void:	db $0D, $0A

		;; ***************
		;; *** Errores ***
		;; ***************

		.error.option: db "No existe esa opción", $0D, $0A, $00
		.error.option.length = $ - .error.option

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
		.number.one:	db "Ingrese el primer número: ", $00
		.number.one.length = $ - .number.one

		.number.two:	db $0D, $0A, "Ingrese el segundo número: ", $00
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
		.options.sum:				db "0) Suma", $0D, $0A
		.options.minus:				db "1) Resta", $0D, $0A
		
		.options.signed.mult:		db "2) Multiplicación con signo", $0D, $0A
		.options.signed.divs:		db "3) División con signo", $0D, $0A
		.options.signed.module:		db "4) Modulo con signo", $0D, $0A
		
		.options.unsigned.mult:		db "5) Multiplicación sin signo", $0D, $0A
		.options.unsigned.divs:		db "6) División sin signo", $0D, $0A
		.options.unsigned.module:	db "7) Modulo sin signo", $0D, $0A
		
		.options.end:				db "8) Salir del programa", $0D, $0A

		.options.length = $ - .options

		;; **************************
		;; *** Formatos de printf ***
		;; **************************

		.printf.format.signed.long:			db "%lld", $0D, $0A, $00
		.printf.format.signed.integer:		db "%d", $0D, $0A, $00

;; *********************
;; *** Recordatorios ***
;; *********************

;; 1) Agregar un printf inmediato después de la operación
;; 2) Mejorarlo para que lea archivos después
;; 3) Corregit el error del input (urgente)