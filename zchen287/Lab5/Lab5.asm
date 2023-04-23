########################################################################################################################
# Created by:  Chen, Zhiqi
#              zchen287
#              12 March 2021
#
# Assignment:  Lab 5
#              CSE 12, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2021
#
# Description: This program perform some primitive graphics operations on a small simulated display.
# 
# Notes:       This program is intended to be run from the MARS.
########################################################################################################################
# Pesudocode #########################################################################################################################
# clear_bitmap:          use draw_pixel to fill the color into every pixel, 
#                        by looping from the first pixel (0xffff0000) till the last (0xfffffffc).
# draw_pixel:            store the color into correct address.
# get_pixel:             load the color from correct address.
# draw_horizontal_line:  make a loop of x-coordinate incrementing from 0 to 127,
#                        get the coordinate and then draw for each pixel in the line.
# draw_vertical_line:    make a loop of y-coordinate incrementing from 0 to 127,
#                        get the coordinate and then draw for each pixel in the line.
# draw_crosshair:        save the original color at intersection,
#                        draw horizontal line,
#                        draw horizontal line,
#                        draw the original color back at intersestion point.
########################################################################################################################

# Winter 2021 CSE12 Lab5 Template
######################################################
# Macros for instructor use (you shouldn't need these)
######################################################

# Macro that stores the value in %reg on the stack 
#	and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#	loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
.macro getCoordinates(%input %x %y)
	# YOUR CODE HERE
	move %x %input
	srl %x %x 16                                    #shift right for 16 bytes
	and %x %x 0x0000ffff                            #only keep the last four digits
	and %y %input 0x0000ffff                        #only keep the last four digits
	
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	# YOUR CODE HERE
	sll %output %x 16                               #shift %x left for 16 bytes and save it in %output
	or %output %output %y                           #combined the value of x and y in specific format and save it in %output
.end_macro 

# Macro that converts pixel coordinate to address
# 	output = origin + 4 * (x + 128 * y)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%origin: register containing address of (0, 0)
#	%output: register to store memory address in
.macro getPixelAddress(%output %x %y %origin)
	# YOUR CODE HERE
	mul %output %y 128                              #128*y
	add %output %output %x                          #x+128*y
	mul %output %output 4                           #4*(x+128*y)
	add %output %output %origin                     #origin+4*(x+128*y)
.end_macro


.data
originAddress: .word 0xFFFF0000

.text
# prevent this file from being run as main
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB)
# Outputs:
#	No register outputs
#*****************************************************

# REGISTER USAGE
# $t0: the address of each pixel (start from the first one)
# $t1: the address of the last pixel
clear_bitmap: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	
	li $t0 0xffff0000                               #the first pixel
	li $t1 0xfffffffc                               #the last pixel
	
	Square:	nop
	sw $a0 ($t0)                                    #fill the color $a0 into the pixels $t0
	addi $t0 $t0 4                                  #increment $t0
	ble $t0 $t1 Square                              #loop till the last pixel
	
 	jr $ra

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************

# REGISTER USAGE
# $t6: x-coordinate
# $t7: y-coordinate
# $t8: origin address
# $t9: address of pixels
draw_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	
	push($t9)
	push($t8)
	push($t7)
	push($t6)
	
	li $t6 0
	li $t7 0 
	li $t8 0
	li $t9 0
	
	getCoordinates($a0 $t6 $t7)                     #get the coordinates of pixel to get address
	li $t8 0xffff0000
	getPixelAddress($t9 $t6 $t7 $t8)                #get the address of pixels
	sw $a1 ($t9)                                    #store the color into the correct address of pixels to draw
	
	pop($t6)
	pop($t7)
	pop($t8)
	pop($t9)
	
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************

