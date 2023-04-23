######################################################################################################################################
# Created by:  Chen, Zhiqi
#              zchen287
#              27 February 2021
#
# Assignment:  Lab 4
#              CSE 12, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2021
#
# Description: This program open and read the specified file and determines whether it has balanced braces, brackets, and parentheses.
# 
# Notes:       This program is intended to be run from the MARS.
######################################################################################################################################

# Pesudocode #########################################################################################################################
# Print out the file name
#
# TestFileName:
#                     Split the file name into separated characterss
#                     if the file name length exceeds 20: 
#                       invalid
#                     if the first letter not A-Z or a-z: 
#                       invalid
#                     if there exists a character is neither letters, number, period, or underscore: 
#                       invalid
#
# Open file
# Read file: if exceed 128 bytes, read multiple times
# Close file
#
# if empty: 
#   success and exit
#
# TestFileDescriptor:
#                     Split the file descriptor into separated characters
#                     if ( [ {:
#                       push into stack
#                     if ) ] }:
#                       pop out ( [ { if has ( [ { on stack:
#                         if not correspond brace:
#                            Mismatch
#                       push into stack if has no more braces on stack
# check stack: 
#                    if nothing left (everything that has been pulled into is popped out): 
#                         Success
#                    if still ({[ on stack: 
#                         Remain
#                    if )}] remain: 
#                         Mismatch
######################################################################################################################################

.data
enter: .asciiz "You entered the file:\n"
buffer: .space 128
empty: .asciiz "\nSUCCESS: There are 0 pairs of braces.\n"
invalid: .asciiz "\nERROR: Invalid program argument.\n"
mismatch1: .asciiz "\nERROR - There is a brace mismatch: "
mismatch2: .asciiz " at index "
remain: .asciiz "\nERROR - Brace(s) still on stack: "
success1: .asciiz "\nSUCCESS: There are "
success2: .asciiz " pairs of braces.\n"
newline: .asciiz "\n"

.text
li $v0 4
la $a0 enter
syscall                                          #print enter text

li $v0 4
lw $s0 ($a1)                                     #save the address of file name into $s0
la $a0 ($s0)
syscall                                          #print file name

li $v0 4
la $a0 newline
syscall

move $s1 $s0                                     #make a copy of the address of file name

# REGISTER USAGE
# $s1: address of file name
# $t0: separated characters of file name
# $t1: counter for length of file name
# $t2 $t3 $t4: use to check if in the range 65-122
TestFileName1:      nop
                    lb $t0 0($s0)                #split file name into separated characters
                    beqz $t0 OpenFile            #if $t0=0, finish testing, end loop
                    addi $s0 $s0 1
                    addi $t1 $t1 1               #counter for length
                    bgt $t1 20 Invalid           #if exceed 20 character, invalid

                    sge $t2 $t0 65
                    sle $t3 $t0 122
                    and $t4 $t2 $t3

                    li $t2 0
                    li $t3 0

                    beq $t4 1 TestFileName2      #if in the range 65-122, next test
                    beq $t4 0 TestFileName3      #if out of the range 65-122, test if 45(period) or 0-9(numbers)

# REGISTER USAGE
# $t2 $t3 $t5: use to check if in the range
TestFileName2:      nop
                    sle $t2 $t0 90
                    sge $t3 $t0 97
                    or $t5 $t2 $t3

                    li $t2 0
                    li $t3 0

                    beq $t5 1 TestFileName1      #if in the range 65-90(A-Z) or 97-122(a-z), valid, test next character
                    beq $t5 0 TestFileName3      #if out of the range 65-91 and 97-123, but in the range 65-122, test if 95(underscore) or 0-9(numbers)

# REGISTER USAGE
# $t2 $t3 $t6: use to check if in the range
TestFileName3:      nop
                    beq $t1 1 Invalid
                    seq $t2 $t0 46
                    seq $t3 $t0 95
                    or $t6 $t2 $t3

                    li $t2 0
                    li $t3 0

                    beq $t6 1 TestFileName1      #if equal 46(period) or 95(underscore), valid, test next character
                    beq $t6 0 TestFileName4      #if not equal, test if 0-9(numbers)

