#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Laksh Patel, 1008080363, patellak, laksh.patel@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10010000 (static data)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
# All the milestones have been reached in this submission.
# 
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 
# 1. Health: is tracked & shown on screen during the game through red pluses on the bottom left of the screen, 
# that disappear when the player gets hurt by the gray spikes on the bottom left of the screen.
# 2. Fail condition: Player fails the game when he loses all his red pluses, revealing a game over screen.
# 3. Win condition: Player wins the game when he collects the gold/yellow coin at the top of the screen, revealing a game won screen.
# 4. Disappearing platforms: The 2 floating platforms disappear and reappear every 5 seconds.
# 5. Pick-up effects: First pick-up is gas for the jetpack refuels gas bar at the bottom of the screen. 
# Then, I have a health pick-up which gives you an extra life. Then, my third pick-up is a coin which ends the game when you reach it. 
# 6. Jet Pack: Able to fly using jet pack whenever fuel bar is not empty. Which can be filled using orange fuel pick-ups.
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
# https://youtu.be/64CTxTsgvi0
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
# Sure, here's the Github link: 
# Any additional information that the TA needs to know:
# - When you collect the gold coin to win the game, the win screen will appear after you've fallen to the ground.
# 
# - Sometimes when the win or lose screen appears it doesn't get fully drawn onto the bitmap display, however if you
# click on the bitmap display window to switch from the keyboard window, then the rest of the win/lose screen will show up.
# 
# - The first orange gas container pick-up on the ground is the pick-up for the pick-up requirement 
# as it's coded to disappear while the otherone is not. Therefore reaching a total of 3 pick-ups, the coin, the red plus, & the orange gas pick-up.
#
# - The p key to restart the game works but not when the game is finished and either the win/lose screen are already showing.
#####################################################################
.eqv BASE_ADDRESS 0x10010000 # 268500992

.eqv BLACK 0x000000
.eqv BLUE 0x0000FF
.eqv GRAY 0x808080
.eqv GOLD 0xFFD700
.eqv GREEN 0x00FF00
.eqv ORANGE 0xff8c00
.eqv FLOOR_COLOR 0x964B00
.eqv HEART_COLOR 0xFF0000
.eqv HEART1 0x10013C04
.eqv HEART2
.eqv HEART3
.eqv HEART_PICK_UP 268509916
.eqv SPIKE_LOC 268515076
.eqv COIN_LOC 268501644
.eqv GAS_LOC1 268514956 # BASE_ADDRESS + (54 * 64 + 35) * 4
.eqv GAS_LOC2 268506900 # BASE_ADDRESS + (23 * 64 + 5) * 4
.eqv KEYSTROKE_LOC 0xffff0000
.eqv GAS_START 268516432 # BASE_ADDRESS + (60 * 64 + 20) * 4
.eqv ACTUAL_GAS_END 268516592 # BASE_ADDRESS + (60 * 64 + 60) * 4
.eqv END_OF_SPIKES 268515184 # BASE_ADDRESS + (55 * 64 + 28) * 4


.data # This tells the assembler that the following are data. (Basically your variable declarations and initializations.)
spacer: .space 100000
HEART_COUNT: .word 2
PLAYER_LOC: .word 0x100137F4
GAS_END: .word 268516432
JETPACK_FLAG: .word 0
PLAYER_COLOR: .word 0x0000FF
HEART_PICK_UP_FLAG: .word 0
ERASE_GAS_BAR_FLAG: .word 0
COIN_FLAG: .word 0
PLATFORM_FLAG: .word 0


.text # This tells the assembler that the following are instructions.
.globl main

main:
		jal RESTART_GAME # Function call to start game and draw everything.

		la $t7, JETPACK_FLAG # Loading the address of the JETPACK_FLAG variable into register t7.
		li $t5, 0

MAINLOOP:			
				
		
		li $t9, KEYSTROKE_LOC
		lw $t8, ($t9)
		beq $t8, 1, CALLFUNCTION
		j DONTCALLFUNCTION
CALLFUNCTION:	
		jal CHECK_KEYPRESS
		sw $zero, ($t9)

DONTCALLFUNCTION:
		
		
		
		
		#li $v0, 32
		#li $a0, 40
		#syscall
		
		lw $t6, ($t7) # Loading the value of JETPACK_FLAG variable.
		beq $t6, 1, SKIP_GRAVITY
		jal GRAVITY
SKIP_GRAVITY:

		li $v0, 32
		li $a0, 150
		syscall

		
		bne $t5, 32, SKIP_DISAPPEAR
		la $t5, PLATFORM_FLAG
		lw $t0, ($t5)
		
		beq $t0, 0, OTHER
		li $t0, 0
		sw $t0, ($t5)
		j DONE_FLAG_UPDATE
OTHER:
		li $t0, 1
		sw $t0, ($t5)	
DONE_FLAG_UPDATE:
		li $t5, 0
		jal UPDATE_PLATFORMS
SKIP_DISAPPEAR:		
		addi $t5, $t5, 1

		li $t0, 0
		sw $t0, ($t7) # Storing a 0 in JETPACK_FLAG
		
		j MAINLOOP

############# FUNCTIONS BELOW ##################

# This function restarts the game.
RESTART_GAME:
		addi $sp, $sp, -4
		sw $ra, ($sp) # Storing the return address for this function call into the stack.
		
		jal ERASE_SCREEN # Calling function to erase the screen.
		
		la $t0, HEART_COUNT
		li $t1, 2
		sw $t1, ($t0) # Resetting the HEART_COUNT variable to 2.
		
		la $t0, PLAYER_LOC
		li $t1, 0x100137F4
		sw $t1, ($t0) # Resetting the PLAYER_LOCATION variable back to the starting location.	
		
		la $t0, GAS_END
		li $t1, GAS_START
		sw $t1, ($t0) # Resetting the GAS_END variable back to the start of game value.	
		
		la $t0, PLAYER_COLOR
		li $t1, BLUE
		sw $t1, ($t0) # Resetting the PLAYER_COLOR variable back to BLUE.			
		
		la $t0, HEART_PICK_UP_FLAG
		li $t1, 0
		sw $t1, ($t0) # Resetting the HEART_PICK_UP_FLAG variable back to 0.
		
		la $t0, COIN_FLAG
		li $t1, 0
		sw $t1, ($t0) # Resetting the COIN_FLAG variable back to 0.	
		
		la $t0, PLATFORM_FLAG
		li $t1, 0
		sw $t1, ($t0) # Resetting the PLATFORM_FLAG variable back to 0.				
		
		jal DRAW_PLAYER
		jal DRAW_PLATFORMS
		jal DRAW_SPIKES
		jal UPDATE_HEARTS
		jal DRAW_COIN
		jal DRAW_GAS
		jal DRAW_HEART_PICK_UP
		jal DRAW_BORDERS
		jal UPDATE_PLATFORMS
		
		lw $ra, ($sp) # Load return address back from stack. 
		addi $sp, $sp, 4		
		
		jr $ra