# REGISTER USAGE
# $t6: x-coordinate
# $t7: y-coordinate
# $t8: origin address
# $t9: address of pixels
get_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	
	push($t9)
	push($t8)
	push($t7)
	push($t6)
	
	li $t6 0
	li $t7 0 
	li $t8 0
	li $t9 0
	
	getCoordinates($a0 $t6 $t7)                     #get the coordinates of pixel to get address
	li $t8 0xffff0000
	getPixelAddress($t9 $t6 $t7 $t8)                #get the address of pixels
	lw $v0 ($t9)                                    #load the color of pixels and store into $v0
	
	pop($t6)
	pop($t7)
	pop($t8)
	pop($t9)
	
	jr $ra

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************

# REGISTER USAGE
# $t0: x-coordinate
# $t1: coordinate of pixels 
# $t2: y-coordinate
draw_horizontal_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	
	push($t2)
	push($t1)
	push($t0)
	push($ra)
	
	li $t0 0                                        #$t0 is x-coordinate
	li $t1 0
	li $t2 0
	
	move $t2 $a0                                    #save y-coordinate into $t2
	HorizontalLine: nop	
	formatCoordinates($t1 $t0 $t2)                  #get the coordinate of pixels
	move $a0 $t1 
	jal draw_pixel                                  #draw
	addi $t0 $t0 1                                  #counter for x-coordinate
	blt $t0 128 HorizontalLine                      #if exceeds 128, end the loop
	
	pop($ra)
	pop($t0)
	pop($t1)
	pop($t2)
	
 	jr $ra

#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************

# REGISTER USAGE
# $t0: y-coordinate
# $t1: coordinate of pixels 
# $t2: x-coordinate
draw_vertical_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	
	push($t2)
	push($t1)
	push($t0)
	push($ra)
	
	li $t0 0                                        #$t0 is y-coordinate
	li $t1 0
	li $t2 0
	
	move $t2 $a0                                    #save x-coordinate into $t2
	VerticalLine: nop	
	formatCoordinates($t1 $t2 $t0)                  #get the coordinate of pixels
	move $a0 $t1
	jal draw_pixel                                  #draw
	addi $t0 $t0 1                                  #counter for y-coordinate
	blt $t0 128 VerticalLine                        #if exceeds 128, end the loop
	
	pop($ra)
	pop($t0)
	pop($t1)
	pop($t2)
	
 	jr $ra

#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************

# REGISTER USAGE
# $s0: coordinates of pixel
# $s1: color of pixel
# $s2: x-coordinate
# $s3: y-coordinate
# $s4: original color at the intersection
draw_crosshair: nop
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	move $s5 $sp

	move $s0 $a0  # store 0x00XX00YY in s0
	move $s1 $a1  # store 0x00RRGGBB in s1
	getCoordinates($a0 $s2 $s3)  # store x and y in s2 and s3 respectively
	
	# get current color of pixel at the intersection, store it in s4
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a0 $s0                                    #move coordinate of pixel into #a0
	jal get_pixel                                   #get the color of pixels
	move $s4 $v0                                    #save the color into $s4

	# draw horizontal line (by calling your `draw_horizontal_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)	
	push($s0)
	move $a1 $s1                                    #move color into $a1 to draw
	and $s0 $s0 0x0000ffff                          #get y-coordinate
	move $a0 $s0                                    #move y-coordinate into $a0 to draw
	jal draw_horizontal_line                        #draw
	pop($s0)

	# draw vertical line (by calling your `draw_vertical_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	push($s0)
	move $a1 $s1                                    #move color into $a1 to draw
	srl $s0 $s0 16
	and $s0 $s0 0x0000ffff                          #get x-coordinate
	move $a0 $s0                                    #move x-coordinate into $a0 to draw
	jal draw_vertical_line                          #draw
	pop($s0)

	# restore pixel at the intersection to its previous color
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a1 $s4                                    #move the original color into $a1 to draw
	move $a0 $s0                                    #move coordinate into $a0 to draw
	jal draw_pixel                                  #draw

	move $sp $s5
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	jr $ra
