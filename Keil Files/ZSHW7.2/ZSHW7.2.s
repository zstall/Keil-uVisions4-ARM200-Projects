;******************************************************
; CS 2400 Homework 7
; By: Zachary Stall
; Version: 2
;
; This program takes a message stored in memory
; and using a 'secret' key, encrypts the message, and 
; decrypts the message. After decyption the program 
; compares the new message to the original.
;
; The subroutine store the registers to a stack, 
; and at the end of the subroutine they are pop'ed 
; back to original state.
;
; The program also implements a jump or branch table. 
; Note: Use for memory map 0x00000000, 0xFFFFFFFF
;******************************************************

		AREA ZSHW72, CODE, READWRITE
	ENTRY

main
	LDR		sp, =TOS			; Top Of Stack
	ADR		r0, jumpTable		
	LDR		r1, =EOS			; End Of Stack
	LDR		r2, =message
	LDR		r3, =scrtKey
	LDR		r4, =encryptMssg
	LDR		r5, =decryptMssg
	
	BL		jumpFunc			; Branch to the jump table
	BL		jumpFunc
	BL		jumpFunc
	BL		jumpFunc

jumpFunc
	LDR		pc, [r0], #4		; load jumpt table address

jumpTable
	DCD		encrypt				; encrypt message
	DCD		decrypt				; decrypt message
	DCD		compare				; compare decrypted with original
	DCD		done				
		
encrypt
	MOV		r12, lr						; store link register to return to main
	PUSH	{r0, r1, r2, r3, r4, r5}	; push registers to preserve their values
	LDR		r0, [r3] 					; load secret key into r0

encryptLoop
	MOV		r3, r2						; move message address to r9
	LDR		r9, [r2]					; move first byte of message to r3
	CMP		r9, #0						; check for terminating zero
	BLNE	permutations
	EORNE	r1, r1, r0					; encrypt
	STRNE	r1, [r4]					; store encrypted byte in mem
	ADDNE	r4, r4, #4					; move to next mem location
	ADDNE	r2, r2, #4					; get next byte to encrypt
	BNE		encryptLoop
	
	POP		{r0, r1, r2, r3, r4, r5}	; restore registers
	MOV		lr, r12						; load link register
	BX		lr
	
decrypt
	MOV		r12, lr						; store link register
	PUSH	{r0, r1, r2, r3, r4, r5}	; push registers to preserve their values
	LDR		r0, [r3]					; load secret message
	
decryptLoop
	MOV		r3, r4						; load address of secret message
	LDR		r9, [r4]					; load first byte of secret message
	CMP		r9, #0						; look for terminating zero
	EORNE	r9, r9, r0					; decrypt with key
	STRNE	r9, [r4]					; store permutated message
	BLNE	permutations				; restore original message
	STRNE	r1, [r5]					; store decrypted message
	ADDNE	r5, r5, #4					; move to next mem location
	ADDNE	r4, r4, #4					; move to next mem location
	BNE		decryptLoop					; loop
	
	POP		{r0, r1, r2, r3, r4, r5}	; restore register
	MOV		lr, r12						; restore link register
	BX		lr
	
permutations
	LDRB	r5, [r3]					; store first byte
	LDRB	r6, [r3, #1]				; store second byte
	LDRB	r7, [r3, #2]				; store third byte
	LDRB	r8, [r3, #3]				; store fourth byte
	LSL		r1, r5, #8					; permutate bytes
	ADD		r1, r1, r6
	LSL		r1, r1, #8
	ADD		r1, r1, r7
	LSL		r1, r1, #8
	ADD		r1, r1, r8
	BX		lr
	
compare
	PUSH	{r0, r1, r2, r3, r4, r5}	; store registers on stack
	MOV		r12, lr						; store link register
	
compareLoop
	LDR		r0, [r2]					; load first byte of original message
	LDR		r1, [r5]					; load first byte of decrypted message
	CMP		r0, r1						; compare the two
	ADDEQ	r2, r2, #4					; if equal, move to next byte
	ADDEQ	r5, r5, #5					; 	"	"	"	"	"	"
	CMP		r0, #0						; check for terminating zero
	BNE		compareLoop					; loop until complete
	
	POP		{r0, r1, r2, r3, r4, r5}	; restore registers
	MOV		lr, r12						; restore link register
	BX		lr							; link back

done
	SWI		&11
	
EOS			% 32*4		; reserve memory for stack (End Of Stack)
TOS			% 1*4		; reserve memory for Top Of Stack
message		DCB		"Nice Try",0,0,0,0	; message with #0 for termination
pad			% 2*4
scrtKey		DCB		"FACE"
encryptMssg	% 8*4
decryptMssg	% 8*4

	END