# This function erases the screen.
ERASE_SCREEN:
		li $t0, BASE_ADDRESS
		li $t1, BASE_ADDRESS
		addi $t1, $t1, 16380
		li $t2, BLACK
ERASE:
		bgt $t0, $t1, STOP_ERASING
		sw $t2, ($t0)
		addi $t0, $t0, 4
		j ERASE
STOP_ERASING:
		jr $ra



# This function erases the character.
ERASE_PLAYER:
		la $t0, PLAYER_LOC # Loading the address of variable PLAYER_LOC
		lw $t0, ($t0) # Loading the player's address.
		li $t1, BLACK # Loading the hex code for black.
		
		sw $t1, ($t0) # Drawing the player's body.
		addi $t0, $t0, -256
		sw $t1, ($t0)
		addi $t0, $t0, -256
		sw $t1, ($t0)
		addi $t0, $t0, -256
		sw $t1, ($t0)
		
		addi $t0, $t0, 252 # Drawing the players arms.
		sw $t1, ($t0)
		sw $t1, 4($t0)
		sw $t1, 8($t0)

		
		jr $ra		

# This function checks the user's keypress and calls the corresponding functions.
CHECK_KEYPRESS:
		li $t0, KEYSTROKE_LOC
		lw $t0, 4($t0) # Storing the ascii value of the keypress in register t0.
		addi $sp, $sp, -4
		sw $ra, ($sp) # Storing the return address for this function call onto stack.

		bne $t0, 0x70, CHECK_MOVEMENT_KEYS # if the key pressed was not a p, then branch to check if other keys were pressed.
		jal RESTART_GAME # Function to restart the game.
		j DONE_KEY_CHECK # Jump to skip the rest of the key checks.		
CHECK_MOVEMENT_KEYS:		
		bne $t0, 0x61, CHECK_D # If the key pressed was not a, then branch to check if key d was pressed.
		jal MOVE_PLAYER_LEFT # Function call to move player left.
		j DONE_KEY_CHECK # Jump to skip the rest of the key checks.	
CHECK_D:
		bne $t0, 0x64, CHECK_GAS_BAR # If the key pressed was not d, then branch. 
		jal MOVE_PLAYER_RIGHT # Function call to move player right.
		j DONE_KEY_CHECK # Jump to skip the rest of the key checks.	

CHECK_GAS_BAR:
		li $t1, GAS_START # Loading the address of the start of the gas bar.
		la $t2, GAS_END
		lw $t2, ($t2) # Loading the address of the end of the gas bar.
		
		beq $t1, $t2, DONE_KEY_CHECK # If the start and end of the gas bar are equal then branch.
		bne $t0, 0x71, CHECK_E # If the key pressed was not a q, then branch.
		jal FLY_PLAYER_LEFT
		j DONE_KEY_CHECK

CHECK_E:	bne $t0, 0x65, DONE_KEY_CHECK # If the key pressed was not an e, then branch.
		jal FLY_PLAYER_RIGHT


DONE_KEY_CHECK:
		lw $ra, ($sp) # Load return address back from stack. 
		addi $sp, $sp, 4
		
		jr $ra

# This function applies gravity to the player.
GRAVITY: 
		addi $sp, $sp, -4
		sw $ra, ($sp) # Storing the return address of this function call into the stack.

		li $t2, FLOOR_COLOR # Loading the color of the floor.
		la $t3, PLAYER_LOC
		lw $t0, ($t3)
		
		lw $t1 256($t0) # Loading the value of the pixel right below the player.
		beq $t1, $t2, DONT_DROP # If pixel is border color then branch.		
		
		addi $sp, $sp, -4
		sw $t0, ($sp) # Saving register t0 onto stack.
		addi $sp, $sp, -4
		sw $t3, ($sp) # Saving register $t3 onto stack.
		
		jal ERASE_PLAYER # Function call to erase current location of player.
		jal DRAW_SPIKES
		jal DRAW_GAS
		jal DRAW_HEART_PICK_UP
		jal DRAW_COIN
		lw $t3, ($sp) # Loading back register t3.
		addi $sp, $sp, 4
		lw $t0, ($sp) # Loading back register t0.
		addi $sp, $sp, 4

		
		li $t2, FLOOR_COLOR # Loading the color of the floor.
		li $t4, GRAY
		lw $t1 -260($t0) # Loading the value of the pixel right below the player's left arm.
		beq $t1, $t2, ADD # If the pixel right below the player's left arm is a floor then branch.
		beq $t1, $t4, OVER_SPIKE
		lw $t1 -252($t0) # Loading the value of the pixel right below the player's right arm.
		beq $t1, $t2, ADD # If the pixel right below the player's right arm is a floor then branch.
		beq $t1, $t4, OVER_SPIKE
		lw $t1, 256($t0)
		beq $t1, $t4, OVER_SPIKE
		j START_DRAWING	
ADD:		addi $t0, $t0, 256 # Moving the player's location down one from the current location.
		sw $t0, ($t3) # Storing the new player location into variable PLAYER_LOC.
		j START_DRAWING
	
