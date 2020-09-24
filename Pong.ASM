;Lab-4: PING PONG GAME BY - AARYA VARAT JOSHI

.MODEL SMALL

.STACK 100

;******  Data Segment ******
.DATA
	
	WINDOW_WIDTH DW 140h				;the width of the window (320 pixels)
	WINDOW_HEIGHT DW 0C8h				;the height of the window (200 pixels)
	WINDOW_BOUNDS DW 6 					;variable used to check collisions early

	TIME_AUX DB 0 						;variable used when checking if the time has changed

	BALL_ORIGINAL_X DW 0A0h				;X position of the ball at the beginning of tha game
	BALL_ORIGINAL_Y DW 64h 				;Y position of the ball at the beginning of tha game
	BALL_X DW 0Ah 						;current X position (column) of the ball 
	BALL_Y DW 0Ah 						;current Y position (line) of the ball
	BALL_SIZE DW 04h					;size of the ball (how many pixels does the ball have in width and height)
	BALL_VELOCITY_X DW 05h 				;X (horizontal) velocity of the ball
	BALL_VELOCITY_Y DW 02h				;Y (vertical) velocity of the ball

	PADDLE_LEFT_X DW 0Ah 				;current X position of the left paddle
	PADDLE_LEFT_Y DW 0Ah 				;current Y position of the left paddle

	PADDLE_RIGHT_X DW 130h 				;current X position of the right paddle
	PADDLE_RIGHT_Y DW 0Ah 				;current X position of the right paddle

	PADDLE_WIDTH DW 04h 				;default width of the paddle
	PADDLE_HEIGHT DW 1Fh				;default height of the paddle
	PADDLE_VELCITY DW 05h 				;default velocity of the paddle

