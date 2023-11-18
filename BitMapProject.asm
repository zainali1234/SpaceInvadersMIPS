.data

#Game Core information
# Unit Width: 8
# Unit Height: 8
# Display Width: 512
# Display Height 512
# Base Address ($gp)

#Screen 
screenWidth: 	.word 64
screenHeight: 	.word 64

charColor: 	.word	0x0066cc # blue
backgroundColor:.word	0x000000 # black	
borderColor:    .word	0xffffff # white	
shootColor:    .word  0x00ff00 # green
enemyColor:	.word  0xff0000 # red

enemyCount: 	.word 5
enemyArray:    .space 10

lostMessage:   .asciiz "You finished the game!"
replayMessage:   .asciiz "Play again?"
score: 		.word 0

HeadX: 	.word 31 # player initial coordinates
HeadY:	.word 11

EnemyX:  .word 8 # first enemy initial coordinates
EnemyY:  .word 14

ObsX: 	.word 31 # projectile initial coordinates
ObsY:	.word 81

.text

main:
#Draw Background to Black, for reset
	lw $a0, screenWidth 
	lw $a1, backgroundColor 
	mul $a2, $a0, $a0 #total number of pixels on screen
	mul $a2, $a2, 4 
	add $a2, $a2, $gp 
	add $a0, $gp, $zero #loop counter
FillLoop:
	beq $a0, $a2, Init #end condition
	sw $a1, 0($a0) #store color
	addiu $a0, $a0, 4 
	j FillLoop

# Initialize Variables
Init:
	# initialize starting plane coordinates
	li $t0, 32
	sw $t0, HeadX
	li $t0, 47
	sw $t0, HeadY
	
	# initialize starting projectile coordinates
	li $t0, 32
	sw $t0, ObsX
	li $t0, 45
	sw $t0, ObsY

# initializes array that keeps track of existing enemies 
initArr:	
    la $t3, enemyArray    
    addi $t2, $zero, 1  
    addi $t0, $zero, 11 
top:
    sb $zero, 0($t3)      
                        
    addi $t2, $t2, 1    
    addi $t3, $t3, 1  
    	
    bne $t0, $t2, top 
# clears registers before starting loop
ClearRegisters:
	li $v0, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0	
	
	lw $s0, enemyCount

# draws border around screen
DrawBorder:
	lw $a2, borderColor #store color into $a2
	li $t1, 0	#load Y coordinate for the left border
	LeftLoop:
	move $a1, $t1	#move y coordinate into $a1
	li $a0, 0	# load x direction to 0, doesnt change
	jal CoordinateToAddress	#get screen coordinates
	move $a0, $v0	# move screen coordinates into $a0
	lw $a1, borderColor	#move color code into $a1
	jal DrawPixel	#draw the color at the screen location
	add $t1, $t1, 1	#increment y coordinate
	
	bne $t1, 64, LeftLoop	#loop through to draw entire left border
	
	li $t1, 0	
	RightLoop:
	move $a1, $t1	
	li $a0, 63	
	jal CoordinateToAddress	
	move $a0, $v0	
	lw $a1, borderColor	
	jal DrawPixel	
	add $t1, $t1, 1
	
	bne $t1, 64, RightLoop	#loop through to draw entire right border
	
	li $t1, 0	
	TopLoop:
	move $a0, $t1	
	li $a1, 0	
	jal CoordinateToAddress	
	move $a0, $v0	
	lw $a1, borderColor	
	jal DrawPixel	
	add $t1, $t1, 1 
	
	bne $t1, 64, TopLoop #loop through to draw entire top border
	
	li $t1, 0	
	BottomLoop:
	move $a0, $t1	
	li $a1, 63	
	jal CoordinateToAddress	
	move $a0, $v0	
	lw $a1, borderColor	
	jal DrawPixel	
	add $t1, $t1, 1	
	
	bne $t1, 64, BottomLoop # loop through to draw entire bottom border
	lw $a2, enemyColor	
	
DrawEnemies:
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, 1
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, -1
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, 2
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, -2
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, 2
	add $a1, $a1, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, -2
	add $a1, $a1, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, -2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, -1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, -1
	add $a0, $a0, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, -1
	add $a0, $a0, -1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, -2
	add $a0, $a0, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, -2
	add $a0, $a0, -2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 1
	add $a0, $a0, 3
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 1
	add $a0, $a0, -3
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 2
	add $a0, $a0, 4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 2
	add $a0, $a0, -4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 3
	add $a0, $a0, 4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 3
	add $a0, $a0, -4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 3
	add $a0, $a0, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 3
	add $a0, $a0, -2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 4
	add $a0, $a0, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 4
	add $a0, $a0, -2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 4
	add $a0, $a0, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 4
	add $a0, $a0, -1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate	
	addi $a0, $a0, 11
	sw $a0, EnemyX
	
	addi $s0, $s0, -1
	bgt $s0, 0, DrawEnemies
	
	li $t0, 8
	sw $t0, EnemyX
	
	lw $a1, EnemyY #load y coordinate
	addi $a1, $a1, -8
	sw $a1, EnemyY 
			
	lw $a2, charColor #store color into $a2