OVER_SPIKE:
		la $t3, PLAYER_COLOR # Load the address of the PLAYER_COLOR variable.
		lw $t0, ($t3) # Loading the current color of the player into register t0.
		li $t2, HEART_COLOR # Load the color HEART_COLOR into register t2.
		
		beq $t2, $t0, GO_HERE # If the current color of the player is already red, then branch.
		
		sw $t2, ($t3) # Store the color HEART_COLOR into the variable PLAYER_COLOR.
		
		la $t3, HEART_COUNT # Store the address of the variable HEART_COUNT.
		lw $t2, ($t3) # Load the current value of HEART_COUNT.
		addi $t2, $t2, -1 # Subtract 1 to the current value of HEART_COUNT.
		sw $t2, ($t3) # Store the decreased value back into HEART_COUNT variable.
		
		la $t0, ERASE_GAS_BAR_FLAG # Load the address of variable ERASE_GAS_BAR_FLAG into register t0.
		li $t2, 1 # Load the immediate 1 into register t2.
		sw $t2, ($t0) # Store a 1 into variable ERASE_GAS_BAR_FLAG
		
		la $t0, GAS_END # Load the address of variable GAS_END into register t0.
		li $t2, GAS_START # Load the address stored in GAS_START variable.
		sw $t2, ($t0) #Updating the GAS_END variable to equal GAS_START.

GO_HERE:
		la $t3, PLAYER_LOC
		lw $t0, ($t3)

		addi $t0, $t0, 256 # Moving the player's location down one from the current location.
		sw $t0, ($t3) # Storing the new player location into variable PLAYER_LOC.

		jal DRAW_PLAYER # Function call to draw the player.
		jal UPDATE_HEARTS
		jal DRAW_GAS_BAR
		j SKIP_GAME_WIN	

START_DRAWING:	
		addi $t0, $t0, 256 # Moving the player's location down one from the current location.
		sw $t0, ($t3) # Storing the new player location into variable PLAYER_LOC.
		
		la $t0, PLAYER_COLOR # Loading the address of the variable PLAYER_COLOR into register t0.
		li $t1, BLUE # Loading the hex value of the color BLUE into register t1.
		sw $t1, ($t0) # Storign the hex value for BLUE into PLAYER_COLOR variable.

		jal DRAW_PLAYER # Function call to draw the player.
		j SKIP_GAME_WIN	
DONT_DROP:
		la $t0, COIN_FLAG
		lw $t0, ($t0)
		bne $t0, 1, SKIP_GAME_WIN
		jal ERASE_SCREEN
		j DRAW_W
SKIP_GAME_WIN:
		lw $ra, ($sp) # Load return address back from stack. 
		addi $sp, $sp, 4
		
		jr $ra

# This function flys the player to the right.
FLY_PLAYER_RIGHT:
		addi $sp, $sp, -4
		sw $ra, ($sp) # Storing the return address of this function call into the stack.
		
		li $t2, FLOOR_COLOR # Loading the color of the floor.
		li $t4, GOLD # Loading the color of the coin.
		la $t3, PLAYER_LOC
		lw $t0, ($t3)
		
		lw $t1 -252($t0) # Loading the value of the pixel that will be the new feet of player.
		beq $t1, $t2, DONT_FLY_RIGHT # If pixel is border color branch.
		lw $t1, -1020($t0) # Loading the value of the pixel that will be the new head pixel of player.
		beq $t1, $t2, DONT_FLY_RIGHT # If pixel is border color branch.
		beq $t1, $t4, FLYING_INTO_COIN # If pixel is the coin color, then branch.
		lw $t1, -760($t0) # Loading the value of the pixel that will be the new right hand of player.
		beq $t1, $t2, DONT_FLY_RIGHT # If pixel is border color branch.
		beq $t1, $t4, FLYING_INTO_COIN # If pixel is the coin color, then branch.
		j NO_COIN # Didn't fly into coin so branch. 
FLYING_INTO_COIN:
		la $t1, COIN_FLAG
		li $t2, 1
		sw $t2, ($t1) # Storing a 1 into COIN_FLAG variable.
		
		la $t1 ERASE_GAS_BAR_FLAG
		sw $t2, ($t1) # Storing a 1 into ERASE_GAS_BAR_FLAG
		
		la $t1, GAS_END
		li $t2, GAS_START
		addi $t2, $t2, 4 # Adding 4 just to negate the -4 that happens to GAS_END later on in this function.
		sw $t2, ($t1) # Emptying the gas bar by setting GAS_END variable back to value of GAS_START.
NO_COIN:
		addi $sp, $sp, -4
		sw $t0, ($sp) # Saving register t0 onto stack.
		addi $sp, $sp, -4
		sw $t3, ($sp) # Saving register $t3 onto stack.

		jal ERASE_PLAYER # Function call to erase current location of player.
		jal DRAW_SPIKES
		jal DRAW_GAS
		jal DRAW_HEART_PICK_UP
		jal DRAW_COIN
		lw $t3, ($sp) # Loading back register t3.
		addi $sp, $sp, 4
		lw $t0, ($sp) # Loading back register t0.
		addi $sp, $sp, 4
		
		addi $t0, $t0, -252 # Moving the player's location up and left one from the current location.
		sw $t0, ($t3) # Storing the new player location into variable PLAYER_LOC.
		
		la $t0, PLAYER_COLOR # Loading the address of the variable PLAYER_COLOR into register t0.
		li $t1, GREEN # Loading the hex value of the color GREEN into register t1.
		sw $t1, ($t0) # Storing the hex value for GREEN into PLAYER_COLOR variable.
		
		jal DRAW_PLAYER # Function call to draw the player.
		
		# Updating the new GAS_END value by subtracting 4 to lower the gas tank.
		la $t0, GAS_END
		lw $t1, ($t0)
		addi $t1, $t1, -4
		sw $t1, ($t0)
		
		jal DRAW_GAS_BAR
		
		li $t0, 1 # Loading the immediate 1 into register t0.
		sw $t0, ($t7) # Storing 1 into the JETPACK_FLAG.
DONT_FLY_RIGHT:

		lw $ra, ($sp) # Loading back the return address for this function from the stack.
		addi $sp, $sp, 4
		jr $ra