;********** Code Segment ************
.CODE 
	MAIN PROC FAR
	MOV AX,@DATA 						;save on the AX register the contents of the DATA segment
	MOV DS,AX							;save on the DS segment the contents of the AX

		CALL CLEAR_SCREEN 				;set the initial video mode configuration

		CHECK_TIME: 					;time loop of the game
			MOV AH,2Ch					;get the system time
			INT 21h						;CH = hour CL = minute DH = second DL = 1/100 seconds

			CMP DL,TIME_AUX				;is the current time equal to the previous one (TIME_AUX)?
			JE CHECK_TIME				;if it is the same ,check again

			;if it reaches this point, it's because the time has passed
			MOV TIME_AUX,DL 			;if not update time
			CALL CLEAR_SCREEN 			;clearing the screen by restarting the video mode

			CALL MOVE_BALL 				;calling the procedure to move the balls
			CALL DRAW_BALL 				;calling the procedure to draw the ball

			CALL MOVE_PADDLES 			;move the paddles (check for key presses)
			CALL DRAW_PADDLES 			;draw the paddles with the updated positions

			JMP	CHECK_TIME 				;after everything check time again

		RET
	MAIN ENDP

	MOVE_BALL PROC NEAR					;process the movemment of the ball

		MOV AX,BALL_VELOCITY_X
		ADD BALL_X,AX 					;move the ball horizontally

		;check if it has passed the left boundaries (BALL_X < 0 + WINDOW_BOUNDS)
		;if its colliding restart its position
		MOV AX,WINDOW_BOUNDS
		CMP BALL_X,AX 					;BALL_X is compared with the left boundaries of the screen
		JL RESET_POSITION 				;if it is less, reset position

		;check if it has passed the right boundaries (BALL_X > WINDOW_WIDTH - BALL_SIZE - WINDOW_BOUNDS)
		;if its colliding restart its position
		MOV AX,WINDOW_WIDTH
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_X,AX					;BALL_Y is compared with the right boundaries of the screen
		JG RESET_POSITION 				;if it is greater, reset position

		;move the ball vertically
		MOV AX,BALL_VELOCITY_Y
		ADD BALL_Y,AX 			

		;check if it has passed the top boundary (BALL_Y < 0 + WINDOW_BOUNDS)
		;if its colliding reverse the velocity in Y
		MOV AX,WINDOW_BOUNDS
		CMP BALL_Y,AX					;BALL_Y is compared with the top boundaries of the screen	
		JL NEG_VELOCITY_Y				;if its less reverse the velocity in Y

		;check if it has passed the bottom boundary (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
		;if its colliding reverse the velocity in Y
		MOV AX,WINDOW_HEIGHT
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS					
		CMP BALL_Y,AX					;BALL_Y is compared with the bottom boundaries of the screen
		JG NEG_VELOCITY_Y				;if its greater reverse the velocity in Y

		;Check if the ball is colliding with rigth paddle
		;maxx1 > maxx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
		;BALL_X + BALL_SIZE > PADDLE_RIGHT_X && BALL_X < PADDLE_RIGHT_X + PADDLE_WIDTH 
		;&& BALL_Y + BALL_SIZE > PADDLE_RIGHT_Y && BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT

		MOV AX,BALL_X
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_RIGHT_X
		JNG CHECK_COLLISION_WITH_LEFT_PADDLE	;if there is no collision check for the left paddle

		MOV AX,PADDLE_RIGHT_X
		ADD AX,PADDLE_WIDTH
		CMP BALL_X,AX
		JNL CHECK_COLLISION_WITH_LEFT_PADDLE	;if there is no collision check for the left paddle

		MOV AX,BALL_Y
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_RIGHT_Y
		JNG CHECK_COLLISION_WITH_LEFT_PADDLE	;if there is no collision check for the left paddle

		MOV AX,PADDLE_RIGHT_Y
		ADD AX,PADDLE_HEIGHT
		CMP BALL_Y,AX
		JNL CHECK_COLLISION_WITH_LEFT_PADDLE	;if there is no collision check for the left paddle

		;if it reaches this point the ball is colliding with the right paddle

		NEG BALL_VELOCITY_X 					;reverse the ball horizontall velocity
		RET 									;exit this procedure

		RESET_POSITION:
			CALL RESET_BALL_POSITION	;reset ball position to the center of the screen
			RET

		NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y			;reverse the velocity in Y (BALL_VELOCITY_Y = -BALL_VELOCITY_Y)
			RET

; 		Check if the ball is colliding with left paddle
		CHECK_COLLISION_WITH_LEFT_PADDLE:
		;minx1 < maxx2 && maxx1 > minx2 && maxy1 > miny2 && miny1 < maxy2
		;BALL_X < PADDLE_LEFT_X + PADDLE_WIDTH && BALL_X +BALL_SIZE > PADDLE_LEFT_X
		;&& BALL_Y + BALL_SIZE > PADDLE_LEFT_Y && BALL_Y < PADDLE_LEFT_Y + PADDLE_HEIGHT

		MOV AX,PADDLE_LEFT_X
		ADD AX,PADDLE_WIDTH
		CMP BALL_X,AX
		JNL EXIT_BALL_COLLISION					;if there is no collision exit the procedure

		MOV AX,BALL_X
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_LEFT_X
		JNG EXIT_BALL_COLLISION					;if there is no collision exit the procedure

		MOV AX,BALL_Y
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_LEFT_Y
		JNG EXIT_BALL_COLLISION					;if there is no collision exit the procedure

		MOV AX,PADDLE_LEFT_Y
		ADD AX,PADDLE_HEIGHT
		CMP BALL_Y,AX
		JNL EXIT_BALL_COLLISION					;if there is no collision exit the procedure

		;if it reaches this point the ball is colliding with the right paddle
		NEG BALL_VELOCITY_X 					;reverse the ball horizontall velocity
		RET 									;exit this procedure

		EXIT_BALL_COLLISION:
		RET

	MOVE_BALL ENDP

	MOVE_PADDLES PROC NEAR 				;process movement of paddles

		;Left paddle movement
		;check if any key is being pressed (if not check the other paddle)
		MOV AH,01h
		INT 16h
		JZ CHECK_RIGHT_PADDLE_MOVEMENT 	;ZF=1, JZ -> Jump if zero

		;check which key is being pressed (AL = ASCII Character)
		MOV AH,00h
		INT 16h

		CMP     AL, 1Bh 							;check for 'Esc'
		JZ      exit 								;Jump to exit if 'Esc' is pressed

		;if it is 'w' or 'W' -> move up
		CMP AL,77h 									;check for 'w'
		JE MOVE_LEFT_PADDLE_UP
		CMP AL,57h 									;check for 'W'
		JE MOVE_LEFT_PADDLE_UP

		;if it is 's' or 'S' -> move down
		CMP AL,73h 									;check for 's'
		JE MOVE_LEFT_PADDLE_DOWN
		CMP AL,53h 									;check for 'S'
		JE MOVE_LEFT_PADDLE_DOWN
		JMP CHECK_RIGHT_PADDLE_MOVEMENT

		MOVE_LEFT_PADDLE_UP: 						;procedure to move the left paddle up
			MOV AX,PADDLE_VELCITY 				
			SUB PADDLE_LEFT_Y,AX 					;subtracting the PADDLE_VELCITY in current position of the paddle

			MOV AX,WINDOW_BOUNDS
			CMP PADDLE_LEFT_Y,AX 					;checking if the paddle is at the top boundary
			JL FIX_PADDLE_LEFT_TOP_POSITION 		;if it is at the top boundary then fix the position 
			JMP CHECK_RIGHT_PADDLE_MOVEMENT

			FIX_PADDLE_LEFT_TOP_POSITION:
				MOV PADDLE_LEFT_Y,AX 				;fixing paddle top position to WINDOW_BOUNDS
				JMP CHECK_RIGHT_PADDLE_MOVEMENT

		MOVE_LEFT_PADDLE_DOWN: 						;procedure to move the left paddle down
			MOV AX,PADDLE_VELCITY 					
			ADD PADDLE_LEFT_Y,AX 					;adding the PADDLE_VELCITY in current position of the paddle
			MOV AX,WINDOW_HEIGHT
			SUB AX,WINDOW_BOUNDS
			SUB AX,PADDLE_HEIGHT
			CMP PADDLE_LEFT_Y,AX 					;checking if the paddle is at the bottom boundary
			JG FIX_PADDLE_LEFT_BOTTOM_POSITION 		;if it is at the bottom boundary then fix the position 
			JMP CHECK_RIGHT_PADDLE_MOVEMENT

			FIX_PADDLE_LEFT_BOTTOM_POSITION:
				MOV PADDLE_LEFT_Y,AX 				;fixing paddle top position
				JMP CHECK_RIGHT_PADDLE_MOVEMENT

		exit:
			JMP exit2 								;Jump to exit2

		;Right paddle movement
		CHECK_RIGHT_PADDLE_MOVEMENT:
			;if it is 'o' or 'O' -> move up
			CMP AL,6Fh 								;check for 'o'
			JE MOVE_RIGHT_PADDLE_UP
			CMP AL,4Fh 								;check for 'O'
			JE MOVE_RIGHT_PADDLE_UP

			;if it is 'l' or 'L' -> move down
			CMP AL,6Ch 								;check for 'l'
			JE MOVE_RIGHT_PADDLE_DOWN
			CMP AL,4Ch 								;check for 'L'
			JE MOVE_RIGHT_PADDLE_DOWN
			JMP EXIT_PADDLE_MOVEMENT

		MOVE_RIGHT_PADDLE_UP: 						;procedure to move the right paddle up
			MOV AX,PADDLE_VELCITY 					
			SUB PADDLE_RIGHT_Y,AX 					;subtracting the PADDLE_VELCITY in current position of the paddle

			MOV AX,WINDOW_BOUNDS
			CMP PADDLE_RIGHT_Y,AX 					;checking if the paddle is at the top boundary
			JL FIX_PADDLE_RIGHT_TOP_POSITION  		;if it is at the top boundary then fix the position
			JMP EXIT_PADDLE_MOVEMENT

			FIX_PADDLE_RIGHT_TOP_POSITION:
				MOV PADDLE_RIGHT_Y,AX 				;fix the postion of the paddle
				JMP EXIT_PADDLE_MOVEMENT

		MOVE_RIGHT_PADDLE_DOWN:
			MOV AX,PADDLE_VELCITY
			ADD PADDLE_RIGHT_Y,AX 					;adding the PADDLE_VELCITY in current position of the paddle	
			MOV AX,WINDOW_HEIGHT
			SUB AX,WINDOW_BOUNDS
			SUB AX,PADDLE_HEIGHT
			CMP PADDLE_RIGHT_Y,AX 					;checking if the paddle is at the bottom boundary
			JG FIX_PADDLE_RIGHT_BOTTOM_POSITION 	;if it is at the bottom boundary then fix the position
			JMP CHECK_RIGHT_PADDLE_MOVEMENT

			FIX_PADDLE_RIGHT_BOTTOM_POSITION:
				MOV PADDLE_RIGHT_Y,AX 				;fix the postion of the paddle
				JMP EXIT_PADDLE_MOVEMENT

		EXIT_PADDLE_MOVEMENT:
		RET
	MOVE_PADDLES ENDP

	exit2: 								;the procedure to exit the game by clearing the screen
	  	MOV AH,00h 						;clearing the screen
  	  	MOV AL,02h						;loading the default video mode of dos
  	  	INT 10h 
		MOV AH, 4Ch 					;exit the porgram
		MOV AL, 00h
		INT 21H

	RESET_BALL_POSITION PROC NEAR 		;restart ball position to the center of the screen

		MOV AX,BALL_ORIGINAL_X 			
		MOV BALL_X,AX 					;setting current X-coordinate of the ball to BALL_ORIGINAL_X

		MOV AX,BALL_ORIGINAL_Y
		MOV BALL_Y,AX 					;setting current Y-coordinate of the ball to BALL_ORIGINAL_X

		RET
	RESET_BALL_POSITION ENDP

	DRAW_BALL PROC NEAR 				;procedure to draw the ball

		MOV CX,BALL_X 					;set the initial column (X)
		MOV DX,BALL_Y 					;set the initial line (Y)

		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch					;set the configuration to writing the pixel
			MOV AL,02h					;choose green as color of the pixel
			MOV BH,00h					;set the page number
			INT 10h 					;execute the configuration

			INC CX 						;CX = CX + 1
			MOV AX,CX					
			SUB AX,BALL_X		
			CMP AX,BALL_SIZE 			;CX - BALL_X > BALL_SIZE (Y-> We go to the next line. N-> we continue to the next column)
			JNG DRAW_BALL_HORIZONTAL

			MOV CX,BALL_X 				;the CX register goes back to the initial column
			INC DX 						;we advance one line
			MOV AX,DX					
			SUB AX,BALL_Y					
			CMP AX,BALL_SIZE 			;DX - BALL_Y > BALL_SIZE (Y-> We exit this procedure. N-> we continue to the next line)
			JNG DRAW_BALL_HORIZONTAL

		RET
	DRAW_BALL ENDP

	DRAW_PADDLES PROC NEAR

		MOV CX,PADDLE_LEFT_X 			;set the initial column (X)
		MOV DX,PADDLE_LEFT_Y 			;set the initial line (Y)

		DRAW_PADDLE_LEFT_HORIZONTAL:
			MOV AH,0Ch					;set the configuration to writing the pixel
			MOV AL,0Fh					;choose white as color of the pixel
			MOV BH,00h					;set the page number
			INT 10h 					;execute the configuration

			INC CX 						;CX = CX + 1
			MOV AX,CX					;CX - PADDLE_LEFT_X > PADDLE_WIDTH (Y-> We go to the next line. N-> we continue to the next column)
			SUB AX,PADDLE_LEFT_X		
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_LEFT_HORIZONTAL

			MOV CX,PADDLE_LEFT_X 		;the CX register goes back to the initial column
			INC DX 						;we advance one line
			MOV AX,DX					;DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y-> We exit this procedure. N-> we continue to the next line)
			SUB AX,PADDLE_LEFT_Y					
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_LEFT_HORIZONTAL

			MOV CX,PADDLE_RIGHT_X 		;set the initial column (X)
			MOV DX,PADDLE_RIGHT_Y 		;set the initial line (Y)

		DRAW_PADDLE_RIGHT_HORIZONTAL:
			MOV AH,0Ch					;set the configuration to writing the pixel
			MOV AL,0Fh					;choose white as color of the pixel
			MOV BH,00h					;set the page number
			INT 10h 					;execute the configuration

			INC CX 						;CX = CX + 1
			MOV AX,CX					;CX - PADDLE_LEFT_X > PADDLE_WIDTH (Y-> We go to the next line. N-> we continue to the next column)
			SUB AX,PADDLE_RIGHT_X		
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL

			MOV CX,PADDLE_RIGHT_X 		;the CX register goes back to the initial column
			INC DX 						;we advance one line
			MOV AX,DX					;DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y-> We exit this procedure. N-> we continue to the next line)
			SUB AX,PADDLE_RIGHT_Y					
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL

		RET
	DRAW_PADDLES ENDP

	CLEAR_SCREEN PROC NEAR 				;procedure to clear the screen by restarting the video mode

		MOV AH,00h 						;set the configuration to video mode
		MOV AL,13h 						;choose the video mode
		INT 10h							;execute the configuration

		MOV AH,0Bh						;set the configuration
		MOV BH,00h						;to the background color
		MOV BL,00h 						;choose black as background
		INT 10h 						;execute the configuration

		RET
	CLEAR_SCREEN ENDP
END MAIN