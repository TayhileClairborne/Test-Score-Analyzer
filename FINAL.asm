
.ORIG x3000

; ------------- Data -------------
PROMPT_MSG  .STRINGZ "Enter five test scores (0-100): "
RESULT_MSG  .STRINGZ "\nResults:\n"
MIN_MSG     .STRINGZ "Minimum Score: "
MAX_MSG     .STRINGZ "Maximum Score: "
AVG_MSG     .STRINGZ "Average Score: "
GRADE_MSG   .STRINGZ "Letter Grade: "
LETTER_A    .STRINGZ "A"
LETTER_B    .STRINGZ "B"
LETTER_C    .STRINGZ "C"
LETTER_D    .STRINGZ "D"
LETTER_F    .STRINGZ "F"

SCORE_COUNT .FILL #5
MAX_INIT    .FILL #0
MIN_INIT    .FILL #100
SUM_SCORE   .FILL #0
AVG_SCORE   .FILL #0
MIN_SCORE   .FILL #0
MAX_SCORE   .FILL #0

STACK_BASE  .FILL x4000
SCORES      .BLKW 5
STR_BUF     .BLKW 4

ASCII_48    .FILL #48
THRESH_90   .FILL #90
THRESH_80   .FILL #80
THRESH_70   .FILL #70
THRESH_60   .FILL #60

; Initialize stack pointer
        LEA R6, STACK_BASE

        LEA R0, PROMPT_MSG
        PUTS

        LD R1, SCORE_COUNT      ; Load number of scores (5)
        LD R2, MAX_INIT         ; Max = 0
        ST R2, MAX_SCORE
        LD R3, MIN_INIT         ; Min = 100
        ST R3, MIN_SCORE
        AND R4, R4, #0          ; Sum = 0
        ST R4, SUM_SCORE

        LEA R7, SCORES          ; R7 points to scores array

INPUT_LOOP
        JSR READ_INPUT
        STR R0, R7, #0          ; Store score in SCORES array
        ADD R7, R7, #1
        JSR PROCESS_SCORE
        ADD R1, R1, #-1
        BRp INPUT_LOOP

        JSR COMPUTE_AVERAGE

        LEA R0, RESULT_MSG
        PUTS

        JSR DISPLAY_MIN
        JSR DISPLAY_MAX
        JSR DISPLAY_AVG

        LEA R0, GRADE_MSG
        PUTS
        JSR DISPLAY_GRADE

        HALT

; ---------------- Subroutines ----------------

; READ_INPUT - reads a number up to 2 digits, converts ASCII to int in R0
READ_INPUT
        ; Read first digit
        GETC
        OUT
        LD R1, ASCII_48
        NOT R1, R1
        ADD R1, R1, #1          ; R1 = -48
        ADD R0, R0, R1          ; R0 = first digit - 48
        ADD R2, R0, #0          ; Save first digit in R2

        ; Read second digit
        GETC
        OUT
        ADD R3, R0, #0          ; Save second char in R3 temporarily
        LD R1, ASCII_48
        NOT R1, R1
        ADD R1, R1, #1          ; R1 = -48
        ADD R0, R3, R1          ; Convert second char to digit (second - 48)
        BRn SINGLE_DIGIT        ; If not a digit, fallback to single digit

        ; Multiply first digit by 10 (digit * (8 + 2))
        ADD R3, R2, R2          ; *2
        ADD R4, R3, R3          ; *4
        ADD R4, R4, R4          ; *8
        ADD R3, R4, R3          ; *10 = 8 + 2

        ADD R0, R3, R0          ; total = 10 * first_digit + second_digit
        BRnzp DONE_READ

SINGLE_DIGIT
        ADD R0, R2, #0          ; Use only first digit

DONE_READ
        RET