# This function flys the player to the left.
FLY_PLAYER_LEFT:
		addi $sp, $sp, -4
		sw $ra, ($sp) # Storing the return address of this function call into the stack.
		
		li $t2, FLOOR_COLOR # Loading the color of the floor.
		li $t4, GOLD # Loading the color of the coin.
		la $t3, PLAYER_LOC
		lw $t0, ($t3)
		
		lw $t1 -260($t0) # Loading the value of the pixel that will be the new feet of player.
		beq $t1, $t2, DONT_FLY_LEFT # If pixel is border color branch.
		lw $t1, -1028($t0) # Loading the value of the pixel that will be the new head pixel of player.
		beq $t1, $t2, DONT_FLY_LEFT # If pixel is border color branch.
		beq $t1, $t4, FLYING_INTO_COIN2 # If pixel is the coin color, then branch.
		lw $t1, -776($t0) # Loading the value of the pixel that will be the new left hand of player.
		beq $t1, $t2, DONT_FLY_LEFT # If pixel is border color branch.
		beq $t1, $t4, FLYING_INTO_COIN2 # If pixel is the coin color, then branch.
		j NO_COIN2 # Didn't fly into coin so branch. 
FLYING_INTO_COIN2:
		la $t1, COIN_FLAG
		li $t2, 1
		sw $t2, ($t1) # Storing a 1 into COIN_FLAG variable.
		
		la $t1 ERASE_GAS_BAR_FLAG
		sw $t2, ($t1) # Storing a 1 into ERASE_GAS_BAR_FLAG
		
		la $t1, GAS_END
		li $t2, GAS_START
		addi $t2, $t2, 4 # Adding 4 just to negate the -4 that happens to GAS_END later on in this function.
		sw $t2, ($t1) # Emptying the gas bar by setting GAS_END variable back to value of GAS_START.
NO_COIN2:	
			
		addi $sp, $sp, -4
		sw $t0, ($sp) # Saving register t0 onto stack.
		addi $sp, $sp, -4
		sw $t3, ($sp) # Saving register $t3 onto stack.

		jal ERASE_PLAYER # Function call to erase current location of player.
		jal DRAW_SPIKES
		jal DRAW_GAS
		jal DRAW_HEART_PICK_UP
		jal DRAW_COIN
		lw $t3, ($sp) # Loading back register t3.
		addi $sp, $sp, 4
		lw $t0, ($sp) # Loading back register t0.
		addi $sp, $sp, 4
		
		addi $t0, $t0, -260 # Moving the player's location up and left one from the current location.
		sw $t0, ($t3) # Storing the new player location into variable PLAYER_LOC.
		
		la $t0, PLAYER_COLOR # Loading the address of the variable PLAYER_COLOR into register t0.
		li $t1, GREEN # Loading the hex value of the color GREEN into register t1.
		sw $t1, ($t0) # Storign the hex value for GREEN into PLAYER_COLOR variable.
		
		jal DRAW_PLAYER # Function call to draw the player.
		
		# Updating the new GAS_END value by subtracting 4 to lower the gas tank.
		la $t0, GAS_END
		lw $t1, ($t0)
		addi $t1, $t1, -4
		sw $t1, ($t0)
		
		jal DRAW_GAS_BAR
		
		li $t0, 1 # Loading the immediate 1 into register t0.
		sw $t0, ($t7) # Storing 1 into the JETPACK_FLAG		
DONT_FLY_LEFT:

		lw $ra, ($sp) # Loading back the return address for this function from the stack.
		addi $sp, $sp, 4
		jr $ra

# This function moves the player right.
MOVE_PLAYER_RIGHT:
		addi $sp, $sp, -4
		sw $ra, ($sp) # Storing the return address of this function call into the stack.
		
		la $t3, PLAYER_LOC
		lw $t0, ($t3)
		
		lw $t1, -504($t0) # Loading value of the pixel to the right of the player.
		li $t2, FLOOR_COLOR # Loading the color of the floor.
		
		beq $t1, $t2, DONT_MOVE_RIGHT # If on the right of the player is border color branch.
		lw $t1, 256($t0)
		bne $t1, $t2, DONT_MOVE_RIGHT # If below the player is not a border color, then branch.
		lw $t1, -504($t0) # Set register t1 back to the color of the pixel on the right of the player.
		
		
		addi $sp, $sp, -4
		sw $t0, ($sp) # Saving register t0 onto stack.
		addi $sp, $sp, -4
		sw $t3, ($sp) # Saving register $t3 onto stack.
		
		addi $t0, $t0, 4 # Adding 4 to the current player location address to set it to the address of the pixel to the right of the players feet.
		li $t3, END_OF_SPIKES # Loading the address of the pixel END_OF_SPIKES
		bne $t0, $t3, CHECK_HEALTH_PICK_UP # If the pixel to the right of the player is not the END_OF_SPIKE address, then branch.
		la $t0, PLAYER_COLOR # Loading the address of PLAYER_COLOR variable.
		li $t3, BLUE # Loading the color blue.
		sw $t3, ($t0) # Setting the PLAYER_COLOR variable to the value BLUE
		j SKIP_REFILL2 # Skipping all other right of player checks. 
		
CHECK_HEALTH_PICK_UP:		
		li $t2, HEART_COLOR # Loading the color the heart pick-up.
		bne $t1, $t2, SKIP_HEALTH2 # If on the left of the player is not the heart color, then branch.
		la $t3, HEART_COUNT # Store the address of the variable HEART_COUNT.
		lw $t2, ($t3) # Load the current value of HEART_COUNT.
		addi $t2, $t2, 1 # Add 1 to the current value of HEART_COUNT.
		sw $t2, ($t3) # Store the increased value back into HEART_COUNT variable.
		
		la $t3, HEART_PICK_UP_FLAG # Loading the address of the HEART_PICK_UP_FLAG variable.
		li $t2, 1 # Loading the immediate 1 into register t2.
		sw $t2, ($t3) # Storing 1 as the HEART_PICK_UP_FLAG variable value.
		j SKIP_REFILL2 # Skipping all other right of player checks. 
SKIP_HEALTH2:		
		li $t2, ORANGE # Loading the color of the gas pick-up.
		bne $t1, $t2, SKIP_REFILL2 # If on the left of the player is not the gas color branch.
		
		la $t0, GAS_END
		li $t3, ACTUAL_GAS_END # Loading the address of the end of the entire gas bar.
		sw $t3, ($t0) # Updating the end of the gas bar.
		
		jal DRAW_GAS_BAR # Calling function to draw the new gas bar.
