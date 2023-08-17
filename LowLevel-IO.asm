TITLE String Primitives and Macros Parameters

; Author:					Masaki Nishi
; Description:				This program gathers 10 valid decimal integers from the user.
;							It converts these integers into their corresponding numeric values and stores them in an array.
;							Finally, it displays the list of integers, their sum, and the average value after the conversion.

INCLUDE Irvine32.inc

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
; mMaxLength = buffer size for the input string
;
; Returns: 
; mStringAddress = input address for the string
; mStringLength = length of the input string
; ---------------------------------------------------------------------------------------
mGetString MACRO	mPromptMsg, mStringAddress, mStringLength, mMaxLength
	PUSHAD 

	MOV		EDX, mPromptMsg
	CALL	WriteString

	MOV		EDX, mInputAddress		; set address of string to EDX to store
	MOV		ECX, mStringLength		; set buffer size for ReadString
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

; CONSTANTS
ARRAYSIZE   = 10			; maximum number for the user input unsigned integers
MAXSIZE     = 32			; maximum length for the user input string
MAXNUM      = -2147483648

.data

; statements
titleMsg			BYTE		"Designing low-level I/O procedures!", 13,10,0
authorMsg			BYTE		"Written by: Masaki Nishi", 13,10,0
instructionMsg		BYTE		"Please provide 10 signed decimal integers.", 0Ah
					BYTE		"Each number needs to be small enough to fit inside a 32 bit register." , 0Ah
					BYTE		"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 13,10,0

; variables

.code

main PROC
	; Call introduction
	PUSH	OFFSET instructionMsg
	PUSH	OFFSET authorMsg
	PUSH	OFFSET titleMsg
	CALL	introduction

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

END main
