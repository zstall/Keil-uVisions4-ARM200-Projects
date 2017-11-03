;***************************************************************************************
; CS 2400 Homework 5 
; By: Zachary Stall
;
; This program converts numbers from IEEE to TNS
; and TNS to IEEE. The program has four cases, 2 for 
; converting the number 128.0625 from IEEE to TNS and
; TNS to IEEE. 2 for converting the number 2047.75 
;
; note: Use for memory map: 0x00000000, 0xFFFFFFFF
;***************************************************************************************

		
		AREA zstallHW5, 	CODE

	ENTRY
	
main
		MOV		r12, #0					; Clear to count good conversions
				
		; Start with conversions from IEEE -> TNS
		LDR		r1, num1IEEE			; Load 128.0625 in IEEE format
		BL		IEEE2TNS				; Subroutine to convert IEEE to TNS
		LDR		r2, num1TNS				; Load 128.0625 in TNS format
		CMP		r6, r2					; Compare to check conversion
		ADDEQ	r12, r12, #1			; Add one to register if conversion good
		
		LDR		r1, num2IEEE			; Load 2047.75 in IEEE format
		BL		IEEE2TNS				; Subroutine to convert IEEE to TNS
		LDR		r2, num2TNS				; Load 2047.75 in TNS format
		CMP		r6, r2					; Compare to check conversion
		ADDEQ	r12, r12, #1			; Add one to register if conversion good

		; Conversions from TNS -> IEEE
		LDR		r1, num1TNS				; Load 128.0625 in TNS
		BL		TNS2IEEE				; Subroutine to convert TNS to IEEE
		LDR		r2, num1IEEE			; Load 128.0625 in IEEE
		CMP		r6, r2					; Compare to check conversion
		ADDEQ	r12, r12, #1			; Add one to register if conversion good
		
		LDR		r1, num2TNS				; Load 2047.75 in TNS format
		BL		TNS2IEEE				; Subroutine to convert TNS to IEEE
		LDR		r2, num2IEEE			; Load 2047.75 in IEEE
		CMP		r6, r2					; Compare to check conversion
		ADDEQ	r12, r12, #1			; Add one to register if conversion good

		BAL		done					; End program

IEEE2TNS
		LDR		r3, mSign				; Load Sign Mask
		LDR		r4, mExpIEEE			; Load IEEE Exponent Mask
		LDR		r5, mSigIEEE			; Load IEEE Significant Mask address
				
		; Unpack the IEEE number
		AND		r3, r1, r3				; Unpack the sign bit
		AND		r4, r1, r4				; Unpack the Exponent
		AND		r5, r1, r5				; Unpack the significant
				
		; Convert unpacked numbers from IEEE to TNS
		LSR		r4, r4, #23				; Shift Exp to TNS location
		SUB		r4, r4, #127			; Convert from excess 127
		ADD		r4, r4, #256			; Convert to excess 256
				
		LSR		r5, r5, #1				; Shift out 23 bit (loss of bit from IEEE to TNS)
		LSL		r5, r5, #9				; Shift significant to new location for TNS
				
		; Pack converted TNS number
		ORR		r6, r3, r4				; pack sign and exponent
		ORR		r6, r6, r5				; pack significant
		BX		lr
				
TNS2IEEE
		LDR		r3,	mSign				; Load Sign Mask
		LDR		r4, mExpTNS				; Load TNS Exponent Mask
		LDR		r5, mSigTNS				; Load TNS Significant Mask
		
		; Unpack the TNS number
		AND		r3, r1, r3				; Unpack the Sign bit
		AND		r4, r1, r4				; Unpack the Exponent
		AND		r5, r1, r5				; Unpack the Significant
		
		; Convert unpacked numbers from TNS to IEEE
		SUB		r4, r4, #256			; Convert from excess 256 to decimal
		CMP		r4, #255				; Check that Exp is in IEEE range
		BXGE	lr						; If not, link back to main
		ADD		r4, r4, #127			; Convert to excess 127
		LSL		r4, r4, #23				; Move TNS exponent into IEEE place
		
		LSR		r5, r5, #8				; Move TNS significant to IEEE location

		; Pack converted TNS number
		ORR		r6, r3, r4				; pack sign and exponent
		ORR		r6, r6, r5				; pack significant
		BX		lr
		
num1IEEE		DCD		&43001000		; 128.0625 in IEEE hex
num1TNS			DCD		&00100107		; 128.0625 in TNS hex

num2IEEE		DCD		&44FFF800		; 2047.75 in IEEE hex
num2TNS			DCD		&7FF8010A		; 2047.75 in TNS hex
	
mSign			DCD		&80000000	 	; Sign mask for TNS and IEEE
mExpIEEE		DCD		&7F800000		; Exponent Mask for IEEE
mSigIEEE		DCD		&007FFFFF		; Significant Mask for IEEE
mExpTNS			DCD		&000001FF		; Exponent Mask for TNS
mSigTNS			DCD		&7FFFFE00		; Significant Mask for TNS
	
done			SWI		&11				; End program
		
		
		END