TITLE String Primitives and Macros Parameters

; Author:					Masaki Nishi
; Description:				This program gathers 10 valid decimal integers from the user.
;							It converts these integers into their corresponding numeric values and stores them in an array.
;							Finally, it displays the list of integers, their sum, and the average value after the conversion.

INCLUDE Irvine32.inc

; CONSTANTS
ARRAY_SIZE   = 10			; maximum number for the user input unsigned integers
MAX_SIZE     = 32			; maximum length for the user input string
MAX_NUM      = -2147483648

; ---------------------------------------------------------------------------------------
; Name: mGetString
;
; Prompts the user to enter a signed integer, then store user inputted integer into a memory location.
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
; mStringAddress = input address for the string
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

    promptMsg           BYTE    "	Please enter an signed number: ", 0
    errorMsg            BYTE    "	ERROR: You did not enter an signed number or your number was too big.", 13,10,0

    displayNumMsg       BYTE    10, "You entered the following numbers:", 10, 0

; variables
	numberArray			SDWORD	ARRAY_SIZE DUP (?)	; an array of 10 valid integers from the user
	arrayString			BYTE	MAX_NUM DUP (?)		; convereted user's entered strings to output
	userInputValue		BYTE	MAX_NUM DUP (?)		; user's entered strings

	inputCharLength		DWORD	?					; length of the user's entered strings
	convertedInput		SDWORD	?

	isNegative			DWORD	0
	currentTotal		DWORD	0
	lineCount			DWORD	1	

.code

main PROC
	; call introduction
	PUSH	OFFSET instructionMsg
	PUSH	OFFSET authorMsg
	PUSH	OFFSET titleMsg
	CALL	introduction

	; set up an array
	MOV		ECX, ARRAY_SIZE
	MOV		EDI, OFFSET numberArray 

	; call ReadVal
_validateInput:
	PUSH	ARRAY_SIZE
	PUSH	inputCharLength
	PUSH	OFFSET userInputValue
	PUSH	OFFSET promptMsg
	PUSH	OFFSET errorMsg
	PUSH	OFFSET convertedInput
	PUSH	currentTotal
	PUSH	lineCount
	PUSH	isNegative
	PUSH	OFFSET arrayString
	CALL	ReadVal

	MOV		EAX, DWORD PTR convertedInput
	MOV		[EDI], EAX						; store convertedInput value into the numberArray
	INC		lineCount
	ADD		EBX, EAX

	ADD		EDI, 4							; point to next element
	LOOP	_validateInput

	; set up an array
	MOV		ECX, ARRAY_SIZE	
	MOV		ESI, OFFSET numberArray

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
; [EBP+8]  = arrayString
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
	LODSB						; [ESI] to AL

	MOV		EBX, [EBP+40]		; inputCharLength
	CMP		EBX, ECX			; if "+ / -"
	JNE		_convertToInteger

	; if negative
	CMP		AL, 45				
	JE		_isNegative

	; if positive
	CMP		AL, 43				
	JE		_goNext

	JMP		_convertToInteger

	_isNegative:
		MOV		AL, 1
		MOV		[EBP+12], AL	; set negative flag
		JMP		_goNext

	_convertToInteger:
		; validate the input character. 48 to 57 is valid integer in ASCII
		CMP		AL, 48
		JL		_promptUserAgain 

		CMP		AL, 57
		JG		_promptUserAgain

		; subtract 48, then add it to 10-times the current total to convert to the integer
		SUB		AL, 48
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

END main
