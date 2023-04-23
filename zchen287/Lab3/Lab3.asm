######################################################################################################################
# Created by:  Chen, Zhiqi
#              zchen287
#              9 February 2021
#
# Assignment:  Lab 3
#              CSE 12, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2021
#
# Description: This program prints the specific pattern using numbers and stars with a tab between each of them.
# 
# Notes:       This program is intended to be run from the MARS.
######################################################################################################################

# Pesudocode #########################################################################################################
# set counter for row to 0
# set counter for column to 0
#
# EnterValue:
#                     print text and ask the user to enter a value
#                     if the enter value less than 0:
#                       Invalid and enter again
#
# A big loop for printing star, tab, and number for each line: 
#
#   Loop for StarTab:
#                     counter for row increment
#                     if counter for row greater than or equal to counter for column:
#                       print out number (go to number)
#                     print star
#                     print tab
#
#   Number:
#                     print out the value of counter for column
#
#   set counter for row to 0
#   Loop for TabStar: 
#                     counter for row increment
#                     if counter for row greater than or equal to counter for column:
#                       new line or finish running (go to End)
#                     print tab
#                     print star
#
#   Loop for End:
#                     counter for column increment 
#                     print next line
#                     set counter for row to 0
#                     if value of counter for column less than or equal to the enter value:
#                       big loop again
######################################################################################################################

# REGISTER USAGE
# $t0: user input
# $t1: loop counter (row)
# $t2: loop counter (column)

.data
text: .asciiz "Enter the height of the pattern (must be greater than 0):"
warning: .asciiz "Invalid Entry!\n"

.text
li $t1 0                                           # initialize $t1
li $t2 1                                           # initialize $t2

EnterValue: nop                                    # ask the user to enter a valid value
            li $v0 4                               # prep to print text
            la $a0 text
            syscall

            li $v0 11                              # prep to print character (tab)
            li $a0 9
            syscall

            li $v0 5                               # prep to enter value
            syscall
            move $t0 $v0                           # move (store) the enter value into t0
            ble $v0 0 Invalid                      # if the enter value is less than or equal to 0:

Invalid:    nop                                    # print out warning if the enter value is invalid
            bgt $v0 0 StarTab                      # go to StarTab if the enter value is greater than 0
            li $v0 4                               # prep to print warning
            la $a0 warning
            syscall
         
            j EnterValue                           # jump to EnterValue to re-enter the value

StarTab:    nop                                    # print out the first part of star and tab before printing number
            addi $t1 $t1 1                         # increment $t1
            bge $t1 $t2 Number                     # go to print out the number if done

            li $v0 11                              # prep to print character (*)
            li $a0 42
            syscall

            li $v0 11                              # prep to print character (tab)
            li $a0 9
            syscall

            j StarTab
         
Number:     nop                                    # print the number
            move $a0 $t2                           # moving $t2 into $a0 to print
            li $v0 1                               # prep to print out integer
            syscall
                                           
li $t1 0                                           # initialize $t1
TabStar:    nop                                    # print out the second part of tab and star after printing number
            addi $t1 $t1 1                         # increment $t1
            bge $t1 $t2 End                        # go to next line or end the loop if done

            li $v0 11                              # prep to print character (tab)
            li $a0 9
            syscall

            li $v0 11                              # prep to print character (*)
            li $a0 42
            syscall        

            j TabStar

End:        nop                                    # end the loop, go to next line, or finish running
            addi $t2 $t2 1                         # increment $t2
            li $v0 11                              # prep to print character (next line)
            li $a0 10
            syscall
            
            li $t1 0                               # initialize $t1
            ble $t2 $t0 StarTab                    # if the counter less then the enter value, loop again
li $v0 10
syscall