# REGISTER USAGE
# $t2 $t3 $t7: use to check if in the range
TestFileName4:      nop
                    sge $t2 $t0 48
                    sle $t3 $t0 57
                    and $t7 $t2 $t3

                    li $t2 0
                    li $t3 0

                    beq $t7 1 TestFileName1      #if in the range 0-9(numbers), valid, test next character
                    beq $t7 0 Invalid            #if out of the range 0-9(numbers), invalid


li $t1 0
li $t2 0
li $t3 0
li $t4 0
li $t5 0
li $t6 0
li $t7 0

# REGISTER USAGE
# $s1: address of file name
OpenFile:           nop                          #open file                                                                                        
                    li $v0 13
                    la $a0 ($s1)                 #address of null-terminated string containing file name
                    li $a1 0
                    li $a2 0
                    syscall
                    move $s2 $v0                 #save the file descriptor into $s2

# REGISTER USAGE
# $s2: address of file descriptor
ReadFile:           nop                          #read from file
                    li $v0 14
                    move $a0 $s2                 #file descriptor
                    la $a1 buffer                #address of input buffer
                    li $a2 128                   #maximum number of characters to read
                    syscall
                    li $t3 0
                    move $s7 $v0
                    beq $t3 $s7 Done
                    beqz $s7 CloseFile                    
                    j TestFileDescriptor
                                   
# REGISTER USAGE
# $s2: address of file descriptor           
CloseFile:          nop                          #close the file
                    li $v0 16       
                    move $a0 $s2      
                    syscall

lb $t2 buffer($zero)
beqz $t2 Empty                                   #if empty, go to print out the success message, if not, continue to test the file descriptor

li $t1 0
li $t2 0
li $t3 0
li $t4 0
li $t5 0
li $t6 0
li $t7 0
li $t8 0
li $t9 0

# REGISTER USAGE
# $t2: separated characters of file descriptor
# $t3: counter for index (not include buffer loop)
# $t8: counter for index (include buffer loop)
TestFileDescriptor: nop
                    lb $t2 buffer($t3)           #loading value from buffer 
                    beqz $t2 Done
                    addi $t3 $t3 1
                    addi $t8 $t8 1                    
                    bgt $t3 $s7 Done
                    beq $t2 40 Push              #if (, push into stack
                    beq $t2 91 Push              #if [, push into stack
                    beq $t2 123 Push             #if {, push into stack
                    beq $t2 41 Parentheses       #if ), go to Parentheses
                    beq $t2 93 Brackets          #if ], go to Brackets
                    beq $t2 125 Braces           #if }, go to Braces
                    
                    j TestFileDescriptor

# REGISTER USAGE
# $t9: counter for number of pairs if succeed at the end
Push:               nop
                    subi $sp $sp 4               #move $sp to push the value into stack
                    sw $t2 0($sp)
                    addi $t9 $t9 1               #counter for number of pairs if succeed at the end
                    j TestFileDescriptor

# REGISTER USAGE
# $s3: separated character on stack
# $t4 $t5 $t6: use to recongize if [ or {
Parentheses:        nop
                    lw $s3 0($sp)
                    beq $s3 40 Pop               #if (, go to Pop

                    beq $s3 1 Mismatch           #if no more braces remain on stack, but still ) exists, Mismatch

                    seq $t4 $s3 91
                    seq $t5 $s3 123
                    or $t6 $t4 $t5
                    beq $t6 1 Mismatch           #if [ or {, go to mismatch

                    li $t4 0
                    li $t5 0
                    li $t6 0

                    j TestFileDescriptor