DrawPlane:
	#draw head of the plane
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a1, $a1, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a0, $a0, 1
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a0, $a0, -1
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a0, $a0, -1
	add $a1, $a1, 3
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a0, $a0, 1
	add $a1, $a1, 3
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a0, $a0, -2
	add $a1, $a1, 3
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a0, $a0, 2
	add $a1, $a1, 3
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a0, $a0, -3
	add $a1, $a1, 4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a0, $a0, 3
	add $a1, $a1, 4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a1, $a1, 3
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a1, $a1, 4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a1, $a1, 5
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a1, $a1, 6
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, HeadX #load x coordinate
	lw $a1, HeadY #load y coordinate
	add $a1, $a1, 7
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel

	li $t5, 1 # if one return to left movement
	beq $s3, $t5, left
	
	li $t5, 2 # if two return to loop movement
	beq $s3, $t5, Loop
	
	li $t5, 3 # if one return to right movement
	beq $s3, $t5, right
Loop:	
	beq	$t3, 3, shoot # if currently in process of shooting, jump to shoot loop
	
WinCheck:	
   	la $t3, enemyArray    # Load the address of array 
    	addi $t2, $zero, 5  # Initialize the first data value in register.
    	addi $t3, $t3, 5
winLoop:
    	lb $t4, 0($t3)      # Copy data from register to address [ 0 + contents of register $t3]
    	addi $t2, $t2, 1    # Increment loop counter
    	addi $t3, $t3, 1    # next array element
    	
    	beq $t4, 1, winLoop # increments by 1
	beq $t2, 11, Exit # if array portion is all element '1', then jump to exit 
	
	j	Control
shoot:
	li $v0, 32 
	li $a0, 70 # 70 ms delay
	syscall

	li	$a2, 0	# black out the pixel
	
	lw $a0, ObsX #load x coordinate
	lw $a1, ObsY #load y coordinate
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a2
	jal DrawPixel	#draw color at pixel
	
	lw $t1, ObsY  #load y coordinate	
	addi $t1, $t1, -1
	sw $t1, ObsY
	
	lw	$a2, shootColor
	
	lw $a0, ObsX #load x coordinate
	lw $a1, ObsY #load y coordinate
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a2
	jal DrawPixel	#draw color at pixel
	
	bgt $a1, 19, Control
	lw $a0, ObsX #load x coordinate
	
	# remove specific enemy based on projectile X position
	
	beq $a0, 7, removeE1 
	beq $a0, 12, removeE1 
	beq $a0, 17, removeE2
	beq $a0, 22, removeE2
	beq $a0, 27, removeE3
	beq $a0, 32, removeE3
	beq $a0, 37, removeE4
	beq $a0, 42, removeE4
	beq $a0, 52, removeE5
	beq $a0, 57, removeE5
	j endshoot
	
removeE1:
	la $t4, enemyArray # loads array address
	lb $a3, 5($t4) # loads byte from array
	
	lw $a0, EnemyX # initializes enemy head coordinate for removal
	li $a0, 8
	sw $a0, EnemyX
	
	li $t6, 1 # turns array element = 1 to indicate that enemy is gone 
	sb $t6, 5($t4) 
	
	la $t3, enemyArray 
	beq $a3, 0, removeEnemy # if element = 0 then jump to remove enemy loop
	
	j endshoot

removeE2:
	la $t4, enemyArray # loads array address
	lb $a3, 6($t4) # loads byte from array
	
	lw $a0, EnemyX # initializes enemy head coordinate for removal
	li $a0, 19
	sw $a0, EnemyX
	
	li $t6, 1 # turns array element = 1 to indicate that enemy is gone 
	sb $t6, 6($t4) 
	
	la $t3, enemyArray 
	beq $a3, 0, removeEnemy # if element = 0 then jump to remove enemy loop
	
	j endshoot

removeE3:
	la $t4, enemyArray # loads array address
	lb $a3, 7($t4) # loads byte from array
	
	lw $a0, EnemyX # initializes enemy head coordinate for removal
	li $a0, 30
	sw $a0, EnemyX 
	
	li $t6, 1 # turns array element = 1 to indicate that enemy is gone 
	sb $t6, 7($t4) 
	
	la $t3, enemyArray 
	beq $a3, 0, removeEnemy # if element = 0 then jump to remove enemy loop
	
	j endshoot

removeE4:
	la $t4, enemyArray # loads array address
	lb $a3, 8($t4) # loads byte from array
	
	lw $a0, EnemyX # initializes enemy head coordinate for removal
	li $a0, 41
	sw $a0, EnemyX
	
	li $t6, 1 # turns array element = 1 to indicate that enemy is gone 
	sb $t6, 8($t4) 
	
	la $t3, enemyArray 
	beq $a3, 0, removeEnemy # if element = 0 then jump to remove enemy loop

	j endshoot
	
