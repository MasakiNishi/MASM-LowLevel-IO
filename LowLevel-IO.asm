TITLE String Primitives and Macros Parameters     (LowLevel-IO.asm)

; Author:					Masaki Nishi
; Description:				This program gathers 10 valid decimal integers from the user.
;							It converts these integers into their corresponding numeric values and stores them in an array.
;							Finally, it displays the list of integers, their sum, and the average value after the conversion.

INCLUDE Irvine32.inc

; CONSTANTS
ARRAY_SIZE   = 10		; maximum number for the user input unsigned integers
MAX_SIZE     = 50		; maximum length for the user input string

LO_ASCII	 = 48		; 0 in ASCII
HI_ASCII	 = 57		; 9 in ASCII

; ---------------------------------------------------------------------------------------
; Name: mGetString
;
; Prompts the user to enter a signed integer, then store user's entered integer into a memory.
;
; Precondition: none.
;
; Postcondition: none.
;
; Receives: 
; mPromptMsg  = address of the prompt message 
; mStringAddress = input address for the string
; mStringLength = length of the input string
;
; Returns:
; mStringLength = length of the input string
; ---------------------------------------------------------------------------------------
mGetString MACRO mPromptMsg, mStringAddress, mStringLength
	PUSHAD 

	MOV		EDX, mPromptMsg
	CALL	WriteString

	MOV		EDX, mStringAddress		; set address of string to EDX to store
	MOV		ECX, MAX_SIZE			; set buffer size for ReadString
	CALL	ReadString				; returns: EDX = address of user string, EAX = number of characters entered
	MOV		mStringLength, EAX		; store the length of the string

	POPAD
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Output the string.
;
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
; mString = string address
;			
; Returns: none
; ---------------------------------------------------------------------------------
mDisplayString MACRO mString
    PUSH    EDX

    ; display string
    MOV     EDX, mString
    CALL    WriteString

    POP     EDX
ENDM

.data

; statements
    titleMsg			BYTE    "Designing low-level I/O procedures!", 13,10,0
    authorMsg			BYTE	"Written by: Masaki Nishi", 13,10,0
    instructionMsg		BYTE	"Please provide 10 signed decimal integers.", 0Ah
					    BYTE	"Each number needs to be small enough to fit inside a 32 bit register." , 0Ah
					    BYTE    "After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 13,10,0

    promptMsg           BYTE    ". Please enter an signed number: ", 0
    errorMsg            BYTE    "ERROR: You did not enter an signed number or your number was too big.", 13,10,0

    displayNumMsg       BYTE    10, "You entered the following numbers:", 10, 0
	space				BYTE	", ", 0

	sumMsg				BYTE	10, "The sum of these numbers is: ", 0
	averageMsg			BYTE	10, "The truncated average is: ", 0

	closingMsg			BYTE	10, "Thanks for playing! ", 0

; variables
	numberArray			SDWORD	ARRAY_SIZE	DUP (?)	; an array of 10 valid integers from the user
	stringArray			BYTE	MAX_SIZE	DUP (?)	; convereted user's entered strings to output
	userInputValue		BYTE	MAX_SIZE	DUP (?)	; user's entered strings

	inputCharLength		DWORD	?					; length of the user's entered strings
	convertedInput		SDWORD	?

	isNegative			DWORD	0
	currentTotal		DWORD	0
	lineCount			DWORD	1	

	sum					SDWORD	0
	average				SDWORD	0

.code

main PROC
	; call introduction
	PUSH	OFFSET instructionMsg
	PUSH	OFFSET authorMsg
	PUSH	OFFSET titleMsg
	CALL	introduction

;------------------------------------------------------------
; propts the user to enter the numeric values,
;	and converts the values to the signed integers.
;------------------------------------------------------------
	; set up an array
	MOV		ECX, ARRAY_SIZE
	MOV		EDI, OFFSET numberArray 

	_getUserValue:
		; call ReadVal
		PUSH	ARRAY_SIZE
		PUSH	inputCharLength
		PUSH	OFFSET userInputValue
		PUSH	OFFSET promptMsg
		PUSH	OFFSET errorMsg
		PUSH	OFFSET convertedInput
		PUSH	currentTotal
		PUSH	lineCount
		PUSH	isNegative
		PUSH	OFFSET stringArray
		CALL	ReadVal

		MOV		EAX, DWORD PTR convertedInput
		MOV		[EDI], EAX						; store convertedInput value into the numberArray
		INC		lineCount
		ADD		EBX, EAX

		ADD		EDI, 4							; point to next element
		LOOP	_getUserValue