SKIP_REFILL2:
		
		jal ERASE_PLAYER # Function call to erase current location of player.
		jal DRAW_SPIKES
		jal DRAW_GAS
		jal DRAW_HEART_PICK_UP
		jal UPDATE_HEARTS
		
		lw $t3, ($sp) # Loading back register t3.
		addi $sp, $sp, 4
		lw $t0, ($sp) # Loading back register t0.
		addi $sp, $sp, 4
		
		addi $t0, $t0, 4 # Moving the player's location right by adding 4 to current location.
		sw $t0, ($t3) # Storing the new player location into variable PLAYER_LOC.
		
		jal DRAW_PLAYER # Function call to draw the player.
DONT_MOVE_RIGHT:
		
		lw $ra, ($sp) # Loading back the return address for this function from the stack.
		addi $sp, $sp, 4
		jr $ra



# This function moves the player left.
MOVE_PLAYER_LEFT:

		addi $sp, $sp, -4
		sw $ra, ($sp) # Storing the return address of this function call into the stack.
		
		la $t3, PLAYER_LOC
		lw $t0, ($t3)
		
		lw $t1, -520($t0) # Loading value of the pixel to the left of the player.
		li $t2, FLOOR_COLOR # Loading the color of the floor.
		
		beq $t1, $t2, DONT_MOVE_LEFT # If on the left of the player is border color branch.
		lw $t1, 256($t0)
		bne $t1, $t2, DONT_MOVE_RIGHT # If below the player is not a border color, then branch.
		lw $t1, -520($t0) # Set register t1 back to the color of the pixel on the left of the player.

		addi $sp, $sp, -4
		sw $t0, ($sp) # Saving register t0 onto stack.
		addi $sp, $sp, -4
		sw $t3, ($sp) # Saving register $t3 onto stack.
		
		li $t2, GRAY # Load the color gray into register t2.
		beq $t1, $t2, THERES_SPIKE # If on the left of they player is the color gray, then branch.
		lw $t1, -260($t0)
		beq $t1, $t2, THERES_SPIKE
		lw $t1, -4($t0)
		beq $t1, $t2, THERES_SPIKE
		lw $t1, -520($t0)
		j SKIP_SPIKE
THERES_SPIKE:
		la $t3, PLAYER_COLOR # Load the address of the PLAYER_COLOR variable.
		lw $t0, ($t3) # Loading the current color of the player into register t0.
		li $t2, HEART_COLOR # Load the color HEART_COLOR into register t2.
		
		beq $t2, $t0, ALREADY_RED # If the current color of the player is already red, then branch.
		
		sw $t2, ($t3) # Store the color HEART_COLOR into the variable PLAYER_COLOR.
		
		la $t3, HEART_COUNT # Store the address of the variable HEART_COUNT.
		lw $t2, ($t3) # Load the current value of HEART_COUNT.
		addi $t2, $t2, -1 # Subtract 1 to the current value of HEART_COUNT.
		sw $t2, ($t3) # Store the decreased value back into HEART_COUNT variable.
		
		la $t0, ERASE_GAS_BAR_FLAG # Load the address of variable ERASE_GAS_BAR_FLAG into register t0.
		li $t2, 1 # Load the immediate 1 into register t2.
		sw $t2, ($t0) # Store a 1 into variable ERASE_GAS_BAR_FLAG
		
		la $t0, GAS_END # Load the address of variable GAS_END into register t0.
		li $t2, GAS_START # Load the address stored in GAS_START variable.
		sw $t2, ($t0) #Updating the GAS_END variable to equal GAS_START.
ALREADY_RED:		
		j SKIP_REFILL # Jump to SKIP_REFILL bc nothing else except spike can be on left of player.
		
SKIP_SPIKE:	li $t2, HEART_COLOR # Loading the color the heart pick-up.
		bne $t1, $t2, SKIP_HEALTH # If on the left of the player is not the heart color, then branch.
		la $t3, HEART_COUNT # Store the address of the variable HEART_COUNT.
		lw $t2, ($t3) # Load the current value of HEART_COUNT.
		addi $t2, $t2, 1 # Add 1 to the current value of HEART_COUNT.
		sw $t2, ($t3) # Store the increased value back into HEART_COUNT variable.
		
		la $t3, HEART_PICK_UP_FLAG # Loading the address of the HEART_PICK_UP_FLAG variable.
		li $t2, 1 # Loading the immediate 1 into register t2.
		sw $t2, ($t3) # Storing 1 as the HEART_PICK_UP_FLAG variable value.
		j SKIP_REFILL # Jump to SKIP_REFILL bc nothing else except spike can be on left of player.
SKIP_HEALTH:				
		li $t2, ORANGE # Loading the color of the gas pick-up.
		bne $t1, $t2, SKIP_REFILL # If on the left of the player is not the gas color, then branch.
		
		la $t0, GAS_END
		li $t3, ACTUAL_GAS_END # Loading the address of the end of the entire gas bar.
		sw $t3, ($t0) # Updating the end of the gas bar.
		
		#jal DRAW_GAS_BAR # Calling function to draw the new gas bar.
SKIP_REFILL:
		
		jal ERASE_PLAYER # Function call to erase current location of player.
		jal DRAW_SPIKES
		jal DRAW_GAS
		jal DRAW_HEART_PICK_UP
		jal UPDATE_HEARTS
		jal DRAW_GAS_BAR # Calling function to draw the new gas bar.

		lw $t3, ($sp) # Loading back register t3.
		addi $sp, $sp, 4
		lw $t0, ($sp) # Loading back register t0.
		addi $sp, $sp, 4
		
		addi $t0, $t0, -4 # Moving the player's location left by subtracting 4 to current location.
		sw $t0, ($t3) # Storing the new player location into variable PLAYER_LOC.
		
		jal DRAW_PLAYER # Function call to draw the player.
DONT_MOVE_LEFT:
		
		lw $ra, ($sp) # Loading back the return address for this function from the stack.
		addi $sp, $sp, 4
		jr $ra

################ DRAW_FUNCTIONS BELOW #####################
# This function draws the heart pick-up.
DRAW_HEART_PICK_UP:
		li $t0, HEART_PICK_UP
		la $t2, HEART_PICK_UP_FLAG
		lw $t2, ($t2)
		
		beq $t2, 1, REMOVE
		li $t1, HEART_COLOR
		j DRAW