removeE5:
	la $t4, enemyArray # loads array address
	lb $a3, 9($t4) # loads byte from array
	
	lw $a0, EnemyX # initializes enemy head coordinate for removal
	li $a0, 52
	sw $a0, EnemyX
	
	li $t6, 1 # turns array element = 1 to indicate that enemy is gone 
	sb $t6, 9($t4) 
	
	la $t3, enemyArray 
	beq $a3, 0, removeEnemy # if element = 0 then jump to remove enemy loop

	j endshoot

removeEnemy: 
	li $a2, 0
	
	lw $a1, EnemyY #load y coordinate
	li $a1, 14
	sw $a1, EnemyY
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, 1
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, -1
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, 2
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, -2
	add $a1, $a1, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, 2
	add $a1, $a1, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, -2
	add $a1, $a1, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, -2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a0, $a0, -1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, -1
	add $a0, $a0, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, -1
	add $a0, $a0, -1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, -2
	add $a0, $a0, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, -2
	add $a0, $a0, -2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 1
	add $a0, $a0, 3
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 1
	add $a0, $a0, -3
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 2
	add $a0, $a0, 4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 2
	add $a0, $a0, -4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 3
	add $a0, $a0, 4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 3
	add $a0, $a0, -4
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 3
	add $a0, $a0, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 3
	add $a0, $a0, -2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 4
	add $a0, $a0, 2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 4
	add $a0, $a0, -2
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 4
	add $a0, $a0, 1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	lw $a0, EnemyX #load x coordinate
	lw $a1, EnemyY #load y coordinate
	add $a1, $a1, 4
	add $a0, $a0, -1
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a0
	jal DrawPixel	#draw color at pixel
	
	li $t5, 1
	la $t4, enemyArray 
	sb $t5, 7($t4)	
		
	j endshoot
	
# blacks out projectile and reinitializes projectile position
endshoot:
	li	$a2, 0		# black out the pixel
	
	lw $a0, ObsX #load x coordinate
	lw $a1, ObsY #load y coordinate
	jal CoordinateToAddress #get screen coordinates
	move $a0, $v0 #copy coordinates to $a2
	jal DrawPixel	#draw color at pixel
	
	lw $a1, ObsY #load y coordinate
	li $a1, 45
	sw $a1, ObsY
	
	li $t3, 0
	j Control
Control:
	li $t1, 10
	li $t2, 54
	# check for input
	lw $t0, 0xffff0000  #t1 holds if input available
	
    	beq $t0, 0, Loop   #If no input, keep displaying
	
    	# process input
    	lw 	$s1, 0xffff0004
	
	beq	$s1, 97, blankleft  	# input a
	beq	$s1, 100, blankright	# input d
	beq	$s1, 119, checkshoot	# input w
	
	# invalid input
	j	Loop
	lw $a2, charColor #store color into $a2
	
checkshoot:
	beq $t3, 3, Control #if $t3 = 3 then projectile still moving, jumps back to Control
	li $t3, 3 # $t3 = 3 lets program know to not allow another projectile to be shot while moving 
	lw $a0, HeadX 
	sw $a0, ObsX #loads projectile X coordinate based on where plane is placed 
	j	Loop
# removes plane
blankleft:
	lw 	$a0, HeadX # loads current plane head coordinate
	ble	$a0, $t1, Loop	# makes sure plane coordinate is not too left
	li	$a2, 0	# blacks out the pixels
	li	$s3, 1 
	jal	DrawPlane
# creates plane in new position
left:	
	lw	$a2, charColor		
	li	$s3, 2
	
	lw $a0, HeadX #load x coordinate	
	addi $a0, $a0, -5 # moves plane head 5px to the left 
	sw $a0, HeadX
	
	jal	DrawPlane 
	j	Loop 
# removes plane
blankright:	
	lw $a0, HeadX # loads current plane head coordinate
	bge	$a0, $t2, Loop # makes sure plane coordinate is not too right
	li	$a2, 0	# black out the pixel
	li	$s3, 3
	jal	DrawPlane
# creates plane in new position
right:	
	lw	$a2, charColor		
	li	$s3, 2
	
	lw $a0, HeadX #load x coordinate	
	addi $a0, $a0, 5 # moves plane head 5px to the left 
	sw $a0, HeadX
	
	jal	DrawPlane
	j	Loop	
	
CoordinateToAddress:
	lw $v0, screenWidth 	#Store screen width into $v0
	mul $v0, $v0, $a1	#multiply by y position
	add $v0, $v0, $a0	#add the x position
	mul $v0, $v0, 4		#multiply by 4
	add $v0, $v0, $gp	#add global pointer from bitmap display
	jr $ra			#return $v0
	
DrawPixel:
	sw $a2, ($a0) 	#fill the coordinate with specified color
	jr $ra		#return

Exit:	
	li $v0, 55 #syscall value for dialog
	la $a0, lostMessage #get message
	syscall
	
	li $v0, 50 #syscall for yes/no dialog
	la $a0, replayMessage #get message
	syscall
	
	beqz $a0, main #jump back to start of program

	li $v0, 10  #end program
	syscall