;------------------------------------------------------------
; outputs the list of the user's entered signed integers.
;------------------------------------------------------------
	; set up an array
	MOV		ECX, ARRAY_SIZE	
	MOV		ESI, OFFSET numberArray

	mDisplayString OFFSET displayNumMsg

	_outputUserValue:
		; call WriteVal
		PUSH	ARRAY_SIZE
		PUSH	[ESI]
		PUSH	OFFSET stringArray
		CALL	WriteVal

		CMP		ECX, 1				; quit if end of loop
		JE		_computeSum

		mDisplayString	OFFSET space		

		ADD		ESI, 4				; point to next element
		LOOP	_outputUserValue

;------------------------------------------------------------
; compute the sum and average of the user's entered signed integers.
;------------------------------------------------------------
	_computeSum:
		; set up an array
		MOV		ECX, ARRAY_SIZE
		MOV		ESI, OFFSET numberArray

		MOV		EAX, 0				; initialize the sum

		_computeLoop:
			; calculate the sum
			ADD		EAX, [ESI]		; add current element
			ADD		ESI, 4			; go to next element
			LOOP	_computeLoop
			MOV		sum, EAX			

		; calculate the average
		MOV		EAX, sum
		CDQ							; clear EDX before IDIV
		MOV		EBX, ARRAY_SIZE
		IDIV	EBX						
		MOV		average, EAX

;------------------------------------------------------------
; output the sum and the average
;------------------------------------------------------------	
	; output the sum
	mDisplayString OFFSET sumMsg
	PUSH	ARRAY_SIZE
	PUSH	sum
	PUSH	OFFSET stringArray
	CALL	WriteVal

	; output the average
	mDisplayString OFFSET averageMsg
	PUSH	ARRAY_SIZE
	PUSH	average
	PUSH	OFFSET stringArray
	CALL	WriteVal

	; call goodbye
	PUSH	OFFSET closingMsg
	CALL	goodbye

	; exit to operating system
	Invoke	ExitProcess,0
main ENDP

; ---------------------------------------------------------------------------------------
; Name: introduction
; Output program title, my name, and instructions for user.
;
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
; [EBP+16] = instructionsMsg
; [EBP+12] = authorMsg
; [EBP+8]  = titleMsg
;
; Returns: none
; ---------------------------------------------------------------------------------------
introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	
	mDisplayString  [EBP+8]
	mDisplayString	[EBP+12]
	CALL	CrLf
	mDisplayString	[EBP+16]
	CALL	CrLf

	POP		EBP
	RET		12
introduction ENDP

; ---------------------------------------------------------------------------------------
; Name: ReadVal
;
; Converts the user's entered ASCII digit strings to its signed integer value. 
;
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
; [EBP+44] = ARRAY_SIZE
; [EBP+40] = inputCharLength
; [EBP+36] = userInputValue
; [EBP+32] = promptMsg
; [EBP+28] = errorMsg
; [EBP+24] = convertedInput
; [EBP+20] = currentTotal
; [EBP+16] = lineCount
; [EBP+12] = isNegative
; [EBP+8]  = stringArray
;
; Returns: convertedInput
; ---------------------------------------------------------------------------------------
ReadVal PROC
	; set up stack frame
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

_promptUser:
	; output the line number
	PUSH	[EBP+44]
	PUSH	[EBP+16]
	PUSH	[EBP+8]
	CALL	WriteVal

	; get value from the user
	mGetString	[EBP+32], [EBP+36], [EBP+40]	; mPromptMsg, mStringAddress, mStringLength
	MOV		ECX, [EBP+40]						; store length of the input string 
	MOV		ESI, [EBP+36]						; store strings

	; setup for String Primitives
	MOV		EDI, [EBP+24]		
	CLD											

