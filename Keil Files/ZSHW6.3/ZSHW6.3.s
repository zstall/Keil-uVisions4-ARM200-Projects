;********************************************************
; CS 2400 Homework 6
; By: Zachary Stall
; Version: 3
;
; This program generates 11 random numbers using the RANDOM.s file
; from Dr. Georgiev at MSU Denver. The random numbers are stored in
; a location who's address is stored in 'numbers'. It then bubble sorts 
; the random numbers. Once sorted, the program counts how many ones
; each random number has, and stores this information at a destination
; stored in 'ones'.
;
;Note: Use for memory map: 0x00000000, 0xFFFFFFFF
;********************************************************

	AREA	ZSHW6, CODE, READWRITE
	EXPORT	zshw6
	IMPORT	randomnumber
		
	ENTRY

zshw6
	; randomnumber uses registers 0-2
	
	LDR		r3, =numbers
	LDR		r6, =ones 			; Move address of r6 to store number of ones
	MOV		r10, #0				; Reserve r10 for counter	
	BL		getRandomNum		; Branch to get random numbers
	MOV		r10, #0
	MOV		r7, r3				; Store address of numbers to a second register
	BL		bubSort
	MOV		r10, #0				; Reset counter
	BL		loader				; Load the numbers, count how many ones,
	BAL		done				; store the number of ones in mem

getRandomNum
	CMP		r10, #0				; Check if first iteration of getRandomNum
	MOVEQ	r11, lr				; Store link register
	BL		randomnumber		; branch to randomnumber
	STR		r0, [r3]			; Store random number at address in r3
	ADD		r10, r10, #1		; Increment
	CMP		r10, #11			; Check for completion of iteration
	MOVEQ	lr, r11				; Load link register back to zswh6 if done
	BXEQ	lr
	ADD		r3, r3, #4			; If not done, move to next mem location
	BAL		getRandomNum		; Iterate

bubSort
	MOV		r8, r7 				; Get address in second register (r7 first operand address)
	SUB		r8, r8, #4			; Moving to next operand address (r8 second operand address)
	LDR		r0, [r7]			; Load first operand 
	LDR		r1, [r8]			; Load second operand
	CMP		r0, r1				; Compare for sorting
	STRGT	r0, [r8]			; If first operand is greater than second, switch location/sort
	STRGT	r1, [r7]			;   		"						"
	ADD		r10, r10, #1		; Increment counter to end loop
	MOV		r7, r8				; Load next memory address as first operand
	CMP		r10, #10			; Check if sorting is done
	BXEQ	lr					; If done branch back to main program
	BAL		bubSort				; If not, loop back to continue sortin
	
	
loader
	CMP		r10, #0				; First iteration store link register
	MOVEQ	r11, lr
	CMP		r10, #11			; Check for end of iteration, branch back if end
	MOVEQ	lr, r11
	BXEQ	lr
	
	MOV		r9, #0				; Reset counter each iteration
	
	LDR		r4, [r3]			; Load num to count ones
	BL		findOnes			; Branch to sub to count ones
	STR		r9, [r6]			; store number of ones at address of r6
	SUB		r3, r3, #4			; Move to next numbers address
	ADD		r6, r6, #4			; Move to next address for storing
	ADD		r10, r10, #1		; Increment
	BAL		loader				; Iterate

findOnes
	CMP		r4, #0				; Check for completion
	BXEQ	lr
	SUB		r5, r4, #1			; Count "1" off by subtracting it
	AND		r4, r4, r5			; Remove the one from the orginal number
	ADD		r9, r9, #1			; Add one to counter
	BAL		findOnes			; Iterate

numbers % 11*4
ones	% 11*4
done
	SWI		&11

	END