REMOVE:	
		li $t1, BLACK
DRAW:
		sw $t1, ($t0)
		sw $t1, -4($t0)
		sw $t1, 4($t0)
		addi $t0, $t0, -256
		sw $t1, ($t0)
		addi $t0, $t0, 512
		sw $t1, ($t0)
		
		jr $ra

# This function draws the gas bar.
DRAW_GAS_BAR:
		li $t0, GAS_START # Loading the start of the GAS BAR address on display.
		
		la $t1 ERASE_GAS_BAR_FLAG
		lw $t1, ($t1) # Loading the ERASE_GAS_BAR_FLAG variable value.
		
		bne $t1, 1, USE_JETPACK_ONCE # If the ERASE_GAS_BAR_FLAG is not set, then branch.
		
		la $t1, ERASE_GAS_BAR_FLAG # Loading the address of the ERASE_GAS_BAR_FLAG variable into register t1.
		li $t2, 0 # Loading the immediate 0 into register t2.
		sw $t2, ($t1) # Storing a 0 into the ERASE_GAS_BAR_FLAG variable.
		
		li $t1, ACTUAL_GAS_END # Loading the actual end of the GAS BAR address on display.
		li $t2, BLACK # Loading the color BLACK to erase all the way to the ACTUAL_GAS_END.
						
		j GAS_BAR_LOOP
		
USE_JETPACK_ONCE:		
		la $t1, GAS_END 
		lw $t1, ($t1) # Loading the end of the GAS BAR address on display.
		li $t2, GREEN # Loading the color green.
		
GAS_BAR_LOOP:	beq $t0, $t1, END_GAS_BAR_LOOP # If the address in t0 is equal to GAS END (t1) then end loop.
		sw $t2, ($t0) # Storing the color green into display.
		addi $t0, $t0, 4
		j GAS_BAR_LOOP # Looping
END_GAS_BAR_LOOP:
		li $t2, BLACK 
		sw $t2, ($t0) # Colouring the last pixel in the gas bar, black.
		j END_OF_GAS_BAR_FUNC
		
END_OF_GAS_BAR_FUNC:		
		jr $ra

# This function draws the gas containers.
DRAW_GAS:
		li $t0, GAS_START # Loading the address GAS_START into register t0.
		la $t1, GAS_END 
		lw $t1, ($t1) # Loading the address of GAS_END into register t1.
		
		beq $t0, $t1, COLOR_ORANGE # If the address for GAS_START and GAS_END are equal, then the gas bar is empty and we branch.
		li $t2, BLACK # Loading the color black into register t2.
		j START_COLORING
COLOR_ORANGE:
		li $t2, ORANGE # Loading the color orange into register t2.
START_COLORING:		
		li $t0, GAS_LOC1 # Loading the address of the lower gas pick-up.
		li $t1, GAS_LOC2 # Loading the address of the highter gas pick-up.
		
		sw $t2, ($t0) # Drawing the lower gas pick-up
		addi $t0, $t0, -256
		sw $t2, ($t0)
		addi $t0, $t0, -256
		sw $t2, ($t0)
		addi $t0, $t0, -256
		sw $t2, ($t0)
		addi $t0, $t0, 772
		sw $t2, ($t0)
		addi $t0, $t0, -256
		sw $t2, ($t0)
		addi $t0, $t0, -256
		sw $t2, ($t0)
			
		li $t2, ORANGE	# Loading the color orange into register t2.
			
		sw $t2, ($t1) # Drawing the upper gas pick-up
		addi $t1, $t1, -256
		sw $t2, ($t1)
		addi $t1, $t1, -256
		sw $t2, ($t1)
		addi $t1, $t1, -256
		sw $t2, ($t1)
		addi $t1, $t1, 772
		sw $t2, ($t1)
		addi $t1, $t1, -256
		sw $t2, ($t1)
		addi $t1, $t1, -256
		sw $t2, ($t1)		
		
		jr $ra

# This function draws the gold coin.
DRAW_COIN:
		li $t0, COIN_LOC
		li $t1, COIN_LOC
		addi $t1, $t1, 4 # Setting up the address of the coin in registers t1 and t0.
		
		la $t3, COIN_FLAG
		lw $t3, ($t3) # Loading COIN_FLAG variable value into register t3.
		bne $t3, 1, DONT_ERASE_COIN # If COIN_FLAG value is not 1, then branch.
		li $t2, BLACK # Load the color black into register t2.
		j START_DRAWING_COIN # Jump to avoid loading the color gold into register t2.
DONT_ERASE_COIN:
		li $t2, GOLD # Loading the color gold into register t2.
START_DRAWING_COIN:
		sw $t2, ($t0) # Drawing in the coin below.
		sw $t2, ($t1)
		addi $t0, $t0, 256
		addi $t1, $t1, 256
		
		sw $t2, ($t0)
		sw $t2, ($t1)
		addi $t0, $t0, 256
		addi $t1, $t1, 256

		sw $t2, ($t0)
		sw $t2, ($t1)
		
		jr $ra
		
		

# This function draws the player.
DRAW_PLAYER:
		la $t0, PLAYER_LOC # Loading the address of variable PLAYER_LOC
		lw $t0, ($t0) # Loading the player's address.
		la $t1, PLAYER_COLOR # Loading the address of PLAYER_COLOR variable in register t1.
		lw $t1, ($t1) # Loading the color hex code stored in address.
		
		sw $t1, ($t0) # Drawing the player's body.
		addi $t0, $t0, -256
		sw $t1, ($t0)
		addi $t0, $t0, -256
		sw $t1, ($t0)
		addi $t0, $t0, -256
		sw $t1, ($t0)
		
		addi $t0, $t0, 252 # Drawing the players arms.
		sw $t1, ($t0)
		sw $t1, 4($t0)
		sw $t1, 8($t0)

		
		jr $ra
		
		