# REGISTER USAGE
# $s4: separated character on stack
# $t4 $t5 $t6: use to recongize if ( or {
Brackets:           nop
                    lw $s4 0($sp)
                    beq $s4 91 Pop               #if [, go to Pop

                    beq $s4 1 Mismatch           #if no more braces remain on stack, but still ] exists, Mismatch

                    seq $t4 $s4 40
                    seq $t5 $s4 123
                    or $t6 $t4 $t5
                    beq $t6 1 Mismatch           #if ( or {, go to mismatch

                    li $t4 0
                    li $t5 0
                    li $t6 0

                    j TestFileDescriptor

# REGISTER USAGE
# $s5: separated character on stack
# $t4 $t5 $t6: use to recongize if ( or [
Braces:             nop
                    lw $s5 0($sp)
                    beq $s5 123 Pop              #if {, go to Pop

                    beq $s5 1 Mismatch               #if no more braces remain on stack, but still } exists, Mismatch

                    seq $t4 $s5 40
                    seq $t5 $s5 91
                    or $t6 $t4 $t5
                    beq $t6 1 Mismatch           #if ( or [, go to mismatch

                    li $t4 0
                    li $t5 0
                    li $t6 0

                    j TestFileDescriptor

Pop:                nop
                    lw $t2 0($sp)
                    addi $sp $sp 4               #move the $sp to pop out the value from stack
                    j TestFileDescriptor

Done:               nop
                    beq $s7 128 ReadFile                    
                    lw $t2 0($sp)
                    beq $t2 40 Remain            #if (, go to Remain
                    beq $t2 91 Remain            #if [, go to Remain
                    beq $t2 123 Remain           #if {, go to Remain
                    beq $t2 41 Mismatch          #if ), go to Mismatch
                    beq $t2 93 Mismatch          #if ], go to Mismatch
                    beq $t2 125 Mismatch         #if }, go to Mismatch
                    beq $t2 1 Success            #if no more braces on stack, go to Success

Empty:              nop
                    li $v0 4
                    la $a0 empty
                    syscall                      #print out the empty text

                    li $v0 10 
                    syscall                      #exit

Invalid:            nop
                    li $v0 4
                    la $a0 invalid
                    syscall                      #print out the invalid text

                    li $v0 10
                    syscall                      #exit

Mismatch:           nop
                    li $v0 4
                    la $a0 mismatch1
                    syscall                      #print out the first part of mismatch text

                    li $v0 11
                    la $a0 ($t2)
                    syscall                      #print out the mismatch brace

                    li $v0 4
                    la $a0 mismatch2
                    syscall                      #print out the second part of mismatch text

                    li $v0 1
                    add $a0 $t8 -1               #Since the counter $t9 starts from 1, add -1 to print out the correct index number
                    syscall

                    li $v0 4
                    la $a0 newline
                    syscall                      #print out newline

                    li $v0 10
                    syscall                      #exit

Remain:             nop
                    li $v0 4
                    la $a0 remain
                    syscall                      #print out the remain text

# REGISTER USAGE
# $s6: separated character on stack
Loop:               nop                          #loop for printint out the braces that are still on stack
                    lw $s6 0($sp)
                    addi $sp $sp 4
                    beq $s6 40 PrintBraces       #if (, print out
                    beq $s6 91 PrintBraces       #if [, print out
                    beq $s6 123 PrintBraces      #if {, print out
                    
                    li $v0 4
                    la $a0 newline
                    syscall                      #print out newline
                    
                    li $v0 10
                    syscall                      #exit

PrintBraces:        nop                          #print out the braces
                    li $v0 11
                    la $a0 ($s6)
                    syscall
                    j Loop

Success:            nop
                    li $v0 4
                    la $a0 success1
                    syscall                      #print out the first part of success text

                    li $v0 1
                    add $a0 $t9 $zero
                    syscall                      #print out the number of succeed pairs

                    li $v0 4
                    la $a0 success2
                    syscall                      #print out the second part of success text

                    li $v0 10
                    syscall                      #exit
