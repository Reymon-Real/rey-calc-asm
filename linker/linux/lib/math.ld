/* Out format files */

OUTPUT_FORMAT(elf64-x86-64)

/* Seacrh dir */

SEARCH_DIR(/usr/lib/x86_64-linux-gnu)

/* Memory */

MEMORY {
	TEXT	(rx) : ORIGIN = 40M + 00K, LENGTH = 4K
	DATA	(rw) : ORIGIN = 40M + 04K, LENGTH = 8K
	BSS		(rw) : ORIGIN = 40M + 08K, LENGTH = 4K
	RODATA	(r)  : ORIGIN = 40M + 12K, LENGTH = 4K
}

/* Sections */

SECTIONS {
	. = 40M;

	.text : {
		*(.text)
		*(.code)

		*(_CODE)
		*(_TEXT)
	} > TEXT

	.data : {
		*(.data)
		*(_DATA)
	} > DATA

	.bss (NOLOAD) : {
		*(.bss)
		*(_BSS)
	} > BSS

	.rodata : {
		*(.rodata)
		*(_RODATA)
	} > RODATA
}