# This function updates the players hearts displayed on the screen.
UPDATE_HEARTS:
		
		la $t0, HEART_COUNT # Loading the address of heart count. 
		lw $t0, ($t0) # Storing the heart count in register t0.
		li $t1, BLACK # Loading the color black in register t1
		
		ble $t0, 0, NOHEARTS # Branch if player has no hearts. 
		li $t1, HEART_COLOR # Loading the color of the heart in register t1
		j HAS_HEARTS
NOHEARTS:
		jal ERASE_SCREEN
		j DRAW_L
HAS_HEARTS:
		li $t2, HEART1 # Loading the address of where HEART1 is on the display. 
		
		sw $t1, ($t2) # Storing HEART_COLOR into HEART1 location on display. 
		sw $t1, 4($t2)
		sw $t1, 8($t2)
		sw $t1, 12($t2)
		sw $t1, 16($t2)
		
		addi $t2, $t2, -504 # Updating the address of HEART1 to draw the vertical red line of the heart.
		sw $t1, ($t2)
		addi $t2, $t2, 256
		sw $t1, ($t2)
		addi $t2, $t2, 512
		sw $t1, ($t2)
		addi $t2, $t2, 256
		sw $t1, ($t2)
		li $t1, BLACK # Loading the color of the heart in register t1
		
		ble $t0, 1, ONLY1
		li $t1, HEART_COLOR # Loading the color of the heart in register t1		
ONLY1:
		li $t2, HEART1 # Loading the address of where HEART2 is on the display. 
		addi $t2, $t2, 24
		
		sw $t1, ($t2) # Storing HEART_COLOR into HEART2 location on display. 
		sw $t1, 4($t2)
		sw $t1, 8($t2)
		sw $t1, 12($t2)
		sw $t1, 16($t2)
		
		addi $t2, $t2, -504 # Updating the address of HEART2 to draw the vertical red line of the heart.
		sw $t1, ($t2)
		addi $t2, $t2, 256
		sw $t1, ($t2)
		addi $t2, $t2, 512
		sw $t1, ($t2)
		addi $t2, $t2, 256
		sw $t1, ($t2)
		li $t1, BLACK # Loading the color black in register t1
		
		ble $t0, 2, ONLY2
		li $t1, HEART_COLOR # Loading the color of the heart in register t1
ONLY2:		
		
		li $t2, HEART1 # Loading the address of where HEART3 is on the display. 
		addi $t2, $t2, 48
		
		sw $t1, ($t2) # Storing HEART_COLOR into HEART2 location on display. 
		sw $t1, 4($t2)
		sw $t1, 8($t2)
		sw $t1, 12($t2)
		sw $t1, 16($t2)
		
		addi $t2, $t2, -504 # Updating the address of HEART2 to draw the vertical red line of the heart.
		sw $t1, ($t2)
		addi $t2, $t2, 256
		sw $t1, ($t2)
		addi $t2, $t2, 512
		sw $t1, ($t2)
		addi $t2, $t2, 256
		sw $t1, ($t2)		

	
		jr $ra

# This function updates the 2 floating platforms by either erasing or drawing them.
UPDATE_PLATFORMS:
		addi $sp, $sp, -4
		sw $ra, ($sp)

		la $t1, PLATFORM_FLAG
		lw $t1, ($t1)

		beq $t1, 1, ERASE_PLATFORMS
		li $s1, FLOOR_COLOR

# Loop draws the lower platform
		li $s0, BASE_ADDRESS
		addi $s0, $s0, 9672
		li $s2, BASE_ADDRESS
		addi $s2, $s2, 9712

LOOP2: 		
		la $s3, PLAYER_LOC
		lw $s3, ($s3) # Loading the PLAYER_LOC variable. 
		
		beq $s0, $s3, SITUATION1
		addi $s3, $s3, -256
		beq $s0, $s3, SITUATION2
		addi $s3, $s3, -256
		beq $s0, $s3, SITUATION3
		addi $s3, $s3, -256
		beq $s0, $s3, SITUATION4
		j NO_SITUATION
SITUATION1:
		jal ERASE_PLAYER
		jal DRAW_HEART_PICK_UP
		jal DRAW_GAS
		la $s4, PLAYER_LOC
		lw $s3, ($s4)
		addi $s3, $s3, -256
		sw $s3, ($s4)
		jal DRAW_PLAYER
		j NO_SITUATION
SITUATION2:	
		jal ERASE_PLAYER
		jal DRAW_HEART_PICK_UP
		jal DRAW_GAS
		la $s4, PLAYER_LOC
		lw $s3, ($s4)
		addi $s3, $s3, -512
		sw $s3, ($s4)
		jal DRAW_PLAYER
		j NO_SITUATION
SITUATION3:
		jal ERASE_PLAYER
		jal DRAW_HEART_PICK_UP
		jal DRAW_GAS
		la $s4, PLAYER_LOC
		lw $s3, ($s4)
		addi $s3, $s3, 512
		sw $s3, ($s4)
		jal DRAW_PLAYER
		j NO_SITUATION
SITUATION4:	
		jal ERASE_PLAYER
		jal DRAW_HEART_PICK_UP
		jal DRAW_GAS
		la $s4, PLAYER_LOC
		lw $s3, ($s4)
		addi $s3, $s3, 256
		sw $s3, ($s4)
		jal DRAW_PLAYER	
		j NO_SITUATION	
NO_SITUATION:	
		sw $s1, ($s0)
		addi $s0, $s0, 4
		bgtu $s0, $s2, LOOP2END
		j LOOP2
LOOP2END:	

# Loop draws the higher platform
		li $s0, BASE_ADDRESS
		addi $s0, $s0, 6412
		li $s2, BASE_ADDRESS
		addi $s2, $s2, 6492
		
LOOP3:	
		la $s3, PLAYER_LOC
		lw $s3, ($s3) # Loading the PLAYER_LOC variable. 
		
		beq $s0, $s3, SIT1
		addi $s3, $s3, -256
		beq $s0, $s3, SIT2
		addi $s3, $s3, -256
		beq $s0, $s3, SIT3
		addi $s3, $s3, -256
		beq $s0, $s3, SIT4
		j NO_SITUATION2
SIT1:
		jal ERASE_PLAYER
		jal DRAW_HEART_PICK_UP
		jal DRAW_GAS
		la $s4, PLAYER_LOC
		lw $s3, ($s4)
		addi $s3, $s3, -256
		sw $s3, ($s4)
		jal DRAW_PLAYER
		j NO_SITUATION2