_signCheck:
	LODSB						; MOV AL, [ESI]

	MOV		EBX, [EBP+40]		; inputCharLength

	; if "+ / -"
	CMP		EBX, ECX
	JNE		_convertToInt

	; if negative
	CMP		AL, 45				
	JE		_isNegative

	; if positive
	CMP		AL, 43				
	JE		_goNext

	JMP		_convertToInt

	_isNegative:
		MOV		AL, 1
		MOV		[EBP+12], AL	; set negative flag
		JMP		_goNext

	_convertToInt:
		; validate the input character. 48 to 57 is valid integer in ASCII
		CMP		AL, LO_ASCII
		JL		_promptUserAgain 

		CMP		AL, HI_ASCII
		JG		_promptUserAgain

		; subtract 48, then add it to 10-times the current total to convert to the integer
		SUB		AL, LO_ASCII
		MOVSX	EAX, AL				; move with sign of signed integer
		PUSH	EAX

		MOV		EAX, [EBP+20]
		MOV		EBX, 10
		MUL		EBX					; current value * 10
		POP		EBX
		JO		_promptUserAgain	; overflow validation

		ADD		EAX, EBX
		MOV		[EBP+20], EAX		; store to currentTotal

	_goNext:
		LOOP	_signCheck 

		MOV		EBX, [EBP+12]
		CMP		EBX, 1
		JNE		_validated
		NEG		EAX				; multiplying by -1

	_validated:
		MOV		[EDI], EAX		; store the validated value
		JMP		_quit

	_promptUserAgain:
		; output the error message and reprompt user to enter valid value
		mDisplayString	[EBP+28]
		MOV		EBX, 0

		MOV		[EBP+12], EBX	; reset isNegative
		MOV		[EBP+20], EBX	; reset currentTotal
		JMP		_promptUser

_quit:
	POPAD
	POP		EBP
	RET		40
ReadVal	ENDP

; ---------------------------------------------------------------------------------------
; Name: WriteVal
;
; Converts a signed integer value to ASCII digit string, then outputs the string.
;
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
; [EBP+16] = ARRAY_SIZE
; [EBP+12] = signed integer (will be converted to ASCII)
; [EBP+8] = stringArray
;
; Returns: none.
; ---------------------------------------------------------------------------------------
WriteVal PROC
	; set up stack frame
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD						

	; setup stringArray and signed integer to be converted
	MOV		EDI, [EBP+8]
	MOV		ESI, [EBP+12]
	MOV		EAX, ESI
	
	MOV		ECX, 0			; initialize counter

	; if positive
	CMP		EAX, 0
	JGE		_convertToStr

	; if negative
	NEG		EAX				; multiplying by -1
	PUSH	EAX
	MOV		AL, 45			; add the - sign to the value
	STOSB					; MOV [EDI], AL
	POP		EAX

	_convertToStr:
		; divide by 10, then add 48 to the reminder to convert to the string
		MOV		EBX, 10
		MOV		EDX, 0
		CDQ						; clear EDX before IDIV
		IDIV	EBX				; EAX / 10
		INC		ECX				; increment counter

		ADD		EDX, LO_ASCII
		PUSH	EDX				; store converted ASCII (remainder + 48)

		CMP		EAX, 0
		JZ		_alignStr		; quit if quotient is 0
		JNZ		_convertToStr	; continue if quotien is not 0

	_alignStr:
		POP		EAX
		STOSB
		LOOP	_alignStr 

		MOV		EAX, 0			; reset the string
		STOSB

	; output the strings
	mDisplayString [EBP+8]

	POPAD
	POP		EBP
	RET		12
WriteVal ENDP

; ---------------------------------------------------------------------------------
; Name: goodbye
;
; Display a closing message.
;
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
; [EBP+8] = closingMsg
;
; Returns: nothing.
; ---------------------------------------------------------------------------------
goodbye PROC
	PUSH	EBP
	MOV		EBP, ESP

	CALL	CrLf
	mDisplayString [EBP+8]

	POP		EBP
	RET		4
goodbye ENDP

END main