; PROCESS_SCORE - update min, max, sum
PROCESS_SCORE
        ADD R6, R6, #-1
        STR R1, R6, #0
        ADD R6, R6, #-1
        STR R2, R6, #0
        ADD R6, R6, #-1
        STR R3, R6, #0

        LD R1, MAX_SCORE
        LD R2, MIN_SCORE

        NOT R3, R0
        ADD R3, R3, #1
        ADD R3, R1, R3
        BRn UPDATE_MAX
        BR SKIP_MAX

UPDATE_MAX
        ST R0, MAX_SCORE

SKIP_MAX
        NOT R3, R2
        ADD R3, R3, #1
        ADD R3, R0, R3
        BRn SKIP_MIN
        ST R0, MIN_SCORE

SKIP_MIN
        LD R4, SUM_SCORE
        ADD R4, R4, R0
        ST R4, SUM_SCORE

        LDR R3, R6, #0
        ADD R6, R6, #1
        LDR R2, R6, #0
        ADD R6, R6, #1
        LDR R1, R6, #0
        ADD R6, R6, #1

        RET

; COMPUTE_AVERAGE - sum / count (integer division)
COMPUTE_AVERAGE
        LD R4, SUM_SCORE
        LD R1, SCORE_COUNT
        AND R0, R0, #0

DIV_LOOP
        NOT R2, R1
        ADD R2, R2, #1
        ADD R3, R4, R2
        BRn DIV_DONE
        ADD R0, R0, #1
        ADD R4, R4, R2
        BRnzp DIV_LOOP

DIV_DONE
        ST R0, AVG_SCORE
        RET

; DISPLAY_MIN
DISPLAY_MIN
        LEA R0, MIN_MSG
        PUTS
        LD R0, MIN_SCORE
        JSR INT_TO_ASCII
        PUTS
        RET

; DISPLAY_MAX
DISPLAY_MAX
        LEA R0, MAX_MSG
        PUTS
        LD R0, MAX_SCORE
        JSR INT_TO_ASCII
        PUTS
        RET

; DISPLAY_AVG
DISPLAY_AVG
        LEA R0, AVG_MSG
        PUTS
        LD R0, AVG_SCORE
        JSR INT_TO_ASCII
        PUTS
        RET

; DISPLAY_GRADE
DISPLAY_GRADE
        LD R0, AVG_SCORE
        LD R1, THRESH_90
        LD R2, THRESH_80
        LD R3, THRESH_70
        LD R4, THRESH_60

        NOT R5, R1
        ADD R5, R0, R5
        BRzp GRADE_A

        NOT R5, R2
        ADD R5, R0, R5
        BRzp GRADE_B

        NOT R5, R3
        ADD R5, R0, R5
        BRzp GRADE_C

        NOT R5, R4
        ADD R5, R0, R5
        BRzp GRADE_D

GRADE_F
        LEA R0, LETTER_F
        PUTS
        RET

GRADE_D
        LEA R0, LETTER_D
        PUTS
        RET

GRADE_C
        LEA R0, LETTER_C
        PUTS
        RET

GRADE_B
        LEA R0, LETTER_B
        PUTS
        RET

GRADE_A
        LEA R0, LETTER_A
        PUTS
        RET

; INT_TO_ASCII - convert number 0-99 in R0 to ASCII string in STR_BUF
INT_TO_ASCII
        ADD R6, R6, #-3
        STR R1, R6, #0
        STR R2, R6, #1
        STR R3, R6, #2

        LEA R1, STR_BUF
        AND R2, R0, #0
        ADD R3, R0, #0

LOOP_TENS
        ADD R3, R3, #-10
        BRn DONE_TENS
        ADD R2, R2, #1
        BRnzp LOOP_TENS
DONE_TENS
        ADD R3, R3, #10

        LD R4, ASCII_48
        ADD R2, R2, R4
        STR R2, R1, #0
        ADD R1, R1, #1

        ADD R3, R3, R4
        STR R3, R1, #0
        ADD R1, R1, #1

        AND R2, R2, #0
        STR R2, R1, #0

        LEA R0, STR_BUF

        LDR R1, R6, #0
        LDR R2, R6, #1
        LDR R3, R6, #2
        ADD R6, R6, #3

        RET

.END