SIT2:	
		jal ERASE_PLAYER
		jal DRAW_HEART_PICK_UP
		jal DRAW_GAS
		la $s4, PLAYER_LOC
		lw $s3, ($s4)
		addi $s3, $s3, -512
		sw $s3, ($s4)
		jal DRAW_PLAYER
		j NO_SITUATION2
SIT3:
		jal ERASE_PLAYER
		jal DRAW_HEART_PICK_UP
		jal DRAW_GAS
		la $s4, PLAYER_LOC
		lw $s3, ($s4)
		addi $s3, $s3, 512
		sw $s3, ($s4)
		jal DRAW_PLAYER
		j NO_SITUATION2
SIT4:	
		jal ERASE_PLAYER
		jal DRAW_HEART_PICK_UP
		jal DRAW_GAS
		la $s4, PLAYER_LOC
		lw $s3, ($s4)
		addi $s3, $s3, 256
		sw $s3, ($s4)
		jal DRAW_PLAYER	
		j NO_SITUATION2	
NO_SITUATION2:				
		sw $s1, ($s0)
		addi $s0, $s0, 4
		bgtu $s0, $s2, LOOP3END
		j LOOP3
		
LOOP3END:
		j RETURN
ERASE_PLATFORMS:
		li $t1, BLACK
	
# Loop erases the lower platform
		li $t0, BASE_ADDRESS
		addi $t0, $t0, 9672
		li $t2, BASE_ADDRESS
		addi $t2, $t2, 9712

LOOP2_ERASE: 	sw $t1, ($t0)
		addi $t0, $t0, 4
		bgtu $t0, $t2, LOOP2END_ERASE
		j LOOP2_ERASE
LOOP2END_ERASE:	

# Loop erases the higher platform
		li $t0, BASE_ADDRESS
		addi $t0, $t0, 6412
		li $t2, BASE_ADDRESS
		addi $t2, $t2, 6492
		
LOOP3_ERASE:	sw $t1, ($t0)
		addi $t0, $t0, 4
		bgtu $t0, $t2, RETURN
		j LOOP3_ERASE	
RETURN:
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra


# Function that drows the 3 platforms
DRAW_PLATFORMS: li $t0, BASE_ADDRESS
		addi $t0, $t0, 14336
		li $t1, FLOOR_COLOR
		li $t2, BASE_ADDRESS
		addi $t2, $t2, 14588

# Loop draws the floor
LOOP1:		sw $t1, ($t0)
		addi $t0, $t0, 4
		bgtu $t0, $t2, LOOP1END	
		j LOOP1
LOOP1END:	
		jr $ra
	
# This function draws the spikes.
DRAW_SPIKES:
		li $t0, SPIKE_LOC # Loading the address of the spikes into register t0.
		li $t1, GRAY # Storing the color gray in register t1.
		li $t2, 0 # Setting the loop counter to 0.
		li $t3, 7 # Setting the number of iterations the loop will go.
		
LOOP4:		beq $t2, $t3, LOOP4END # If loop iterations are done branch.
		
		sw $t1, ($t0) # Drawing spikes.
		addi $t0, $t0, -256
		sw $t1, ($t0) 
		addi $t0, $t0, -256
		sw $t1, ($t0) 
		addi $t0, $t0, 520
		
		sw $t1, ($t0)
		addi $t0, $t0, -256
		sw $t1, ($t0)
		addi $t0, $t0, 264
		
		addi $t2, $t2, 1
		j LOOP4

LOOP4END:
		jr $ra

# This function draws the borders.
DRAW_BORDERS:
		li $t1, FLOOR_COLOR
		li $t0, BASE_ADDRESS
		addi $t2, $t0, 252
		
		addi $t3, $t0, 14336
		addi $t4, $t0, 14588
		
TOP_BORDER_LOOP:
		bgt $t0, $t2, SIDE_BORDER_LOOP
		
		sw $t1, ($t0)
		addi $t0, $t0, 4
		j TOP_BORDER_LOOP
		
END_TOP_BORDER_LOOP:
		li $t0, BASE_ADDRESS
SIDE_BORDER_LOOP:		
		bgt $t0, $t3, END_SIDE_BORDER_LOOP
		
		sw $t1, ($t0)
		sw $t1, ($t2)
		addi $t0, $t0, 256
		addi $t2, $t2, 256
		j SIDE_BORDER_LOOP

END_SIDE_BORDER_LOOP:
		jr $ra

# This function draws a gold W on the screen and ends the game.
DRAW_W:
		li $t1, 268507436
		li $t2, 14
		li $t3, GOLD	
PART1:
		beq $t2, 0, NEXT
		sw $t3, ($t1)
		addi $t2, $t2, -1
		addi $t1, $t1, 260
		j PART1
NEXT:
		li $t2, 7
PART2:
		beq $t2, 0, NEXT2
		sw $t3, ($t1)
		addi $t2, $t2, -1
		addi $t1, $t1, -252
		j PART2
NEXT2:
		li $t2, 7
PART3:
		beq $t2, 0, NEXT3
		sw $t3, ($t1)
		addi $t2, $t2, -1
		addi $t1, $t1, 260
		j PART3
NEXT3:
		li $t2, 15
PART4:
		beq $t2, 0, NEXT4
		sw $t3, ($t1)
		addi $t2, $t2, -1
		addi $t1, $t1, -252
		j PART4
NEXT4:

		li $v0, 10 # terminate the program gracefully
		syscall

# This function draws a red L on the screen and ends the game.
DRAW_L:
		li $t1, 268506484
		li $t2, 20
		li $t3, HEART_COLOR

PART1L:
		beq $t2, 0, NEXTL
		sw $t3, ($t1)
		addi $t2, $t2, -1
		addi $t1, $t1, 256
		j PART1L
NEXTL:
		li $t2, 7
PART2L:
		beq $t2, 0, NEXT2L
		sw $t3, ($t1)
		addi $t2, $t2, -1
		addi $t1, $t1, 4
		j PART2L
NEXT2L:
		
		li $v0, 10 # terminate the program gracefully
		syscall













